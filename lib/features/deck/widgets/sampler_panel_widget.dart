import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/audio/sampler_service.dart';
import '../providers/deck_provider.dart';
import '../providers/deck_provider.dart';
import '../../../core/models/deck_state.dart';
import 'advanced_fx_pad_widget.dart';

class SamplerPanelWidget extends StatefulWidget {
  const SamplerPanelWidget({super.key});

  @override
  State<SamplerPanelWidget> createState() => _SamplerPanelWidgetState();
}

class _SamplerPanelWidgetState extends State<SamplerPanelWidget> {
  final SamplerService _samplerService = SamplerService();
  double _volume = 0.5;

  // Track press state for 16 pads
  // Track press state for 16 pads
  final List<bool> _isPressed = List.filled(16, false);

  bool _showFxPad = false;

  @override
  void initState() {
    super.initState();
    _samplerService.init();
  }

  void _captureLoop(BuildContext context, DeckSide side) {
    final deckProvider = context.read<DeckProvider>();
    final state = side == DeckSide.A
        ? deckProvider.deckAState
        : deckProvider.deckBState;

    if (state.track == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Load a track to Deck ${side.name} first!')),
      );
      return;
    }

    // Find first empty slot starting from index 8 (keeping 0-7 for presets usually)
    // Or just find first empty overall. Let's use 8-15 for user samples.
    int slot = -1;
    for (int i = 8; i < 16; i++) {
      if (_samplerService.getSample(i) == null) {
        slot = i;
        break;
      }
    }
    // If user banks full, overwrite 8
    if (slot == -1) slot = 8;

    // Determine Capture Region
    Duration start = state.position;
    Duration end;

    if (state.isLoopActive &&
        state.loopInPoint != null &&
        state.loopOutPoint != null) {
      start = state.loopInPoint!;
      end = state.loopOutPoint!;
    } else {
      // Capture 4 beats from current position
      final bpm = state.detectedBPM ?? 120.0;
      final beatDuration = 60.0 / bpm;
      final loopDuration = Duration(
        milliseconds: (beatDuration * 4 * 1000).round(),
      );
      end = start + loopDuration;
    }

    // Save
    _samplerService.saveSample(slot, state.track!, start, end);
    setState(() {}); // Refresh grid

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Captured buffer to Pad ${slot + 1} (${(end - start).inSeconds}s)',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2746), // Matching app theme
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.grid_view, color: Colors.orangeAccent),
              const SizedBox(width: 8),
              const Text(
                'SAMPLER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),

              // Slicer Toggles
              _buildSlicerToggle(context, DeckSide.A),
              const SizedBox(width: 4),
              _buildSlicerToggle(context, DeckSide.B),

              const SizedBox(width: 8),

              // Pitch Play Toggles
              _buildPitchPlayToggle(context, DeckSide.A),
              const SizedBox(width: 4),
              _buildPitchPlayToggle(context, DeckSide.B),

              const SizedBox(width: 16),

              // Capture Buttons
              _buildCaptureButton(DeckSide.A),
              const SizedBox(width: 8),
              _buildCaptureButton(DeckSide.B),

              const SizedBox(width: 16),

              // FX Toggle
              IconButton(
                icon: Icon(
                  Icons.bolt,
                  color: _showFxPad ? Colors.cyanAccent : Colors.grey,
                ),
                onPressed: () => setState(() => _showFxPad = !_showFxPad),
                tooltip: "Toggle Reactor FX",
              ),

              const SizedBox(width: 16),

              // Capture Buttons

              // Volume
              SizedBox(
                width: 100,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.orangeAccent,
                    inactiveTrackColor: Colors.black45,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    trackHeight: 2,
                  ),
                  child: Slider(
                    value: _volume,
                    onChanged: (val) {
                      setState(() => _volume = val);
                      _samplerService.setVolume(val);
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Pads Grid (2 rows of 8 for desktop feel, or 4x4)
          // 8x2 aspect ratio fits bottom bar better
          if (_showFxPad)
            Expanded(
              child: Row(
                children: [
                  Expanded(child: AdvancedFXPadWidget(side: DeckSide.A)),
                  SizedBox(width: 16),
                  Expanded(child: AdvancedFXPadWidget(side: DeckSide.B)),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8, // 8 columns
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                return _buildPad(index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton(DeckSide side) {
    return OutlinedButton.icon(
      onPressed: () => _captureLoop(context, side),
      icon: Icon(Icons.emergency_recording, size: 14, color: side.color),
      label: Text(
        'CAP ${side.name}',
        style: TextStyle(fontSize: 10, color: side.color),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: side.color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 32),
      ),
    );
  }

  Widget _buildSlicerToggle(BuildContext context, DeckSide side) {
    final deckProvider = context.watch<DeckProvider>();
    final state = side == DeckSide.A
        ? deckProvider.deckAState
        : deckProvider.deckBState;
    final isActive = state.isSlicerActive;

    return GestureDetector(
      onTap: () => deckProvider.toggleSlicer(side),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? side.color : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isActive ? side.color : Colors.white24),
        ),
        child: Text(
          'SLICER ${side.name}',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildPitchPlayToggle(BuildContext context, DeckSide side) {
    final deckProvider = context.watch<DeckProvider>();
    final state = side == DeckSide.A
        ? deckProvider.deckAState
        : deckProvider.deckBState;
    final isActive = state.isPitchPlayActive;

    return GestureDetector(
      onTap: () => deckProvider.togglePitchPlay(side),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.purpleAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? Colors.purpleAccent : Colors.white24,
          ),
        ),
        child: Text(
          'PITCH ${side.name}',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildPad(int index) {
    final deckProvider = context.read<DeckProvider>();
    final deckA = deckProvider.deckAState;
    final deckB = deckProvider.deckBState;

    // Priority: Pitch Play > Slicer > Sampler
    // Check for Pitch Play mode first
    bool isPitchPlay = false;
    String? noteName;
    Color pitchColor = Colors.white;
    DeckSide? pitchSide;

    final noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G'];

    if (deckA.isPitchPlayActive && index < 8) {
      isPitchPlay = true;
      noteName = noteNames[index];
      pitchColor = Colors.purpleAccent;
      pitchSide = DeckSide.A;
    } else if (deckB.isPitchPlayActive && index >= 8 && index < 16) {
      isPitchPlay = true;
      noteName = noteNames[index - 8];
      pitchColor = Colors.purpleAccent;
      pitchSide = DeckSide.B;
    }

    if (isPitchPlay) {
      final isPressed = _isPressed[index];
      return GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed[index] = true);
          deckProvider.playPitchedNote(pitchSide!, index % 8);
        },
        onTapUp: (_) {
          deckProvider.stopPitchedNote(pitchSide!, index % 8);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) setState(() => _isPressed[index] = false);
          });
        },
        onTapCancel: () {
          deckProvider.stopPitchedNote(pitchSide!, index % 8);
          if (mounted) setState(() => _isPressed[index] = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPressed
                  ? [pitchColor, pitchColor.withOpacity(0.6)]
                  : [pitchColor.withOpacity(0.5), pitchColor.withOpacity(0.2)],
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: isPressed ? 2 : 1),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note,
                color: Colors.white,
                size: isPressed ? 24 : 20,
              ),
              const SizedBox(height: 4),
              Text(
                noteName!,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isPressed ? 16 : 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Check if slicer is active on either deck
    // We'll prioritize Deck A slices on pads 0-7, Deck B on pads 8-15 if both active
    // Or if only one active, map 1-8 to the active deck's slices.

    bool isSlice = false;
    Duration? sliceTimestamp;
    Color sliceColor = Colors.white;
    DeckSide? sliceSide;

    if (deckA.isSlicerActive && index < 8 && deckA.slicerSegments != null) {
      isSlice = true;
      sliceTimestamp = deckA.slicerSegments![index];
      sliceColor = DeckSide.A.color;
      sliceSide = DeckSide.A;
    } else if (deckB.isSlicerActive &&
        index >= 8 &&
        index < 16 &&
        deckB.slicerSegments != null) {
      isSlice = true;
      sliceTimestamp = deckB.slicerSegments![index - 8];
      sliceColor = DeckSide.B.color;
      sliceSide = DeckSide.B;
    }

    if (isSlice) {
      final isPressed = _isPressed[index];
      return GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed[index] = true);
          deckProvider.jumpToSlice(sliceSide!, index % 8);
        },
        onTapUp: (_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) setState(() => _isPressed[index] = false);
          });
        },
        onTapCancel: () {
          if (mounted) setState(() => _isPressed[index] = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          decoration: BoxDecoration(
            color: isPressed
                ? sliceColor.withOpacity(1.0)
                : sliceColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: isPressed ? 2 : 1),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SLICE ${index % 8 + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              Text(
                '${sliceTimestamp!.inSeconds}s',
                style: const TextStyle(color: Colors.white70, fontSize: 8),
              ),
            ],
          ),
        ),
      );
    }

    // Default Sampler Pad Logic
    final sample = _samplerService.getSample(index);
    final isPressed = _isPressed[index];
    final bool isEmpty = sample == null;

    final color = isEmpty ? Colors.white10 : (sample.color);

    return GestureDetector(
      onLongPress: () {
        if (!isEmpty) {
          // Add delete logic? For now let's just use it as delete
          // Or we can just leave it.
        }
      },
      onTapDown: (_) {
        if (!isEmpty) {
          setState(() => _isPressed[index] = true);
          _samplerService.playSample(index);
        }
      },
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() => _isPressed[index] = false);
        });
      },
      onTapCancel: () {
        if (mounted) setState(() => _isPressed[index] = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        decoration: BoxDecoration(
          color: isPressed ? color.withOpacity(0.8) : color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isPressed
                ? Colors.white
                : (isEmpty ? Colors.transparent : color),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          isEmpty ? '' : sample.name,
          style: TextStyle(
            color: isPressed ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
