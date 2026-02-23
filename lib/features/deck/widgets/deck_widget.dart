import 'package:flutter/material.dart';
import '../../../core/models/deck_state.dart';
import '../../../core/services/waveform_service.dart';
import 'waveform_widget.dart';
import 'tempo_control_widget.dart';
import '../../../core/audio/effects_processor.dart';
import 'loop_controls_widget.dart';
import 'performance_pads_widget.dart';
import 'advanced_fx_pad_widget.dart';
import 'jog_wheel_widget.dart';
import '../../../core/services/key_matching_service.dart';

class DeckWidget extends StatefulWidget {
  final DeckSide side;
  final DeckState state;
  final VoidCallback onLoadTrack;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final ValueChanged<Duration>? onSeek;
  final ValueChanged<double> onTempoChanged;
  final ValueChanged<bool> onKeyLockChanged;
  final VoidCallback onTapTempo;
  final VoidCallback onSync;
  final ValueChanged<AudioEffectType> onEffectChanged;
  final ValueChanged<double> onFxWetDryChanged;
  final ValueChanged<bool> onFxActiveChanged;
  final ValueChanged<int> onSetCue;
  final ValueChanged<int> onJumpToCue;
  final ValueChanged<int> onDeleteCue;
  final VoidCallback onToggleLoop;
  final ValueChanged<double> onLoopLengthChanged;
  final VoidCallback onLoopIn;
  final VoidCallback onLoopOut;

  // Stem Callbacks
  final VoidCallback onToggleStems;
  final ValueChanged<double> onVocalsVolumeChanged;
  final ValueChanged<double> onDrumsVolumeChanged;
  final ValueChanged<double> onHarmonicsVolumeChanged;
  final ValueChanged<double> onOtherVolumeChanged;

  // Phase 2 - Slip Mode
  final VoidCallback onToggleSlipMode;

  // Phase 2 - Quantize
  final VoidCallback onToggleQuantize;

  // Phase 2 - Beat Jump
  final ValueChanged<int>? onBeatJump;

  // Phase 2 - Slicer Mode
  final VoidCallback onToggleSlicer;
  final ValueChanged<int> onJumpToSlice;
  final ValueChanged<Offset> onFxXYChanged;

  // Phase 2 - Saved Loops
  final VoidCallback onSaveLoop;
  final ValueChanged<String> onDeleteLoop;
  final ValueChanged<SavedLoop> onActivateSavedLoop;

  // Phase 2 - Scratch Banks
  final VoidCallback onToggleScratchBank;
  final ValueChanged<int> onTriggerScratchBank;
  final ValueChanged<int> onReleaseScratchBank;

  // Jog Wheel Callbacks
  final VoidCallback? onScratchStart;
  final VoidCallback? onScratchEnd;

  final VoidCallback onTriggerCue; // New

  const DeckWidget({
    super.key,
    required this.side,
    required this.state,
    required this.onLoadTrack,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    this.onSeek,
    required this.onTempoChanged,
    required this.onKeyLockChanged,
    required this.onTapTempo,
    required this.onSync,
    required this.onEffectChanged,
    required this.onFxWetDryChanged,
    required this.onFxActiveChanged,
    required this.onSetCue,
    required this.onJumpToCue,
    required this.onDeleteCue,
    required this.onToggleLoop,
    required this.onLoopLengthChanged,
    required this.onLoopIn,
    required this.onLoopOut,
    required this.onToggleStems,
    required this.onVocalsVolumeChanged,
    required this.onDrumsVolumeChanged,
    required this.onHarmonicsVolumeChanged,
    required this.onOtherVolumeChanged,
    required this.onToggleSlipMode,
    required this.onToggleQuantize,
    this.onBeatJump,
    required this.onSaveLoop,
    required this.onDeleteLoop,
    required this.onActivateSavedLoop,
    required this.onToggleSlicer,
    required this.onJumpToSlice,
    required this.onFxXYChanged,
    required this.onToggleScratchBank,
    required this.onTriggerScratchBank,
    required this.onReleaseScratchBank,
    required this.onTriggerCue,
    this.onScratchStart,
    this.onScratchEnd,
  });

  @override
  State<DeckWidget> createState() => _DeckWidgetState();
}

class _DeckWidgetState extends State<DeckWidget> {
  List<double>? _waveformData;
  bool _isLoadingWaveform = false;

  @override
  void initState() {
    super.initState();
    if (widget.state.track != null) {
      _loadWaveform();
    }
  }

  @override
  void didUpdateWidget(DeckWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Load waveform when track changes
    if (widget.state.track != oldWidget.state.track &&
        widget.state.track != null) {
      _loadWaveform();
    } else if (widget.state.track == null) {
      // Clear waveform if track removed
      setState(() {
        _waveformData = null;
      });
    }
  }

  Future<void> _loadWaveform() async {
    if (widget.state.track == null) return;

    setState(() {
      _isLoadingWaveform = true;
    });

    try {
      final waveformService = WaveformService();
      final data = await waveformService.extractWaveformData(
        widget.state.track!.filePath,
      );

      if (mounted) {
        setState(() {
          _waveformData = data;
          _isLoadingWaveform = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load waveform: $e');
      if (mounted) {
        setState(() {
          _isLoadingWaveform = false;
        });
      }
    }
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14161F),
        border: Border.all(color: widget.side.color.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // 1. Top Screen Area
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  // Track Info Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        color: widget.side.color,
                        child: Text(
                          widget.side.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: widget.state.track == null
                            ? const Text(
                                'No Track Loaded',
                                style: TextStyle(color: Colors.white38),
                              )
                            : Text(
                                '${widget.state.track!.artist} - ${widget.state.track!.title}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      // Time Info
                      Text(
                        '${_formatDuration(widget.state.position)} / ${_formatDuration(widget.state.duration)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Waveform
                  Expanded(child: _buildWaveform()),

                  const SizedBox(height: 4),

                  // Phase/Sync Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BPM: ${widget.state.tempo.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                      // Detected Key Badge
                      if (widget.state.detectedKey != null)
                        _buildKeyBadge(widget.state.detectedKey!)
                      else if (widget.state.track != null)
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 8,
                              height: 8,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Colors.white38,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Detecting key...',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.state.isSyncActive)
                            const _StatusBadge(
                              label: 'SYNC',
                              color: Colors.blueAccent,
                            ),
                          if (widget.state.isKeyLock) ...[
                            const SizedBox(width: 4),
                            const _StatusBadge(
                              label: 'KEYLOCK',
                              color: Colors.redAccent,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 2. Main Deck Controls
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left: Loops & Pads
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AdvancedFXPadWidget(side: widget.side),
                        const SizedBox(height: 8),
                        LoopControlsWidget(
                          isLoopActive: widget.state.isLoopActive,
                          loopLength: widget.state.loopLength,
                          onLoopLengthChanged: widget.onLoopLengthChanged,
                          onToggleLoop: widget.onToggleLoop,
                          onLoopIn: widget.onLoopIn,
                          onLoopOut: widget.onLoopOut,
                          isQuantizeActive: widget.state.isQuantizeActive,
                          onToggleQuantize: widget.onToggleQuantize,
                          color: widget.side.color,
                          savedLoops: widget.state.savedLoops,
                          onSaveLoop: widget.onSaveLoop,
                          onDeleteLoop: widget.onDeleteLoop,
                          onActivateSavedLoop: widget.onActivateSavedLoop,
                        ),
                        const SizedBox(height: 8),
                        PerformancePadsWidget(
                          state: widget.state,
                          side: widget.side,
                          color: widget.side.color,
                          onSetCue: widget.onSetCue,
                          onJumpToCue: widget.onJumpToCue,
                          onDeleteCue: widget.onDeleteCue,
                          onAutoLoop: widget.onLoopLengthChanged,
                          onToggleSlicer: widget.onToggleSlicer,
                          onJumpToSlice: widget.onJumpToSlice,
                          onToggleScratchBank: widget.onToggleScratchBank,
                          onTriggerScratchBank: widget.onTriggerScratchBank,
                          onReleaseScratchBank: widget.onReleaseScratchBank,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Center: Jog Wheel
                Expanded(
                  flex: 5,
                  child: Center(
                    child: JogWheelWidget(
                      state: widget.state,
                      side: widget.side,
                      onSeek: (pos) => widget.onSeek?.call(pos),
                      onScratchStart: () {
                        // We need access to DeckProvider to call pause/startScratch.
                        // Ideally DeckWidget should take a callback for onScratchStart/End
                        // or we check if we have access to the provider.
                        // But DeckWidget receives callbacks, not the provider directly.

                        // We need to add onScratchStart/End to DeckWidget parameters?
                        // Or just assume `onSeek` handles it?
                        // No, the scratch logic (pause/resume) is now in DeckProvider.startScratch.
                        // We should expose this via new callbacks in DeckWidget.

                        // Since I can't easily change the DeckWidget constructor signature in this single Move
                        // without updating the parent (likely DJDeckScreen), I'm stuck.
                        // Wait, I can update DeckWidget constructor here, but I must also update where it's used.

                        // Let's assume for now I will add the callbacks to DeckWidget.
                        widget.onScratchStart?.call();
                      },
                      onScratchEnd: () {
                        widget.onScratchEnd?.call();
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Right: Tempo Slider
                SizedBox(
                  width: 60,
                  child: TempoControlWidget(
                    currentTempo: widget.state.tempo,
                    isKeyLock: widget.state.isKeyLock,
                    originalBPM: widget.state.detectedBPM ?? 120.0,
                    onTempoChanged: widget.onTempoChanged,
                    onKeyLockChanged: widget.onKeyLockChanged,
                    onTapTempo: widget.onTapTempo,
                    onSync: widget.onSync,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 3. Bottom Transport
          SizedBox(
            height: 80,
            child: Row(
              children: [
                // CUE Button
                _buildTransportButton(
                  label: 'CUE',
                  color: Colors.orange,
                  onPressed: widget.onTriggerCue,
                  isActive: widget.state.cuePoint != null,
                ),

                const SizedBox(width: 16),
                // PLAY/PAUSE Button
                _buildTransportButton(
                  label: '',
                  icon: Icons.play_arrow,
                  color: Colors.green,
                  onPressed: widget.state.track == null
                      ? null
                      : (widget.state.isPlaying
                            ? widget.onPause
                            : widget.onPlay),
                  isActive: widget.state.isPlaying,
                ),

                const Spacer(),

                // Load / Eject
                IconButton(
                  icon: const Icon(Icons.eject),
                  color: Colors.white54,
                  onPressed: widget.onLoadTrack,
                  tooltip: 'Load Track',
                ),

                // Beat Jump (Quick)
                _buildBeatJumpIcon(-4, Icons.keyboard_arrow_left),
                _buildBeatJumpIcon(4, Icons.keyboard_arrow_right),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportButton({
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF252525),
          border: Border.all(
            color: isActive ? color : Colors.white24,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            if (isActive)
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 10),
          ],
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(
                icon,
                color: isActive ? Colors.white : Colors.white54,
                size: 32,
              )
            : Text(
                label,
                style: TextStyle(
                  color: isActive ? color.withOpacity(0.9) : Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildWaveform() {
    if (_isLoadingWaveform) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_waveformData == null) {
      return GestureDetector(
        onTap: widget.onLoadTrack,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white38),
              SizedBox(height: 4),
              Text(
                'Load Track',
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }

    return WaveformWidget(
      waveformData: _waveformData!,
      currentPosition: widget.state.position,
      totalDuration: widget.state.duration,
      playedColor: widget.side.color,
      waveColor: Colors.grey.withOpacity(0.3),
      playheadColor: Colors.white,
      height: 60,
      onSeek: (position) {
        widget.onSeek?.call(position);
      },
      ghostPosition: widget.state.isSlipActive
          ? widget.state.slipGhostPosition
          : null,
      slicerSegments: widget.state.isSlicerActive
          ? widget.state.slicerSegments
          : null,
    );
  }

  Widget _buildBeatJumpIcon(int beats, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 20),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => widget.onBeatJump?.call(beats),
          color: Colors.white70,
        ),
        Text(
          beats > 0 ? "+$beats" : "$beats",
          style: const TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildKeyBadge(CamelotKey key) {
    // Pick color based on major/minor
    final Color keyColor = key.isMajor
        ? const Color(0xFFFFD700) // Gold for major
        : const Color(0xFF9F7FFF); // Purple for minor

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: keyColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: keyColor.withOpacity(0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_note, size: 8, color: keyColor),
          const SizedBox(width: 3),
          Text(
            key.camelotCode,
            style: TextStyle(
              color: keyColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            key.shortName,
            style: TextStyle(color: keyColor.withOpacity(0.7), fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
