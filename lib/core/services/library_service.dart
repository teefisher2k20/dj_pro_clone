import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';

class LibraryService {
  // In-memory storage
  final List<Track> _tracks = [];
  final StreamController<List<Track>> _tracksController =
      StreamController<List<Track>>.broadcast();

  LibraryService() {
    // Initialize with some mock/demo data
    _tracks.addAll([
      Track(
        id: 'mock_track_1',
        title: 'Demo Track 1',
        artist: 'DJ Clone',
        album: 'Greatest Hits',
        filePath: 'assets/audio/demo1.mp3', // Placeholder
        duration: const Duration(minutes: 3),
        dateAdded: DateTime.now(),
        userId: 'local_user',
        bpm: 128.0,
      ),
      Track(
        id: 'mock_track_2',
        title: 'House Beat',
        artist: 'DJ Clone',
        album: 'Club Mix',
        filePath: 'assets/audio/demo2.mp3',
        duration: const Duration(minutes: 4),
        dateAdded: DateTime.now(),
        userId: 'local_user',
        bpm: 124.0,
      ),
    ]);

    // Emit initial state
    Future.microtask(() => _tracksController.add(List.from(_tracks)));
  }

  // Import tracks from device
  Future<List<Track>> importTracks() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result == null) return [];

      final newTracks = <Track>[];

      for (final file in result.files) {
        if (file.path == null) continue;

        // Get actual duration
        Duration duration = Duration.zero;
        try {
          final audioPlayer = AudioPlayer();
          final d = await audioPlayer.setFilePath(file.path!);
          duration = d ?? Duration.zero;
          await audioPlayer.dispose();
        } catch (e) {
          print('Error getting duration for ${file.path}: $e');
        }

        // ID handling
        final uniqueId =
            '${DateTime.now().millisecondsSinceEpoch}_${_tracks.length + newTracks.length}';

        final track = Track.fromFilePath(file.path!, 'local_user');

        final trackWithDuration = Track(
          id: uniqueId,
          title: track.title,
          artist: track.artist,
          album: track.album,
          filePath: track.filePath,
          duration: duration,
          dateAdded: track.dateAdded,
          userId: track.userId,
          bpm: track.bpm,
        );

        newTracks.add(trackWithDuration);
      }

      _tracks.addAll(newTracks);
      _tracksController.add(List.from(_tracks));

      return newTracks;
    } catch (e) {
      print('Error importing tracks: $e');
      rethrow;
    }
  }

  // Get all tracks stream
  Stream<List<Track>> getAllTracks() {
    return _tracksController.stream;
  }

  // Search tracks (In-memory)
  Future<List<Track>> searchTracks(String query) async {
    if (query.isEmpty) return List.from(_tracks);

    final lowerQuery = query.toLowerCase();
    return _tracks.where((track) {
      return track.title.toLowerCase().contains(lowerQuery) ||
          track.artist.toLowerCase().contains(lowerQuery) ||
          track.album.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Sort tracks
  List<Track> sortTracks(List<Track> tracks, SortOption sortBy) {
    final sorted = List<Track>.from(tracks);

    switch (sortBy) {
      case SortOption.title:
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case SortOption.artist:
        sorted.sort(
          (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        );
        break;
      case SortOption.dateAdded:
        sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case SortOption.bpm:
        sorted.sort((a, b) {
          if (a.bpm == null) return 1;
          if (b.bpm == null) return -1;
          return a.bpm!.compareTo(b.bpm!);
        });
        break;
    }

    return sorted;
  }

  // Delete track
  Future<void> deleteTrack(String trackId) async {
    _tracks.removeWhere((t) => t.id == trackId);
    _tracksController.add(List.from(_tracks));
  }
}

enum SortOption { title, artist, dateAdded, bpm }
