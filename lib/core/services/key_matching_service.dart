import 'package:flutter/material.dart';

/// Represents a musical key in the Camelot Wheel system.
class CamelotKey {
  final int number; // 1-12
  final String letter; // A or B (A = minor, B = major)
  final String musicalKey; // e.g. "Am", "C Major"
  final String shortName; // e.g. "A", "C"
  final bool isMajor; // true = major (B), false = minor (A)

  const CamelotKey({
    required this.number,
    required this.letter,
    required this.musicalKey,
    required this.shortName,
    required this.isMajor,
  });

  String get camelotCode => '$number$letter';

  @override
  String toString() => '$camelotCode ($musicalKey)';
}

/// Defines compatibility levels between two tracked keys.
enum KeyCompatibility {
  perfect, // Same key
  sameNumber, // Same number, different letter (e.g. 8A and 8B — relative major/minor)
  adjacent, // +1 or -1 on the wheel (energy boost/gradual shift)
  semitone, // Musical semitone relationships
  incompatible, // No harmonic relationship
}

class KeyMatchingService {
  static const List<CamelotKey> allKeys = [
    // -- Minor Keys (A) --
    CamelotKey(
      number: 1,
      letter: 'A',
      musicalKey: 'A♭ Minor',
      shortName: 'A♭m',
      isMajor: false,
    ),
    CamelotKey(
      number: 2,
      letter: 'A',
      musicalKey: 'E♭ Minor',
      shortName: 'E♭m',
      isMajor: false,
    ),
    CamelotKey(
      number: 3,
      letter: 'A',
      musicalKey: 'B♭ Minor',
      shortName: 'B♭m',
      isMajor: false,
    ),
    CamelotKey(
      number: 4,
      letter: 'A',
      musicalKey: 'F Minor',
      shortName: 'Fm',
      isMajor: false,
    ),
    CamelotKey(
      number: 5,
      letter: 'A',
      musicalKey: 'C Minor',
      shortName: 'Cm',
      isMajor: false,
    ),
    CamelotKey(
      number: 6,
      letter: 'A',
      musicalKey: 'G Minor',
      shortName: 'Gm',
      isMajor: false,
    ),
    CamelotKey(
      number: 7,
      letter: 'A',
      musicalKey: 'D Minor',
      shortName: 'Dm',
      isMajor: false,
    ),
    CamelotKey(
      number: 8,
      letter: 'A',
      musicalKey: 'A Minor',
      shortName: 'Am',
      isMajor: false,
    ),
    CamelotKey(
      number: 9,
      letter: 'A',
      musicalKey: 'E Minor',
      shortName: 'Em',
      isMajor: false,
    ),
    CamelotKey(
      number: 10,
      letter: 'A',
      musicalKey: 'B Minor',
      shortName: 'Bm',
      isMajor: false,
    ),
    CamelotKey(
      number: 11,
      letter: 'A',
      musicalKey: 'F♯ Minor',
      shortName: 'F♯m',
      isMajor: false,
    ),
    CamelotKey(
      number: 12,
      letter: 'A',
      musicalKey: 'D♭ Minor',
      shortName: 'D♭m',
      isMajor: false,
    ),

    // -- Major Keys (B) --
    CamelotKey(
      number: 1,
      letter: 'B',
      musicalKey: 'B Major',
      shortName: 'B',
      isMajor: true,
    ),
    CamelotKey(
      number: 2,
      letter: 'B',
      musicalKey: 'F♯ Major',
      shortName: 'F♯',
      isMajor: true,
    ),
    CamelotKey(
      number: 3,
      letter: 'B',
      musicalKey: 'D♭ Major',
      shortName: 'D♭',
      isMajor: true,
    ),
    CamelotKey(
      number: 4,
      letter: 'B',
      musicalKey: 'A♭ Major',
      shortName: 'A♭',
      isMajor: true,
    ),
    CamelotKey(
      number: 5,
      letter: 'B',
      musicalKey: 'E♭ Major',
      shortName: 'E♭',
      isMajor: true,
    ),
    CamelotKey(
      number: 6,
      letter: 'B',
      musicalKey: 'B♭ Major',
      shortName: 'B♭',
      isMajor: true,
    ),
    CamelotKey(
      number: 7,
      letter: 'B',
      musicalKey: 'F Major',
      shortName: 'F',
      isMajor: true,
    ),
    CamelotKey(
      number: 8,
      letter: 'B',
      musicalKey: 'C Major',
      shortName: 'C',
      isMajor: true,
    ),
    CamelotKey(
      number: 9,
      letter: 'B',
      musicalKey: 'G Major',
      shortName: 'G',
      isMajor: true,
    ),
    CamelotKey(
      number: 10,
      letter: 'B',
      musicalKey: 'D Major',
      shortName: 'D',
      isMajor: true,
    ),
    CamelotKey(
      number: 11,
      letter: 'B',
      musicalKey: 'A Major',
      shortName: 'A',
      isMajor: true,
    ),
    CamelotKey(
      number: 12,
      letter: 'B',
      musicalKey: 'E Major',
      shortName: 'E',
      isMajor: true,
    ),
  ];

  /// Get a key by its Camelot code (e.g. "8A", "8B").
  static CamelotKey? fromCode(String code) {
    final upper = code.toUpperCase();
    try {
      return allKeys.firstWhere((k) => k.camelotCode == upper);
    } catch (_) {
      return null;
    }
  }

  /// Get a key by musical key name (partial match).
  static CamelotKey? fromMusicalName(String name) {
    final lower = name.toLowerCase();
    try {
      return allKeys.firstWhere(
        (k) =>
            k.musicalKey.toLowerCase() == lower ||
            k.shortName.toLowerCase() == lower,
      );
    } catch (_) {
      return null;
    }
  }

  /// Determine compatibility between two keys.
  static KeyCompatibility getCompatibility(CamelotKey a, CamelotKey b) {
    if (a.number == b.number && a.letter == b.letter) {
      return KeyCompatibility.perfect;
    }
    // Same ring position — relative major/minor
    if (a.number == b.number) {
      return KeyCompatibility.sameNumber;
    }
    // Adjacent on the same ring (±1) — perfect blend
    final diff = ((a.number - b.number) % 12 + 12) % 12;
    if (a.letter == b.letter && (diff == 1 || diff == 11)) {
      return KeyCompatibility.adjacent;
    }
    // Diagonally adjacent (same number ±1, different letter)
    if (a.letter != b.letter && (diff == 1 || diff == 11)) {
      return KeyCompatibility.semitone;
    }
    return KeyCompatibility.incompatible;
  }

  /// Get all compatible keys with a given key.
  static List<CamelotKey> getCompatibleKeys(CamelotKey key) {
    return allKeys
        .where((k) => getCompatibility(key, k) != KeyCompatibility.incompatible)
        .toList();
  }

  /// Color for a compatibility level.
  static Color compatibilityColor(KeyCompatibility c) {
    switch (c) {
      case KeyCompatibility.perfect:
        return const Color(0xFF00FF9F); // Green
      case KeyCompatibility.sameNumber:
        return const Color(0xFF00D9FF); // Cyan
      case KeyCompatibility.adjacent:
        return const Color(0xFFFFD700); // Gold
      case KeyCompatibility.semitone:
        return const Color(0xFFFF8C00); // Orange
      case KeyCompatibility.incompatible:
        return Colors.white12;
    }
  }

  /// Label for a compatibility level.
  static String compatibilityLabel(KeyCompatibility c) {
    switch (c) {
      case KeyCompatibility.perfect:
        return 'Perfect';
      case KeyCompatibility.sameNumber:
        return 'Relative';
      case KeyCompatibility.adjacent:
        return 'Compatible';
      case KeyCompatibility.semitone:
        return 'Tension';
      case KeyCompatibility.incompatible:
        return 'Clash';
    }
  }
}
