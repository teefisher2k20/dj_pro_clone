import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class PitchPlayController {
  final List<AudioPlayer> _players = [];
  bool _isInitialized = false;
  double _volume = 1.0;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      // Create pool of 8 players for 8 pads
      for (int i = 0; i < 8; i++) {
        _players.add(AudioPlayer());
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint("PitchPlayController init error: $e");
    }
  }

  Future<void> loadTrack(String filePath) async {
    if (!_isInitialized) await initialize();

    final futures = <Future>[];
    for (var player in _players) {
      // Stop current if playing
      if (player.playing) await player.stop();
      futures.add(player.setFilePath(filePath));
    }
    await Future.wait(futures);
  }

  Future<void> playNote(int index, double pitch, Duration startPos) async {
    if (index < 0 || index >= _players.length) return;

    final player = _players[index];

    try {
      // Stop/Reset if already playing
      if (player.playing) {
        await player.stop();
      }

      await player.seek(startPos);

      // Apply pitch shift logic (Chipmunk effect)
      // Set both speed and pitch to achieve pitch shift without time stretching artifacts interfering
      // Speed changes duration/rate. Pitch changes frequency.
      // To get "Vinyl" behavior (higher pitch = faster), we set speed.
      // And reset pitch to allow speed to dictate pitch? No, default is Time Stretch.
      // So we set pitch as well.

      await player.setSpeed(pitch);
      await player.setPitch(pitch);

      // Ensure volume matches deck volume
      await player.setVolume(_volume);

      player.play();
    } catch (e) {
      debugPrint("Error playing note on pad $index: $e");
    }
  }

  Future<void> stopNote(int index) async {
    if (index < 0 || index >= _players.length) return;
    await _players[index].pause();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    if (_isInitialized) {
      for (var p in _players) {
        await p.setVolume(volume);
      }
    }
  }

  void dispose() {
    for (var p in _players) p.dispose();
    _players.clear();
    _isInitialized = false;
  }
}
