import 'dart:async';
import 'dart:math' as math;

enum AudioEffectType {
  none,
  echo,
  reverb,
  flanger,
  filter,
  gater;

  String get label {
    switch (this) {
      case AudioEffectType.none:
        return 'None';
      case AudioEffectType.echo:
        return 'Echo';
      case AudioEffectType.reverb:
        return 'Reverb';
      case AudioEffectType.flanger:
        return 'Flanger';
      case AudioEffectType.filter:
        return 'Filter';
      case AudioEffectType.gater:
        return 'Gater';
    }
  }

  /// Short description for the X axis on the pad
  String get xAxisLabel {
    switch (this) {
      case AudioEffectType.filter:
        return 'Freq →';
      case AudioEffectType.gater:
        return 'Depth →';
      case AudioEffectType.echo:
        return 'Delay →';
      case AudioEffectType.reverb:
        return 'Size →';
      case AudioEffectType.flanger:
        return 'Speed →';
      case AudioEffectType.none:
        return 'X';
    }
  }

  /// Short description for the Y axis on the pad
  String get yAxisLabel {
    switch (this) {
      case AudioEffectType.filter:
        return '↑ Reso';
      case AudioEffectType.gater:
        return '↑ Rate';
      case AudioEffectType.echo:
        return '↑ Feedback';
      case AudioEffectType.reverb:
        return '↑ Mix';
      case AudioEffectType.flanger:
        return '↑ Depth';
      case AudioEffectType.none:
        return 'Y';
    }
  }

  /// Icon for the effect button
  String get emoji {
    switch (this) {
      case AudioEffectType.filter:
        return '⌘';
      case AudioEffectType.gater:
        return '⚡';
      case AudioEffectType.echo:
        return '◎';
      case AudioEffectType.reverb:
        return '❋';
      case AudioEffectType.flanger:
        return '≋';
      case AudioEffectType.none:
        return '○';
    }
  }
}

// ---------------------------------------------------------------------------
// EffectsProcessor
// ---------------------------------------------------------------------------

class EffectsProcessor {
  // Callbacks for DeckController to apply changes
  Function(double low, double mid, double high)? onEqChanged;
  Function(double volume)? onVolumeChanged;

  // ── State ──────────────────────────────────────────────────────────────────
  AudioEffectType _currentEffect = AudioEffectType.none;
  bool _isActive = false;

  // Current XY pad position (0.0–1.0)
  double _padX = 0.5;
  double _padY = 0.5;

  // ── Filter ─────────────────────────────────────────────────────────────────
  // (simulated via EQ callbacks)

  // ── Gater ──────────────────────────────────────────────────────────────────
  Timer? _gaterTimer;
  bool _gaterMute = false;
  int _currentGaterIntervalMs = 0;
  double _gaterDepth = 0.5;

  // ── Echo ───────────────────────────────────────────────────────────────────
  // We simulate echo by volume-ducking in a rhythmic pattern and using a
  // software delay ring buffer that drives the EQ / volume callbacks.
  // Max delay: ~1 second at 44100 Hz — but since we have no raw PCM access
  // in just_audio on mobile, we approximate using volume callbacks
  // that replay the attenuation pattern.
  Timer? _echoTimer;
  final _EchoState _echoState = _EchoState();

  // ── Reverb ─────────────────────────────────────────────────────────────────
  Timer? _reverbTimer;
  final _ReverbState _reverbState = _ReverbState();

  // ── Flanger ────────────────────────────────────────────────────────────────
  Timer? _flangerTimer;
  final _FlangerState _flangerState = _FlangerState();

  // ── Constructor ────────────────────────────────────────────────────────────

  EffectsProcessor();

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> setEffect(AudioEffectType type) async {
    _stopAll();
    _currentEffect = type;
    if (_isActive) {
      _startEffect();
    }
  }

  Future<void> setWetDry(double val) async {
    // Placeholder — wet/dry stored in DeckState and shown on UI knob
  }

  /// Called by DeckController whenever the X/Y pad position changes.
  Future<void> updateXY(double x, double y) async {
    _padX = x.clamp(0.0, 1.0);
    _padY = y.clamp(0.0, 1.0);
    if (!_isActive) return;

    switch (_currentEffect) {
      case AudioEffectType.filter:
        _applyFilter(_padX, _padY);
      case AudioEffectType.gater:
        _updateGater(_padX, _padY);
      case AudioEffectType.echo:
        _echoState.update(_padX, _padY);
      case AudioEffectType.reverb:
        _reverbState.update(_padX, _padY);
      case AudioEffectType.flanger:
        _flangerState.update(_padX, _padY);
      case AudioEffectType.none:
        break;
    }
  }

  Future<void> setActive(bool active) async {
    _isActive = active;
    if (!active) {
      _stopAll();
      // Restore defaults
      onEqChanged?.call(1.0, 1.0, 1.0);
      onVolumeChanged?.call(1.0);
    } else {
      _startEffect();
    }
  }

  void dispose() {
    _stopAll();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _startEffect() {
    switch (_currentEffect) {
      case AudioEffectType.echo:
        _startEcho();
      case AudioEffectType.reverb:
        _startReverb();
      case AudioEffectType.flanger:
        _startFlanger();
      case AudioEffectType.gater:
        _updateGater(_padX, _padY);
      case AudioEffectType.filter:
        _applyFilter(_padX, _padY);
      case AudioEffectType.none:
        break;
    }
  }

  void _stopAll() {
    _stopGater();
    _stopEcho();
    _stopReverb();
    _stopFlanger();
  }

  // ── Filter ─────────────────────────────────────────────────────────────────

  void _applyFilter(double x, double y) {
    // X: Frequency sweep — 0=full low pass, 0.5=flat, 1=full high pass
    // Y: Resonance — simulated as exaggerating the cut (mix between flat and full cut)
    double resonance = 0.3 + y * 0.7; // 0.3–1.0

    double low = 1.0;
    double mid = 1.0;
    double high = 1.0;

    if (x < 0.45) {
      final intensity = ((0.45 - x) / 0.45) * resonance;
      high = 1.0 - intensity;
      mid = 1.0 - intensity * 0.5;
    } else if (x > 0.55) {
      final intensity = ((x - 0.55) / 0.45) * resonance;
      low = 1.0 - intensity;
      mid = 1.0 - intensity * 0.5;
    }
    onEqChanged?.call(low, mid, high);
  }

  // ── Gater ──────────────────────────────────────────────────────────────────

  void _updateGater(double x, double y) {
    // Y: Rate — bottom=slow (2 Hz), top=fast (20 Hz)
    // X: Depth — how much the volume dips (0=subtle, 1=full silence)
    final rate = 2.0 + (y * 18.0);
    final intervalMs = (1000 / rate / 2).round().clamp(10, 500);
    _gaterDepth = x;

    final needsRestart =
        _gaterTimer == null || _currentGaterIntervalMs != intervalMs;

    if (needsRestart) {
      _startGater(intervalMs);
    }
  }

  void _startGater(int intervalMs) {
    _stopGater();
    _currentGaterIntervalMs = intervalMs;
    _gaterTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (!_isActive || _currentEffect != AudioEffectType.gater) {
        _stopGater();
        onVolumeChanged?.call(1.0);
        return;
      }
      _gaterMute = !_gaterMute;
      onVolumeChanged?.call(_gaterMute ? (1.0 - _gaterDepth) : 1.0);
    });
  }

  void _stopGater() {
    _gaterTimer?.cancel();
    _gaterTimer = null;
    _gaterMute = false;
  }

  // ── Echo ───────────────────────────────────────────────────────────────────
  //
  // Strategy: We modulate volume in a rhythmic decay pattern.
  //   - X = Delay time (50ms – 700ms)
  //   - Y = Feedback (0 = single repeat, 1 = long tail)
  //
  // Every `delayMs` we fire a "repeat" that briefly ducks then restores volume
  // simulating the echo ghost. Multiple iterations with exponential attenuation.

  void _startEcho() {
    _stopEcho();
    _echoState.update(_padX, _padY);
    _echoState.reset();
    _scheduleNextEcho();
  }

  void _scheduleNextEcho() {
    _echoTimer?.cancel();
    if (!_isActive || _currentEffect != AudioEffectType.echo) return;

    _echoTimer = Timer(Duration(milliseconds: _echoState.delayMs), () {
      if (!_isActive || _currentEffect != AudioEffectType.echo) return;
      // Fire a ghost: drop volume briefly
      _echoState.iteration++;
      final attenuation = math
          .pow(1.0 - _echoState.feedback, _echoState.iteration)
          .toDouble();
      if (attenuation > 0.04 && _echoState.iteration <= 8) {
        // Brief duck — volume at ghost level
        onVolumeChanged?.call(attenuation.clamp(0.0, 0.85));
        // Restore after a short "ghost" duration (1/4 of delay)
        Timer(Duration(milliseconds: (_echoState.delayMs * 0.25).round()), () {
          if (_isActive && _currentEffect == AudioEffectType.echo) {
            onVolumeChanged?.call(1.0);
          }
        });
        // Schedule next repeat
        _scheduleNextEcho();
      } else {
        // Tail complete — restore and wait for next trigger
        onVolumeChanged?.call(1.0);
        _echoState.reset();
      }
    });
  }

  void _stopEcho() {
    _echoTimer?.cancel();
    _echoTimer = null;
    onVolumeChanged?.call(1.0);
  }

  // ── Reverb ─────────────────────────────────────────────────────────────────
  //
  // Strategy: Simulate reverb decay using multiple EQ band modulations
  // that gradually flatten toward silence and back.
  //   - X = Room size (how long the tail lasts)
  //   - Y = Mix / wet amount (how pronounced the reverb colours the sound)
  //
  // Implementation: A periodic "shimmer" timer that oscillates the EQ
  // across highs and mids with a decaying envelope to simulate the
  // diffuse reflections of reverb.

  void _startReverb() {
    _stopReverb();
    _reverbState.update(_padX, _padY);
    int tick = 0;
    _reverbTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!_isActive || _currentEffect != AudioEffectType.reverb) {
        _stopReverb();
        return;
      }
      tick++;
      _reverbState.update(_padX, _padY);
      // Decay envelope oscillating the EQ shimmer
      final elapsed = (tick * 40) / (_reverbState.tailMs);
      final envelope = math.exp(-elapsed * 2.5);
      if (envelope < 0.01) {
        tick = 0; // repeat forever while active
        onEqChanged?.call(1.0, 1.0, 1.0);
        return;
      }
      // Alternating high-mid shimmer
      final shimmer = math.sin(tick * 0.4) * _reverbState.mix * envelope;
      final high = (1.0 + shimmer * 0.25).clamp(0.0, 1.4);
      final mid = (1.0 + shimmer * 0.12).clamp(0.0, 1.2);
      onEqChanged?.call(1.0, mid, high);
    });
  }

  void _stopReverb() {
    _reverbTimer?.cancel();
    _reverbTimer = null;
    onEqChanged?.call(1.0, 1.0, 1.0);
  }

  // ── Flanger ────────────────────────────────────────────────────────────────
  //
  // Strategy: A classic flanger sweeps a comb-filter delay (0.1ms–10ms)
  // with an LFO. We simulate it via oscillating EQ peaks/notches.
  //   - X = LFO Rate (slow sweep → fast sweep)
  //   - Y = Depth (subtle → extreme sweep width)

  void _startFlanger() {
    _stopFlanger();
    _flangerState.update(_padX, _padY);
    int tick = 0;
    _flangerTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!_isActive || _currentEffect != AudioEffectType.flanger) {
        _stopFlanger();
        return;
      }
      tick++;
      _flangerState.update(_padX, _padY);
      // LFO phase
      final lfoPhase = tick * _flangerState.rateRadPerTick;
      final lfo = math.sin(lfoPhase); // -1 to 1

      // Depth scales the EQ sweep
      final depth = _flangerState.depth;
      // Sweep highs and mids in opposite phase (comb-filter simulation)
      final high = (1.0 + lfo * depth * 0.5).clamp(0.0, 1.6);
      final mid = (1.0 - lfo * depth * 0.3).clamp(0.0, 1.4);
      final low = (1.0 + lfo * depth * 0.1).clamp(0.0, 1.2);
      onEqChanged?.call(low, mid, high);
    });
  }

  void _stopFlanger() {
    _flangerTimer?.cancel();
    _flangerTimer = null;
    onEqChanged?.call(1.0, 1.0, 1.0);
  }
}

// ── Effect-specific state holders ─────────────────────────────────────────

class _EchoState {
  int delayMs = 300;
  double feedback = 0.5;
  int iteration = 0;

  void update(double x, double y) {
    delayMs = (50 + x * 650).round(); // 50ms – 700ms
    feedback = y.clamp(0.0, 0.92); // 0 = no repeats, 0.92 = long sustain
  }

  void reset() => iteration = 0;
}

class _ReverbState {
  int tailMs = 1200;
  double mix = 0.5;

  void update(double x, double y) {
    tailMs = (300 + x * 3700).round(); // 300ms – 4s
    mix = y.clamp(0.0, 1.0);
  }
}

class _FlangerState {
  double rateRadPerTick = 0.03;
  double depth = 0.4;

  void update(double x, double y) {
    // X: rate — slow (0.005 rad/tick) to fast (0.18 rad/tick)
    rateRadPerTick = 0.005 + x * 0.175;
    depth = (0.05 + y * 0.95).clamp(0.05, 1.0);
  }
}
