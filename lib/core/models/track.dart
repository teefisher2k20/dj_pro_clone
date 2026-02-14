class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String filePath;
  final Duration duration;
  final DateTime dateAdded;
  final String userId; // NEW
  double? bpm; // NEW (will be set in PROMPT_06)
  String? musicalKey; // NEW (will be set in PROMPT_06)
  String? genre; // NEW
  String? artworkPath; // NEW
  // Phase 1 - Phrase Sync
  int phraseCount; // Standard is 32 (8 bars of 4/4) or 16.
  double phraseOffset; // Time in seconds where first phrase starts (Downbeat)
  Map<double, double>? bpmMap; // Fluid Grid: Timestamp -> BPM

  Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album = 'Unknown Album',
    required this.filePath,
    required this.duration,
    required this.dateAdded,
    required this.userId,
    this.bpm,
    this.musicalKey,
    this.genre,
    this.artworkPath,
    this.phraseCount = 32,
    this.phraseOffset = 0.0,
    this.bpmMap,
  });

  // Firestore serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'filePath': filePath,
      'duration': duration.inMilliseconds,
      'dateAdded': dateAdded.toIso8601String(),
      'userId': userId,
      'bpm': bpm,
      'musicalKey': musicalKey,
      'genre': genre,
      'artworkPath': artworkPath,
      'phraseCount': phraseCount,
      'phraseOffset': phraseOffset,
      'bpmMap': bpmMap?.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'] ?? 'Unknown Album',
      filePath: json['filePath'],
      duration: Duration(milliseconds: json['duration']),
      dateAdded: DateTime.parse(json['dateAdded']),
      userId: json['userId'],
      bpm: json['bpm']?.toDouble(),
      musicalKey: json['musicalKey'],
      genre: json['genre'],
      artworkPath: json['artworkPath'],
      phraseCount: json['phraseCount'] ?? 32,
      phraseOffset: json['phraseOffset']?.toDouble() ?? 0.0,
      bpmMap: (json['bpmMap'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(double.parse(key), value as double),
      ),
    );
  }

  // Create from file path (extract metadata)
  factory Track.fromFilePath(String filePath, String userId) {
    final fileName = filePath
        .split('/')
        .last
        .split('\\')
        .last; // Handle both Unix and Windows
    final nameWithoutExt = fileName.replaceAll(
      RegExp(r'\.(mp3|wav|m4a|flac)$', caseSensitive: false),
      '',
    );

    // Try to parse "Artist - Title" format
    String title = nameWithoutExt;
    String artist = 'Unknown Artist';

    if (nameWithoutExt.contains(' - ')) {
      final parts = nameWithoutExt.split(' - ');
      artist = parts[0].trim();
      title = parts[1].trim();
    }

    return Track(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      artist: artist,
      filePath: filePath,
      duration: Duration.zero, // Will be updated after loading
      dateAdded: DateTime.now(),
      userId: userId,
    );
  }
}
