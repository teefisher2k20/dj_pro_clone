import 'package:flutter/material.dart';
import '../../../core/models/deck_state.dart';

class LoopControlsWidget extends StatelessWidget {
  final bool isLoopActive;
  final double loopLength;
  final ValueChanged<double> onLoopLengthChanged;
  final VoidCallback onToggleLoop;
  final VoidCallback onLoopIn;
  final VoidCallback onLoopOut;
  final bool isQuantizeActive;
  final VoidCallback onToggleQuantize;
  final Color color;

  // Phase 2 - Saved Loops
  final List<SavedLoop> savedLoops;
  final VoidCallback onSaveLoop;
  final ValueChanged<String> onDeleteLoop;
  final ValueChanged<SavedLoop> onActivateSavedLoop;

  const LoopControlsWidget({
    super.key,
    required this.isLoopActive,
    required this.loopLength,
    required this.onLoopLengthChanged,
    required this.onToggleLoop,
    required this.onLoopIn,
    required this.onLoopOut,
    required this.isQuantizeActive,
    required this.onToggleQuantize,
    this.color = Colors.white,
    this.savedLoops = const [],
    required this.onSaveLoop,
    required this.onDeleteLoop,
    required this.onActivateSavedLoop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Auto Loop Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [0.5, 1.0, 2.0, 4.0].map((length) {
            final isSelected = loopLength == length;
            // If loop is active, highlight selected length.
            // If not active, selected length indicates what will happen if activated? (Usually yes).

            return GestureDetector(
              onTap: () {
                onLoopLengthChanged(length);
                if (!isLoopActive) {
                  onToggleLoop(); // Auto-activate
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: (isLoopActive && isSelected) ? color : Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: (isLoopActive && isSelected) ? color : Colors.grey,
                  ),
                ),
                child: Text(
                  length == 0.5 ? '1/2' : '${length.toInt()}',
                  style: TextStyle(
                    color: (isLoopActive && isSelected)
                        ? Colors.black
                        : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 8),

        // Manual Loop Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('IN', onLoopIn, false),
            _buildButton('OUT', onLoopOut, false),
            _buildButton(
              isLoopActive ? 'EXIT' : 'RELOOP',
              onToggleLoop,
              isLoopActive,
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Quantize Toggle
        GestureDetector(
          onTap: onToggleQuantize,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.grid_on,
                size: 12,
                color: isQuantizeActive ? color : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                'QUANTIZE',
                style: TextStyle(
                  color: isQuantizeActive ? color : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ), // End Quantize Row

        const SizedBox(height: 8),

        // Saved Loops Section
        ExpansionTile(
          title: Text(
            "Saved Loops",
            style: TextStyle(color: color, fontSize: 12),
          ),
          dense: true,
          collapsedIconColor: color,
          iconColor: color,
          children: [
            // Save Current Button
            if (isLoopActive)
              ListTile(
                dense: true,
                leading: Icon(Icons.save, color: color, size: 16),
                title: const Text(
                  "Save Current Loop",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                onTap: onSaveLoop,
              ),

            // List
            if (savedLoops.isEmpty && !isLoopActive)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "No saved loops",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),

            ...savedLoops.map(
              (loop) => ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                title: Text(
                  loop.name,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                subtitle: Text(
                  "${loop.start.inSeconds}s - ${loop.end.inSeconds}s",
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                onTap: () => onActivateSavedLoop(loop),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                    size: 14,
                  ),
                  onPressed: () => onDeleteLoop(loop.id),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(String label, VoidCallback onTap, bool active) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : Colors.black38,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: active ? color : Colors.grey),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
