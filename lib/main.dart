// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/services/auth_provider.dart';
import 'core/utils/app_router.dart';
import 'core/utils/timeago_es.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerTimeagoLocales();
  runApp(const StudyMatchApp());
}

class StudyMatchApp extends StatelessWidget {
  const StudyMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..checkAuth(),
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final router = AppRouter.router(auth);

    return MaterialApp.router(
      title: 'StudyMatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
