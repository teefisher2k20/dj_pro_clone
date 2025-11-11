import 'package:flutter/material.dart';

/// Represents a music track with metadata and audio analysis
class Track {
  final String id;
  final String filePath;
  final String title;
  final String artist;
  final Duration duration;
  final double? bpm;
  final String? key; // Musical key (e.g., "Am", "C#")
  final List<CuePoint> cuePoints;
  final List<double>? waveformData;
  final DateTime? analyzedAt;
  final String? albumArt;

  const Track({
    required this.id,
    required this.filePath,
    required this.title,
    required this.artist,
    required this.duration,
    this.bpm,
    this.key,
    this.cuePoints = const [],
    this.waveformData,
    this.analyzedAt,
    this.albumArt,
  });

  Track copyWith({
    String? id,
    String? filePath,
    String? title,
    String? artist,
    Duration? duration,
    double? bpm,
    String? key,
    List<CuePoint>? cuePoints,
    List<double>? waveformData,
    DateTime? analyzedAt,
    String? albumArt,
  }) {
    return Track(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      bpm: bpm ?? this.bpm,
      key: key ?? this.key,
      cuePoints: cuePoints ?? this.cuePoints,
      waveformData: waveformData ?? this.waveformData,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      albumArt: albumArt ?? this.albumArt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'title': title,
      'artist': artist,
      'duration': duration.inMilliseconds,
      'bpm': bpm,
      'key': key,
      'cuePoints': cuePoints.map((cp) => cp.toJson()).toList(),
      'analyzedAt': analyzedAt?.toIso8601String(),
      'albumArt': albumArt,
    };
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      duration: Duration(milliseconds: json['duration'] as int),
      bpm: json['bpm'] as double?,
      key: json['key'] as String?,
      cuePoints: (json['cuePoints'] as List<dynamic>?)
              ?.map((cp) => CuePoint.fromJson(cp as Map<String, dynamic>))
              .toList() ??
          [],
      analyzedAt: json['analyzedAt'] != null
          ? DateTime.parse(json['analyzedAt'] as String)
          : null,
      albumArt: json['albumArt'] as String?,
    );
  }
}

/// Represents a cue point (hot cue) in a track
class CuePoint {
  final int id;
  final Duration position;
  final String? label;
  final Color color;

  const CuePoint({
    required this.id,
    required this.position,
    this.label,
    this.color = Colors.red,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position.inMilliseconds,
      'label': label,
      'color': color.value,
    };
  }

  factory CuePoint.fromJson(Map<String, dynamic> json) {
    return CuePoint(
      id: json['id'] as int,
      position: Duration(milliseconds: json['position'] as int),
      label: json['label'] as String?,
      color: Color(json['color'] as int),
    );
  }
}

/// Represents the state of a single deck
class DeckState {
  final Track? loadedTrack;
  final Duration currentPosition;
  final bool isPlaying;
  final double volume; // 0.0 to 1.0
  final double tempo; // 0.5 to 2.0 (50% to 200%)
  final bool keyLockEnabled;
  final Map<String, dynamic> activeEffects;

  const DeckState({
    this.loadedTrack,
    this.currentPosition = Duration.zero,
    this.isPlaying = false,
    this.volume = 1.0,
    this.tempo = 1.0,
    this.keyLockEnabled = false,
    this.activeEffects = const {},
  });

  DeckState copyWith({
    Track? loadedTrack,
    Duration? currentPosition,
    bool? isPlaying,
    double? volume,
    double? tempo,
    bool? keyLockEnabled,
    Map<String, dynamic>? activeEffects,
  }) {
    return DeckState(
      loadedTrack: loadedTrack ?? this.loadedTrack,
      currentPosition: currentPosition ?? this.currentPosition,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      tempo: tempo ?? this.tempo,
      keyLockEnabled: keyLockEnabled ?? this.keyLockEnabled,
      activeEffects: activeEffects ?? this.activeEffects,
    );
  }
}
