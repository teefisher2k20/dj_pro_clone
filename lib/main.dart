import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  
  // Deck B controls
  bool deckBPlaying = false;
  double deckBVolume = 0.75;
  double deckBTempo = 100.0;
  
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
          _buildMasterControls(),
          
          const Divider(height: 1),
          
          // Deck displays
          Expanded(
            child: Row(
              children: [
                // Deck A
                Expanded(
                  child: _buildDeck(
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
                  ),
                ),
                
                // Deck B
                Expanded(
                  child: _buildDeck(
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
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Crossfader section
          _buildCrossfader(),
        ],
      ),
    );
  }

  int _calculateBpm() {
    if (deckAPlaying && !deckBPlaying) {
      return deckATempo.toInt();
    } else if (!deckAPlaying && deckBPlaying) {
      return deckBTempo.toInt();
    } else {
      // If both are playing or neither is playing, show the average.
      return ((deckATempo + deckBTempo) / 2).toInt();
    }
  }

  Widget _buildMasterControls() {
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
              onChanged: (value) => setState(() => masterVolume = value),
              activeColor: Colors.deepPurple,
            ),
          ),
          Text('${(masterVolume * 100).toInt()}%'),
          const SizedBox(width: 24),
          Text(
            'BPM: ${_calculateBpm()}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDeck({
    required String deckName,
    required bool isPlaying,
    required double volume,
    required double tempo,
    required Color color,
    required VoidCallback onPlayPause,
    required ValueChanged<double> onVolumeChange,
    required ValueChanged<double> onTempoChange,
  }) {
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
          
          // Track name
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.music_note, size: 16),
                SizedBox(width: 8),
                Text('Demo Track - House Mix.mp3'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Waveform visualization
          Expanded(
            child: _buildWaveform(color, isPlaying),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCueButton('1', Colors.red),
              _buildCueButton('2', Colors.orange),
              _buildCueButton('3', Colors.green),
              _buildCueButton('4', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform(Color color, bool isPlaying) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Center(
        child: isPlaying
            ? Icon(Icons.graphic_eq, size: 64, color: color)
            : Icon(Icons.show_chart, size: 64, color: color.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildCueButton(String label, Color color) {
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

  Widget _buildCrossfader() {
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
              const Text('A', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              Expanded(
                child: Slider(
                  value: crossfader,
                  onChanged: (value) => setState(() => crossfader = value),
                  activeColor: crossfader < 0.5 ? Colors.blue : Colors.red,
                ),
              ),
              const Text('B', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
