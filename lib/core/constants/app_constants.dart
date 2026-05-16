// lib/core/constants/app_constants.dart
class AppConstants {
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  // static const String wsUrl = 'ws://10.0.2.2:3000';

  static const String _localIp = '192.168.18.107';
  static const String baseUrl = 'http://$_localIp:3000/api';
  static const String wsUrl   = 'http://$_localIp:3000';
  // JWT Token key
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
}

class AppColors {
  static const int primaryBlue = 0xFF2196F3;
  static const int primaryBlueDark = 0xFF1565C0;
  static const int primaryBlueLight = 0xFF64B5F6;
  static const int backgroundWhite = 0xFFFFFFFF;
  static const int surfaceGrey = 0xFFF5F5F5;
  static const int textPrimary = 0xFF212121;
  static const int textSecondary = 0xFF757575;
  static const int textHint = 0xFFBDBDBD;
  static const int error = 0xFFE53935;
  static const int success = 0xFF43A047;
  static const int divider = 0xFFEEEEEE;
  static const int chipBlue = 0xFFE3F2FD;
  static const int chipBlueText = 0xFF1565C0;
  static const int chipGreen = 0xFFE8F5E9;
  static const int chipGreenText = 0xFF2E7D32;
}

class AppStrings {
  // Auth
  static const String appName = 'StudySync';
  static const String loginTitle = 'StudySync';
  static const String loginSubtitle = 'Inicia sesión para continuar';
  static const String registerTitle = 'Crear Cuenta';
  static const String registerSubtitle = 'Únete a StudySync';
  static const String continueWithGoogle = 'Continuar con Google';
  static const String orWithEmail = 'O inicia sesión con email';
  static const String orRegisterWithEmail = 'O regístrate con email';
  static const String email = 'Email';
  static const String password = 'Contraseña';
  static const String confirmPassword = 'Confirmar contraseña';
  static const String fullName = 'Nombre completo';
  static const String login = 'Iniciar Sesión';
  static const String register = 'Crear Cuenta';
  static const String noAccount = '¿No tienes cuenta? ';
  static const String hasAccount = '¿Ya tienes cuenta? ';
  static const String signUp = 'Regístrate';
  static const String signIn = 'Inicia sesión';
  
  // Nav
  static const String discover = 'Descubrir';
  static const String matches = 'Matches';
  static const String chats = 'Chats';
  static const String profile = 'Perfil';
  
  // Discover
  static const String searching = 'Buscando compañeros...';
  
  // Matches
  static const String pending = 'Pendientes';
  static const String sent = 'Enviados';
  static const String accepted = 'Aceptados';
  
  // Profile
  static const String technicalSkills = 'Habilidades técnicas';
  static const String interestAreas = 'Áreas de interés';
  static const String studyGoals = 'Objetivos de estudio';
  static const String editProfile = 'Editar perfil';
  static const String mySkills = 'Mis habilidades';
  static const String location = 'Ubicación';
  static const String notifications = 'Notificaciones';
  static const String privacy = 'Privacidad';
  static const String settings = 'Configuración';
  static const String helpSupport = 'Ayuda y soporte';
  static const String about = 'Acerca de';
  static const String logout = 'Cerrar sesión';
  static const String availability = 'Disponibilidad';
  static const String groupSize = 'Tamaño de grupo';
}
