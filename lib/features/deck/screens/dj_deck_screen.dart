import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/deck_state.dart';
import '../../../core/services/file_service.dart';
import '../providers/deck_provider.dart';
import '../widgets/deck_widget.dart';
import '../widgets/mixer_widget.dart';
import '../widgets/sampler_panel_widget.dart';
import '../widgets/video_mixing_layer.dart';
import '../widgets/camelot_wheel_widget.dart';
import '../../library/screens/library_screen.dart';
import '../widgets/stem_controls_widget.dart';

class DjDeckScreen extends StatefulWidget {
  const DjDeckScreen({super.key});

  @override
  State<DjDeckScreen> createState() => _DjDeckScreenState();
}

class _DjDeckScreenState extends State<DjDeckScreen> {
  bool _isVideoMode = false;
  int _bottomTab = 0; // 0 = Sampler, 1 = Harmonic Mixing

  Future<void> _loadTrackToDeck(BuildContext context, DeckSide side) async {
    final fileService = FileService();
    // Assuming fileService.pickAudioFile is available and returns Track?
    final track = await fileService.pickAudioFile();

    if (track != null && context.mounted) {
      final deckProvider = context.read<DeckProvider>();
      await deckProvider.loadTrackToDeck(side, track);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeckProvider>(
      builder: (context, deckProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E27),
          appBar: AppBar(
            title: const Text('DJ Mode'),
            backgroundColor: const Color(0xFF0A0E27),
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              // Automix Toggle
              IconButton(
                icon: Icon(
                  Icons.auto_mode,
                  color: deckProvider.isAutomixActive
                      ? Colors.blueAccent
                      : Colors.white,
                ),
                tooltip: 'Toggle Automix',
                onPressed: () {
                  deckProvider.toggleAutomix();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        deckProvider.isAutomixActive
                            ? 'Automix Enabled'
                            : 'Automix Disabled',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              // Video Mode Toggle
              IconButton(
                icon: Icon(
                  Icons.videocam,
                  color: _isVideoMode ? Colors.redAccent : Colors.white,
                ),
                tooltip: 'Toggle Video Mode',
                onPressed: () {
                  setState(() {
                    _isVideoMode = !_isVideoMode;
                  });
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.library_music),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LibraryScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Navigate to settings (Placeholder)
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // 1. Video Mixing Layer (Background)
              if (_isVideoMode)
                Positioned.fill(
                  child: VideoMixingLayer(
                    deckA: deckProvider.deckAState,
                    deckB: deckProvider.deckBState,
                    crossfaderPosition: deckProvider.crossfaderPosition,
                    isVideoMode: _isVideoMode,
                  ),
                ),

              // 2. Main Interface (Semi-transparent in Video Mode)
              Opacity(
                opacity: _isVideoMode ? 0.85 : 1.0,
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Decks & Mixer Row
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Deck A
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 4,
                              ),
                              child: _buildDeckWidget(
                                context,
                                deckProvider,
                                DeckSide.A,
                              ),
                            ),
                          ),

                          // Mixer
                          MixerWidget(
                            crossfaderPosition: deckProvider.crossfaderPosition,
                            onCrossfaderChanged:
                                deckProvider.setCrossfaderPosition,
                            masterVolume: deckProvider.masterVolume,
                            onMasterVolumeChanged: deckProvider.setMasterVolume,
                            isSmartFaderActive: deckProvider.isSmartFaderActive,
                            onToggleSmartFader: deckProvider.toggleSmartFader,

                            // Deck A Controls
                            deckAGain: deckProvider.deckAState.gain,
                            onDeckAGainChanged: (val) =>
                                deckProvider.setGain(DeckSide.A, val),
                            deckAHighEq: deckProvider.deckAState.highEq,
                            onDeckAHighEqChanged: (val) =>
                                deckProvider.setHighEq(DeckSide.A, val),
                            deckAMidEq: deckProvider.deckAState.midEq,
                            onDeckAMidEqChanged: (val) =>
                                deckProvider.setMidEq(DeckSide.A, val),
                            deckALowEq: deckProvider.deckAState.lowEq,
                            onDeckALowEqChanged: (val) =>
                                deckProvider.setLowEq(DeckSide.A, val),
                            deckAColorFx: deckProvider.deckAState.fxWetDry,
                            onDeckAColorFxChanged: (val) =>
                                deckProvider.setFxWetDry(DeckSide.A, val),
                            deckAVolume: deckProvider.deckAState.volume,
                            onDeckAVolumeChanged: (val) =>
                                deckProvider.setVolume(DeckSide.A, val),

                            // Deck B Controls
                            deckBGain: deckProvider.deckBState.gain,
                            onDeckBGainChanged: (val) =>
                                deckProvider.setGain(DeckSide.B, val),
                            deckBHighEq: deckProvider.deckBState.highEq,
                            onDeckBHighEqChanged: (val) =>
                                deckProvider.setHighEq(DeckSide.B, val),
                            deckBMidEq: deckProvider.deckBState.midEq,
                            onDeckBMidEqChanged: (val) =>
                                deckProvider.setMidEq(DeckSide.B, val),
                            deckBLowEq: deckProvider.deckBState.lowEq,
                            onDeckBLowEqChanged: (val) =>
                                deckProvider.setLowEq(DeckSide.B, val),
                            deckBColorFx: deckProvider.deckBState.fxWetDry,
                            onDeckBColorFxChanged: (val) =>
                                deckProvider.setFxWetDry(DeckSide.B, val),
                            deckBVolume: deckProvider.deckBState.volume,
                            onDeckBVolumeChanged: (val) =>
                                deckProvider.setVolume(DeckSide.B, val),
                          ),

                          // Deck B
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                right: 16,
                              ),
                              child: _buildDeckWidget(
                                context,
                                deckProvider,
                                DeckSide.B,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Bottom Panel (Sampler / Harmonic)
                    SizedBox(
                      height: 180,
                      child: Column(
                        children: [
                          // Tab row
                          Row(
                            children: [
                              const SizedBox(width: 16),
                              _BottomTab(
                                label: 'SAMPLER',
                                icon: Icons.piano,
                                selected: _bottomTab == 0,
                                onTap: () => setState(() => _bottomTab = 0),
                              ),
                              const SizedBox(width: 4),
                              _BottomTab(
                                label: 'HARMONIC',
                                icon: Icons.music_note,
                                selected: _bottomTab == 1,
                                onTap: () => setState(() => _bottomTab = 1),
                              ),
                              const SizedBox(width: 4),
                              _BottomTab(
                                label: 'NEURAL MIX',
                                icon: Icons.hub_rounded,
                                selected: _bottomTab == 2,
                                onTap: () => setState(() => _bottomTab = 2),
                              ),
                            ],
                          ),
                          // Panel body
                          Expanded(
                            child: _bottomTab == 0
                                ? const SamplerPanelWidget()
                                : _bottomTab == 1
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 4,
                                    ),
                                    child: CamelotWheelWidget(),
                                  )
                                : _buildNeuralMixPanel(deckProvider),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeuralMixPanel(DeckProvider deckProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // Deck A stems
          Expanded(
            child: StemControlsWidget(
              isActive: deckProvider.deckAState.isStemsActive,
              vocals: deckProvider.deckAState.vocalsVolume,
              drums: deckProvider.deckAState.drumsVolume,
              harmonics: deckProvider.deckAState.harmonicsVolume,
              other: deckProvider.deckAState.otherVolume,
              onToggle: () => deckProvider.toggleStemsMode(DeckSide.A),
              onVocalsChanged: (v) =>
                  deckProvider.setStemVolume(DeckSide.A, StemType.vocals, v),
              onDrumsChanged: (v) =>
                  deckProvider.setStemVolume(DeckSide.A, StemType.drums, v),
              onHarmonicsChanged: (v) =>
                  deckProvider.setStemVolume(DeckSide.A, StemType.harmonics, v),
              onOtherChanged: (v) =>
                  deckProvider.setStemVolume(DeckSide.A, StemType.other, v),
              color: DeckSide.A.color,
            ),
          ),
          const SizedBox(width: 8),
          // Deck B stems
          Expanded(
            child: StemControlsWidget(
              isActive: deckProvider.deckBState.isStemsActive,
              vocals: deckProvider.deckBState.vocalsVolume,
              drums: deckProvider.deckBState.drumsVolume,
              harmonics: deckProvider.deckBState.harmonicsVolume,
              other: deckProvider.deckBState.otherVolume,
              onToggle: () => deckProvider.toggleStemsMode(DeckSide.B),
              onVocalsChanged: (v) =>
                  deckProvider.setStemVolume(DeckSide.B, StemType.vocals, v),
              onDrumsChanged: (v) =>
                  deckProvider.setStemVolume(DeckSide.B, StemType.drums, v),
              onHarmonicsChanged: (v) =>
                  deckProvider.setStemVolume(DeckSide.B, StemType.harmonics, v),
              onOtherChanged: (v) =>
                  deckProvider.setStemVolume(DeckSide.B, StemType.other, v),
              color: DeckSide.B.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckWidget(
    BuildContext context,
    DeckProvider deckProvider,
    DeckSide side,
  ) {
    bool isA = side == DeckSide.A;
    return DeckWidget(
      side: side,
      state: isA ? deckProvider.deckAState : deckProvider.deckBState,
      onLoadTrack: () => _loadTrackToDeck(context, side),
      onPlay: () => deckProvider.play(side),
      onPause: () => deckProvider.pause(side),
      onStop: () => deckProvider.stop(side),
      onSeek: (pos) => deckProvider.seek(side, pos),
      onTempoChanged: (val) => deckProvider.setTempo(side, val),
      onKeyLockChanged: (val) => deckProvider.setKeyLock(side, val),
      onTapTempo: () => deckProvider.tapTempo(side),
      onSync: () => deckProvider.syncDeck(side),
      onEffectChanged: (type) => deckProvider.setEffect(side, type),
      onFxWetDryChanged: (val) => deckProvider.setFxWetDry(side, val),
      onFxActiveChanged: (val) => deckProvider.setFxActive(side, val),
      onSetCue: (idx) => deckProvider.setHotCue(side, idx),
      onJumpToCue: (idx) => deckProvider.jumpToHotCue(side, idx),
      onDeleteCue: (idx) => deckProvider.deleteHotCue(side, idx),
      onToggleLoop: () => deckProvider.toggleLoop(side),
      onLoopLengthChanged: (len) => deckProvider.setLoopLength(side, len),
      onLoopIn: () => deckProvider.loopIn(side),
      onLoopOut: () => deckProvider.loopOut(side),
      onToggleStems: () => deckProvider.toggleStemsMode(side),
      onVocalsVolumeChanged: (val) =>
          deckProvider.setStemVolume(side, StemType.vocals, val),
      onDrumsVolumeChanged: (val) =>
          deckProvider.setStemVolume(side, StemType.drums, val),
      onHarmonicsVolumeChanged: (val) =>
          deckProvider.setStemVolume(side, StemType.harmonics, val),
      onOtherVolumeChanged: (val) =>
          deckProvider.setStemVolume(side, StemType.other, val),
      onToggleSlipMode: () => deckProvider.toggleSlipMode(side),
      onToggleQuantize: () => deckProvider.toggleQuantize(side),
      onBeatJump: (beats) => deckProvider.beatJump(side, beats),
      onSaveLoop: () => deckProvider.saveCurrentLoop(side),
      onDeleteLoop: (id) => deckProvider.deleteSavedLoop(side, id),
      onActivateSavedLoop: (loop) => deckProvider.activateSavedLoop(side, loop),
      onToggleSlicer: () => deckProvider.toggleSlicer(side),
      onJumpToSlice: (index) => deckProvider.jumpToSlice(side, index),
      onFxXYChanged: (offset) =>
          deckProvider.setFxXY(side, offset.dx, offset.dy),
      onToggleScratchBank: () => deckProvider.toggleScratchBankMode(side),
      onTriggerScratchBank: (index) =>
          deckProvider.triggerScratchBank(side, index),
      onReleaseScratchBank: (index) =>
          deckProvider.releaseScratchBank(side, index),
      onTriggerCue: () => deckProvider.triggerCue(side),
    );
  }
}

class _BottomTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _BottomTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF00D9FF) : Colors.white38;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF00D9FF).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border(
            bottom: BorderSide(
              color: selected ? const Color(0xFF00D9FF) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
