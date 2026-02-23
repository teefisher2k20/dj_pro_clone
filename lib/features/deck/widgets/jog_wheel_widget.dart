import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/models/deck_state.dart';

class JogWheelWidget extends StatefulWidget {
  final DeckState state;
  final DeckSide side;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onScratchStart;
  final VoidCallback onScratchEnd;

  const JogWheelWidget({
    super.key,
    required this.state,
    required this.side,
    required this.onSeek,
    required this.onScratchStart,
    required this.onScratchEnd,
  });

  @override
  State<JogWheelWidget> createState() => _JogWheelWidgetState();
}

class _JogWheelWidgetState extends State<JogWheelWidget>
    with SingleTickerProviderStateMixin {
  // Scratch state
  double _accumulatedRotation = 0.0;
  Offset? _lastPanPosition;
  bool _isScratching = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        // Safety margin
        size = size * 0.95;

        return GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: (details) => _handlePanUpdate(details, size),
          onPanEnd: _handlePanEnd,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Base/Platter
                _buildPlatter(size),

                // Rotating Top Plate
                _buildRotatingPlate(size),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlatter(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF151515),
        border: Border.all(color: Colors.white12, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(size * 0.02),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color(0xFF303030), Color(0xFF101010)],
            stops: [0.85, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildRotatingPlate(double size) {
    // Calculate rotation angle
    // Standard: 33 1/3 RPM or Beat Sync?
    // Let's go with Beat Sync (1 rev = 4 beats)
    final bpm = widget.state.detectedBPM ?? 120.0;
    final beatDurationMs = 60000 / bpm;
    final barDurationMs = beatDurationMs * 4;

    // Position in milliseconds
    final posMs = widget.state.position.inMilliseconds;

    // Angle in radians (0 to 2pi)
    final angle = (posMs % barDurationMs) / barDurationMs * 2 * math.pi;

    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size * 0.8, // Slightly smaller than base
        height: size * 0.8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF202020),
          border: Border.all(color: Colors.white12, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Texture/Grooves (simulated with gradient)
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF252525),
                    Color(0xFF151515),
                    Color(0xFF252525),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // LED Ring / Position Marker
            CustomPaint(
              size: Size(size * 0.8, size * 0.8),
              painter: JogWheelPainter(color: widget.side.color),
            ),

            // Center Artwork/Logo
            Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(
                  color: widget.side.color.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: ClipOval(child: _buildCenterLabel()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterLabel() {
    if (widget.state.track == null) return _buildDefaultIcon();
    // Show artist initials as a stylized badge
    final initials = widget.state.track!.artist.isNotEmpty
        ? widget.state.track!.artist[0].toUpperCase()
        : '♪';
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: widget.side.color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return const Center(
      child: Icon(Icons.music_note, color: Colors.white54, size: 32),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    _isScratching = true;
    _lastPanPosition = details.localPosition;
    widget.onScratchStart();
  }

  void _handlePanUpdate(DragUpdateDetails details, double size) {
    if (!_isScratching || _lastPanPosition == null) return;

    // Calculate rotation delta
    // Center of the wheel
    final center = Offset(size / 2, size / 2);
    final currentPos = details.localPosition;
    final prevPos = _lastPanPosition!;

    // Vectors from center
    final vec1 = prevPos - center;
    final vec2 = currentPos - center;

    // Angle between vectors
    // Cross product 2D: x1*y2 - y1*x2
    // Angle ~ sin(theta) for small angles
    // Or just use atan2 difference
    final ang1 = math.atan2(vec1.dy, vec1.dx);
    final ang2 = math.atan2(vec2.dy, vec2.dx);

    double diff = ang2 - ang1;

    // Normalize diff
    if (diff > math.pi) diff -= 2 * math.pi;
    if (diff < -math.pi) diff += 2 * math.pi;

    // Sensitivity: how many ms per radian?
    // Standard Vinyl: 33 1/3 RPM = ~1.8s per rev (2pi)
    // 1800ms / 6.28 = ~286 ms/rad
    const sensitivity = 300.0; // ms per radian

    final deltaMs = (diff * sensitivity).round();

    final newPos = widget.state.position + Duration(milliseconds: deltaMs);

    // Clamp
    if (newPos >= Duration.zero && newPos <= widget.state.duration) {
      widget.onSeek(newPos);
    }

    _lastPanPosition = currentPos;
  }

  void _handlePanEnd(DragEndDetails details) {
    _isScratching = false;
    _lastPanPosition = null;
    widget.onScratchEnd();

    // Future: implement inertia/spin-down here
  }
}

class JogWheelPainter extends CustomPainter {
  final Color color;

  JogWheelPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw Tick Marks
    for (int i = 0; i < 16; i++) {
      final angle = (i / 16) * 2 * math.pi;
      final outer = Offset(
        center.dx + math.cos(angle) * (radius - 5),
        center.dy + math.sin(angle) * (radius - 5),
      );
      final inner = Offset(
        center.dx + math.cos(angle) * (radius - 15),
        center.dy + math.sin(angle) * (radius - 15),
      );
      canvas.drawLine(inner, outer, paint);
    }

    // Draw "Needle" Position Marker (at top, 0 degrees/12 o'clock, but the whole widget rotates)
    // Actually, on a real deck, the MARKER is on the platter and rotates with it.
    // Since we are rotating the container, we just draw a line at 0 degrees (Right) or -pi/2 (Top).
    // Let's draw it at the top.

    final markerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final markerOuter = Offset(center.dx, 10); // Top edge
    final markerInner = Offset(center.dx, 30);

    // Since `Transform.rotate` rotates the whole container,
    // we just need to draw the line at a fixed position relative to the container logic.
    // Our angle 0 is usually 3 o'clock in Flutter transform?
    // No, Transform.rotate rotates from the center.
    // If we want the marker to point to the current "angle", we just draw it at a fixed angle on the canvas,
    // and the canvas is rotated by the parent.
    // So let's draw it at 0 radians (3 o'clock) if our match.atan2 logic assumes standard circles,
    // or -pi/2 (12 o'clock).
    // Let's put it at 12 o'clock.

    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, radius * 0.3), // Line pointing inwards
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
