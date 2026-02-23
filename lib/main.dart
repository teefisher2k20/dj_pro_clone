import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/midi_service.dart';

import 'features/deck/providers/deck_provider.dart';
import 'features/library/providers/library_provider.dart';
import 'features/deck/screens/dj_deck_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MIDI Service

  MidiService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DeckProvider>(
          create: (_) => DeckProvider()..initialize(),
        ),
        ChangeNotifierProvider<LibraryProvider>(
          create: (_) => LibraryProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'DJ Pro Clone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Define the default brightness and colors.
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF00D9FF),
          scaffoldBackgroundColor: const Color(0xFF0A0E27),

          // Define the default font family.
          // fontFamily: 'Georgia',

          // Define the default `TextTheme`. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 72.0,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00D9FF),
            secondary: Color(0xFFB026FF),
            surface: Color(0xFF1A1F3A),
          ).copyWith(surface: const Color(0xFF0A0E27)),
        ),
        home: const DjDeckScreen(),
      ),
    );
  }
}
