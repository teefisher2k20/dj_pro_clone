import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';

class LibraryService {
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  bool _isMockMode = false;

  LibraryService() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _auth = FirebaseAuth.instance;
      } else {
        _isMockMode = true;
      }
    } catch (e) {
      _isMockMode = true;
      print("[LibraryService] Error initializing: $e. Mock Mode Enabled.");
    }
  }

  String get _userId {
    if (_isMockMode) return 'mock_user_id';
    return _auth!.currentUser!.uid;
  }

  // Import tracks from device
  Future<List<Track>> importTracks() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result == null) return [];

      final tracks = <Track>[];

      for (final file in result.files) {
        if (file.path == null) continue;

        // Note: For web, file.path might be null in some versions, bytes are used.
        // But assuming non-web file picker behavior generally available or handled.
        // If web, likely need different handling for bytes.
        // Keeping logical parity with original code.

        final track = Track.fromFilePath(file.path!, _userId);

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
            '${DateTime.now().millisecondsSinceEpoch}_${tracks.length}';

        final trackWithDuration = Track(
          id: uniqueId, // Override ID to be unique
          title: track.title,
          artist: track.artist,
          album: track.album,
          filePath: track.filePath,
          duration: duration,
          dateAdded: track.dateAdded,
          userId: track.userId,
        );

        tracks.add(trackWithDuration);

        // Save to Firestore (Mock check inside)
        await saveTrackToFirestore(trackWithDuration);
      }

      return tracks;
    } catch (e) {
      print('Error importing tracks: $e');
      rethrow;
    }
  }

  // Save track to Firestore
  Future<void> saveTrackToFirestore(Track track) async {
    if (_isMockMode) return;
    await _firestore!.collection('tracks').doc(track.id).set(track.toJson());
  }

  // Get all user's tracks
  Stream<List<Track>> getAllTracks() {
    if (_isMockMode) {
      return Stream.value([
        Track(
          id: 'mock_track_1',
          title: 'Demo Track 1',
          artist: 'DJ Clone',
          album: 'Greatest Hits',
          filePath: 'assets/audio/demo1.mp3', // Placeholder
          duration: const Duration(minutes: 3),
          dateAdded: DateTime.now(),
          userId: 'mock_user_id',
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
          userId: 'mock_user_id',
          bpm: 124.0,
        ),
      ]);
    }

    return _firestore!
        .collection('tracks')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Track.fromJson(doc.data()))
              .toList();
        });
  }

  // Search tracks
  Future<List<Track>> searchTracks(String query) async {
    // For simplicity, just return getAllTracks mocked data if mock
    if (_isMockMode) return []; // Or implement mock search

    final snapshot = await _firestore!
        .collection('tracks')
        .where('userId', isEqualTo: _userId)
        .get();

    final allTracks = snapshot.docs
        .map((doc) => Track.fromJson(doc.data()))
        .toList();

    if (query.isEmpty) return allTracks;

    final lowerQuery = query.toLowerCase();

    return allTracks.where((track) {
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
        ); // Case-insensitive sort
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
    if (_isMockMode) return;
    await _firestore!.collection('tracks').doc(trackId).delete();
  }
}

enum SortOption { title, artist, dateAdded, bpm }
