import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a minimum splash duration or initialization check
    Future.delayed(const Duration(seconds: 2), () {
      // Check auth status here is reactive via the Consumer in main.dart usually,
      // but if we navigated here, we might just wait.
      // However, usually the root widget handles the switch.
      // This splash screen might be just for the initial load.
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0E27),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 100, color: Color(0xFF00D9FF)),
            SizedBox(height: 20),
            Text(
              'DJ Pro Clone',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Color(0xFFB026FF)),
          ],
        ),
      ),
    );
  }
}
