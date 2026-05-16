// lib/core/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await _prefs;
    final str = prefs.getString(AppConstants.userKey);
    if (str == null) return null;
    return UserModel.fromJson(jsonDecode(str));
  }

  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
