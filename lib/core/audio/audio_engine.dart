import '../../core/audio/deck_controller.dart';
import '../../core/audio/mixer.dart';
import '../../core/models/deck_state.dart';

class AudioEngine {
  // Singleton pattern
  static final AudioEngine instance = AudioEngine._internal();
  factory AudioEngine() => instance;
  AudioEngine._internal();

  // Two independent deck controllers
  late DeckController deckA;
  late DeckController deckB;

  // Mixer for crossfading
  late Mixer mixer;

  // Initialize both decks
  Future<void> initialize() async {
    deckA = DeckController(deckSide: DeckSide.A);
    deckB = DeckController(deckSide: DeckSide.B);
    mixer = Mixer(deckA: deckA, deckB: deckB);

    await deckA.initialize();
    await deckB.initialize();
  }

  // Cleanup
  void dispose() {
    deckA.dispose();
    deckB.dispose();
    mixer.dispose();
  }
}
