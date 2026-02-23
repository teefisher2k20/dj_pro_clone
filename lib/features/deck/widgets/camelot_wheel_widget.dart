import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/key_matching_service.dart';
import '../../../../core/models/deck_state.dart';
import '../providers/deck_provider.dart';

class CamelotWheelWidget extends StatefulWidget {
  const CamelotWheelWidget({super.key});

  @override
  State<CamelotWheelWidget> createState() => _CamelotWheelWidgetState();
}

class _CamelotWheelWidgetState extends State<CamelotWheelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  CamelotKey? _hoveredKey;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deckProvider = Provider.of<DeckProvider>(context);
    final keyA = deckProvider.deckAState.detectedKey;
    final keyB = deckProvider.deckBState.detectedKey;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(keyA, keyB),
          // Wheel
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = min(constraints.maxWidth, constraints.maxHeight);
                  return Center(
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: _buildWheel(size, keyA, keyB),
                    ),
                  );
                },
              ),
            ),
          ),
          // Legend
          _buildLegend(keyA, keyB),
        ],
      ),
    );
  }

  Widget _buildHeader(CamelotKey? keyA, CamelotKey? keyB) {
    final compatibility = (keyA != null && keyB != null)
        ? KeyMatchingService.getCompatibility(keyA, keyB)
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          const Icon(Icons.music_note, size: 16, color: Color(0xFF00D9FF)),
          const SizedBox(width: 8),
          const Text(
            'HARMONIC MIXING',
            style: TextStyle(
              color: Color(0xFF00D9FF),
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          if (compatibility != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: KeyMatchingService.compatibilityColor(
                  compatibility,
                ).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: KeyMatchingService.compatibilityColor(compatibility),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: KeyMatchingService.compatibilityColor(
                        compatibility,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    KeyMatchingService.compatibilityLabel(compatibility),
                    style: TextStyle(
                      color: KeyMatchingService.compatibilityColor(
                        compatibility,
                      ),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            )
          else
            const Text(
              'Load tracks to compare',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
        ],
      ),
    );
  }

  Widget _buildWheel(double size, CamelotKey? keyA, CamelotKey? keyB) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          children: [
            // Background rings (visual only)
            CustomPaint(
              size: Size(size, size),
              painter: _WheelBackgroundPainter(),
            ),
            // Interactive key segments
            ...KeyMatchingService.allKeys.map(
              (key) => _buildKeySegment(key, size, keyA, keyB),
            ),
            // Center label
            Center(child: _buildCenterLabel(keyA, keyB)),
          ],
        );
      },
    );
  }

  Widget _buildKeySegment(
    CamelotKey key,
    double size,
    CamelotKey? keyA,
    CamelotKey? keyB,
  ) {
    // Angle calculation: 12 positions on the wheel, start at top
    // Number 1 is at the top (270° or -90°), going clockwise
    final angleStep = (2 * pi) / 12;
    final angle = ((key.number - 1) * angleStep) - (pi / 2);

    // Two rings: outer = Major (B), inner = Minor (A)
    final bool isMajor = key.isMajor;
    final outerRadius = size / 2;
    final minorRadius = outerRadius * 0.62;
    final majorRadius = outerRadius * 0.64;

    final radius = isMajor
        ? (majorRadius + (outerRadius - majorRadius) * 0.5)
        : (minorRadius * 0.5);

    final center = Offset(size / 2, size / 2);
    final x = center.dx + radius * cos(angle);
    final y = center.dy + radius * sin(angle);

    // Determine highlighting
    final bool isKeyAMatch = keyA?.camelotCode == key.camelotCode;
    final bool isKeyBMatch = keyB?.camelotCode == key.camelotCode;
    final bool isHovered = _hoveredKey?.camelotCode == key.camelotCode;

    // Compatibility with deck A key (if deck A has a key)
    KeyCompatibility? compatWithA;
    KeyCompatibility? compatWithB;
    if (keyA != null) {
      compatWithA = KeyMatchingService.getCompatibility(keyA, key);
    }
    if (keyB != null) {
      compatWithB = KeyMatchingService.getCompatibility(keyB, key);
    }

    // Color logic
    Color segColor;
    double scale = 1.0;
    double opacity = 0.6;

    if (isKeyAMatch && isKeyBMatch) {
      // Both decks on same key!
      segColor = const Color(0xFF00FF9F);
      scale = 1.3;
      opacity = 1.0;
    } else if (isKeyAMatch) {
      segColor = const Color(0xFF00D9FF);
      scale = 1.25;
      opacity = 1.0;
    } else if (isKeyBMatch) {
      segColor = const Color(0xFFFF8000);
      scale = 1.25;
      opacity = 1.0;
    } else if (compatWithA != null &&
        compatWithA != KeyCompatibility.incompatible) {
      segColor = KeyMatchingService.compatibilityColor(compatWithA);
      opacity = 0.7;
      scale = 1.05;
    } else {
      segColor = isMajor ? const Color(0xFF2A2A4A) : const Color(0xFF1A2A3A);
      opacity = isHovered ? 0.9 : 0.5;
    }

    final segSize = isMajor ? size * 0.09 : size * 0.075;
    final pulse = _pulseController.value;

    return Positioned(
      left: x - segSize / 2,
      top: y - segSize / 2,
      child: GestureDetector(
        onTap: () {
          setState(() => _hoveredKey = key);
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hoveredKey = key),
          onExit: (_) => setState(() => _hoveredKey = null),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: segSize * scale,
            height: segSize * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: segColor.withOpacity(opacity),
              border: Border.all(
                color: (isKeyAMatch || isKeyBMatch)
                    ? segColor
                    : segColor.withOpacity(0.3),
                width: (isKeyAMatch || isKeyBMatch) ? 2 : 1,
              ),
              boxShadow: (isKeyAMatch || isKeyBMatch)
                  ? [
                      BoxShadow(
                        color: segColor.withOpacity(0.4 + pulse * 0.3),
                        blurRadius: 12 + pulse * 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        key.camelotCode,
                        style: TextStyle(
                          color: (isKeyAMatch || isKeyBMatch)
                              ? Colors.black
                              : Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: segSize * 0.22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        key.shortName,
                        style: TextStyle(
                          color: (isKeyAMatch || isKeyBMatch)
                              ? Colors.black.withOpacity(0.7)
                              : Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                          fontSize: segSize * 0.17,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterLabel(CamelotKey? keyA, CamelotKey? keyB) {
    if (_hoveredKey != null) {
      return _CenterInfo(key2: _hoveredKey!, keyA: keyA, keyB: keyB);
    }
    if (keyA != null || keyB != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (keyA != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00D9FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'A: ${keyA.camelotCode}',
                style: const TextStyle(
                  color: Color(0xFF00D9FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (keyB != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8000).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'B: ${keyB.camelotCode}',
                style: const TextStyle(
                  color: Color(0xFFFF8000),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      );
    }
    return const Text(
      'CAMELOT\nWHEEL',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white24,
        fontWeight: FontWeight.bold,
        fontSize: 10,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildLegend(CamelotKey? keyA, CamelotKey? keyB) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LegendItem(color: const Color(0xFF00FF9F), label: 'Perfect'),
          _LegendItem(color: const Color(0xFF00D9FF), label: 'Compatible'),
          _LegendItem(color: const Color(0xFFFFD700), label: 'Adjacent'),
          _LegendItem(color: const Color(0xFFFF8C00), label: 'Tension'),
        ],
      ),
    );
  }
}

class _CenterInfo extends StatelessWidget {
  final CamelotKey key2;
  final CamelotKey? keyA;
  final CamelotKey? keyB;

  const _CenterInfo({required this.key2, this.keyA, this.keyB});

  @override
  Widget build(BuildContext context) {
    final compatA = keyA != null
        ? KeyMatchingService.getCompatibility(keyA!, key2)
        : null;
    final compatB = keyB != null
        ? KeyMatchingService.getCompatibility(keyB!, key2)
        : null;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            key2.camelotCode,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            key2.shortName,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          if (compatA != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: KeyMatchingService.compatibilityColor(
                  compatA,
                ).withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'vs A: ${KeyMatchingService.compatibilityLabel(compatA)}',
                style: TextStyle(
                  color: KeyMatchingService.compatibilityColor(compatA),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (compatB != null) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: KeyMatchingService.compatibilityColor(
                  compatB,
                ).withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'vs B: ${KeyMatchingService.compatibilityLabel(compatB)}',
                style: TextStyle(
                  color: KeyMatchingService.compatibilityColor(compatB),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ],
    );
  }
}

class _WheelBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;

    // Outer ring (Major)
    final outerPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRadius * 0.32;
    canvas.drawCircle(center, outerRadius * 0.84, outerPaint);

    // Inner ring (Minor)
    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRadius * 0.25;
    canvas.drawCircle(center, outerRadius * 0.4, innerPaint);

    // Dividing lines for 12 sectors
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;

    for (int i = 0; i < 12; i++) {
      final angle = (i * (2 * pi / 12)) - (pi / 2);
      final start = Offset(
        center.dx + outerRadius * 0.18 * cos(angle),
        center.dy + outerRadius * 0.18 * sin(angle),
      );
      final end = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );
      canvas.drawLine(start, end, linePaint);
    }

    // Center circle
    final centerPaint = Paint()
      ..color = const Color(0xFF0D0D0D)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius * 0.18, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
