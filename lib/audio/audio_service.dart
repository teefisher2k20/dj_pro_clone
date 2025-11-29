import 'package:flutter/services.dart';

/// Core audio service for managing dual-deck audio playback
/// and communication with native platform code.
class AudioService {
  /// Get waveform data for a deck
  Future<List<double>> getWaveformData({required bool isDeckA}) async {
    try {
      final result = await _channel.invokeMethod('getWaveformData', {
        'deck': isDeckA ? 'A' : 'B',
      });
      return (result as List<dynamic>).map((e) => e as double).toList();
    } on PlatformException catch (e) {
      throw AudioException('Failed to get waveform data: ${e.message}');
    }
  }

  /// Get beat positions for a deck
  Future<List<double>> getBeatPositions({required bool isDeckA}) async {
    try {
      final result = await _channel.invokeMethod('getBeatPositions', {
        'deck': isDeckA ? 'A' : 'B',
      });
      return (result as List<dynamic>).map((e) => e as double).toList();
    } on PlatformException catch (e) {
      throw AudioException('Failed to get beat positions: ${e.message}');
    }
  }

  /// Stream playback position for a deck
  Stream<double> playbackPositionStream({required bool isDeckA}) async* {
    // This is a stub. Implement using EventChannel for real-time updates.
    // Example:
    // final eventChannel = EventChannel('com.djpro.audio/playbackPosition');
    // yield* eventChannel.receiveBroadcastStream({'deck': isDeckA ? 'A' : 'B'}).map((e) => e as double);
    yield 0.0; // Replace with actual implementation
  }

  static const _channel = MethodChannel('com.djpro.audio/playback');

  // Singleton pattern
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  /// Initialize the audio engine
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      throw AudioException('Failed to initialize audio: ${e.message}');
    }
  }

  /// Load an audio file into the specified deck (A or B)
  Future<void> loadTrack(String filePath, {required bool isDeckA}) async {
    try {
      await _channel.invokeMethod('loadTrack', {
        'filePath': filePath,
        'deck': isDeckA ? 'A' : 'B',
      });
    } on PlatformException catch (e) {
      throw AudioException('Failed to load track: ${e.message}');
    }
  }

  /// Start playback on the specified deck
  Future<void> play({required bool isDeckA}) async {
    try {
      await _channel.invokeMethod('play', {
        'deck': isDeckA ? 'A' : 'B',
      });
    } on PlatformException catch (e) {
      throw AudioException('Failed to play: ${e.message}');
    }
  }

  /// Pause playback on the specified deck
  Future<void> pause({required bool isDeckA}) async {
    try {
      await _channel.invokeMethod('pause', {
        'deck': isDeckA ? 'A' : 'B',
      });
    } on PlatformException catch (e) {
      throw AudioException('Failed to pause: ${e.message}');
    }
  }

  /// Set volume for the specified deck (0.0 to 1.0)
  Future<void> setVolume(double volume, {required bool isDeckA}) async {
    try {
      await _channel.invokeMethod('setVolume', {
        'volume': volume.clamp(0.0, 1.0),
        'deck': isDeckA ? 'A' : 'B',
      });
    } on PlatformException catch (e) {
      throw AudioException('Failed to set volume: ${e.message}');
    }
  }

  /// Set crossfader position (-1.0 to 1.0)
  /// -1.0 = full Deck A, 0.0 = center, 1.0 = full Deck B
  Future<void> setCrossfader(double position) async {
    try {
      await _channel.invokeMethod('setCrossfader', {
        'position': position.clamp(-1.0, 1.0),
      });
    } on PlatformException catch (e) {
      throw AudioException('Failed to set crossfader: ${e.message}');
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    try {
      await _channel.invokeMethod('dispose');
    } on PlatformException catch (e) {
      throw AudioException('Failed to dispose audio: ${e.message}');
    }
  }
}

/// Custom exception for audio-related errors
class AudioException implements Exception {
  final String message;
  AudioException(this.message);

  @override
  String toString() => 'AudioException: $message';
}
