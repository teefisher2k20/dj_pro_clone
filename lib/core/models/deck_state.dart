import 'package:flutter/material.dart';
import '../../core/models/track.dart';
import '../audio/effects_processor.dart'; // For AudioEffectType

enum DeckSide {
  A,
  B;

  String get label => name;
  Color get color => this == A
      ? const Color(0xFF00D9FF) // Blue for A
      : const Color(0xFFFF8000); // Orange for B
}

class SavedLoop {
  final String id;
  final String name;
  final Duration start;
  final Duration end;
  final Color color;

  const SavedLoop({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    this.color = Colors.greenAccent,
  });
}

class DeckState {
  final Track? track;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double volume;
  final DeckSide side;
  final double tempo;
  final bool isKeyLock;
  final double? detectedBPM;

  // EQ & Gain
  final double highEq; // 0.0 to 1.0, 0.5 is flat
  final double midEq; // 0.0 to 1.0, 0.5 is flat
  final double lowEq; // 0.0 to 1.0, 0.5 is flat
  final double gain; // 0.0 to 1.0, 0.5 is 0dB (nominal)

  // FX Controls
  final AudioEffectType currentEffect;
  final double fxWetDry; // 0.0 to 1.0
  final bool isFxActive;

  // Cue Points
  final List<Duration?> hotCues; // 8 hot cues

  // Looping
  final bool isLoopActive;
  final double loopLength; // In beats, e.g. 4.0
  final Duration? loopInPoint;
  final Duration? loopOutPoint;
  final List<SavedLoop> savedLoops;

  // Stem Separation
  final bool isStemsActive;
  final double vocalsVolume;
  final double drumsVolume;
  final double harmonicsVolume; // Bass/Melody combined or splitting
  final double otherVolume;

  // Phase 2 - Slip Mode
  final bool isSlipActive;
  final Duration? slipGhostPosition;

  // Phase 2 - Quantize
  final bool isQuantizeActive;

  // Phase 2 - Slicer Mode
  final bool isSlicerActive;
  final List<Duration>? slicerSegments;

  // Phase 2 - Pitch Play Mode
  final bool isPitchPlayActive;
  final Duration? pitchPlayCuePoint;
  final List<double>? pitchPlayNotes; // Pitch multipliers for 8 pads

  // Phase 2 - Advanced FX Pad
  final bool isFxPadActive;
  final double fxX; // 0.0 to 1.0
  final double fxY; // 0.0 to 1.0

  DeckState({
    this.track,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 0.8,
    required this.side,
    this.tempo = 1.0,
    this.isKeyLock = false,
    this.detectedBPM,
    this.highEq = 0.5,
    this.midEq = 0.5,
    this.lowEq = 0.5,
    this.gain = 0.5,
    this.currentEffect = AudioEffectType.none,
    this.fxWetDry = 0.0,
    this.isFxActive = false,
    this.hotCues = const [null, null, null, null, null, null, null, null],
    this.isLoopActive = false,
    this.loopLength = 4.0,
    this.loopInPoint,
    this.loopOutPoint,
    this.savedLoops = const [],
    this.isStemsActive = false,
    this.vocalsVolume = 1.0,
    this.drumsVolume = 1.0,
    this.harmonicsVolume = 1.0,
    this.otherVolume = 1.0,
    this.isSlipActive = false,
    this.slipGhostPosition,
    this.isQuantizeActive = false,
    this.isSlicerActive = false,
    this.slicerSegments,
    this.isPitchPlayActive = false,
    this.pitchPlayCuePoint,
    this.pitchPlayNotes,
    this.isFxPadActive = false,
    this.fxX = 0.5,
    this.fxY = 0.5,
  });

  DeckState copyWith({
    Track? track,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? volume,
    DeckSide? side,
    double? tempo,
    bool? isKeyLock,
    double? detectedBPM,
    double? highEq,
    double? midEq,
    double? lowEq,
    double? gain,
    AudioEffectType? currentEffect,
    double? fxWetDry,
    bool? isFxActive,
    List<Duration?>? hotCues,
    bool? isLoopActive,
    double? loopLength,
    Duration? loopInPoint,
    Duration? loopOutPoint,
    List<SavedLoop>? savedLoops,
    bool? isStemsActive,
    double? vocalsVolume,
    double? drumsVolume,
    double? harmonicsVolume,
    double? otherVolume,
    bool? isSlipActive,
    Duration? slipGhostPosition,
    bool? isQuantizeActive,
    bool? isSlicerActive,
    List<Duration>? slicerSegments,
    bool? isPitchPlayActive,
    Duration? pitchPlayCuePoint,
    List<double>? pitchPlayNotes,
    bool? isFxPadActive,
    double? fxX,
    double? fxY,
  }) {
    return DeckState(
      track: track ?? this.track,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      side: side ?? this.side,
      tempo: tempo ?? this.tempo,
      isKeyLock: isKeyLock ?? this.isKeyLock,
      detectedBPM: detectedBPM ?? (track != null ? null : this.detectedBPM),
      highEq: highEq ?? this.highEq,
      midEq: midEq ?? this.midEq,
      lowEq: lowEq ?? this.lowEq,
      gain: gain ?? this.gain,
      currentEffect: currentEffect ?? this.currentEffect,
      fxWetDry: fxWetDry ?? this.fxWetDry,
      isFxActive: isFxActive ?? this.isFxActive,
      hotCues: hotCues ?? this.hotCues,
      isLoopActive: isLoopActive ?? this.isLoopActive,
      loopLength: loopLength ?? this.loopLength,
      loopInPoint: loopInPoint ?? this.loopInPoint,
      loopOutPoint: loopOutPoint ?? this.loopOutPoint,
      savedLoops: savedLoops ?? this.savedLoops,
      isStemsActive: isStemsActive ?? this.isStemsActive,
      vocalsVolume: vocalsVolume ?? this.vocalsVolume,
      drumsVolume: drumsVolume ?? this.drumsVolume,
      harmonicsVolume: harmonicsVolume ?? this.harmonicsVolume,
      otherVolume: otherVolume ?? this.otherVolume,
      isSlipActive: isSlipActive ?? this.isSlipActive,
      slipGhostPosition:
          slipGhostPosition ??
          (isSlipActive == true
              ? (this.slipGhostPosition)
              : null), // Reset ghost if slip turned off
      isQuantizeActive: isQuantizeActive ?? this.isQuantizeActive,
      isSlicerActive: isSlicerActive ?? this.isSlicerActive,
      slicerSegments: slicerSegments ?? this.slicerSegments,
      isPitchPlayActive: isPitchPlayActive ?? this.isPitchPlayActive,
      pitchPlayCuePoint: pitchPlayCuePoint ?? this.pitchPlayCuePoint,
      pitchPlayNotes: pitchPlayNotes ?? this.pitchPlayNotes,
      isFxPadActive: isFxPadActive ?? this.isFxPadActive,
      fxX: fxX ?? this.fxX,
      fxY: fxY ?? this.fxY,
    );
  }
}

enum StemType { vocals, drums, harmonics, other }
