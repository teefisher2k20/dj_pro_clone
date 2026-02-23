import 'dart:math' as math;
import 'package:flutter/material.dart';

class StemControlsWidget extends StatefulWidget {
  final bool isActive;
  final double vocals;
  final double drums;
  final double harmonics;
  final double other;
  final VoidCallback onToggle;
  final ValueChanged<double> onVocalsChanged;
  final ValueChanged<double> onDrumsChanged;
  final ValueChanged<double> onHarmonicsChanged;
  final ValueChanged<double> onOtherChanged;
  final Color color;

  const StemControlsWidget({
    super.key,
    required this.isActive,
    required this.vocals,
    required this.drums,
    required this.harmonics,
    required this.other,
    required this.onToggle,
    required this.onVocalsChanged,
    required this.onDrumsChanged,
    required this.onHarmonicsChanged,
    required this.onOtherChanged,
    required this.color,
  });

  @override
  State<StemControlsWidget> createState() => _StemControlsWidgetState();
}

class _StemControlsWidgetState extends State<StemControlsWidget>
    with TickerProviderStateMixin {
  // Muted state per stem
  final Map<String, bool> _muted = {
    'VOCALS': false,
    'DRUMS': false,
    'HARM.': false,
    'OTHER': false,
  };

  // Simulated level meters (animated)
  final Map<String, double> _levels = {
    'VOCALS': 0.65,
    'DRUMS': 0.82,
    'HARM.': 0.4,
    'OTHER': 0.3,
  };

  late AnimationController _meterController;

  @override
  void initState() {
    super.initState();
    _meterController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 120),
          )
          ..addListener(_updateMeters)
          ..repeat();
  }

  final _rng = math.Random();
  void _updateMeters() {
    if (!mounted || !widget.isActive) return;
    setState(() {
      _levels['VOCALS'] =
          (_levels['VOCALS']! + (_rng.nextDouble() - 0.5) * 0.12).clamp(
            0.2,
            widget.vocals * 0.9,
          );
      _levels['DRUMS'] = (_levels['DRUMS']! + (_rng.nextDouble() - 0.5) * 0.2)
          .clamp(0.1, widget.drums * 0.95);
      _levels['HARM.'] = (_levels['HARM.']! + (_rng.nextDouble() - 0.5) * 0.1)
          .clamp(0.1, widget.harmonics * 0.85);
      _levels['OTHER'] = (_levels['OTHER']! + (_rng.nextDouble() - 0.5) * 0.08)
          .clamp(0.05, widget.other * 0.8);
    });
  }

  @override
  void dispose() {
    _meterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: widget.isActive
            ? const Color(0xFF1A1F3A)
            : const Color(0xFF111420),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isActive
              ? widget.color.withValues(alpha: 0.5)
              : Colors.white10,
          width: widget.isActive ? 1.5 : 1.0,
        ),
        boxShadow: widget.isActive
            ? [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.1),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with ON/OFF
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.hub_rounded,
                    size: 12,
                    color: widget.isActive ? widget.color : Colors.white30,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'NEURAL MIX',
                    style: TextStyle(
                      color: widget.isActive ? widget.color : Colors.white30,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              // ON / OFF toggle
              GestureDetector(
                onTap: widget.onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isActive
                        ? widget.color.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: widget.isActive ? widget.color : Colors.white24,
                    ),
                  ),
                  child: Text(
                    widget.isActive ? 'ON' : 'OFF',
                    style: TextStyle(
                      color: widget.isActive ? widget.color : Colors.white38,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Stem sliders row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStem(
                label: 'VOCALS',
                value: widget.vocals,
                onChange: widget.onVocalsChanged,
                stemColor: const Color(0xFF00D9FF),
                icon: Icons.mic,
              ),
              _buildStem(
                label: 'DRUMS',
                value: widget.drums,
                onChange: widget.onDrumsChanged,
                stemColor: const Color(0xFFFF6B35),
                icon: Icons.speaker,
              ),
              _buildStem(
                label: 'HARM.',
                value: widget.harmonics,
                onChange: widget.onHarmonicsChanged,
                stemColor: const Color(0xFFB026FF),
                icon: Icons.piano,
              ),
              _buildStem(
                label: 'OTHER',
                value: widget.other,
                onChange: widget.onOtherChanged,
                stemColor: const Color(0xFF39FF14),
                icon: Icons.music_note,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStem({
    required String label,
    required double value,
    required ValueChanged<double> onChange,
    required Color stemColor,
    required IconData icon,
  }) {
    final isMuted = _muted[label] ?? false;
    final effectiveValue = isMuted ? 0.0 : value;
    final level = _levels[label] ?? 0.0;
    final dimmed = !widget.isActive || isMuted;

    return SizedBox(
      width: 52,
      child: Column(
        children: [
          // Level meter bar (thin, at top)
          SizedBox(
            width: 4,
            height: 60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Background
                    Container(color: Colors.white.withValues(alpha: 0.05)),
                    // Level fill
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 80),
                      heightFactor: dimmed ? 0.0 : level,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              stemColor,
                              stemColor.withValues(alpha: 0.6),
                              Colors.yellow.withValues(alpha: 0.8),
                              Colors.red.withValues(alpha: 0.9),
                            ],
                            stops: const [0.0, 0.6, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Vertical fader
          SizedBox(
            height: 80,
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: _StemThumbShape(
                    color: dimmed ? Colors.grey : stemColor,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: dimmed
                      ? Colors.grey.withValues(alpha: 0.3)
                      : stemColor.withValues(alpha: 0.8),
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                  overlayColor: stemColor.withValues(alpha: 0.15),
                ),
                child: Slider(
                  value: effectiveValue,
                  onChanged: widget.isActive && !isMuted ? onChange : null,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Value percentage
          Text(
            '${(effectiveValue * 100).round()}%',
            style: TextStyle(
              color: dimmed ? Colors.white12 : stemColor.withValues(alpha: 0.7),
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          // Mute button
          GestureDetector(
            onTap: () {
              if (!widget.isActive) return;
              setState(() {
                _muted[label] = !(_muted[label] ?? false);
              });
              // Inform parent — muted = 0.0, unmuted = current value
              final newVal = (_muted[label] ?? false) ? 0.0 : value;
              onChange(newVal);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 26,
              height: 18,
              decoration: BoxDecoration(
                color: isMuted
                    ? stemColor.withValues(alpha: 0.25)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: isMuted ? stemColor : Colors.white24,
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  size: 11,
                  color: isMuted ? stemColor : Colors.white30,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Label with icon
          Icon(icon, size: 10, color: dimmed ? Colors.white24 : stemColor),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: dimmed ? Colors.white24 : Colors.white54,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom circular thumb with inner dot
class _StemThumbShape extends SliderComponentShape {
  final Color color;
  const _StemThumbShape({required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(12, 12);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    // Outer circle
    canvas.drawCircle(center, 7, Paint()..color = color.withValues(alpha: 0.9));
    // Inner bright dot
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
  }
}
