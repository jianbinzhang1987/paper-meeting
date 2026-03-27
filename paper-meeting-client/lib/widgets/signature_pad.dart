import 'package:flutter/material.dart';

class SignaturePad extends StatelessWidget {
  const SignaturePad({
    super.key,
    required this.points,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final List<Offset?> points;
  final ValueChanged<DragStartDetails> onPanStart;
  final ValueChanged<DragUpdateDetails> onPanUpdate;
  final VoidCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: (_) => onPanEnd(),
      child: CustomPaint(
        painter: _SignaturePainter(points),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.points);

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0B5CAD)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      if (current != null && next != null) {
        canvas.drawLine(current, next, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
