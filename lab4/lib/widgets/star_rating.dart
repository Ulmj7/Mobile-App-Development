import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints one five-pointed star filled from the left by [fill] (0–1).
class StarPainter extends CustomPainter {
  const StarPainter({
    required this.fill,
    required this.color,
    required this.empty,
  });

  final double fill;
  final Color color;
  final Color empty;

  Path _star(Size size) {
    final center = size.center(Offset.zero);
    final outer = size.width / 2;
    final inner = outer * 0.4;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _star(size);
    canvas.drawPath(path, Paint()..color = empty);
    if (fill > 0) {
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(0, 0, size.width * fill.clamp(0, 1), size.height),
      );
      canvas.drawPath(path, Paint()..color = color);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(StarPainter old) =>
      old.fill != fill || old.color != color || old.empty != empty;
}

/// Five stars showing a 0–5 [rating], including fractional fill.
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.size = 20});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final empty = Theme.of(context).colorScheme.outlineVariant;
    return Semantics(
      label: 'Үнэлгээ ${rating.toStringAsFixed(1)}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 5; i++)
            CustomPaint(
              size: Size.square(size),
              painter: StarPainter(
                fill: (rating - i).clamp(0, 1).toDouble(),
                color: Colors.amber,
                empty: empty,
              ),
            ),
        ],
      ),
    );
  }
}
