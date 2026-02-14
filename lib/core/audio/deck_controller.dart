import 'package:just_audio/just_audio.dart';
import '../../core/models/track.dart';
import '../../core/models/deck_state.dart';
import 'eq_processor.dart';
import 'effects_processor.dart';
import 'pitch_play_controller.dart';

class DeckController {
  final DeckSide deckSide;

  // Core audio player
  late AudioPlayer _player;

  // Current track
  Track? currentTrack;

  // Audio state
  double _tempo = 1.0;
  bool _keyLock = false;

  // Volume state
  double _volume = 1.0;
  double _fxVolume = 1.0;

  // EQ Processor
  late EQProcessor _eqProcessor;

  // FX Processor
  late EffectsProcessor _effectsProcessor;

  // Pitch Play
  final PitchPlayController pitchPlay = PitchPlayController();

  // Streams for UI updates
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  DeckController({required this.deckSide});

  Future<void> initialize() async {
    // Initialize audio player with proper settings
    _player = AudioPlayer(
      // Handle audio interruptions (phone calls, etc.)
      handleInterruptions: true,

      // Audio focus settings for Android
      androidApplyAudioAttributes: true,

      // Wake lock to prevent screen sleep during playback
      handleAudioSessionActivation: true,
    );

    _eqProcessor = EQProcessor(_player);
    // await _eqProcessor.init(); // If init existed

    _effectsProcessor = EffectsProcessor(_player)
      ..onEqChanged = (low, mid, high) {
        _eqProcessor.setLow(low);
        _eqProcessor.setMid(mid);
        _eqProcessor.setHigh(high);
      }
      ..onVolumeChanged = (vol) {
        _fxVolume = vol;
        _applyVolume();
      };
  }

  // Playback controls
  Future<void> loadTrack(Track track) async {
    try {
      // Load from file path
      await _player.setFilePath(track.filePath);
      currentTrack = track;
    } catch (e) {
      throw Exception('Failed to load track on Deck ${deckSide.label}: $e');
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero); // Reset to start
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // Volume control
  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _applyVolume();
  }

  Future<void> _applyVolume() async {
    final finalVol = _volume * _fxVolume;
    await _player.setVolume(finalVol);
    await pitchPlay.setVolume(finalVol);
  }

  // Tempo & Pitch control
  Future<void> setTempo(double tempo) async {
    _tempo = tempo;
    await _applyTempo();
  }

  Future<void> setKeyLock(bool enabled) async {
    _keyLock = enabled;
    await _applyTempo();
  }

  // Direct pitch control (for Pitch Play mode)
  Future<void> setPitch(double pitch) async {
    await _player.setPitch(pitch);
  }

  Future<void> _applyTempo() async {
    // If key lock is ON (Pitch Correction):
    // Speed changes, but Pitch stays 1.0 (Time Stretch)
    // If key lock is OFF (Vinyl Mode):
    // Speed changes, and Pitch changes proportionally (Chipmunk/Slow-mo)

    // Note: just_audio's setSpeed usually defaults to Time Stretch on mobile.
    // So to simulate Vinyl (Key Lock OFF), we need to setPitch(tempo).
    // To maintain Key Lock (ON), we setPitch(1.0).

    await _player.setSpeed(_tempo);

    if (_keyLock) {
      await _player.setPitch(1.0);
    } else {
      await _player.setPitch(_tempo);
    }
  }

  // EQ Controls
  Future<void> setHighEq(double val) async => _eqProcessor.setHigh(val);
  Future<void> setMidEq(double val) async => _eqProcessor.setMid(val);
  Future<void> setLowEq(double val) async => _eqProcessor.setLow(val);
  Future<void> setGain(double val) async => _eqProcessor.setGain(val);

  // FX Controls
  Future<void> setEffect(AudioEffectType type) async =>
      _effectsProcessor.setEffect(type);
  Future<void> setFxWetDry(double val) async =>
      _effectsProcessor.setWetDry(val);
  Future<void> setFxActive(bool active) async =>
      _effectsProcessor.setActive(active);
  Future<void> setFxXY(double x, double y) async =>
      _effectsProcessor.updateXY(x, y);

  // Cleanup
  void dispose() {
    _player.dispose();
    pitchPlay.dispose();
    _effectsProcessor.dispose();
  }
}
