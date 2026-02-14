import 'package:flutter/material.dart';
import '../../../core/models/deck_state.dart';
import '../../../core/services/waveform_service.dart';
import 'waveform_widget.dart';
import 'tempo_control_widget.dart';
import 'eq_widget.dart';
import 'gain_control_widget.dart';
import '../../../core/audio/effects_processor.dart';
import 'fx_panel_widget.dart';

import 'loop_controls_widget.dart';
import 'stem_controls_widget.dart';
import 'performance_pads_widget.dart';

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
  final ValueChanged<double> onHighEqChanged;
  final ValueChanged<double> onMidEqChanged;
  final ValueChanged<double> onLowEqChanged;
  final ValueChanged<double> onGainChanged;
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
  final ValueChanged<double> onVolumeChanged;

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

  // Phase 2 - Saved Loops
  final VoidCallback onSaveLoop;
  final ValueChanged<String> onDeleteLoop;
  final ValueChanged<SavedLoop> onActivateSavedLoop;

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
    required this.onHighEqChanged,
    required this.onMidEqChanged,
    required this.onLowEqChanged,
    required this.onGainChanged,
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
    required this.onVolumeChanged,
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
      print('Failed to load waveform: $e');
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
        border: Border.all(color: widget.side.color, width: 2),
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1F3A),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with deck label
          Row(
            children: [
              Icon(Icons.album, color: widget.side.color),
              const SizedBox(width: 8),
              Text(
                'DECK ${widget.side.label}',
                style: TextStyle(
                  color: widget.side.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Waveform
          if (widget.state.track != null) _buildWaveform(),

          const SizedBox(height: 16),

          // Track info or load button
          if (widget.state.track == null)
            Center(
              child: ElevatedButton.icon(
                onPressed: widget.onLoadTrack,
                icon: const Icon(Icons.music_note),
                label: const Text('Load Track'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.side.color,
                  foregroundColor: Colors.black, // Visible text
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.state.track!.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.state.track!.artist,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Transport controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  widget.state.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                ),
                iconSize: 64,
                color: widget.side.color,
                onPressed: widget.state.track == null
                    ? null
                    : (widget.state.isPlaying ? widget.onPause : widget.onPlay),
              ),
              IconButton(
                icon: const Icon(Icons.stop),
                iconSize: 36,
                color: Colors.white70,
                onPressed: widget.state.track == null ? null : widget.onStop,
              ),
              // Beat Jump Controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBeatJumpIcon(-8, Icons.fast_rewind),
                  _buildBeatJumpIcon(-4, Icons.keyboard_arrow_left),
                  const SizedBox(width: 4),
                  _buildBeatJumpIcon(4, Icons.keyboard_arrow_right),
                  _buildBeatJumpIcon(8, Icons.fast_forward),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.eject),
                iconSize: 24,
                color: Colors.white30,
                onPressed: widget.onLoadTrack,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Position display
          Center(
            child: Text(
              '${_formatDuration(widget.state.position)} / ${_formatDuration(widget.state.duration)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontFamily: 'monospace',
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tempo Control
          if (widget.state.track != null)
            TempoControlWidget(
              currentTempo: widget.state.tempo,
              isKeyLock: widget.state.isKeyLock,
              originalBPM: widget.state.detectedBPM ?? 120.0,
              onTempoChanged: widget.onTempoChanged,
              onKeyLockChanged: widget.onKeyLockChanged,
              onTapTempo: widget.onTapTempo,
              onSync: widget.onSync,
            ),

          const SizedBox(height: 8),

          // Loop Controls & Slip Mode & Quantize
          Row(
            children: [
              Expanded(
                child: LoopControlsWidget(
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
              ),
              const SizedBox(width: 8),
              // Slip Mode Toggle
              Column(
                children: [
                  const Text(
                    'SLIP',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  Switch(
                    value: widget.state.isSlipActive,
                    onChanged: (_) => widget.onToggleSlipMode(),
                    activeThumbColor: Colors.redAccent,
                    activeTrackColor: Colors.redAccent.withOpacity(0.3),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (widget.state.track != null) ...[
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            // Gain & Neural Mix Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GainControlWidget(
                  gain: widget.state.gain,
                  onChanged: widget.onGainChanged,
                  color: widget.side.color,
                ),
                TextButton.icon(
                  onPressed: widget.onToggleStems,
                  icon: Icon(
                    Icons.layers,
                    size: 16,
                    color: widget.state.isStemsActive
                        ? widget.side.color
                        : Colors.grey,
                  ),
                  label: Text(
                    'NEURAL MIX',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.state.isStemsActive
                          ? widget.side.color
                          : Colors.grey,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // EQ or Stems
            if (widget.state.isStemsActive)
              StemControlsWidget(
                vocals: widget.state.vocalsVolume,
                drums: widget.state.drumsVolume,
                harmonics: widget.state.harmonicsVolume,
                other: widget.state.otherVolume,
                onVocalsChanged: widget.onVocalsVolumeChanged,
                onDrumsChanged: widget.onDrumsVolumeChanged,
                onHarmonicsChanged: widget.onHarmonicsVolumeChanged,
                onOtherChanged: widget.onOtherVolumeChanged,
                color: widget.side.color,
              )
            else
              EQWidget(
                high: widget.state.highEq,
                mid: widget.state.midEq,
                low: widget.state.lowEq,
                onHighChanged: widget.onHighEqChanged,
                onMidChanged: widget.onMidEqChanged,
                onLowChanged: widget.onLowEqChanged,
                color: widget.side.color,
              ),
          ],

          const SizedBox(height: 8),

          const SizedBox(height: 8),

          // FX Panel
          FXPanelWidget(
            currentEffect: widget.state.currentEffect,
            wetDry: widget.state.fxWetDry,
            isActive: widget.state.isFxActive,
            onEffectChanged: widget.onEffectChanged,
            onWetDryChanged: widget.onFxWetDryChanged,
            onActiveChanged: widget.onFxActiveChanged,
            color: widget.side.color,
          ),

          const SizedBox(height: 8),

          const SizedBox(height: 8),

          // Performance Pads (Hot Cue, Loop, Slicer, Sampler)
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
          ),

          const SizedBox(height: 8),

          const SizedBox(height: 8),

          /* Moved Loop Controls up */
          const SizedBox(height: 8),

          // Volume control
          Row(
            children: [
              const Icon(Icons.volume_up, size: 20, color: Colors.white54),
              Expanded(
                child: Slider(
                  value: widget.state.volume,
                  onChanged: (value) {
                    widget.onVolumeChanged(value);
                  },
                  activeColor: widget.side.color,
                  inactiveColor: Colors.white12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    if (_isLoadingWaveform) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(widget.side.color),
            ),
            const SizedBox(height: 8),
            const Text(
              'Analyzing waveform...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_waveformData == null) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Text(
          'No waveform data',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return WaveformWidget(
      waveformData: _waveformData!,
      currentPosition: widget.state.position,
      totalDuration: widget.state.duration,
      playedColor: widget.side.color,
      waveColor: Colors.grey.withOpacity(0.5),
      playheadColor: Colors.white,
      height: 100,
      onSeek: (position) {
        widget.onSeek?.call(position);
      },
      // Pass ghost position if slip is active
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
}
