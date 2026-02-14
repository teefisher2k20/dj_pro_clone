import 'package:flutter/material.dart';
import '../../../core/models/deck_state.dart';

class VideoMixingLayer extends StatelessWidget {
  final DeckState deckA;
  final DeckState deckB;
  final double crossfaderPosition; // -1.0 (A) to 1.0 (B)
  final bool isVideoMode;

  const VideoMixingLayer({
    super.key,
    required this.deckA,
    required this.deckB,
    required this.crossfaderPosition,
    required this.isVideoMode,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVideoMode) return const SizedBox.shrink();

    // Calculate opacities
    // Map -1..1 to 0..1
    final pos = (crossfaderPosition + 1) / 2;
    final opacityA = (1 - pos).clamp(0.0, 1.0);
    final opacityB = pos.clamp(0.0, 1.0);

    return Stack(
      children: [
        // Background (Black)
        Container(color: Colors.black),

        // Deck A Video Layer
        Opacity(
          opacity: opacityA,
          child: _buildVideoPlaceholder(deckA, Colors.blueAccent),
        ),

        // Deck B Video Layer
        Opacity(
          opacity: opacityB,
          child: _buildVideoPlaceholder(deckB, Colors.orangeAccent),
        ),

        // Overlay Info
        Positioned(
          bottom: 20,
          left: 20,
          child: Text(
            'VIDEO OUTPUT',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlaceholder(DeckState state, Color color) {
    if (state.track == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Icon(Icons.videocam_off, color: Colors.white24, size: 100),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.8), Colors.black],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_video, color: Colors.white, size: 80),
            const SizedBox(height: 16),
            Text(
              state.track!.title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              state.track!.artist,
              style: const TextStyle(color: Colors.white70, fontSize: 20),
            ),
            if (state.isPlaying)
              ExcludeSemantics(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
