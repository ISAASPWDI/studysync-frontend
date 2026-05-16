// lib/core/utils/app_router.dart
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/discover/presentation/screens/discover_screen.dart';
import '../../features/matches/presentation/screens/matches_screen.dart';
import '../../features/messages/presentation/screens/chat_screen.dart';
import '../../features/messages/presentation/screens/chats_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../services/auth_provider.dart';
import 'main_shell.dart';

class AppRouter {
  static GoRouter router(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: auth,
      redirect: (context, state) {
        final isAuth = auth.status == AuthStatus.authenticated;
        final isUnknown = auth.status == AuthStatus.unknown;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        if (isUnknown) return null;
        if (!isAuth && !isAuthRoute) return '/login';
        if (isAuth && isAuthRoute) {
          return auth.isNewUser ? '/onboarding' : '/discover';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(path: '/discover', builder: (_, __) => const DiscoverScreen()),
            GoRoute(path: '/matches', builder: (_, __) => const MatchesScreen()),
            GoRoute(path: '/chats', builder: (_, __) => const ChatsListScreen()),
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ],
        ),
        GoRoute(
          path: '/chat/:chatId',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return ChatScreen(
              chatId:            state.pathParameters['chatId']!,
              otherUserName:     extra['name']     as String? ?? 'Usuario',
              otherUserAvatar:   extra['avatar']   as String?,
              otherUserCareer:   extra['career']   as String?,
              otherUserIsOnline: extra['isOnline'] as bool? ?? false,
            );
          },
        ),
        GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
      ],
    );
  }
}
