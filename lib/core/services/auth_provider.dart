import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'storage_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  bool _loading = false;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  bool get isProfileComplete {
    if (_user == null) return false;

    final u = _user!;

    return u.name.isNotEmpty &&
        u.university != null &&
        u.university!.isNotEmpty &&
        u.career != null &&
        u.career!.isNotEmpty &&
        u.semester != null &&
        u.semester!.isNotEmpty &&
        u.district != null &&
        u.district!.isNotEmpty &&
        u.technicalSkills.isNotEmpty &&
        u.interestAreas.isNotEmpty &&
        u.studyGoals.isNotEmpty &&
        u.availability != null &&
        u.availability!.isNotEmpty &&
        u.groupSize != null &&
        u.groupSize!.isNotEmpty &&
        u.bio != null &&
        u.bio!.isNotEmpty;
  }

  bool get isNewUser {
    final result = !(_user?.onboardingCompleted ?? false);
    debugPrint('🚦 isNewUser evaluated: $result (onboardingCompleted: ${_user?.onboardingCompleted})');
    return result;
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _initializationFuture;
  AuthProvider() {
    _initializationFuture = _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      debugPrint('🔵 Inicializando Google Sign In...');
      await _googleSignIn.initialize(
        serverClientId: '59358532022-kvt0268g1i8ldoc20of8noavuens14mc.apps.googleusercontent.com',
      );
      debugPrint('✅ Google Sign In inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error al inicializar Google Sign In: $e');
    }
  }

  Future<void> checkAuth() async {
    final isLoggedIn = await _storage.isLoggedIn();

    if (isLoggedIn) {
      final valid = await _api.verifyToken();

      if (valid) {
        _user = await _storage.getUser();
        debugPrint('🔍 checkAuth - user loaded from storage');
        debugPrint('   onboardingCompleted: ${_user?.onboardingCompleted}');
        debugPrint('   isNewUser: $isNewUser');
        _status = AuthStatus.authenticated;
      } else {
        await _storage.clear();
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final response = await _api.login(email, password);

      await _storage.saveToken(response.token);
      await _storage.saveUser(response.user);

      _user = response.user;
      _status = AuthStatus.authenticated;
      _error = null;

      notifyListeners();

      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(
      String fullName,
      String email,
      String password,
      ) async {
    _setLoading(true);

    try {
      final parts = fullName.trim().split(' ');
      final firstName = parts.first;
      final lastName =
      parts.length > 1 ? parts.sublist(1).join(' ') : '';

      final body = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      };

      await _api.register(body);

      final response = await _api.login(email, password);

      await _storage.saveToken(response.token);
      await _storage.saveUser(response.user);

      _user = response.user;
      _status = AuthStatus.authenticated;
      _error = null;

      notifyListeners();

      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle({
    bool isRegister = false,
  }) async {
    _setLoading(true);

    try {
      await _initializationFuture;

      debugPrint('🔵 Iniciando proceso de authenticate()...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        _error = 'El usuario canceló el inicio de sesión';
        debugPrint('🟡 El usuario cerró el modal de Google');
        notifyListeners();
        return false;
      }

      debugPrint('✅ Usuario obtenido: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken ?? '';

      if (idToken.isEmpty) {
        _error = 'No se pudo obtener el ID Token de Google';
        debugPrint('❌ ID Token vacío');
        notifyListeners();
        return false;
      }

      final response = isRegister
          ? await _api.registerWithGoogleMobile(idToken)
          : await _api.loginWithGoogleMobile(idToken);

      await _storage.saveToken(response.token);
      await _storage.saveUser(response.user);

      _user = response.user;
      _status = AuthStatus.authenticated;
      _error = null;

      notifyListeners();
      return true;

    } on GoogleSignInException catch (e) {
      _error = 'Error de Google (${e.code}): ${e.description}';
      debugPrint('❌ GoogleSignInException: Code ${e.code} | ${e.description}');
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _error = e.message;
      debugPrint('❌ ApiException: ${e.message}');
      return false;
    } catch (e) {
      _error = 'Error inesperado: $e';
      debugPrint('❌ Error genérico en signInWithGoogle: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _api.logout();
    await _storage.clear();
    await _googleSignIn.signOut();

    _user = null;
    _status = AuthStatus.unauthenticated;

    notifyListeners();
  }

  void updateUser(UserModel user) {
    _user = user;
    _storage.saveUser(user);
    debugPrint('🔄 updateUser called');
    debugPrint('   onboardingCompleted: ${user.onboardingCompleted}');
    debugPrint('   isNewUser: $isNewUser');
    debugPrint('   isProfileComplete: $isProfileComplete');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}