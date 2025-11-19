import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djay_pro_clone/main.dart';

void main() {
  testWidgets('BPM display shows Deck A tempo when only Deck A is playing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: DJDemoPage()));

    // Find Deck A and its controls
    final deckAFinder = find.ancestor(
      of: find.text('DECK A'),
      matching: find.byType(Column),
    );
    final deckAPlayButton = find.descendant(
      of: deckAFinder,
      matching: find.widgetWithIcon(ElevatedButton, Icons.play_arrow),
    );
    final deckATempoSlider = find.descendant(
      of: deckAFinder,
      matching: find.byType(Slider),
    ).at(1); // The second slider is tempo

    // Change Deck A's tempo to a value different from the default
    await tester.drag(deckATempoSlider, const Offset(50.0, 0.0));
    await tester.pump();

    // Tap Deck A's play button
    await tester.tap(deckAPlayButton);
    await tester.pump();

    // Get the current tempo of Deck A from its text display
    final deckATempoTextWidget = tester.widget<Text>(
      find.descendant(
        of: deckAFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is Text && widget.data!.endsWith('%') && int.tryParse(widget.data!.replaceAll('%', '')) != null
        )
      ).at(1) // The second text with '%' is the tempo
    );
    final deckATempo = int.parse(deckATempoTextWidget.data!.replaceAll('%', ''));

    // The BPM display should show Deck A's tempo, because it's the only one playing.
    // This assertion is expected to fail with the current buggy implementation.
    expect(find.text('BPM: $deckATempo'), findsOneWidget);
  });
}
