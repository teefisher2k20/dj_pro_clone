import 'package:file_picker/file_picker.dart';
import '../../core/models/track.dart';
import 'package:just_audio/just_audio.dart'; // import just_audio
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // import firebase_auth

class FileService {
  String get _userId {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
      }
    } catch (e) {
      print("[FileService] Firebase not initialized: $e");
    }
    return 'mock_user_id'; // Default to mock user if Firebase is unavailable
  }

  // Pick audio file from device
  Future<Track?> pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        // Assuming we have basic metadata extraction logic here
        // or we rely on 'just_audio' duration post-load.

        final player = AudioPlayer(); // Temporary player just for metadata
        try {
          final duration = await player.setFilePath(filePath);
          final track = Track.fromFilePath(filePath, _userId);

          // Refine duration if possible
          if (duration != null) {
            return Track(
              id: track.id,
              title: track.title,
              artist: track.artist,
              filePath: filePath,
              duration: duration,
              dateAdded: track.dateAdded,
              userId: _userId,
            );
          }
          return track;
        } catch (e) {
          print("Error getting duration: $e");
          return Track.fromFilePath(filePath, _userId); // Fallback
        } finally {
          player.dispose(); // Clean up temporary player
        }
      }
      return null; // User canceled
    } catch (e) {
      print("Error picking file: $e");
      return null;
    }
  }

  // Extract metadata from file (Placeholder for more complex logic)
  Future<Track> extractMetadata(String filePath) async {
    // In a real app, use a metadata library.
    // Here we'll just simulate it or rely on file name.
    return Track.fromFilePath(filePath, _userId);
  }

  // Supported formats
  static const supportedFormats = ['mp3', 'wav', 'm4a', 'aac', 'flac'];
}
