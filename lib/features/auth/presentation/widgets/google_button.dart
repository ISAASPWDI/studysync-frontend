// lib/features/auth/presentation/widgets/google_button.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(AppColors.divider), width: 1.5),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/google-icon.png',
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.error_outline, size: 16, color: Colors.red),
              );
            },
          ),
          const SizedBox(width: 12),
          const Text(
            'Continuar con Google',
            style: TextStyle(
              color: Color(AppColors.textPrimary),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}