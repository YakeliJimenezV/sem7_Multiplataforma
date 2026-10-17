import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Ilustración vectorial local: cajas, hojas y etiquetas sin recursos de red.
class InventoryArt extends StatelessWidget {
  const InventoryArt({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Ilustración de cajas organizadas junto a una planta',
    image: true,
    child: AspectRatio(
      aspectRatio: 1.4,
      child: CustomPaint(painter: _ArtPainter()),
    ),
  );
}

class _ArtPainter extends CustomPainter {
  const _ArtPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 420, size.height / 300);
    final paint = Paint();
    void rect(
      double x,
      double y,
      double w,
      double h,
      Color color, [
      double radius = 10,
    ]) {
      paint.color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          Radius.circular(radius),
        ),
        paint,
      );
    }

    paint.color = const Color(0xFFB9D9C7);
    canvas.drawOval(const Rect.fromLTWH(40, 265, 340, 20), paint);
    paint.color = InventiColors.mint;
    canvas.drawCircle(const Offset(215, 145), 115, paint);
    rect(104, 157, 115, 112, const Color(0xFFEBAF8D));
    rect(104, 157, 115, 20, InventiColors.peach, 4);
    rect(151, 157, 21, 44, const Color(0xFFFFF0E2), 2);
    rect(117, 230, 37, 19, const Color(0xFFFFF9F2), 4);
    rect(229, 201, 83, 68, const Color(0xFFF5CEAC));
    rect(229, 201, 83, 13, const Color(0xFFFFE8D5), 3);
    rect(263, 201, 14, 27, Colors.white.withValues(alpha: .7), 2);
    rect(135, 80, 85, 68, const Color(0xFF49836B));
    rect(135, 80, 85, 14, const Color(0xFF76AB8C), 3);
    rect(170, 80, 14, 27, InventiColors.mint, 2);
    rect(152, 119, 28, 12, InventiColors.mint, 3);
    final stem = Paint()
      ..color = InventiColors.forest
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(338, 229)
        ..quadraticBezierTo(324, 170, 344, 113),
      stem,
    );
    paint.color = InventiColors.forest;
    canvas.drawOval(const Rect.fromLTWH(304, 164, 32, 16), paint);
    canvas.drawOval(const Rect.fromLTWH(332, 142, 37, 18), paint);
    paint.color = const Color(0xFF76AB8C);
    canvas.drawOval(const Rect.fromLTWH(314, 122, 26, 17), paint);
    canvas.drawOval(const Rect.fromLTWH(338, 99, 21, 29), paint);
    rect(313, 226, 49, 43, const Color(0xFFFFE7CF), 9);
    rect(309, 223, 57, 10, InventiColors.peach, 4);
    rect(44, 112, 67, 46, Colors.white, 12);
    final check = Paint()
      ..color = InventiColors.forest
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(63, 135)
        ..lineTo(74, 145)
        ..lineTo(92, 125),
      check,
    );
    paint.color = InventiColors.peach;
    canvas.drawCircle(const Offset(295, 74), 9, paint);
    canvas.drawCircle(const Offset(73, 211), 5, paint);
    paint.color = InventiColors.forest.withValues(alpha: .5);
    canvas.drawCircle(const Offset(242, 43), 4, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArtPainter oldDelegate) => false;
}
