import 'package:flutter/material.dart';
import 'dart:math' as math;

class VisualizerWidget extends StatefulWidget {
  final double width;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;

  const VisualizerWidget({
    super.key,
    this.width = double.infinity,
    this.height = 200,
    this.primaryColor = const Color(0xFF00D9FF), // Cyan/Neon Blue
    this.secondaryColor = const Color(0xFFB026FF), // Neon Purple
  });

  @override
  State<VisualizerWidget> createState() => _VisualizerWidgetState();
}

class _VisualizerWidgetState extends State<VisualizerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Simulated audio data
  List<double> _data = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _generateData();
  }

  void _generateData() {
    // Fill with initial random data
    _data = List.generate(32, (index) => math.Random().nextDouble());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.black87,
              border: Border.all(color: widget.primaryColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _RetroWavePainter(
                data: _data,
                animationValue: _controller.value,
                primaryColor: widget.primaryColor,
                secondaryColor: widget.secondaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RetroWavePainter extends CustomPainter {
  final List<double> data;
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;

  _RetroWavePainter({
    required this.data,
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw Grid (Retro Floor)
    _drawGrid(canvas, size);

    // Draw Frequency Bars
    double barWidth = size.width / data.length;
    for (int i = 0; i < data.length; i++) {
      // Simulate movement: shift phase based on animation + index
      double move = math.sin((animationValue * 2 * math.pi) + (i * 0.2));
      double heightIn = data[i] + (move * 0.2); // Add movement
      double barHeight = (heightIn.clamp(0.1, 1.0)) * size.height * 0.6;

      // Gradient color for bars
      paint.shader =
          LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ).createShader(
            Rect.fromLTWH(
              i * barWidth,
              size.height - barHeight,
              barWidth,
              barHeight,
            ),
          );

      paint.strokeWidth = barWidth * 0.6;
      canvas.drawLine(
        Offset(i * barWidth + (barWidth / 2), size.height),
        Offset(i * barWidth + (barWidth / 2), size.height - barHeight),
        paint,
      );
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = secondaryColor.withOpacity(0.15)
      ..strokeWidth = 1;

    // Perspective lines (vanishing point at top center)
    double vanishX = size.width / 2;
    double vanishY = size.height * 0.2;

    for (int i = 0; i <= 10; i++) {
      double startX = (size.width / 10) * i;
      canvas.drawLine(
        Offset(startX, size.height),
        Offset(
          vanishX + (startX - vanishX) * 0.3,
          vanishY,
        ), // Fade towards vanishing point
        gridPaint,
      );
    }

    // Horizontal lines (moving down)
    for (double i = 0; i < 1.0; i += 0.1) {
      double yPos = (i + animationValue) % 1.0;
      // Exponential spacing to simulate depth
      double drawY = size.height - (size.height * 0.6 * (yPos * yPos));

      if (drawY > size.height) continue;

      canvas.drawLine(Offset(0, drawY), Offset(size.width, drawY), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
