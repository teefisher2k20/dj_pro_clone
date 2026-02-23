import 'package:just_audio/just_audio.dart';
import '../../core/models/track.dart';
import '../../core/models/deck_state.dart';
import 'eq_processor.dart';
import 'effects_processor.dart';
import 'pitch_play_controller.dart';
import 'scratch_bank_controller.dart';

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

  // EQ State
  late EQProcessor _eqProcessor;
  double _mainEqHigh = 1.0;
  double _mainEqMid = 1.0;
  double _mainEqLow = 1.0;
  double _fxEqHigh = 1.0;
  double _fxEqMid = 1.0;
  double _fxEqLow = 1.0;

  // FX Processor
  late EffectsProcessor _effectsProcessor;

  // Pitch Play
  final PitchPlayController pitchPlay = PitchPlayController();

  // Scratch Banks
  final ScratchBankController scratchBank = ScratchBankController();

  // Streams for UI updates
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  DeckController({required this.deckSide});

  Future<void> initialize() async {
    // Initialize audio player with proper settings
    _player = AudioPlayer();

    _eqProcessor = EQProcessor(_player);
    // await _eqProcessor.init(); // If init existed

    _effectsProcessor = EffectsProcessor()
      ..onEqChanged = (low, mid, high) {
        _fxEqLow = low;
        _fxEqMid = mid;
        _fxEqHigh = high;
        _applyEq();
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
    await scratchBank.setVolume(finalVol);
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
  Future<void> setHighEq(double val) async {
    _mainEqHigh = val;
    await _applyEq();
  }

  Future<void> setMidEq(double val) async {
    _mainEqMid = val;
    await _applyEq();
  }

  Future<void> setLowEq(double val) async {
    _mainEqLow = val;
    await _applyEq();
  }

  Future<void> setGain(double val) async => _eqProcessor.setGain(val);

  Future<void> _applyEq() async {
    // Combine Main and FX EQ (Multiply or Clamp)
    // 0.0 is cut, 1.0 is boost/flat.
    // Usually 0.5 is flat in some UI, but in our logic 1.0 was used in EffectsProcessor for flat?
    // Let's check DeckProvider. 0.5 is flat in UI.
    // Logic in DeckProvider maps 0.5 to something?
    // Wait, DeckProvider calls `deck.setLowEq(val)`.
    // If val is 0.5 (UI), DeckController receives 0.5.
    // EQProcessor likely expects 0.0-1.0 or similar.
    // EffectsProcessor sends 1.0 for flat?
    // Line 96 in EffectsProcessor: `high = 1.0 - intensity;` -> 1.0 if intensity is 0.
    // So EffectsProcessor assumes 1.0 is max/flat?
    // If DeckProvider sends 0.5 as "Flat", then we have a mismatch if EffectsProcessor sends 1.0.

    // We need to normalize.
    // Let's assume EQProcessor handles the range.
    // If FX sends 1.0 (Flat) and Main sends 0.5 (Flat), we should use Main.
    // If FX sends 0.0 (Cut), result should be 0.0.
    // So Multiplication seems correct if we normalize FX to 0..1 factor?
    // FX sends 0.0..1.0.
    // Main sends 0.0..1.0.
    // But if Main 0.5 is flat, and FX 1.0 is flat...
    // We should treat FX as a scaler?

    // Let's treat FX EQ as a scaler (0.0 to 1.0, where 1.0 is "No Change").
    // And Main EQ as the base value.

    // Check EffectsProcessor logic again.
    // It returns 1.0 for flat.
    // So `_fxEq...` defaults to 1.0.

    // Apply:
    await _eqProcessor.setHigh(_mainEqHigh * _fxEqHigh);
    await _eqProcessor.setMid(_mainEqMid * _fxEqMid);
    await _eqProcessor.setLow(_mainEqLow * _fxEqLow);
  }

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
    scratchBank.dispose();
    _effectsProcessor.dispose();
  }
}
