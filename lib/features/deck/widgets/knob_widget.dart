import 'package:flutter/material.dart';
import 'dart:math';

class KnobWidget extends StatefulWidget {
  final double value; // 0.0 to 1.0 (normalized)
  final double mmin;
  final double mmax;
  final ValueChanged<double> onChanged;
  final String label;
  final Color color;
  final double size;

  const KnobWidget({
    super.key,
    required this.value,
    this.mmin = 0.0,
    this.mmax = 1.0,
    required this.onChanged,
    required this.label,
    this.color = Colors.white,
    this.size = 50,
  });

  @override
  State<KnobWidget> createState() => _KnobWidgetState();
}

class _KnobWidgetState extends State<KnobWidget> {
  double _currentValue = 0.0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(KnobWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  void _handleDrag(DragUpdateDetails details) {
    // Vertical drag: up increases, down decreases
    final delta = -details.delta.dy / 100.0; // Sensitivity factor

    setState(() {
      _currentValue = (_currentValue + delta).clamp(0.0, 1.0);
    });

    widget.onChanged(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onVerticalDragUpdate: _handleDrag,
          onDoubleTap: () {
            setState(() {
              _currentValue = 0.5; // Reset to center
            });
            widget.onChanged(0.5);
          },
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: KnobPainter(value: _currentValue, color: widget.color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class KnobPainter extends CustomPainter {
  final double value;
  final Color color;

  KnobPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Draw background circle (darker)
    final bgPaint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, bgPaint);

    // Draw outer ring
    final ringPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, ringPaint);

    // Draw value indicator
    // Map 0.0-1.0 to angle range (e.g. -135 to +135 degrees)
    // 0.0 -> -135 deg (bottom left)
    // 0.5 -> 0 deg (top center) - Wait, usually knobs start at 7 o'clock (-135) to 5 o'clock (+135).
    // Let's use standard audio knob range: -150 to +150 degrees, 0 at top (-90 in Flutter coords is top? No, 0 is right).
    // Flutter: 0 is Right (3 o'clock).
    // Top (-90) is 12 o'clock.
    // Start: 7 o'clock = 135 deg (positive from right? No, positive is Clockwise. 90 is bottom. 180 is left.)
    // 7 o'clock is roughly 135 degrees from Start (if start is bottom?).
    // Let's say range is 300 degrees total.
    // Start angle: -240 degrees (from right? No).

    // Math:
    // 0 deg = Right (3 o'clock)
    // 90 deg = Bottom (6 o'clock)
    // 180 deg = Left (9 o'clock)
    // 270 deg = Top (12 o'clock)

    // Knob Start (Min): 7 o'clock -> roughly 120 degrees? No.
    // Let's simplify:
    // 0.0 -> 135 degrees (Bottom Left)
    // 1.0 -> 45 degrees (Bottom Right)
    // Total sweep: 270 degrees.
    // Center (0.5) -> -90 degrees (Top)

    // Convert to radians.
    // 0.0 -> 3/4 PI approx?

    // Start Angle (0.0): 135 degrees = 2.356 rad
    // End Angle (1.0): 405 degrees (or 45) = 7.068 rad?
    // Let's range from (PI - PI/4) to (2PI + PI/4)?
    // Start: 135 degrees. End: 405 degrees.
    // Center: 270 degrees (Top).

    double startAngle = 135 * pi / 180;
    double sweepAngle = 270 * pi / 180;

    double currentAngle = startAngle + (sweepAngle * value);

    // Draw indicator line
    final indicatorPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final indicatorLength = radius * 0.8;

    final lineStart = Offset(
      center.dx +
          cos(currentAngle) *
              (radius * 0.2), // prevent drawing from exact center
      center.dy + sin(currentAngle) * (radius * 0.2),
    );

    final lineEnd = Offset(
      center.dx + cos(currentAngle) * indicatorLength,
      center.dy + sin(currentAngle) * indicatorLength,
    );

    canvas.drawLine(lineStart, lineEnd, indicatorPaint);

    // Draw active arc (optional, from center)
    // If value != 0.5, draw arc from center to current value
    if ((value - 0.5).abs() > 0.01) {
      final arcPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      double centerAngle = startAngle + (sweepAngle * 0.5);
      // Draw arc from centerAngle to currentAngle
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.6),
        centerAngle,
        currentAngle - centerAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(KnobPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
