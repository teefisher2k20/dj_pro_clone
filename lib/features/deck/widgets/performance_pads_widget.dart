import 'package:flutter/material.dart';
import '../../../core/models/deck_state.dart';

enum PadMode { hotCue, loop, slicer, sampler }

class PerformancePadsWidget extends StatefulWidget {
  final DeckState state;
  final DeckSide side;
  // Hot Cues
  final ValueChanged<int> onSetCue;
  final ValueChanged<int> onJumpToCue;
  final ValueChanged<int> onDeleteCue;
  // Loops
  final ValueChanged<double> onAutoLoop;
  // Slicer
  final VoidCallback onToggleSlicer;
  final ValueChanged<int> onJumpToSlice;
  // Styling
  final Color color;

  const PerformancePadsWidget({
    super.key,
    required this.state,
    required this.side,
    required this.onSetCue,
    required this.onJumpToCue,
    required this.onDeleteCue,
    required this.onAutoLoop,
    required this.onToggleSlicer,
    required this.onJumpToSlice,
    required this.color,
  });

  @override
  State<PerformancePadsWidget> createState() => _PerformancePadsWidgetState();
}

class _PerformancePadsWidgetState extends State<PerformancePadsWidget> {
  PadMode _currentMode = PadMode.hotCue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mode Tabs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTab(PadMode.hotCue, 'HOT CUE'),
            _buildTab(PadMode.loop, 'LOOP'),
            _buildTab(PadMode.slicer, 'SLICER'),
            _buildTab(PadMode.sampler, 'SAMPLE'),
          ],
        ),
        const SizedBox(height: 8),
        // Pads Grid
        Container(
          height: 120, // Approx height for 2 rows
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _buildPadsGrid(),
        ),
      ],
    );
  }

  Widget _buildTab(PadMode mode, String label) {
    final isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMode = mode;
        });

        // Handle Slicer Activation/Deactivation
        if (mode == PadMode.slicer) {
          if (!widget.state.isSlicerActive) {
            widget.onToggleSlicer();
          }
        } else {
          if (widget.state.isSlicerActive) {
            widget.onToggleSlicer(); // Deactivate if leaving slicer tab
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? widget.color.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? widget.color : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? widget.color : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildPadsGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return _buildPad(index);
      },
    );
  }

  Widget _buildPad(int index) {
    switch (_currentMode) {
      case PadMode.hotCue:
        return _buildHotCuePad(index);
      case PadMode.loop:
        return _buildLoopPad(index);
      case PadMode.slicer:
        return _buildSlicerPad(index);
      case PadMode.sampler:
        return _buildSamplerPad(index);
    }
  }

  Widget _buildHotCuePad(int index) {
    final cue = widget.state.hotCues.length > index
        ? widget.state.hotCues[index]
        : null;
    final isSet = cue != null;

    return GestureDetector(
      onTapDown: (_) {
        if (isSet) {
          widget.onJumpToCue(index);
        } else {
          widget.onSetCue(index);
        }
      },
      onLongPress: () {
        if (isSet) widget.onDeleteCue(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSet ? widget.color.withOpacity(0.8) : Colors.black26,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSet ? widget.color : Colors.white10,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: isSet ? Colors.black : Colors.white30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoopPad(int index) {
    // Auto Loop Sizes: 1/8, 1/4, 1/2, 1, 2, 4, 8, 16
    final sizes = [0.125, 0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0];
    if (index >= sizes.length) return const SizedBox();

    final size = sizes[index];
    final label = size < 1 ? '1/${(1 / size).round()}' : '${size.round()}';

    // Check if this loop is active
    final isActive =
        widget.state.isLoopActive && widget.state.loopLength == size;

    return GestureDetector(
      onTap: () => widget.onAutoLoop(size),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.greenAccent : Colors.black26,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSlicerPad(int index) {
    // Active if current position is within this slice
    bool isActive = false;
    if (widget.state.isSlicerActive &&
        widget.state.slicerSegments != null &&
        widget.state.slicerSegments!.isNotEmpty) {
      // Check if currently playing slice index matches 'index'
      // We can determine this by finding which segment start we passed last?
      // Or simpler: The widget doesn't easily know "current segment index" without calc.
      // Let's rely on simple highlight for now on tap.

      // Improved Check:
      final segments = widget.state.slicerSegments!;
      if (index < segments.length) {
        final start = segments[index];
        Duration end;

        if (index < segments.length - 1) {
          end = segments[index + 1];
        } else {
          // Estimate duration from previous segments (assuming uniform)
          // If only 1 segment, default to 0 (should correspond to 8 beats though)
          final duration = segments.length > 1
              ? segments[1] - segments[0]
              : const Duration(milliseconds: 500);
          end = start + duration;
        }

        if (widget.state.position >= start && widget.state.position < end) {
          isActive = true;
        }
      }
    }

    return GestureDetector(
      onTapDown: (_) => widget.onJumpToSlice(index),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? Colors.redAccent
              : Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.redAccent),
        ),
        alignment: Alignment.center,
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSamplerPad(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        'S${index + 1}',
        style: const TextStyle(color: Colors.white30),
      ),
    );
  }
}
