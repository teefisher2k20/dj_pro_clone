import 'package:flutter/material.dart';
import 'package:djay_pro_clone/ui/widgets/track_loader.dart';
import 'package:djay_pro_clone/ui/widgets/waveform_painter.dart';

void main() {
  runApp(const DJProCloneApp());
}

class DJProCloneApp extends StatelessWidget {
  const DJProCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DJ Pro Clone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DJDemoPage(),
    );
  }
}

// Demo DJ Controller
class DJDemoPage extends StatefulWidget {
  const DJDemoPage({super.key});

  @override
  State<DJDemoPage> createState() => _DJDemoPageState();
}

class _DJDemoPageState extends State<DJDemoPage> {
  // Deck A controls
  bool deckAPlaying = false;
  double deckAVolume = 0.75;
  double deckATempo = 100.0;
  String? deckATrack;
  String? deckASource;

  // Deck B controls
  bool deckBPlaying = false;
  double deckBVolume = 0.75;
  double deckBTempo = 100.0;
  String? deckBTrack;
  String? deckBSource;

  // Crossfader (0.0 = Deck A, 0.5 = Center, 1.0 = Deck B)
  double crossfader = 0.5;

  // Master volume
  double masterVolume = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('DJ Pro Clone - Demo Mode'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Master controls
          _MasterControls(
            masterVolume: masterVolume,
            deckATempo: deckATempo,
            deckBTempo: deckBTempo,
            onMasterVolumeChanged: (value) =>
                setState(() => masterVolume = value),
          ),

          const Divider(height: 1),

          // Deck displays
          Expanded(
            child: Row(
              children: [
                // Deck A
                Expanded(
                  child: _Deck(
                    deckName: 'DECK A',
                    isPlaying: deckAPlaying,
                    volume: deckAVolume,
                    tempo: deckATempo,
                    color: Colors.blue,
                    onPlayPause: () {
                      setState(() => deckAPlaying = !deckAPlaying);
                    },
                    onVolumeChange: (value) {
                      setState(() => deckAVolume = value);
                    },
                    onTempoChange: (value) {
                      setState(() => deckATempo = value);
                    },
                    loadedTrack: deckATrack,
                    trackSource: deckASource,
                    onTrackLoad: (track, source) {
                      setState(() {
                        deckATrack = track;
                        deckASource = source;
                      });
                    },
                  ),
                ),

                // Deck B
                Expanded(
                  child: _Deck(
                    deckName: 'DECK B',
                    isPlaying: deckBPlaying,
                    volume: deckBVolume,
                    tempo: deckBTempo,
                    color: Colors.red,
                    onPlayPause: () {
                      setState(() => deckBPlaying = !deckBPlaying);
                    },
                    onVolumeChange: (value) {
                      setState(() => deckBVolume = value);
                    },
                    onTempoChange: (value) {
                      setState(() => deckBTempo = value);
                    },
                    loadedTrack: deckBTrack,
                    trackSource: deckBSource,
                    onTrackLoad: (track, source) {
                      setState(() {
                        deckBTrack = track;
                        deckBSource = source;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Crossfader section
          _Crossfader(
            crossfader: crossfader,
            onCrossfaderChanged: (value) => setState(() => crossfader = value),
          ),

          // Video player section
          // Video player section removed
        ],
      ),
    );
  }
}

class _MasterControls extends StatelessWidget {
  final double masterVolume;
  final double deckATempo;
  final double deckBTempo;
  final ValueChanged<double> onMasterVolumeChanged;

  const _MasterControls({
    required this.masterVolume,
    required this.deckATempo,
    required this.deckBTempo,
    required this.onMasterVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[850],
      child: Row(
        children: [
          const Icon(Icons.volume_up, color: Colors.white),
          const SizedBox(width: 8),
          const Text('MASTER', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Expanded(
            child: Slider(
              value: masterVolume,
              onChanged: onMasterVolumeChanged,
              activeColor: Colors.deepPurple,
            ),
          ),
          Text('${(masterVolume * 100).toInt()}%'),
          const SizedBox(width: 24),
          Text(
            'BPM: ${((deckATempo + deckBTempo) / 2).toInt()}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _Deck extends StatelessWidget {
  final String deckName;
  final bool isPlaying;
  final double volume;
  final double tempo;
  final Color color;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onVolumeChange;
  final ValueChanged<double> onTempoChange;
  final String? loadedTrack;
  final String? trackSource;
  final Function(String?, String?) onTrackLoad;

  // Demo/mock waveform, beat, and video data
  final List<double> waveformData;
  final List<double> beatPositions;
  final double playbackPosition;
  final String? videoUrl;

  const _Deck({
    required this.deckName,
    required this.isPlaying,
    required this.volume,
    required this.tempo,
    required this.color,
    required this.onPlayPause,
    required this.onVolumeChange,
    required this.onTempoChange,
    required this.loadedTrack,
    required this.trackSource,
    required this.onTrackLoad,
    List<double>? waveformData,
    List<double>? beatPositions,
    double? playbackPosition,
    String? videoUrl,
  })  : waveformData =
            waveformData ?? const [0.2, 0.5, 0.8, 0.6, 0.3, 0.7, 0.9, 0.4],
        beatPositions = beatPositions ?? const [0.1, 0.3, 0.5, 0.7, 0.9],
        playbackPosition = playbackPosition ?? 0.5,
        videoUrl = videoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Deck header
          Text(
            deckName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),

          // Track loader or display
          TrackLoader(
            onTrackLoaded: onTrackLoad,
            color: color,
          ),
          const SizedBox(height: 16),

          // Waveform & video visualization
          Expanded(
            child: _Waveform(
              color: color,
              isPlaying: isPlaying,
              waveformData: waveformData,
              playbackPosition: playbackPosition,
              beatPositions: beatPositions,
              videoUrl: videoUrl,
            ),
          ),
          const SizedBox(height: 16),

          // Transport controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: 32,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Previous track')),
                  );
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: onPlayPause,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 32,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Next track')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Volume control
          Row(
            children: [
              const Icon(Icons.volume_up, size: 20),
              Expanded(
                child: Slider(
                  value: volume,
                  onChanged: onVolumeChange,
                  activeColor: color,
                ),
              ),
              Text('${(volume * 100).toInt()}%'),
            ],
          ),

          // Tempo control
          Row(
            children: [
              const Icon(Icons.speed, size: 20),
              Expanded(
                child: Slider(
                  value: tempo,
                  min: 80,
                  max: 120,
                  onChanged: onTempoChange,
                  activeColor: color,
                ),
              ),
              Text('${tempo.toInt()}%'),
            ],
          ),

          // Hot cue buttons
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CueButton(label: '1', color: Colors.red),
              _CueButton(label: '2', color: Colors.orange),
              _CueButton(label: '3', color: Colors.green),
              _CueButton(label: '4', color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  final Color color;
  final bool isPlaying;
  final List<double> waveformData;
  final double playbackPosition;
  final List<double> beatPositions;
  final String? videoUrl;

  const _Waveform({
    required this.color,
    required this.isPlaying,
    required this.waveformData,
    required this.playbackPosition,
    required this.beatPositions,
    this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: CustomPaint(
        painter: WaveformPainter(
          waveformData: waveformData,
          playbackPosition: playbackPosition,
          beatPositions: beatPositions,
        ),
        child: Container(),
      ),
    );
  }
}

class _CueButton extends StatelessWidget {
  final String label;
  final Color color;

  const _CueButton({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hot Cue $label activated')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(50, 40),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _Crossfader extends StatelessWidget {
  final double crossfader;
  final ValueChanged<double> onCrossfaderChanged;

  const _Crossfader(
      {required this.crossfader, required this.onCrossfaderChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.grey[850],
      child: Column(
        children: [
          const Text(
            'CROSSFADER',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('A',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
              Expanded(
                child: Slider(
                  value: crossfader,
                  onChanged: onCrossfaderChanged,
                  activeColor: crossfader < 0.5 ? Colors.blue : Colors.red,
                ),
              ),
              const Text('B',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(
            crossfader < 0.4
                ? 'Deck A Dominant'
                : crossfader > 0.6
                    ? 'Deck B Dominant'
                    : 'Balanced Mix',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
