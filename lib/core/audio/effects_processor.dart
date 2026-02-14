import 'package:just_audio/just_audio.dart';
import 'dart:async';

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
}

class EffectsProcessor {
  final AudioPlayer _player;

  // State
  AudioEffectType _currentEffect = AudioEffectType.none;
  bool _isActive = false;

  // Filter State
  // We use AndroidEqualizer or basic EQ if available.
  // just_audio doesn't have built-in filter, so we'll simulate with EQ.
  // Note: This requires the platform to support AndroidEqualizer or similar.
  // For this MVF (Minimum Viable Feature), we might only implement Volume Gater if EQ is not accessible.
  // However, DeckController has setEqualizer(low, mid, high). We can use that!

  // Gater State
  Timer? _gaterTimer;
  bool _gaterMute = false;
  double _gaterRate = 0.5; // Hz or division
  double _gaterDepth = 0.5; // Volume dip

  EffectsProcessor(this._player);

  Future<void> setEffect(AudioEffectType type) async {
    _currentEffect = type;
    if (!_isActive) return;

    // Reset any previous effect state
    _stopGater();
    // Reset Filter (via DeckController logic ideally, but here we might need a callback or ref)
    // For now, let's assume DeckController handles the EQ reset when FX is disabled
  }

  Future<void> setWetDry(double val) async {
    // Implement wet/dry mix logic here
    // For now, this is a placeholder to satisfy the interface
  }

  // Update effect parameters based on X/Y pad (0.0 to 1.0)
  // This should be called by DeckController
  Future<void> updateXY(double x, double y) async {
    if (!_isActive) return;

    if (_currentEffect == AudioEffectType.filter) {
      _applyFilter(x, y);
    } else if (_currentEffect == AudioEffectType.gater) {
      _applyGater(x, y);
    }
  }

  Future<void> _applyFilter(double x, double y) async {
    // X-axis: Frequency (Low Pass < 0.5 < High Pass)
    // Y-axis: Resonance (Not easily simulation with 3-band EQ, so maybe use Y for Depth)

    // Simulating Filter with 3-Band EQ:
    // Left (0.0) -> Low Pass (Cut Highs/Mids)
    // Center (0.5) -> Flat
    // Right (1.0) -> High Pass (Cut Lows/Mids)

    double low = 1.0;
    double mid = 1.0;
    double high = 1.0;

    if (x < 0.45) {
      // Low Pass: Cut High and Mid
      // Intensity based on how far left
      double intensity = (0.45 - x) / 0.45; // 0 to 1
      high = 1.0 - intensity;
      mid = 1.0 - (intensity * 0.5);
    } else if (x > 0.55) {
      // High Pass: Cut Low and Mid
      double intensity = (x - 0.55) / 0.45; // 0 to 1
      low = 1.0 - intensity;
      mid = 1.0 - (intensity * 0.5);
    }

    // We need a way to apply this to the player.
    // Since DeckController manages the EQ, EffectsProcessor needs access to it or returns values.
    // Ideally, EffectsProcessor should be able to manipulate the audio pipeline.
    // Since just_audio uses platform EQ, and we don't have direct ref here...
    // We will emit these values via a callback or Stream?
    // Or better: DeckController calls this, and we return the desired EQ state?
    // Actually, DeckController owns EffectsProcessor.
    // DeckController should handle the EQ applying if it owns the EQ.

    // REFACTOR: Let's just store the desired EQ offsets here, and DeckController reads them.
    // _filterGainLow = low; ...

    // Apply EQ
    onEqChanged?.call(low, mid, high);
  }

  // Callbacks for DeckController to apply changes
  Function(double low, double mid, double high)? onEqChanged;
  Function(double volume)? onVolumeChanged;

  void _applyGater(double x, double y) {
    // Y-axis: Rate (Top = Fast, Bottom = Slow)
    // X-axis: Depth (Right = Full silence, Left = Subtle)

    // Rate: 2Hz to 20Hz
    double rate = 2.0 + (y * 18.0);
    int ms = (1000 / rate / 2).round(); // Half cycle duration
    if (ms < 10) ms = 10;

    _gaterRate = rate;
    _gaterDepth = x;

    if (_gaterTimer == null || !_gaterTimer!.isActive) {
      _startGater(ms);
    }
  }

  void _startGater(int intervalMs) {
    _stopGater();
    _gaterTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!_isActive || _currentEffect != AudioEffectType.gater) {
        _stopGater();
        onVolumeChanged?.call(1.0);
        return;
      }

      _gaterMute = !_gaterMute;
      // If muted, reduce volume by depth
      double vol = _gaterMute ? (1.0 - _gaterDepth) : 1.0;
      onVolumeChanged?.call(vol);

      // Update timer if rate changed substantially?
      // Simplify: Fixed rate for now or tricky logic.
      // For smooth rate changes, we'd need a tick loop.
    });
  }

  void _stopGater() {
    _gaterTimer?.cancel();
    _gaterTimer = null;
    _gaterMute = false;
    onVolumeChanged?.call(1.0); // Restore volume
  }

  Future<void> setActive(bool active) async {
    _isActive = active;
    if (!active) {
      _stopGater();
      // Reset filter
      onEqChanged?.call(1.0, 1.0, 1.0);
    }
  }

  void dispose() {
    _stopGater();
  }
}
