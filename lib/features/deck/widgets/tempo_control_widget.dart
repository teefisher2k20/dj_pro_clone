import 'package:flutter/material.dart';

class TempoControlWidget extends StatefulWidget {
  final double currentTempo;
  final bool isKeyLock;
  final double originalBPM;
  final ValueChanged<double> onTempoChanged;
  final ValueChanged<bool> onKeyLockChanged;
  final VoidCallback onTapTempo;
  final VoidCallback onSync;

  const TempoControlWidget({
    super.key,
    required this.currentTempo,
    required this.isKeyLock,
    required this.originalBPM,
    required this.onTempoChanged,
    required this.onKeyLockChanged,
    required this.onTapTempo,
    required this.onSync,
  });

  @override
  State<TempoControlWidget> createState() => _TempoControlWidgetState();
}

class _TempoControlWidgetState extends State<TempoControlWidget> {
  // For tap tempo logic if handled internally or just visual feedback?
  // We'll leave tap tempo logic to provider/service, here just UI button.

  @override
  Widget build(BuildContext context) {
    final currentBPM = widget.originalBPM * widget.currentTempo;

    // Percentage string (e.g. +8.0%, -2.5%)
    final percentChange = ((widget.currentTempo - 1.0) * 100).toStringAsFixed(
      1,
    );
    final percentString = widget.currentTempo >= 1.0
        ? '+$percentChange%'
        : '$percentChange%';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // BPM Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BPM',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  Text(
                    currentBPM.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ORIG: ${widget.originalBPM.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  Text(
                    percentString,
                    style: TextStyle(
                      color: widget.currentTempo == 1.0
                          ? Colors.grey
                          : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Tempo Slider
          // Vertical slider is traditional for DJ but Horizontal is easier in this layout.
          // Using Horizontal given the DeckWidget layout.
          Row(
            children: [
              const Text(
                'SLOW',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: widget.currentTempo,
                    min: 0.5,
                    max: 2.0,
                    divisions: 150, // Granular
                    onChanged: widget.onTempoChanged,
                  ),
                ),
              ),
              const Text(
                'FAST',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),

          // Reset button (Double tap center?) - Add small "Reset" text button
          Center(
            child: GestureDetector(
              onTap: () => widget.onTempoChanged(1.0),
              child: const Text(
                'RESET',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Key Lock & Tap Tempo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Key Lock Button
              InkWell(
                onTap: () => widget.onKeyLockChanged(!widget.isKeyLock),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isKeyLock
                        ? const Color(0xFF00D9FF)
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.isKeyLock
                          ? const Color(0xFF00D9FF)
                          : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock,
                        size: 14,
                        color: widget.isKeyLock ? Colors.black : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'KEY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: widget.isKeyLock ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sync Button
              InkWell(
                onTap: widget.onSync,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SYNC',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              // Tap Tempo Button
              InkWell(
                onTap: widget.onTapTempo,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TAP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
