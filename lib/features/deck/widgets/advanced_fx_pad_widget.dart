import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/deck_state.dart';
import '../../../../core/audio/effects_processor.dart';
import '../providers/deck_provider.dart';

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

  // Particle System
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _addParticle(double x, double y, Color color) {
    if (_particles.length > 20) _particles.removeAt(0);
    setState(() {
      _particles.add(_Particle(x, y, color));
    });
  }

  @override
  Widget build(BuildContext context) {
    final deckProvider = Provider.of<DeckProvider>(context);
    final state = widget.side == DeckSide.A
        ? deckProvider.deckAState
        : deckProvider.deckBState;
    final primaryColor = Theme.of(context).primaryColor;
    final accentColor = widget.side == DeckSide.A
        ? const Color(0xFF00D9FF)
        : const Color(0xFFB026FF);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: state.isFxPadActive
              ? accentColor.withOpacity(0.6)
              : Colors.white12,
          width: 1,
        ),
        boxShadow: state.isFxPadActive
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          // Header / Effect Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(7),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt, size: 16, color: accentColor),
                    const SizedBox(width: 8),
                    Text(
                      "REACTOR FX",
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _EffectButton(
                      label: "FILTER",
                      selected: _selectedEffect == AudioEffectType.filter,
                      color: accentColor,
                      onTap: () {
                        setState(
                          () => _selectedEffect = AudioEffectType.filter,
                        );
                        deckProvider.setAudioEffect(
                          widget.side,
                          AudioEffectType.filter,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _EffectButton(
                      label: "GATER",
                      selected: _selectedEffect == AudioEffectType.gater,
                      color: accentColor,
                      onTap: () {
                        setState(() => _selectedEffect = AudioEffectType.gater);
                        deckProvider.setAudioEffect(
                          widget.side,
                          AudioEffectType.gater,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // X/Y Pad Area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanStart: (details) => _handleInput(
                    details.localPosition,
                    constraints,
                    deckProvider,
                    true,
                  ),
                  onPanUpdate: (details) => _handleInput(
                    details.localPosition,
                    constraints,
                    deckProvider,
                    true,
                  ),
                  onPanEnd: (_) => _handleInputEnd(deckProvider),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent, // Hit test target
                    child: Stack(
                      children: [
                        // Grid
                        CustomPaint(
                          size: Size.infinite,
                          painter: _GridPainter(color: Colors.white10),
                        ),

                        // Particles
                        ..._particles.map(
                          (p) => Positioned(
                            left: p.x * constraints.maxWidth,
                            top: p.y * constraints.maxHeight,
                            child: Opacity(
                              opacity: 0.5, // p.opacity,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Cursor
                        if (state.isFxPadActive)
                          Positioned(
                            left: (state.fxX * constraints.maxWidth) - 20,
                            top: (state.fxY * constraints.maxHeight) - 20,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accentColor.withOpacity(0.2),
                                    border: Border.all(
                                      color: accentColor.withOpacity(
                                        0.8 + (_pulseController.value * 0.2),
                                      ),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentColor,
                                        blurRadius:
                                            10 + (_pulseController.value * 15),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // Hint
                        if (!state.isFxPadActive)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  color: Colors.white24,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "TOUCH TO ENGAGE",
                                  style: TextStyle(
                                    color: Colors.white24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  void _handleInput(
    Offset localPos,
    BoxConstraints constraints,
    DeckProvider provider,
    bool active,
  ) {
    // Normalize
    double x = (localPos.dx / constraints.maxWidth).clamp(0.0, 1.0);
    double y = (localPos.dy / constraints.maxHeight).clamp(0.0, 1.0);

    // Add particle
    if (active && DateTime.now().millisecond % 5 == 0) {
      // Throttled particles
      // _addParticle(x, y, Colors.white);
    }

    provider.updateFxPad(widget.side, active, x, y);

    // Ensure effect type is set
    if (!active) {
      // provider.setAudioEffect(widget.side, _selectedEffect); // Or none?
    }
  }

  void _handleInputEnd(DeckProvider provider) {
    provider.updateFxPad(widget.side, false, 0.5, 0.5);
  }
}

class _EffectButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _EffectButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: selected ? color : Colors.white30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({this.color = Colors.white10});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // Vertical lines
    for (double i = 0; i <= 1.0; i += 0.25) {
      canvas.drawLine(
        Offset(size.width * i, 0),
        Offset(size.width * i, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double i = 0; i <= 1.0; i += 0.25) {
      canvas.drawLine(
        Offset(0, size.height * i),
        Offset(size.width, size.height * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Particle {
  double x, y;
  Color color;
  _Particle(this.x, this.y, this.color);
}
