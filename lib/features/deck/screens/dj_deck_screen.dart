import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/deck_state.dart';
import '../../../core/services/file_service.dart';
import '../providers/deck_provider.dart';
import '../widgets/deck_widget.dart';
import '../widgets/mixer_widget.dart';
import '../widgets/sampler_panel_widget.dart';
import '../widgets/video_mixing_layer.dart';
import '../../library/screens/library_screen.dart';

class DjDeckScreen extends StatefulWidget {
  const DjDeckScreen({super.key});

  @override
  State<DjDeckScreen> createState() => _DjDeckScreenState();
}

class _DjDeckScreenState extends State<DjDeckScreen> {
  bool _isVideoMode = false;

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

                    const SizedBox(height: 16),

                    // Sampler Panel
                    const SamplerPanelWidget(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
      onHighEqChanged: (val) => deckProvider.setHighEq(side, val),
      onMidEqChanged: (val) => deckProvider.setMidEq(side, val),
      onLowEqChanged: (val) => deckProvider.setLowEq(side, val),
      onGainChanged: (val) => deckProvider.setGain(side, val),
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
      onVolumeChanged: (val) => deckProvider.setVolume(side, val),
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
    );
  }
}
