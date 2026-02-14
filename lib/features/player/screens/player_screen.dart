import 'package:flutter/material.dart';
import '../../../core/audio/deck_controller.dart';
import '../../../core/models/track.dart';
import '../../../core/models/deck_state.dart'; // For DeckSide
import '../../../core/services/file_service.dart';
import '../widgets/transport_controls.dart';
import 'package:just_audio/just_audio.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late DeckController _deckController;
  final FileService _fileService = FileService();

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Track? _currentTrack;

  @override
  void initState() {
    super.initState();
    _deckController = DeckController(deckSide: DeckSide.A);
    _deckController.initialize();

    // Listen to player state
    _deckController.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
        if (state.processingState == ProcessingState.completed) {
          _deckController.seek(Duration.zero);
          _deckController.pause();
        }
      }
    });

    // Listen to position updates
    _deckController.positionStream.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    // Listen to duration updates
    _deckController.durationStream.listen((dur) {
      if (mounted && dur != null) {
        setState(() {
          _duration = dur;
        });
      }
    });
  }

  @override
  void dispose() {
    _deckController.dispose();
    super.dispose();
  }

  Future<void> _loadTrack() async {
    final track = await _fileService.pickAudioFile();
    if (track != null) {
      try {
        await _deckController.loadTrack(track);
        setState(() {
          _currentTrack = track;
          // Duration might update from stream, but we can set initial
          _duration = track.duration;
        });

        // Auto-play on load is common, but let's wait for user
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error loading track: $e")));
        }
      }
    }
  }

  void _playPause() {
    if (_isPlaying) {
      _deckController.pause();
    } else {
      _deckController.play();
    }
  }

  void _stop() {
    _deckController.stop();
  }

  void _seek(double value) {
    // Optional: Update local position state for smooth dragging
    setState(() {
      _position = Duration(milliseconds: value.toInt());
    });
  }

  void _seekEnd(double value) {
    _deckController.seek(Duration(milliseconds: value.toInt()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Player'),
        backgroundColor: const Color(0xFF1A1F3A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Track Info
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentTrack != null) ...[
                      const Icon(
                        Icons.music_note,
                        size: 100,
                        color: Color(0xFF00D9FF),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _currentTrack!.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _currentTrack!.artist,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      const Icon(Icons.album, size: 100, color: Colors.white24),
                      const SizedBox(height: 20),
                      const Text(
                        'No track loaded',
                        style: TextStyle(fontSize: 18, color: Colors.white54),
                      ),
                    ],

                    const SizedBox(height: 40),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Load Track'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1F3A),
                        foregroundColor: const Color(0xFF00D9FF),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: _loadTrack,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Transport Controls
            TransportControls(
              isPlaying: _isPlaying,
              position: _position,
              duration: _duration,
              onPlayPause: _playPause,
              onStop: _stop,
              onSeek: _seek,
              onSeekEnd: _seekEnd,
            ),

            const SizedBox(height: 30),

            // Volume Control
            Row(
              children: [
                const Icon(Icons.volume_down, color: Colors.white54),
                Expanded(
                  child: Slider(
                    value: 1.0, // Initial volume
                    onChanged: (value) {
                      _deckController.setVolume(value);
                    },
                    activeColor: const Color(0xFFB026FF), // Purple for volume
                    inactiveColor: Colors.white24,
                  ),
                ),
                const Icon(Icons.volume_up, color: Colors.white54),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
