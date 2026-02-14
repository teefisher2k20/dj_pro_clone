import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';

class Sample {
  final String id;
  final String name;
  final String? filePath;
  final Duration start;
  final Duration end;
  final Color color;
  final bool isLoop;

  const Sample({
    required this.id,
    required this.name,
    this.filePath,
    this.start = Duration.zero,
    this.end = Duration.zero,
    this.color = Colors.blue,
    this.isLoop = false,
    this.isAsset = false,
  });

  final bool isAsset;
}

class SamplerService {
  static final SamplerService instance = SamplerService._internal();
  factory SamplerService() => instance;
  SamplerService._internal();

  // 16 Pads
  final List<Sample?> _padSamples = List.filled(16, null);
  final List<AudioPlayer> _playersPool = [];
  final int _maxPolyphony = 8;
  double _volume = 0.5;

  // Defaults
  final List<String> _defaultSampleNames = [
    'Air Horn',
    'Siren',
    'Kick',
    'Snare',
    'HiHat',
    'Clap',
    'Vocal Hit',
    'Scratch',
  ];

  Future<void> init() async {
    // Initialize pool
    for (int i = 0; i < _maxPolyphony; i++) {
      _playersPool.add(AudioPlayer());
    }

    // Load defaults into first 8 pads
    for (int i = 0; i < _defaultSampleNames.length; i++) {
      _padSamples[i] = Sample(
        id: 'default_$i',
        name: _defaultSampleNames[i],
        color: Colors.purpleAccent,
        isAsset: true,
        // In a real app we would have these assets
        // 'assets/samples/airhorn.mp3'
        filePath: 'assets/samples/kick.mp3',
      );
    }
  }

  Sample? getSample(int index) {
    if (index >= 0 && index < _padSamples.length) {
      return _padSamples[index];
    }
    return null;
  }

  void saveSample(int padIndex, Track track, Duration start, Duration end) {
    if (padIndex < 0 || padIndex >= _padSamples.length) return;

    _padSamples[padIndex] = Sample(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Rec ${padIndex + 1}',
      filePath: track.filePath,
      start: start,
      end: end,
      color: Colors.redAccent,
    );
    print(
      'Sample saved to Pad ${padIndex + 1}: ${track.title} ($start - $end)',
    );
  }

  Future<void> playSample(int index) async {
    if (index < 0 || index >= _padSamples.length) return;
    final sample = _padSamples[index];
    if (sample == null) return;

    print('Playing Sample: ${sample.name}');

    try {
      // Find free player
      AudioPlayer? player;
      for (var p in _playersPool) {
        if (!p.playing) {
          player = p;
          break;
        }
      }
      // If all busy, steal oldest? For now just skip.
      if (player == null) {
        print('Max polyphony reached.');
        return;
      }

      player.setVolume(_volume);

      if (sample.filePath != null) {
        if (sample.isAsset) {
          // Mock asset playback
          // In real app: await player.setAsset(sample.filePath!);
          print("Playing Asset Sample: ${sample.name}");
        } else {
          // Play Clip from File (User Recorded)
          final source = ClippingAudioSource(
            child: AudioSource.file(sample.filePath!),
            start: sample.start,
            end: sample.end > sample.start ? sample.end : null,
          );
          await player.setAudioSource(source);
          player.play();
        }
      }
    } catch (e) {
      print('Error playing sample: $e');
    }
  }

  void setVolume(double volume) {
    _volume = volume;
    for (var player in _playersPool) {
      player.setVolume(volume);
    }
  }

  void dispose() {
    for (var player in _playersPool) {
      player.dispose();
    }
    _playersPool.clear();
  }
}
