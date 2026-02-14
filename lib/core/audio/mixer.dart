import '../../core/audio/deck_controller.dart';
import '../../core/models/deck_state.dart';

class Mixer {
  final DeckController deckA;
  final DeckController deckB;

  // Channel volumes (faders)
  double _channelVolumeA = 1.0;
  double _channelVolumeB = 1.0;

  // Crossfader position (-1.0 = full A, 1.0 = full B)
  double _crossfaderPosition = 0.0;

  // Master volume (0.0 to 1.0)
  double _masterVolume = 1.0;

  Mixer({required this.deckA, required this.deckB});

  void setChannelVolume(DeckSide side, double volume) {
    if (side == DeckSide.A) {
      _channelVolumeA = volume;
    } else {
      _channelVolumeB = volume;
    }
    _applyMixing();
  }

  // Set crossfader position
  void setCrossfaderPosition(double position) {
    _crossfaderPosition = position.clamp(-1.0, 1.0);
    _applyMixing();
  }

  // Set master volume
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    _applyMixing();
  }

  // Apply mixing volumes to decks
  void _applyMixing() {
    double factorA = 1.0;
    double factorB = 1.0;

    // Linear crossfade
    if (_crossfaderPosition > 0) {
      factorA = 1.0 - _crossfaderPosition;
    } else if (_crossfaderPosition < 0) {
      factorB = 1.0 + _crossfaderPosition;
    }

    final volA = _channelVolumeA * factorA * _masterVolume;
    final volB = _channelVolumeB * factorB * _masterVolume;

    deckA.setVolume(volA);
    deckB.setVolume(volB);
  }

  double get crossfaderPosition => _crossfaderPosition;
  double get masterVolume => _masterVolume;

  void dispose() {
    // any needed cleanup
  }
}
