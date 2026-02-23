import 'package:flutter/material.dart';
import '../../../core/audio/effects_processor.dart';

class FxPadWidget extends StatefulWidget {
  final AudioEffectType currentEffect;
  final bool isActive;
  final double x;
  final double y;
  final ValueChanged<Offset> onXYChanged;
  final ValueChanged<bool> onActiveChanged;
  final Color color;

  const FxPadWidget({
    super.key,
    required this.currentEffect,
    required this.isActive,
    required this.x,
    required this.y,
    required this.onXYChanged,
    required this.onActiveChanged,
    this.color = Colors.blueAccent,
  });

  @override
  State<FxPadWidget> createState() => _FxPadWidgetState();
}

class _FxPadWidgetState extends State<FxPadWidget> {
  void _updateTouch(
    BuildContext context,
    Offset localPosition,
    double width,
    double height,
  ) {
    if (!widget.isActive) return;

    // Normalize coordinates (0.0 to 1.0)
    double x = (localPosition.dx / width).clamp(0.0, 1.0);
    // Invert Y for audio logic (Bottom = 0.0, Top = 1.0)
    double y = 1.0 - (localPosition.dy / height).clamp(0.0, 1.0);

    widget.onXYChanged(Offset(x, y));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pad Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'XY PAD - ${_getEffectName(widget.currentEffect)}',
              style: TextStyle(
                color: widget.isActive ? widget.color : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Switch(
              value: widget.isActive,
              onChanged: widget.onActiveChanged,
              activeColor: widget.color,
              activeTrackColor: widget.color.withOpacity(0.3),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Pad Area
        AspectRatio(
          aspectRatio: 1.5, // Widescreen pad
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return GestureDetector(
                onPanStart: (details) =>
                    _updateTouch(context, details.localPosition, width, height),
                onPanUpdate: (details) =>
                    _updateTouch(context, details.localPosition, width, height),
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2342),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.isActive
                          ? widget.color
                          : Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: widget.isActive
                        ? [
                            BoxShadow(
                              color: widget.color.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Stack(
                    children: [
                      // Grid Lines
                      CustomPaint(
                        size: Size(width, height),
                        painter: GridPainter(
                          color: Colors.white10,
                          showCenter:
                              widget.currentEffect == AudioEffectType.filter,
                        ),
                      ),

                      // Labels
                      _buildLabels(width, height),

                      // Puck/Cursor
                      if (widget.currentEffect != AudioEffectType.none)
                        Positioned(
                          left: widget.x * width - 15,
                          top:
                              (1.0 - widget.y) * height -
                              15, // Invert Y back for UI
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: widget.isActive
                                  ? widget.color
                                  : Colors.grey,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            // Optional: Glow effect if touched
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getEffectName(AudioEffectType type) {
    switch (type) {
      case AudioEffectType.none:
        return 'None';
      case AudioEffectType.echo:
        return 'Echo';
      case AudioEffectType.reverb:
        return 'Reverb';
      case AudioEffectType.flanger:
        return 'Flanger';
      case AudioEffectType.filter:
        return 'Filter';
      case AudioEffectType.gater:
        return 'Gater';
    }
  }

  Widget _buildLabels(double width, double height) {
    String xLabel = '';
    String yLabel = '';

    switch (widget.currentEffect) {
      case AudioEffectType.filter:
        xLabel = 'Lpf < Freq > Hpf';
        yLabel = 'Resonance';
        break;
      case AudioEffectType.gater:
        xLabel = 'Depth';
        yLabel = 'Rate';
        break;
      case AudioEffectType.echo:
        xLabel = 'Time';
        yLabel = 'Feedback';
        break;
      case AudioEffectType.reverb:
        xLabel = 'Size';
        yLabel = 'Damp';
        break;
      case AudioEffectType.flanger:
        xLabel = 'Delay';
        yLabel = 'Depth';
        break;
      default:
        break;
    }

    return Stack(
      children: [
        // X Label (Bottom Center)
        Positioned(
          bottom: 4,
          width: width,
          child: Center(
            child: Text(
              xLabel,
              style: const TextStyle(
                color: Colors.white30,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Y Label (Left Center - Rotated)
        Positioned(
          left: 4,
          height: height,
          child: Center(
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                yLabel,
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  final bool showCenter;

  GridPainter({required this.color, this.showCenter = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // Main Grid (3x3)
    // Vertical 1/3
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    // Vertical 2/3
    canvas.drawLine(
      Offset(2 * size.width / 3, 0),
      Offset(2 * size.width / 3, size.height),
      paint,
    );

    // Horizontal 1/3
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    // Horizontal 2/3
    canvas.drawLine(
      Offset(0, 2 * size.height / 3),
      Offset(size.width, 2 * size.height / 3),
      paint,
    );

    if (showCenter) {
      final centerPaint = Paint()
        ..color = Colors.white24
        ..strokeWidth = 2;

      // Center Vertical Line for Filter (Frequency split)
      canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height),
        centerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.showCenter != showCenter;
}
