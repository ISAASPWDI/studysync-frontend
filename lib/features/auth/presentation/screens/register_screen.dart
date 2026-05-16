// lib/features/auth/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada exitosamente! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: const Color(AppColors.error),
        ),
      );
    }
  }

  Future<void> _googleRegister() async {
    final auth = context.read<AuthProvider>();
    await auth.signInWithGoogle(isRegister: true);
    if (!mounted) return;
    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: const Color(AppColors.error)),
      );
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
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.go('/login'),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.school, color: Color(AppColors.primaryBlue), size: 38),
                  ),
                  const SizedBox(height: 12),
                  const Text('Crear Cuenta', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Únete a StudySync', style: TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
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
                        GoogleButton(onPressed: auth.loading ? null : _googleRegister),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('O regístrate con email', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _nameCtrl,
                          hint: 'Nombre completo',
                          icon: Icons.person_outline,
                          validator: (v) => v!.isEmpty ? 'Ingresa tu nombre' : null,
                        ),
                        const SizedBox(height: 14),
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
                          validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _confirmCtrl,
                          hint: 'Confirmar contraseña',
                          icon: Icons.lock_outline,
                          obscure: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          validator: (v) => v != _passCtrl.text ? 'Las contraseñas no coinciden' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: auth.loading ? null : _register,
                            child: auth.loading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Crear Cuenta'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('¿Ya tienes cuenta? ', style: TextStyle(color: Colors.grey[600])),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: const Text('Inicia sesión', style: TextStyle(color: Color(AppColors.primaryBlue), fontWeight: FontWeight.bold)),
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
