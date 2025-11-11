# DJ Pro Clone - AI Coding Assistant Instructions

## Project Overview

This is a Flutter-based DJ Pro clone application focused on providing professional DJ software capabilities including audio mixing, effects processing, and playlist management for cross-platform deployment (iOS, Android, desktop).

## Architecture Principles

### Audio Processing Core

- **Real-time Audio**: All audio processing must maintain low-latency performance (<10ms)
- **Platform Channels**: Use method channels for native audio processing (Android: AudioTrack/MediaPlayer, iOS: AVAudioEngine)
- **Isolates**: Leverage Dart isolates for heavy audio analysis (BPM detection, waveform generation) to avoid blocking UI
- **FFI Integration**: Consider using `dart:ffi` for performance-critical audio processing with native libraries

### Project Structure

```plaintext
lib/
├── audio/              # Audio engine and native integration
│   ├── engine/        # Core audio processing
│   ├── effects/       # Audio effects and filters
│   └── analyzers/     # BPM, key detection, waveform
├── ui/                # Flutter UI components
│   ├── screens/       # Main app screens
│   ├── widgets/       # Reusable widgets
│   └── themes/        # App theming
├── features/
│   ├── mixing/        # Crossfader, EQ, mixer controls
│   ├── playlist/      # Track management and playlists
│   └── library/       # Music library and browsing
├── models/            # Data models
├── services/          # Business logic and state management
└── utils/             # Shared utilities and helpers

android/
└── app/src/main/kotlin/  # Android audio implementation

ios/
└── Runner/               # iOS audio implementation
```

## Development Patterns

### State Management

- **Provider/Riverpod**: Use for audio state, playlist, and UI state management
- **ChangeNotifier**: For audio parameters (gain, EQ, effects) with proper disposal
- **StreamController**: For real-time audio metrics and waveform data
- Implement undo/redo stack for mixer settings and playlist operations

### Audio Architecture

- Create `AudioService` singleton for platform channel communication
- Use `StreamBuilder` for reactive audio visualizations
- Implement `AudioSession` management for handling interruptions (calls, other apps)
- Cache decoded audio metadata (BPM, key, waveform) in local database

### Performance Considerations

- **CustomPainter**: Use for high-performance waveform and spectrum visualizations
- **RepaintBoundary**: Wrap static UI elements to avoid unnecessary repaints
- **Compute Function**: Offload heavy computations to isolates
- **Image Caching**: Cache album art with `CachedNetworkImage`
- **Lazy Loading**: Use `ListView.builder` for large playlists

### File Handling

- Use `file_picker` package for audio file selection
- Support formats: MP3, FLAC, WAV, M4A, AAC
- Implement `path_provider` for persistent storage of settings and cache
- Handle permissions properly (storage access on Android/iOS)

### Dual Deck Pattern

- Maintain two independent `AudioPlayer` instances (Deck A and Deck B)
- Synchronize playback using beat grid alignment
- Implement tempo adjustment independently per deck (pitch bend, tempo slider)
- Use separate volume controls with master output mixing

### Crossfader Implementation

```dart
// Crossfader value: -1.0 (full Deck A) to 1.0 (full Deck B)
double calculateDeckVolume(double crossfaderPosition, bool isDeckA) {
  if (isDeckA) {
    return crossfaderPosition <= 0 ? 1.0 : 1.0 - crossfaderPosition;
  } else {
    return crossfaderPosition >= 0 ? 1.0 : 1.0 + crossfaderPosition;
  }
}
```

## Key Integrations

### Flutter Packages

- `just_audio` or `audioplayers`: Primary audio playback
- `audio_service`: Background audio and media controls
- `provider` or `riverpod`: State management
- `sqflite`: Local database for track metadata and playlists
- `path_provider`: File system access
- `permission_handler`: Runtime permissions

### Platform-Specific Audio

- **Android**: Use `AudioTrack` for low-latency playback, `MediaCodec` for decoding
- **iOS**: Leverage `AVAudioEngine` for real-time effects and mixing
- **Desktop**: Consider `miniaudio` or `PortAudio` via FFI

### Audio Analysis

- Implement BPM detection using autocorrelation in isolate
- Real-time spectrum analysis via FFT (native implementation for performance)
- Peak detection for automatic gain control and beat matching

## Testing Approach

- **Widget Tests**: Test UI components in isolation
- **Unit Tests**: Mock `AudioService` for business logic testing
- **Integration Tests**: Test audio playback flows with platform channels mocked
- **Golden Tests**: Ensure waveform visualizations render correctly

## Development Workflow

```bash
# Run on Android device/emulator with hot reload
flutter run -d android

# Run on iOS simulator
flutter run -d ios

# Build release APK
flutter build apk --release

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Critical Files

- `lib/audio/audio_service.dart` - Platform channel interface for audio
- `lib/features/mixing/crossfader_widget.dart` - DJ crossfader UI and logic
- `lib/audio/effects/effect_processor.dart` - Audio effects chain
- `lib/ui/widgets/waveform_painter.dart` - Custom waveform visualization
- `android/app/src/main/kotlin/AudioEngine.kt` - Android audio implementation
- `ios/Runner/AudioEngine.swift` - iOS audio implementation

## Common Gotchas

- Always dispose `AudioPlayer` instances and `StreamController`s to prevent memory leaks
- Handle `AudioSession` interruptions (phone calls, notifications)
- Request permissions before accessing audio files or microphone
- Use `compute()` or isolates for CPU-intensive operations to avoid jank
- Implement proper error handling for platform channel calls
- Test on physical devices—audio latency behaves differently than emulators
- Handle hot reload carefully with audio resources (may need full restart)

## Code Style

- Follow official Dart style guide (use `dart format`)
- Use async/await for file operations and audio loading
- Prefer `const` constructors for widgets when possible
- Implement proper lifecycle management (initState, dispose)
- Use meaningful widget names that describe UI structure
- Document complex audio algorithms and platform-specific code
- Keep platform channel method names consistent across iOS/Android

## DJ-Specific Features to Implement

### Beat Synchronization

- Calculate beat grids from BPM and first beat position
- Implement quantization for cue points (snap to beat)
- Visual beat markers on waveform display
- Sync button to match BPM between decks

### Effects Chain

Common DJ effects to implement:

- **Filter**: High-pass/Low-pass cutoff with resonance
- **Echo/Delay**: Feedback delay with beat sync
- **Reverb**: Room simulation for atmosphere
- **Flanger**: Modulated delay for swoosh effect
- **Phaser**: Phase shifting for sweeping sound
- Effects should be bypassable and have wet/dry mix control

### Cue Points

- Store multiple cue points per track (hot cues)
- Visual indicators on waveform
- Instant jump to cue point on trigger
- Export/import cue points with track metadata

### Loop System

- Set loop in/out points with beat quantization
- Auto-loop lengths: 1/8, 1/4, 1/2, 1, 2, 4, 8, 16 beats
- Loop roll (temporary loops that exit on release)
- Smart loop detection (auto-detect suitable loop sections)

### Tempo & Pitch

- Independent tempo adjustment (±50% range typical)
- Pitch bend buttons (temporary speed adjustment)
- Key lock (maintain pitch when changing tempo)
- Master tempo for syncing both decks

## Waveform Visualization Best Practices

```dart
class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double playbackPosition;
  final List<double> beatPositions;
  
  @override
  void paint(Canvas canvas, Size size) {
    // Use RRect for smooth waveform bars
    // Draw beat markers as vertical lines
    // Highlight current playback position
    // Use different colors for played/unplayed sections
  }
  
  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    // Only repaint when playback position or data changes
    return oldDelegate.playbackPosition != playbackPosition ||
           oldDelegate.waveformData != waveformData;
  }
}
```

## Audio Latency Optimization

- Target latency: <10ms for professional feel
- Use native audio APIs (avoid Flutter plugin overhead for time-critical paths)
- Implement audio buffer pooling to reduce GC pressure
- Pre-load next track in adjacent deck for instant playback
- Use double buffering for waveform rendering
- Profile with Android Profiler / Instruments to identify bottlenecks

## Data Models Example

```dart
class Track {
  final String id;
  final String filePath;
  final String title;
  final String artist;
  final Duration duration;
  final double bpm;
  final String? key; // Musical key (e.g., "Am", "C#")
  final List<CuePoint> cuePoints;
  final List<double> waveformData;
  final DateTime? analyzedAt;
}

class CuePoint {
  final int id;
  final Duration position;
  final String? label;
  final Color color;
}

class DeckState {
  final Track? loadedTrack;
  final Duration currentPosition;
  final bool isPlaying;
  final double volume; // 0.0 to 1.0
  final double tempo; // 0.5 to 2.0 (50% to 200%)
  final bool keyLockEnabled;
  final Map<String, EffectState> activeEffects;
}
```

## Performance Monitoring

Track these metrics during development:

- Audio buffer underruns (causes audio dropouts)
- Frame rendering time (keep under 16ms for 60fps)
- Memory usage (watch for audio buffer leaks)
- Platform channel call latency
- BPM detection accuracy (test against known tracks)

## Future Considerations

As the codebase evolves, update this file with:

- Actual file paths and class names
- Proven architectural patterns from implementation
- Discovered performance optimizations
- Common bugs and their solutions
- Integration patterns with third-party services (cloud storage, streaming)

## Quick Reference: Common Tasks

### Adding a New Effect

1. Create effect class in `lib/audio/effects/`
2. Implement `AudioEffect` interface with `process()` method
3. Add effect to `EffectProcessor` chain
4. Create UI control widget in `lib/ui/widgets/effects/`
5. Wire up state management in effect provider
6. Add unit tests for audio processing logic

### Implementing a New Screen

1. Create screen file in `lib/ui/screens/`
2. Define route in `lib/routes.dart`
3. Add navigation logic in parent widget
4. Create required widgets in `lib/ui/widgets/`
5. Add screen tests in `test/ui/screens/`

### Adding Platform-Specific Audio Code

**Android (Kotlin):**

```kotlin
// In AudioEngine.kt
class AudioEngine(private val context: Context) {
    fun processAudio(buffer: FloatArray, sampleRate: Int) {
        // Low-latency audio processing
    }
}
```

**iOS (Swift):**

```swift
// In AudioEngine.swift
class AudioEngine {
    func processAudio(buffer: UnsafeMutablePointer<Float>, frameCount: Int) {
        // Low-latency audio processing
    }
}
```

### Debugging Audio Issues

1. Enable verbose logging in `AudioService`
2. Check buffer sizes: `adb shell dumpsys media.audio_flinger` (Android)
3. Monitor CPU usage during playback
4. Verify sample rates match (44.1kHz or 48kHz)
5. Test with different audio formats
6. Use physical device (emulators have poor audio performance)

## EQ Implementation Pattern

```dart
class ThreeBandEQ {
  // Frequencies: Low (100Hz), Mid (1kHz), High (10kHz)
  double lowGain = 0.0;    // -12dB to +12dB
  double midGain = 0.0;
  double highGain = 0.0;
  
  void applyEQ(AudioBuffer buffer) {
    // Use biquad filters for each band
    // Apply gains in native code for performance
  }
}
```

## Naming Conventions

- **Models**: PascalCase nouns (`Track`, `Playlist`, `CuePoint`)
- **Services**: PascalCase with "Service" suffix (`AudioService`, `LibraryService`)
- **Widgets**: PascalCase with "Widget" suffix (`WaveformWidget`, `CrossfaderWidget`)
- **State classes**: PascalCase with "State" or "Provider" suffix (`DeckState`, `AudioProvider`)
- **Method channels**: lowercase with dots (`com.djpro.audio/playback`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_TEMPO`, `DEFAULT_BPM`)

## Git Workflow

```bash
# Feature branch naming
git checkout -b feature/beat-sync
git checkout -b fix/audio-latency
git checkout -b refactor/audio-engine

# Commit message format
# feat: Add beat synchronization
# fix: Resolve audio dropout on Android
# refactor: Optimize waveform rendering
# docs: Update audio architecture docs
```

## Resources & References

- [Flutter Audio Performance Best Practices](https://flutter.dev/docs/perf)
- [Web Audio API concepts](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API) (for understanding audio theory)
- [DJ TechTools Articles](https://djtechtools.com) (DJ feature inspiration)
- [just_audio package docs](https://pub.dev/packages/just_audio)
- [AVAudioEngine Apple Docs](https://developer.apple.com/documentation/avfaudio/avaudioengine) (iOS)
- [Android AudioTrack Docs](https://developer.android.com/reference/android/media/AudioTrack) (Android)

## AI Assistant Guidelines

When working on this codebase:

- **Audio code changes**: Always consider latency impact and test on physical devices
- **UI updates**: Ensure 60fps performance with `RepaintBoundary` and `const` constructors
- **State changes**: Verify proper disposal to prevent memory leaks
- **Platform code**: Keep iOS/Android implementations synchronized
- **New features**: Start with data model, then service layer, then UI
- **Breaking changes**: Update this file with new patterns and lessons learned

