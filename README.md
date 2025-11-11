# DJ Pro Clone

A professional DJ software application built with Flutter, providing cross-platform audio mixing, effects processing, and playlist management for iOS, Android, and desktop platforms.

## Features (Planned)

- 🎚️ **Dual Deck Mixing**: Independent audio players with professional crossfader
- 🎵 **Audio Effects**: Filter, Echo, Reverb, Flanger, Phaser with wet/dry control
- 📊 **Waveform Visualization**: Real-time audio visualization with beat markers
- 🎯 **Hot Cues**: Multiple cue points per track with instant triggering
- 🔄 **Loop System**: Auto-loops with beat quantization and loop rolls
- ⚡ **Beat Sync**: BPM detection and automatic beat matching
- 🎹 **3-Band EQ**: Dedicated Low, Mid, High frequency control per deck
- 🔊 **Low Latency**: Optimized for <10ms audio latency
- 📱 **Cross-Platform**: iOS, Android, and desktop support

## Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider/Riverpod
- **Audio**: just_audio + native platform channels
- **Database**: sqflite (local metadata storage)
- **Platform Code**: Kotlin (Android), Swift (iOS)

## Project Structure

```plaintext
lib/
├── audio/              # Audio engine and native integration
├── ui/                # Flutter UI components
├── features/          # Feature modules (mixing, playlist, library)
├── models/            # Data models
├── services/          # Business logic
└── utils/             # Shared utilities

android/               # Android native audio implementation
ios/                   # iOS native audio implementation
test/                  # Unit and widget tests
```

## Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / Xcode (for platform-specific builds)
- Physical device recommended (audio latency testing)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/djay_pro_clone.git
cd djay_pro_clone
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run on device:

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Desktop
flutter run -d macos  # or windows/linux
```

### Development Setup

1. Enable developer mode on your device
2. Install Flutter/Dart VS Code extensions
3. Review `.github/copilot-instructions.md` for coding guidelines
4. Run `flutter analyze` before committing

## Development Workflow

```bash
# Run with hot reload
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .

# Build release
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/audio/audio_service_test.dart

# Run with coverage
flutter test --coverage
```

## Architecture

This project follows a feature-based architecture with clear separation of concerns:

- **Audio Layer**: Native platform channels for low-latency audio processing
- **Service Layer**: Business logic and state management
- **UI Layer**: Flutter widgets with reactive updates
- **Data Layer**: Local database and file system access

See `.github/copilot-instructions.md` for detailed architecture documentation.

## Performance Targets

- Audio latency: <10ms
- UI rendering: 60fps
- BPM detection: <2 seconds per track
- Waveform generation: <1 second per track

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the coding guidelines in `.github/copilot-instructions.md`
4. Commit your changes (`git commit -m 'feat: Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by professional DJ software (djay Pro, Traktor, Serato)
- Flutter community for audio plugin development
- Contributors and testers

## Roadmap

### Phase 1: Core Audio (Current)

- [ ] Basic dual deck playback
- [ ] Crossfader implementation
- [ ] Waveform visualization
- [ ] File loading and playback

### Phase 2: DJ Features

- [ ] BPM detection
- [ ] Beat synchronization
- [ ] Hot cues system
- [ ] Loop functionality

### Phase 3: Effects & Mixing

- [ ] 3-band EQ
- [ ] Audio effects chain
- [ ] Tempo/pitch control
- [ ] Key lock

### Phase 4: Library & Polish

- [ ] Music library browser
- [ ] Playlist management
- [ ] Track metadata editor
- [ ] UI/UX refinements

## Support

For questions or issues, please open an issue on GitHub.

## Status

🚧 **Under Development** - This project is in early development phase.
