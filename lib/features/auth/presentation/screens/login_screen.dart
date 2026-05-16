// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (!ok && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: const Color(AppColors.error)),
      );
    }
    // Router will redirect automatically
  }

  Future<void> _googleLogin() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithGoogle();

    if (!mounted) return;

    if (!ok) {
      final error = auth.error ?? 'Error desconocido';

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: const Color(AppColors.error),
            duration: const Duration(seconds: 4),
          ),
        );

      if (error.contains('regístrate') || error.contains('registrate')) {
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) context.go('/register');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(AppColors.primaryBlue),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.school, color: Color(AppColors.primaryBlue), size: 44),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'StudySync',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inicia sesión para continuar',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        GoogleButton(onPressed: auth.loading ? null : _googleLogin),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'O inicia sesión con email',
                                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AuthTextField(
                          controller: _emailCtrl,
                          hint: 'Email',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.isEmpty ? 'Ingresa tu email' : null,
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _passCtrl,
                          hint: 'Contraseña',
                          icon: Icons.lock_outline,
                          obscure: _obscure,
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) => v!.isEmpty ? 'Ingresa tu contraseña' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: auth.loading ? null : _login,
                            child: auth.loading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Iniciar Sesión'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('¿No tienes cuenta? ', style: TextStyle(color: Colors.grey[600])),
                            GestureDetector(
                              onTap: () => context.go('/register'),
                              child: const Text(
                                'Regístrate',
                                style: TextStyle(
                                  color: Color(AppColors.primaryBlue),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
