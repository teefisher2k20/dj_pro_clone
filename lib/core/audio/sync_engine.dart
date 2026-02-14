import 'deck_controller.dart';

class SyncEngine {
  static final SyncEngine _instance = SyncEngine._internal();
  factory SyncEngine() => _instance;
  SyncEngine._internal();

  /// Syncs the tempo of the target deck to match the source deck.
  ///
  /// [source] The deck to sync from (Master).
  /// [target] The deck to sync to (Slave).
  /// [sourceBpm] The detected BPM of the source track.
  /// [targetBpm] The detected BPM of the target track.
  /// [sourceTempo] The current tempo slider value of the source (1.0 = 0%).
  Future<double> syncTempo({
    required DeckController target,
    required double sourceBpm,
    required double targetBpm,
    required double sourceTempo,
  }) async {
    if (sourceBpm <= 0 || targetBpm <= 0) return 1.0;

    // Calculate effective BPM of source
    final effectiveSourceBpm = sourceBpm * sourceTempo;

    // Calculate required tempo for target to match effective source BPM
    // targetBpm * targetTempo = effectiveSourceBpm
    // targetTempo = effectiveSourceBpm / targetBpm
    double requiredTempo = effectiveSourceBpm / targetBpm;

    // Clamp to slider range (0.5 to 2.0)
    requiredTempo = requiredTempo.clamp(0.5, 2.0);

    await target.setTempo(requiredTempo);

    return requiredTempo;
  }

  /// Syncs Tempo AND Phase (Beat/Phrase alignment).
  ///
  /// [sourcePosition] Current position of source deck.
  /// [targetPosition] Current position of target deck.
  /// [phraseCount] Number of beats per phrase (default 32).
  Future<double> syncTempoWithPhase({
    required DeckController target,
    required double sourceBpm,
    required double targetBpm,
    required double sourceTempo,
    required Duration sourcePosition,
    required Duration targetPosition,
    int phraseCount = 32,
  }) async {
    // 1. Sync Tempo first
    final newTempo = await syncTempo(
      target: target,
      sourceBpm: sourceBpm,
      targetBpm: targetBpm,
      sourceTempo: sourceTempo,
    );

    // 2. Calculate Beat/Phrase Alignment
    // Effective BPMs
    final effSourceBpm = sourceBpm * sourceTempo;
    final effTargetBpm = targetBpm * newTempo;

    // Beat Durations (ms)
    final sourceBeatDur = 60000 / effSourceBpm;
    final targetBeatDur = 60000 / effTargetBpm;

    // Current Beats (assuming downbeat at 0.0 for now)
    final sourceBeat = sourcePosition.inMilliseconds / sourceBeatDur;
    final targetBeat = targetPosition.inMilliseconds / targetBeatDur;

    // Phrase Positions (where are we in the 0..31 beat cycle?)
    final sourcePhrasePos = sourceBeat % phraseCount;
    // We want target to be at the SAME phrase position, or aligned to next phrase.

    // Calculate difference
    // Target should be at sourcePhrasePos.
    // Current target phrase pos:
    final targetPhrasePos = targetBeat % phraseCount;

    // Delta (in beats) to align
    var beatDelta = sourcePhrasePos - targetPhrasePos;

    // Find shortest path (wrap around)
    // e.g. if we are at 31 and want 0. (+1 beat) vs (-31 beats)
    if (beatDelta > phraseCount / 2) {
      beatDelta -= phraseCount;
    } else if (beatDelta < -phraseCount / 2) {
      beatDelta += phraseCount;
    }

    // Apply correction
    final correctionMs = beatDelta * targetBeatDur;
    final newPosMs = targetPosition.inMilliseconds + correctionMs;

    if (newPosMs >= 0) {
      await target.seek(Duration(milliseconds: newPosMs.round()));
    }

    return newTempo;
  }
}
