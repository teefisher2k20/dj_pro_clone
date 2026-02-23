import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/deck_state.dart';
import '../../../../core/audio/effects_processor.dart';
import '../providers/deck_provider.dart';

/// Advanced FX Pad — an X/Y scratchpad with effect selection (Filter, Gater,
/// Echo, Reverb, Flanger). Touching the pad enables the selected effect and
/// controls its parameters via the XY position.
class AdvancedFXPadWidget extends StatefulWidget {
  final DeckSide side;

  const AdvancedFXPadWidget({super.key, required this.side});

  @override
  State<AdvancedFXPadWidget> createState() => _AdvancedFXPadWidgetState();
}

class _AdvancedFXPadWidgetState extends State<AdvancedFXPadWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  AudioEffectType _selectedEffect = AudioEffectType.filter;

  // Particle trail
  final List<_Particle> _particles = [];

  // The five effects we expose (excludes AudioEffectType.none)
  static const _effects = [
    AudioEffectType.filter,
    AudioEffectType.gater,
    AudioEffectType.echo,
    AudioEffectType.reverb,
    AudioEffectType.flanger,
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _addParticle(double x, double y, Color color) {
    if (_particles.length > 24) _particles.removeAt(0);
    setState(() => _particles.add(_Particle(x, y, color)));
  }

  @override
  Widget build(BuildContext context) {
    final deckProvider = Provider.of<DeckProvider>(context);
    final state = widget.side == DeckSide.A
        ? deckProvider.deckAState
        : deckProvider.deckBState;
    final accentColor = widget.side == DeckSide.A
        ? const Color(0xFF00D9FF)
        : const Color(0xFFB026FF);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1118),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: state.isFxActive
              ? accentColor.withOpacity(0.65)
              : Colors.white12,
          width: 1,
        ),
        boxShadow: state.isFxActive
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.18),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          _buildHeader(state, accentColor, deckProvider),

          // ── Effect Selector Tabs ────────────────────────────────────────────
          _buildEffectSelector(accentColor, deckProvider),

          // ── X/Y Pad ────────────────────────────────────────────────────────
          Expanded(child: _buildPad(state, accentColor, deckProvider)),

          // ── Axis Labels ────────────────────────────────────────────────────
          _buildAxisLabels(accentColor),
        ],
      ),
    );
  }

  Widget _buildHeader(
    DeckState state,
    Color accentColor,
    DeckProvider deckProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.bolt, size: 14, color: accentColor),
              const SizedBox(width: 6),
              Text(
                'REACTOR FX',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          // ON/OFF Toggle
          GestureDetector(
            onTap: () =>
                deckProvider.setFxActive(widget.side, !state.isFxActive),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: state.isFxActive
                    ? accentColor.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: state.isFxActive ? accentColor : Colors.white30,
                  width: 1,
                ),
              ),
              child: Text(
                state.isFxActive ? 'ON' : 'OFF',
                style: TextStyle(
                  color: state.isFxActive ? accentColor : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectSelector(Color accentColor, DeckProvider deckProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _effects.map((effect) {
          final isSelected = _selectedEffect == effect;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedEffect = effect);
              deckProvider.setEffect(widget.side, effect);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withOpacity(0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: isSelected ? accentColor : Colors.white12,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(effect.emoji, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    effect.label.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? accentColor : Colors.white38,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPad(
    DeckState state,
    Color accentColor,
    DeckProvider deckProvider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (d) =>
              _onTouch(d.localPosition, constraints, deckProvider, accentColor),
          onPanUpdate: (d) =>
              _onTouch(d.localPosition, constraints, deckProvider, accentColor),
          onPanEnd: (_) {
            deckProvider.setFxXY(widget.side, 0.5, 0.5);
            deckProvider.setFxActive(widget.side, false);
          },
          onTapDown: (d) =>
              _onTouch(d.localPosition, constraints, deckProvider, accentColor),
          onTapUp: (_) {
            deckProvider.setFxXY(widget.side, 0.5, 0.5);
            deckProvider.setFxActive(widget.side, false);
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Grid background
                CustomPaint(
                  size: Size.infinite,
                  painter: _GridPainter(color: accentColor.withOpacity(0.06)),
                ),

                // Particle trail
                ..._buildParticles(constraints, accentColor),

                // Active cursor
                if (state.isFxActive)
                  _buildCursor(state, constraints, accentColor),

                // Idle hint
                if (!state.isFxActive) _buildIdleHint(accentColor),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildParticles(BoxConstraints constraints, Color color) {
    return _particles.asMap().entries.map((e) {
      final frac = e.key / _particles.length;
      return Positioned(
        left: e.value.x * constraints.maxWidth,
        top: e.value.y * constraints.maxHeight,
        child: Opacity(
          opacity: frac * 0.6,
          child: Container(
            width: 4 + frac * 4,
            height: 4 + frac * 4,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color, blurRadius: frac * 6)],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCursor(
    DeckState state,
    BoxConstraints constraints,
    Color accentColor,
  ) {
    return Positioned(
      left: (state.fxX * constraints.maxWidth) - 22,
      top: (state.fxY * constraints.maxHeight) - 22,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (_, __) {
          final pulse = _pulseController.value;
          return Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.18 + pulse * 0.1),
              border: Border.all(
                color: accentColor.withOpacity(0.8 + pulse * 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(color: accentColor, blurRadius: 8 + pulse * 18),
              ],
            ),
            child: Center(
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIdleHint(Color accentColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_outlined,
            color: accentColor.withOpacity(0.25),
            size: 36,
          ),
          const SizedBox(height: 6),
          Text(
            'TOUCH TO ENGAGE',
            style: TextStyle(
              color: accentColor.withOpacity(0.25),
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedEffect.label.toUpperCase(),
            style: TextStyle(color: accentColor.withOpacity(0.18), fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildAxisLabels(Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedEffect.yAxisLabel,
            style: TextStyle(
              color: accentColor.withOpacity(0.45),
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            _selectedEffect.xAxisLabel,
            style: TextStyle(
              color: accentColor.withOpacity(0.45),
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _onTouch(
    Offset pos,
    BoxConstraints constraints,
    DeckProvider deckProvider,
    Color accentColor,
  ) {
    final x = (pos.dx / constraints.maxWidth).clamp(0.0, 1.0);
    final y = (pos.dy / constraints.maxHeight).clamp(0.0, 1.0);

    _addParticle(x, y, accentColor);

    // Ensure the correct effect type is active
    deckProvider.setEffect(widget.side, _selectedEffect);
    deckProvider.setFxActive(widget.side, true);
    deckProvider.setFxXY(widget.side, x, y);
  }
}

// ── Grid Painter ─────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({this.color = Colors.white10});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double t = 0; t <= 1.0; t += 0.25) {
      canvas.drawLine(
        Offset(size.width * t, 0),
        Offset(size.width * t, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, size.height * t),
        Offset(size.width, size.height * t),
        paint,
      );
    }

    // Center cross
    final crossPaint = Paint()
      ..color = color
          .withOpacity(2.0) // brighter center
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      crossPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.color != color;
}

// ── Particle ──────────────────────────────────────────────────────────────────

class _Particle {
  final double x, y;
  final Color color;
  _Particle(this.x, this.y, this.color);
}

// ── unused _DelayLine helper kept for future integration ─────────────────────
// ignore: unused_element
class _DelayLine {
  final List<double> _buffer;
  int _writePos = 0;

  _DelayLine({int maxSamples = 4096}) : _buffer = List.filled(maxSamples, 0.0);

  double process(double input, int delaySamples, double feedback) {
    final readPos =
        (_writePos -
            delaySamples.clamp(1, _buffer.length - 1) +
            _buffer.length) %
        _buffer.length;
    final delayed = _buffer[readPos];
    _buffer[_writePos] = (input + delayed * feedback).clamp(-1.0, 1.0);
    _writePos = (_writePos + 1) % _buffer.length;
    return delayed;
  }
}
