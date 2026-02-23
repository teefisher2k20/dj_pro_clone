import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Manages a bank of short sample players for scratch/stab triggers.
/// Each bank slot has its own AudioPlayer so multiple can fire simultaneously.
class ScratchBankController {
  final List<AudioPlayer> _players = [];
  bool _isInitialized = false;
  double _volume = 1.0;

  // Maximum number of scratch bank slots
  static const int maxSlots = 8;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      for (int i = 0; i < maxSlots; i++) {
        _players.add(AudioPlayer());
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('ScratchBankController init error: $e');
    }
  }

  /// Load a sample file path into a specific bank slot.
  Future<void> loadSample(int slotIndex, String filePath) async {
    if (!_isInitialized) await initialize();
    if (slotIndex < 0 || slotIndex >= _players.length) return;
    try {
      await _players[slotIndex].setFilePath(filePath);
    } catch (e) {
      debugPrint('ScratchBankController: failed to load sample $filePath: $e');
    }
  }

  /// Trigger (play from beginning) a scratch bank slot.
  Future<void> trigger(int slotIndex) async {
    if (slotIndex < 0 || slotIndex >= _players.length) return;
    final player = _players[slotIndex];
    try {
      await player.seek(Duration.zero);
      await player.setVolume(_volume);
      player.play();
    } catch (e) {
      debugPrint('ScratchBankController: trigger error on slot $slotIndex: $e');
    }
  }

  /// Release (stop/pause) a scratch bank slot.
  Future<void> release(int slotIndex) async {
    if (slotIndex < 0 || slotIndex >= _players.length) return;
    try {
      await _players[slotIndex].pause();
    } catch (e) {
      debugPrint('ScratchBankController: release error on slot $slotIndex: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    if (_isInitialized) {
      for (final p in _players) {
        try {
          await p.setVolume(volume);
        } catch (_) {}
      }
    }
  }

  void dispose() {
    for (final p in _players) {
      p.dispose();
    }
    _players.clear();
    _isInitialized = false;
  }
}
