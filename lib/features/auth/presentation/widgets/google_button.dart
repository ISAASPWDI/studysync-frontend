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
          // Google G logo
          Container(
            width: 24, height: 24,
            child: CustomPaint(painter: _GoogleLogoPainter()),
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

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -0.5, 1.8, true, paint);
    // Red
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 1.3, 1.2, true, paint);
    // Yellow
    paint.color = const Color(0xFFFBBC04);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 2.5, 0.8, true, paint);
    // Green
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.3, 1.2, true, paint);

    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.6, paint);
    
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - 2, radius * 0.9, 4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
