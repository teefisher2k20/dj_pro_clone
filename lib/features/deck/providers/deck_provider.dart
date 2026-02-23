import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/audio/audio_engine.dart';
import '../../../core/models/deck_state.dart';
import '../../../core/models/track.dart';
import '../../../core/services/audio_analysis_service.dart';
import '../../../core/audio/sync_engine.dart';
import '../../../core/audio/effects_processor.dart';
import '../../../core/services/midi_service.dart';
import '../../../core/services/key_matching_service.dart';

class DeckProvider extends ChangeNotifier {
  final AudioEngine _audioEngine = AudioEngine.instance;
  final AudioAnalysisService _audioAnalysisService = AudioAnalysisService();
  final SyncEngine _syncEngine = SyncEngine();
  final List<StreamSubscription> _subscriptions = [];

  DeckState _deckAState = DeckState(side: DeckSide.A);
  late DeckState
  _deckBState; // Initialized in constructor to avoid late error if accessed early

  double _crossfaderPosition = 0.0; // -1.0 to 1.0
  double _masterVolume = 1.0;
  bool _isAutomixActive = false;
  bool _isTransitioning = false;
  bool _isSmartFaderActive = false;

  DeckProvider() {
    _deckBState = DeckState(side: DeckSide.B);
  }

  // Default Scratch Banks
  final List<ScratchBank> _defaultScratchBanks = [
    ScratchBank(
      label: 'Ahhh',
      filePath: 'assets/samples/scratch_ahhh.mp3',
      color: Colors.purpleAccent,
    ),
    ScratchBank(
      label: 'Fresh',
      filePath: 'assets/samples/scratch_fresh.mp3',
      color: Colors.purpleAccent,
    ),
    ScratchBank(
      label: 'Yeah',
      filePath: 'assets/samples/scratch_yeah.mp3',
      color: Colors.purpleAccent,
    ),
    ScratchBank(
      label: 'Hit',
      filePath: 'assets/samples/scratch_hit.mp3',
      color: Colors.purpleAccent,
    ),
    ScratchBank(
      label: 'Uhh',
      filePath: 'assets/samples/scratch_uhh.mp3',
      color: Colors.purpleAccent,
    ),
    ScratchBank(
      label: 'Horn',
      filePath: 'assets/samples/scratch_horn.mp3',
      color: Colors.purpleAccent,
    ),
    ScratchBank(
      label: 'Siren',
      filePath: 'assets/samples/scratch_siren.mp3',
      color: Colors.purpleAccent,
    ),
    ScratchBank(
      label: 'Laser',
      filePath: 'assets/samples/scratch_laser.mp3',
      color: Colors.purpleAccent,
    ),
  ];

  DeckState get deckAState => _deckAState;
  DeckState get deckBState => _deckBState;
  double get crossfaderPosition => _crossfaderPosition;
  double get masterVolume => _masterVolume;
  bool get isAutomixActive => _isAutomixActive;
  bool get isSmartFaderActive => _isSmartFaderActive;

  // Initialize provider
  Future<void> initialize() async {
    await _audioEngine.initialize();
    _listenToDeckUpdates();

    // MIDI Listener
    _subscriptions.add(
      MidiService.instance.eventStream.listen(_handleMidiEvent),
    );

    // await _updateEffectiveVolumes(); // Deprecated, handled by Mixer
    if (_isSmartFaderActive) {
      _applySmartFader();
    }
  }

  // Listen to deck changes
  void _listenToDeckUpdates() {
    // Cancel any existing subscriptions
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();

    // Deck A Listeners
    _subscriptions.add(
      _audioEngine.deckA.playerStateStream.listen((state) {
        _deckAState = _deckAState.copyWith(isPlaying: state.playing);
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _audioEngine.deckA.positionStream.listen((position) {
        _deckAState = _deckAState.copyWith(position: position);
        _checkAutomix(DeckSide.A);
        // Fluid Grid Check
        _checkFluidBpm(DeckSide.A, position);
        // Update Ghost if Slip is Active
        if (_deckAState.isSlipActive) _updateGhostPosition(DeckSide.A);
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _audioEngine.deckA.durationStream.listen((duration) {
        if (duration != null) {
          _deckAState = _deckAState.copyWith(duration: duration);
          notifyListeners();
        }
      }),
    );

    // Deck B Listeners
    _subscriptions.add(
      _audioEngine.deckB.playerStateStream.listen((state) {
        _deckBState = _deckBState.copyWith(isPlaying: state.playing);
        notifyListeners();
      }),
    );

    // Note: We need to be careful not to cycle-update if we are the ones pausing for scratch.
    // The streams will update the state, which is fine.

    _subscriptions.add(
      _audioEngine.deckB.positionStream.listen((position) {
        _deckBState = _deckBState.copyWith(position: position);
        _checkAutomix(DeckSide.B);
        // Fluid Grid Check
        _checkFluidBpm(DeckSide.B, position);
        if (_deckBState.isSlipActive) _updateGhostPosition(DeckSide.B);
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _audioEngine.deckB.durationStream.listen((duration) {
        if (duration != null) {
          _deckBState = _deckBState.copyWith(duration: duration);
          notifyListeners();
        }
      }),
    );
  }

  // Load track to specific deck
  Future<void> loadTrackToDeck(DeckSide side, Track track) async {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;

    // Load track
    await deck.loadTrack(track);

    // Initial state update
    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(
        track: track,
        tempo: 1.0,
        isKeyLock: false,
        detectedBPM: null,
        volume: 1.0, // Initialize volume
      );
      // Init Scratch Banks
      if (_deckAState.scratchBanks.isEmpty) {
        _deckAState = _deckAState.copyWith(scratchBanks: _defaultScratchBanks);
      }
      notifyListeners();
    } else {
      _deckBState = _deckBState.copyWith(
        track: track,
        tempo: 1.0,
        isKeyLock: false,
        detectedBPM: null,
        volume: 1.0, // Initialize volume
      );
      // Init Scratch Banks
      if (_deckBState.scratchBanks.isEmpty) {
        _deckBState = _deckBState.copyWith(scratchBanks: _defaultScratchBanks);
      }
      notifyListeners();
    }

    // Detect BPM (simulated)
    // In real app, check if track.bpm is already set.
    if (track.bpm == null) {
      final bpm = await _audioAnalysisService.detectBPM(track.filePath);
      if (side == DeckSide.A) {
        _deckAState = _deckAState.copyWith(detectedBPM: bpm);
      } else {
        _deckBState = _deckBState.copyWith(detectedBPM: bpm);
      }
      notifyListeners();
    } else {
      if (side == DeckSide.A) {
        _deckAState = _deckAState.copyWith(detectedBPM: track.bpm);
      } else {
        _deckBState = _deckBState.copyWith(detectedBPM: track.bpm);
      }
      notifyListeners();
    }

    // Detect Musical Key (simulated — async, non-blocking)
    _audioAnalysisService.detectKey(track.filePath).then((key) {
      if (side == DeckSide.A) {
        _deckAState = _deckAState.copyWith(detectedKey: key);
      } else {
        _deckBState = _deckBState.copyWith(detectedKey: key);
      }
      notifyListeners();
    });
  }

  // Playback controls
  void play(DeckSide side) {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    final state = side == DeckSide.A ? _deckAState : _deckBState;

    deck.play();

    if (state.isSlipActive) {
      _startGhostTracking(side);
    }
  }

  void pause(DeckSide side) {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    deck.pause();
    _stopGhostTracking(side);
  }

  void stop(DeckSide side) {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    deck.stop();
    _stopGhostTracking(side);
  }

  Future<void> seek(DeckSide side, Duration position) async {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    await deck.seek(position);
  }

  // Scratching
  bool _wasPlayingBeforeScratchA = false;
  bool _wasPlayingBeforeScratchB = false;

  void startScratch(DeckSide side) {
    // If playing, pause to allow smooth seeking/scratching
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    if (state.isPlaying) {
      if (side == DeckSide.A) {
        _wasPlayingBeforeScratchA = true;
      } else {
        _wasPlayingBeforeScratchB = true;
      }
      pause(side);
    } else {
      if (side == DeckSide.A) {
        _wasPlayingBeforeScratchA = false;
      } else {
        _wasPlayingBeforeScratchB = false;
      }
    }
  }

  void endScratch(DeckSide side) {
    // Resume if it was playing
    bool wasPlaying = side == DeckSide.A
        ? _wasPlayingBeforeScratchA
        : _wasPlayingBeforeScratchB;
    if (wasPlaying) {
      play(side);
    }
  }

  Future<void> beatJump(DeckSide side, int beats) async {
    // Jump forward or backward by N beats
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    if (state.track == null || state.detectedBPM == null) return;

    final bpm = state.detectedBPM!;
    if (bpm <= 0) return;

    final beatDurMs = 60000.0 / bpm;
    final jumpAmountMs = (beatDurMs * beats).round();

    final currentPos = state.position;
    var targetPos = currentPos + Duration(milliseconds: jumpAmountMs);

    // Clamp to duration
    if (targetPos < Duration.zero) targetPos = Duration.zero;
    if (targetPos > state.duration) targetPos = state.duration;

    // If Quantize is active, snap the target
    if (state.isQuantizeActive) {
      targetPos = _getQuantizedPosition(targetPos, bpm);
    }

    await seek(side, targetPos);

    // If Slip Mode is active, the "ghost" continues unaffected.
    // The "real" playhead (which we just moved) is now at the new position.
    // When we release slip, it should jump back to where the ghost is.
    // Wait... standard Slip Mode behavior with Beat Jump:
    // If I beat jump +4 beats, I hear the future.
    // If successful, the ghost continues linearly.
    // When I release slip, it returns to ghost.
    // This is already handled because _updateGhostPosition runs on timer/position updates
    // but relies on _slipStartTimes.
    // Actually, simple seeking in Slip Mode moves the PLAYHEAD, but the GHOST is just time-based.
    // So if we seek, the ghost calculation:
    // ghost = startPos + elapsed * tempo
    // It remains correct regardless of where playhead is.
    // So Beat Jump works automatically with Slip Mode!
  }

  // Tempo & Key Lock
  Future<void> setTempo(DeckSide side, double tempo) async {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    await deck.setTempo(tempo);

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(tempo: tempo);
    } else {
      _deckBState = _deckBState.copyWith(tempo: tempo);
    }
    notifyListeners();
  }

  Future<void> setKeyLock(DeckSide side, bool enabled) async {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    await deck.setKeyLock(enabled);

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(isKeyLock: enabled);
    } else {
      _deckBState = _deckBState.copyWith(isKeyLock: enabled);
    }
    notifyListeners();
  }

  void tapTempo(DeckSide side) {
    // Basic tap tempo placeholder
    // In real implementation, measure interval between taps and update BPM/tempo.
    print('Tap Tempo on Deck ${side.name}');
  }

  // Sync
  Future<void> syncDeck(DeckSide targetSide) async {
    // sourceSide was unused.
    final sourceState = targetSide == DeckSide.A ? _deckBState : _deckAState;
    final targetState = targetSide == DeckSide.A ? _deckAState : _deckBState;

    if (sourceState.track == null || targetState.track == null) return;

    // Get BPMs. Fallback to 120 if missing.
    final sourceBpm = sourceState.detectedBPM ?? 120.0;
    final targetBpm = targetState.detectedBPM ?? 120.0;

    final targetController = targetSide == DeckSide.A
        ? _audioEngine.deckA
        : _audioEngine.deckB;

    // Perform sync (Phrase Sync)
    final double newTempo = await _syncEngine.syncTempoWithPhase(
      target: targetController,
      sourceBpm: sourceBpm,
      targetBpm: targetBpm,
      sourceTempo: sourceState.tempo,
      sourcePosition: sourceState.position,
      targetPosition: targetState.position,
    );

    // Update state
    if (targetSide == DeckSide.A) {
      _deckAState = _deckAState.copyWith(tempo: newTempo);
    } else {
      _deckBState = _deckBState.copyWith(tempo: newTempo);
    }
    notifyListeners();
  }

  // EQ Controls
  Future<void> setHighEq(DeckSide side, double val) async {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    await deck.setHighEq(val);

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(highEq: val);
    } else {
      _deckBState = _deckBState.copyWith(highEq: val);
    }
    notifyListeners();
  }

  Future<void> setMidEq(DeckSide side, double val) async {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    await deck.setMidEq(val);

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(midEq: val);
    } else {
      _deckBState = _deckBState.copyWith(midEq: val);
    }
    notifyListeners();
  }

  Future<void> setLowEq(DeckSide side, double val) async {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    await deck.setLowEq(val);

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(lowEq: val);
    } else {
      _deckBState = _deckBState.copyWith(lowEq: val);
    }
    notifyListeners();
  }

  Future<void> setGain(DeckSide side, double val) async {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    await deck.setGain(val);

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(gain: val);
    } else {
      _deckBState = _deckBState.copyWith(gain: val);
    }
    notifyListeners();
  }

  // FX Controls
  Future<void> setEffect(DeckSide side, AudioEffectType type) async {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    await deck.setEffect(type);

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(currentEffect: type);
    } else {
      _deckBState = _deckBState.copyWith(currentEffect: type);
    }
    notifyListeners();
  }

  Future<void> setFxWetDry(DeckSide side, double val) async {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    await deck.setFxWetDry(val);

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(fxWetDry: val);
    } else {
      _deckBState = _deckBState.copyWith(fxWetDry: val);
    }
    notifyListeners();
  }

  Future<void> setFxActive(DeckSide side, bool active) async {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    await deck.setFxActive(active);

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(isFxActive: active);
    } else {
      _deckBState = _deckBState.copyWith(isFxActive: active);
    }
    notifyListeners();
  }

  Future<void> setFxXY(DeckSide side, double x, double y) async {
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    await deck.setFxXY(x, y);

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(fxX: x, fxY: y);
    } else {
      _deckBState = _deckBState.copyWith(fxX: x, fxY: y);
    }
    notifyListeners();
  }

  // Hot Cues
  void setHotCue(DeckSide side, int index) {
    if (side == DeckSide.A) {
      final cues = List<Duration?>.from(_deckAState.hotCues);
      if (index < cues.length) {
        cues[index] = _deckAState.position;
        _deckAState = _deckAState.copyWith(hotCues: cues);
      }
    } else {
      final cues = List<Duration?>.from(_deckBState.hotCues);
      if (index < cues.length) {
        cues[index] = _deckBState.position;
        _deckBState = _deckBState.copyWith(hotCues: cues);
      }
    }
    notifyListeners();
  }

  // Main Cue Point Logic
  Future<void> triggerCue(DeckSide side) async {
    final state = side == DeckSide.A ? _deckAState : _deckBState;

    if (state.isPlaying) {
      // If playing, pause and jump to CUE
      if (state.cuePoint != null) {
        pause(side);
        await seek(side, state.cuePoint!);
      } else {
        // If no cue, just pause? Or pause and set cue?
        // Standard is: Pause.
        pause(side);
      }
    } else {
      // If paused
      if (state.cuePoint == null) {
        // Set Cue
        if (side == DeckSide.A) {
          _deckAState = _deckAState.copyWith(cuePoint: state.position);
        } else {
          _deckBState = _deckBState.copyWith(cuePoint: state.position);
        }
      } else {
        // Jump to Cue
        await seek(side, state.cuePoint!);
        // If holding... (requires separate press/release logic)
        // For simple trigger: just jump.
      }
    }
    notifyListeners();
  }

  void setCuePoint(DeckSide side) {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(cuePoint: state.position);
    } else {
      _deckBState = _deckBState.copyWith(cuePoint: state.position);
    }
    notifyListeners();
  }

  Future<void> jumpToHotCue(DeckSide side, int index) async {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    if (index < state.hotCues.length && state.hotCues[index] != null) {
      await seek(side, state.hotCues[index]!);
      // If pressing jump while paused, play? Usually yes or "On Play".
      // Let's assume just seek for now.
      // If playing, it continues playing from there.
    }
  }

  void deleteHotCue(DeckSide side, int index) {
    if (side == DeckSide.A) {
      final cues = List<Duration?>.from(_deckAState.hotCues);
      if (index < cues.length) {
        cues[index] = null;
        _deckAState = _deckAState.copyWith(hotCues: cues);
      }
    } else {
      final cues = List<Duration?>.from(_deckBState.hotCues);
      if (index < cues.length) {
        cues[index] = null;
        _deckBState = _deckBState.copyWith(hotCues: cues);
      }
    }
    notifyListeners();
  }

  // Looping
  void toggleLoop(DeckSide side) {
    if (side == DeckSide.A) {
      final active = !_deckAState.isLoopActive;
      _deckAState = _deckAState.copyWith(isLoopActive: active);
      if (active) {
        _activateAutoLoop(DeckSide.A);
      } else {
        // Deactivated
        if (_deckAState.isSlipActive) {
          releaseSlip(DeckSide.A);
        }
      }
    } else {
      final active = !_deckBState.isLoopActive;
      _deckBState = _deckBState.copyWith(isLoopActive: active);
      if (active) {
        _activateAutoLoop(DeckSide.B);
      } else {
        // Deactivated
        if (_deckBState.isSlipActive) {
          releaseSlip(DeckSide.B);
        }
      }
    }
    notifyListeners();
  }

  void _activateAutoLoop(DeckSide side) {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    final bpm = state.detectedBPM ?? 120.0;
    final beatDuration = 60.0 / bpm;
    final loopDuration = Duration(
      milliseconds: (state.loopLength * beatDuration * 1000).round(),
    );

    // Quantize In Point if active
    Duration inPoint = state.position;
    if (state.isQuantizeActive) {
      inPoint = _getQuantizedPosition(inPoint, bpm);
    }

    final outPoint = inPoint + loopDuration;

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(
        loopInPoint: inPoint,
        loopOutPoint: outPoint,
      );
    } else {
      _deckBState = _deckBState.copyWith(
        loopInPoint: inPoint,
        loopOutPoint: outPoint,
      );
    }
    // In real implementation, tell audio engine to loop this region
  }

  void setLoopLength(DeckSide side, double length) {
    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(loopLength: length);
      if (_deckAState.isLoopActive) {
        _activateAutoLoop(
          DeckSide.A,
        ); // Re-calculate out point based on new length
      }
    } else {
      _deckBState = _deckBState.copyWith(loopLength: length);
      if (_deckBState.isLoopActive) {
        _activateAutoLoop(DeckSide.B);
      }
    }
    notifyListeners();
  }

  void loopIn(DeckSide side) {
    // Manual Loop In
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    var pos = state.position;

    if (state.isQuantizeActive) {
      final bpm = state.detectedBPM ?? 120.0;
      pos = _getQuantizedPosition(pos, bpm);
    }

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(loopInPoint: pos);
    } else {
      _deckBState = _deckBState.copyWith(loopInPoint: pos);
    }
    notifyListeners();
  }

  void loopOut(DeckSide side) {
    // Manual Loop Out & Activate
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    var pos = state.position;

    if (state.isQuantizeActive) {
      final bpm = state.detectedBPM ?? 120.0;
      pos = _getQuantizedPosition(pos, bpm);
    }

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(loopOutPoint: pos, isLoopActive: true);
    } else {
      _deckBState = _deckBState.copyWith(loopOutPoint: pos, isLoopActive: true);
    }
    notifyListeners();
  }

  // Volume control (Channel Fader)
  Future<void> setVolume(DeckSide side, double volume) async {
    // Determine target deck
    // Note: This sets the "Channel Volume" which Mixer uses.
    // It updates State for UI slider.

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(volume: volume);
    } else {
      _deckBState = _deckBState.copyWith(volume: volume);
    }

    _audioEngine.mixer.setChannelVolume(side, volume);
    notifyListeners();
  }

  // Stem Controls
  void toggleStemsMode(DeckSide side) {
    if (side == DeckSide.A) {
      final active = !_deckAState.isStemsActive;
      _deckAState = _deckAState.copyWith(isStemsActive: active);
      if (!active) {
        // Reset Simulation (Restore flat EQ for simplicity when exiting)
        // ideally recall previous EQ.
        setLowEq(side, 0.5);
        setMidEq(side, 0.5);
        setHighEq(side, 0.5);
      } else {
        _applyStemSimulation(side);
      }
    } else {
      final active = !_deckBState.isStemsActive;
      _deckBState = _deckBState.copyWith(isStemsActive: active);
      if (!active) {
        setLowEq(side, 0.5);
        setMidEq(side, 0.5);
        setHighEq(side, 0.5);
      } else {
        _applyStemSimulation(side);
      }
    }
    notifyListeners();
  }

  Future<void> setStemVolume(
    DeckSide side,
    StemType type,
    double volume,
  ) async {
    if (side == DeckSide.A) {
      switch (type) {
        case StemType.vocals:
          _deckAState = _deckAState.copyWith(vocalsVolume: volume);
          break;
        case StemType.drums:
          _deckAState = _deckAState.copyWith(drumsVolume: volume);
          break;
        case StemType.harmonics:
          _deckAState = _deckAState.copyWith(harmonicsVolume: volume);
          break;
        case StemType.other:
          _deckAState = _deckAState.copyWith(otherVolume: volume);
          break;
      }
    } else {
      switch (type) {
        case StemType.vocals:
          _deckBState = _deckBState.copyWith(vocalsVolume: volume);
          break;
        case StemType.drums:
          _deckBState = _deckBState.copyWith(drumsVolume: volume);
          break;
        case StemType.harmonics:
          _deckBState = _deckBState.copyWith(harmonicsVolume: volume);
          break;
        case StemType.other:
          _deckBState = _deckBState.copyWith(otherVolume: volume);
          break;
      }
    }

    await _applyStemSimulation(side);
    notifyListeners();
  }

  Future<void> _applyStemSimulation(DeckSide side) async {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    if (!state.isStemsActive) return;

    // Simulate Stem Separation via EQ
    // Drums -> Low Freq focus
    // Harmonics -> Low-Mid
    // Vocals -> High-Mid
    // Other -> High

    // Mapping Logic (Approximate)
    // Low EQ = Drums (mostly) + some Harmonics
    final double low = (state.drumsVolume * 0.8 + state.harmonicsVolume * 0.2)
        .clamp(0.0, 1.0);

    // Mid EQ = Harmonics (mostly) + Vocals (lower range)
    final double mid = (state.harmonicsVolume * 0.6 + state.vocalsVolume * 0.4)
        .clamp(0.0, 1.0);

    // High EQ = Vocals (mostly) + Other (cymbals/air)
    final double high = (state.vocalsVolume * 0.6 + state.otherVolume * 0.4)
        .clamp(0.0, 1.0);

    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;

    // Apply without updating state.highEq directly to avoid circular UI updates?
    // Actually we WANT UI to reflect these changes if we are reusing EQ knobs in EQ mode?
    // But in Stems Mode, EQ knobs are hidden.
    // So application to Audio Engine is key.

    await deck.setLowEq(low);
    await deck.setMidEq(mid);
    await deck.setHighEq(high);

    // Note: We do NOT update _deckAState.highEq here, because that would change the stored "Manual EQ" value.
    // However, since DeckController is what drives the audio, and DeckProvider updates State based on calls...
    // If we call deck.setLowEq, it changes the audio.
    // We are deliberately NOT updating the provider's `lowEq` state so that when we toggle back,
    // we can (conceptually) restore it.
    // BUT we are using setLowEq definition from THIS provider in togglestemsmode to reset.
    // It calls `deck.setLowEq`.
  }

  // Smart Fader / Crossfader control
  void toggleSmartFader() {
    _isSmartFaderActive = !_isSmartFaderActive;
    notifyListeners();
  }

  void setCrossfaderPosition(double position) {
    _crossfaderPosition = position;
    _audioEngine.mixer.setCrossfaderPosition(position);

    if (_isSmartFaderActive) {
      _applySmartFader();
    }

    notifyListeners();
  }

  void _applySmartFader() {
    // Logic:
    // -1.0 (Left, A is full, B is silent) to 1.0 (Right, B is full, A is silent)
    // When moving away from a deck, High Pass Filter increases (cutting bass).
    // When moving towards a deck, starts with High Pass and reduces to 0.

    final pos = _crossfaderPosition;

    // Filter Calculation
    // Range 0.0 (No Filter) to 1.0 (Max Filter)

    double filterA = 0.0;
    double filterB = 0.0;

    if (pos > -0.8) {
      // Moving right, leaving A. Increase A filter.
      // Map -0.8 ... 1.0 to 0.0 ... 1.0
      filterA = ((pos + 0.8) / 1.8).clamp(0.0, 1.0);
    }

    if (pos < 0.8) {
      // Moving left, leaving B. Increase B filter.
      // Map 0.8 ... -1.0 to 0.0 ... 1.0
      // Invert pos for calculation
      filterB = ((0.8 - pos) / 1.8).clamp(0.0, 1.0);
    }

    // Apply (Simulating HPF via Low EQ cut)
    // If filter is high (1.0), Low EQ should be 0.0 (Cut).
    // If filter is low (0.0), Low EQ should be 0.5 (Neutral) or untouched.
    // NOTE: This overrides manual EQ. That's expected for Smart Fader.

    final lowEqA = 0.5 * (1 - filterA);
    final lowEqB = 0.5 * (1 - filterB);

    // Apply
    _audioEngine.deckA.setLowEq(lowEqA);
    _audioEngine.deckB.setLowEq(lowEqB);

    // Update State (so UI knobs turn automatically!)
    _deckAState = _deckAState.copyWith(lowEq: lowEqA);
    _deckBState = _deckBState.copyWith(lowEq: lowEqB);
  }

  // Master Volume control
  void setMasterVolume(double volume) {
    _masterVolume = volume;
    _audioEngine.mixer.setMasterVolume(volume);
    notifyListeners();
  }

  // Automix
  void toggleAutomix() {
    _isAutomixActive = !_isAutomixActive;
    notifyListeners();
  }

  void _checkFluidBpm(DeckSide side, Duration position) {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    if (state.track == null || state.track!.bpmMap == null) return;

    // Find current BPM segment
    final map = state.track!.bpmMap!;
    // Simple lookup: find latest key <= current position
    final seconds = position.inMilliseconds / 1000.0;

    double? currentBpm;
    // Sort keys (assuming sorted, but map order isn't guaranteed in all implementations)
    final keys = map.keys.toList()..sort();

    for (final key in keys) {
      if (key <= seconds) {
        currentBpm = map[key];
      } else {
        break;
      }
    }

    if (currentBpm != null && currentBpm != state.detectedBPM) {
      // Update detected BPM dynamically!
      if (side == DeckSide.A) {
        _deckAState = _deckAState.copyWith(detectedBPM: currentBpm);
      } else {
        _deckBState = _deckBState.copyWith(detectedBPM: currentBpm);
      }
      // Note: If synced, SyncEngine logic in the loop needs to adjust tempo slider or internal speed to maintain lock.
      // This is complex. For now, we update the display.
    }
  }

  void _checkAutomix(DeckSide activeSide) {
    if (!_isAutomixActive || _isTransitioning) return;

    final state = activeSide == DeckSide.A ? _deckAState : _deckBState;
    if (!state.isPlaying || state.duration == Duration.zero) return;

    final remaining = state.duration - state.position;
    // Trigger 10s before end
    if (remaining.inSeconds <= 10 && remaining.inSeconds > 0) {
      _startAutomixTransition(activeSide);
    }
  }

  Future<void> _startAutomixTransition(DeckSide fromSide) async {
    _isTransitioning = true;
    final toSide = fromSide == DeckSide.A ? DeckSide.B : DeckSide.A;
    final toState = toSide == DeckSide.A ? _deckAState : _deckBState;

    if (toState.track == null) {
      // Cannot transition if no track.
      // Maybe try to load one? For now, just stop.
      _isTransitioning = false;
      return;
    }

    // 1. Sync
    await syncDeck(toSide);

    // 2. Start Playing Target
    play(toSide);

    // 3. Animate Crossfader
    // Target position: if A->B, target is 1.0. If B->A, target is -1.0.
    final targetPos = fromSide == DeckSide.A ? 1.0 : -1.0;
    final startPos = _crossfaderPosition;

    // Duration: 10 seconds? Or remaining duration?
    // Let's do 8 seconds to be safe.
    const steps = 80;
    const interval = Duration(milliseconds: 100);
    final stepSize = (targetPos - startPos) / steps;

    for (int i = 0; i < steps; i++) {
      if (!_isAutomixActive) break; // Allow cancel

      final newPos = startPos + (stepSize * (i + 1));
      setCrossfaderPosition(newPos.clamp(-1.0, 1.0));
      await Future.delayed(interval);
    }

    // Ensure final position
    if (_isAutomixActive) {
      setCrossfaderPosition(targetPos);
    }

    _isTransitioning = false;
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
    _audioEngine.dispose();
    super.dispose();
  }

  // Phase 2 - Slip Mode
  void toggleSlipMode(DeckSide side) {
    if (side == DeckSide.A) {
      final active = !_deckAState.isSlipActive;
      if (!active) {
        releaseSlip(DeckSide.A);
      }
      _deckAState = _deckAState.copyWith(isSlipActive: active);
      if (active) {
        _startGhostTracking(DeckSide.A);
      } else {
        _stopGhostTracking(DeckSide.A);
      }
    } else {
      final active = !_deckBState.isSlipActive;
      if (!active) {
        releaseSlip(DeckSide.B);
      }
      _deckBState = _deckBState.copyWith(isSlipActive: active);
      if (active) {
        _startGhostTracking(DeckSide.B);
      } else {
        _stopGhostTracking(DeckSide.B);
      }
    }
    notifyListeners();
  }

  final Map<DeckSide, DateTime?> _slipStartTimes = {
    DeckSide.A: null,
    DeckSide.B: null,
  };
  final Map<DeckSide, Duration> _slipStartPositions = {
    DeckSide.A: Duration.zero,
    DeckSide.B: Duration.zero,
  };

  // Phase 2 - Saved Loops
  void saveCurrentLoop(DeckSide side) {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    if (!state.isLoopActive ||
        state.loopInPoint == null ||
        state.loopOutPoint == null) {
      return;
    }

    final newLoop = SavedLoop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "Loop ${state.savedLoops.length + 1}",
      start: state.loopInPoint!,
      end: state.loopOutPoint!,
      color: side.color,
    );

    final updatedLoops = List<SavedLoop>.from(state.savedLoops)..add(newLoop);

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(savedLoops: updatedLoops);
    } else {
      _deckBState = _deckBState.copyWith(savedLoops: updatedLoops);
    }
    notifyListeners();
  }

  void deleteSavedLoop(DeckSide side, String loopId) {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    final updatedLoops = state.savedLoops.where((l) => l.id != loopId).toList();

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(savedLoops: updatedLoops);
    } else {
      _deckBState = _deckBState.copyWith(savedLoops: updatedLoops);
    }
    notifyListeners();
  }

  Future<void> activateSavedLoop(DeckSide side, SavedLoop loop) async {
    // Jump to start and activate loop

    // 1. Jump
    await seek(side, loop.start);

    // 2. Set Loop Points
    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(
        loopInPoint: loop.start,
        loopOutPoint: loop.end,
        isLoopActive: true,
      );
    } else {
      _deckBState = _deckBState.copyWith(
        loopInPoint: loop.start,
        loopOutPoint: loop.end,
        isLoopActive: true,
      );
    }
    notifyListeners();
    // In real engine, we'd send loop command
  }

  void _startGhostTracking(DeckSide side) {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    if (!state.isPlaying) return; // Only relevant if playing

    _slipStartTimes[side] = DateTime.now();
    _slipStartPositions[side] = state.position;
  }

  void _stopGhostTracking(DeckSide side) {
    _slipStartTimes[side] = null;
    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(slipGhostPosition: null);
    } else {
      _deckBState = _deckBState.copyWith(slipGhostPosition: null);
    }
  }

  void _updateGhostPosition(DeckSide side) {
    final startTime = _slipStartTimes[side];
    if (startTime == null) return;

    final state = side == DeckSide.A ? _deckAState : _deckBState;
    if (!state.isSlipActive || !state.isPlaying) return;

    final elapsed = DateTime.now().difference(startTime);
    final elapsedAdjusted = elapsed * state.tempo;

    final ghostPos = _slipStartPositions[side]! + elapsedAdjusted;

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(slipGhostPosition: ghostPos);
    } else {
      _deckBState = _deckBState.copyWith(slipGhostPosition: ghostPos);
    }
  }

  // Phase 2 - Quantize Loop
  void toggleQuantize(DeckSide side) {
    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(
        isQuantizeActive: !_deckAState.isQuantizeActive,
      );
    } else {
      _deckBState = _deckBState.copyWith(
        isQuantizeActive: !_deckBState.isQuantizeActive,
      );
    }
    notifyListeners();
  }

  Duration _getQuantizedPosition(Duration target, double bpm) {
    // Snap to nearest beat
    // Beat duration in milliseconds
    if (bpm <= 0) return target;

    final beatDurMs = 60000.0 / bpm;
    final currentMs = target.inMilliseconds.toDouble();

    // Nearest beat index
    final beatIndex = (currentMs / beatDurMs).round();
    final snappedMs = beatIndex * beatDurMs;

    return Duration(milliseconds: snappedMs.toInt());
  }

  Future<void> releaseSlip(DeckSide side) async {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    if (!state.isSlipActive || state.slipGhostPosition == null) return;

    await seek(side, state.slipGhostPosition!);

    if (!state.isPlaying) {
      play(side);
    }
  }

  // Phase 2 - Slicer Mode
  void toggleSlicer(DeckSide side) {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    final active = !state.isSlicerActive;

    if (active) {
      _activateSlicer(side);
    } else {
      if (side == DeckSide.A) {
        _deckAState = _deckAState.copyWith(
          isSlicerActive: false,
          slicerSegments: null,
        );
      } else {
        _deckBState = _deckBState.copyWith(
          isSlicerActive: false,
          slicerSegments: null,
        );
      }
    }
    notifyListeners();
  }

  void _activateSlicer(DeckSide side) {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    final bpm = state.detectedBPM ?? 120.0;
    final beatDuration = 60.0 / bpm;

    // Slicer divides next 8 beats into 8 segments
    final startPos = state.position;
    final List<Duration> segments = [];

    for (int i = 0; i < 8; i++) {
      final segmentOffset = Duration(
        milliseconds: (i * beatDuration * 1000).round(),
      );
      segments.add(startPos + segmentOffset);
    }

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(
        isSlicerActive: true,
        slicerSegments: segments,
      );
    } else {
      _deckBState = _deckBState.copyWith(
        isSlicerActive: true,
        slicerSegments: segments,
      );
    }
  }

  Future<void> jumpToSlice(DeckSide side, int index) async {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    if (!state.isSlicerActive ||
        state.slicerSegments == null ||
        index >= state.slicerSegments!.length) {
      return;
    }

    // In Slicer mode, tapping a pad jumps to that slice.
    // Usually it continues playing from there.
    // If Slip Mode is active, the ghost continues.
    await seek(side, state.slicerSegments![index]);

    if (!state.isPlaying) {
      play(side);
    }
  }

  // Phase 2 - Pitch Play Mode
  void togglePitchPlay(DeckSide side) {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    final active = !state.isPitchPlayActive;

    if (active) {
      _activatePitchPlay(side);
    } else {
      if (side == DeckSide.A) {
        _deckAState = _deckAState.copyWith(
          isPitchPlayActive: false,
          pitchPlayCuePoint: null,
          pitchPlayNotes: null,
        );
      } else {
        _deckBState = _deckBState.copyWith(
          isPitchPlayActive: false,
          pitchPlayCuePoint: null,
          pitchPlayNotes: null,
        );
      }
    }
    notifyListeners();
  }

  void _activatePitchPlay(DeckSide side) {
    final state = side == DeckSide.A ? _deckAState : _deckBState;

    // Set the current position as the cue point
    final cuePoint = state.position;

    // Create chromatic scale (8 semitones)
    // C, C#, D, D#, E, F, F#, G
    // Pitch multipliers: 2^(semitones/12)
    final List<double> notes = [
      1.0, // Root (C)
      1.0594630943592953, // C# (+1 semitone)
      1.122462048309373, // D (+2 semitones)
      1.189207115002721, // D# (+3 semitones)
      1.2599210498948732, // E (+4 semitones)
      1.3348398541700344, // F (+5 semitones)
      1.4142135623730951, // F# (+6 semitones)
      1.4983070768766815, // G (+7 semitones)
    ];

    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(
        isPitchPlayActive: true,
        pitchPlayCuePoint: cuePoint,
        pitchPlayNotes: notes,
      );
    } else {
      _deckBState = _deckBState.copyWith(
        isPitchPlayActive: true,
        pitchPlayCuePoint: cuePoint,
        pitchPlayNotes: notes,
      );
    }

    // Load track into Pitch Play Controller
    if (state.track != null) {
      final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
      deck.pitchPlay.loadTrack(state.track!.filePath);
    }
  }

  Future<void> playPitchedNote(DeckSide side, int index) async {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    if (!state.isPitchPlayActive ||
        state.pitchPlayNotes == null ||
        state.pitchPlayCuePoint == null ||
        index >= state.pitchPlayNotes!.length) {
      return;
    }

    // Play polyphonic note
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    await deck.pitchPlay.playNote(
      index,
      state.pitchPlayNotes![index],
      state.pitchPlayCuePoint!,
    );

    // Start tracking playing state if not already?
    // Actually Pitch Play is independent of main deck playing state in this mode.
    // We don't need to call default play().
  }

  Future<void> stopPitchedNote(DeckSide side, int index) async {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    if (!state.isPitchPlayActive) return;

    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;
    await deck.pitchPlay.stopNote(index);
  }

  void updateFxPad(DeckSide side, bool active, double x, double y) {
    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(isFxPadActive: active, fxX: x, fxY: y);
      _audioEngine.deckA.setFxActive(active);
      _audioEngine.deckA.setFxXY(x, y);
    } else {
      _deckBState = _deckBState.copyWith(isFxPadActive: active, fxX: x, fxY: y);
      _audioEngine.deckB.setFxActive(active);
      _audioEngine.deckB.setFxXY(x, y);
    }
    notifyListeners();
  }

  void setAudioEffect(DeckSide side, AudioEffectType type) {
    if (side == DeckSide.A) {
      _audioEngine.deckA.setEffect(type);
    } else {
      _audioEngine.deckB.setEffect(type);
    }
  }

  void _handleMidiEvent(MidiEvent event) {
    // Basic Mapping:
    // Channel 0 (Ch1) -> Deck A
    // Channel 1 (Ch2) -> Deck B
    // Notes 60-67 (C3-G3) -> Pads 1-8

    // Filter useful events
    if (event.type != MidiEventType.NoteOn &&
        event.type != MidiEventType.NoteOff)
      return;

    DeckSide? side;
    if (event.channel == 0) side = DeckSide.A;
    if (event.channel == 1) side = DeckSide.B;

    if (side == null) return; // Ignore other channels

    // Map Note to Pad Index
    // C3 (60) is usually Middle C.
    // Let's assume user controller starts at 60.
    final int padIndex = event.note - 60;

    if (padIndex < 0 || padIndex >= 8) return; // Out of range for our 8 pads

    if (side == DeckSide.A && _deckAState.isPitchPlayActive) {
      if (event.type == MidiEventType.NoteOn) {
        playPitchedNote(side, padIndex);
      } else {
        stopPitchedNote(side, padIndex);
      }
    } else if (side == DeckSide.B && _deckBState.isPitchPlayActive) {
      if (event.type == MidiEventType.NoteOn) {
        playPitchedNote(side, padIndex);
      } else {
        stopPitchedNote(side, padIndex);
      }
    }
  }

  // Phase 2 - Scratch Banks
  void toggleScratchBankMode(DeckSide side) {
    if (side == DeckSide.A) {
      _deckAState = _deckAState.copyWith(
        isScratchBankActive: !_deckAState.isScratchBankActive,
      );
    } else {
      _deckBState = _deckBState.copyWith(
        isScratchBankActive: !_deckBState.isScratchBankActive,
      );
    }
    notifyListeners();
  }

  Future<void> triggerScratchBank(DeckSide side, int index) async {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;

    // Safety check
    if (index < 0 || index >= state.scratchBanks.length) return;

    // Store playing state
    if (side == DeckSide.A)
      _wasPlayingBeforeScratchA = state.isPlaying;
    else
      _wasPlayingBeforeScratchB = state.isPlaying;

    if (state.isPlaying) {
      if (state.isSlipActive) {
        // Slip Mode: Continue playing but mute
        await deck.setVolume(0.0);
      } else {
        // Normal Mode: Pause
        // Note: this stops ghost tracking if we were in slip mode but logic implies slip is OFF here.
        await deck.pause();
      }
    }

    // Play Scratch Sample
    final bank = state.scratchBanks[index];
    // In real app, we likely pre-load these. Here we set logic to load-on-demand if needed.
    await deck.scratchBank.loadSample(index, bank.filePath);
    await deck.scratchBank.trigger(index);
  }

  Future<void> releaseScratchBank(DeckSide side, int index) async {
    final state = side == DeckSide.A ? _deckAState : _deckBState;
    final deck = side == DeckSide.A ? _audioEngine.deckA : _audioEngine.deckB;

    // Stop Scratch
    await deck.scratchBank.release(index);

    // Restore Main Deck
    bool wasPlaying = side == DeckSide.A
        ? _wasPlayingBeforeScratchA
        : _wasPlayingBeforeScratchB;

    if (wasPlaying) {
      if (state.isSlipActive) {
        // Unmute
        await deck.setVolume(state.volume);
      } else {
        // Resume
        deck.play();
      }
    } else {
      // If it wasn't playing, ensure volume is restored if it was muted (edge case)
      await deck.setVolume(state.volume);
    }
  }
}
