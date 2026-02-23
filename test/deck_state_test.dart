import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:djay_pro_clone/core/models/deck_state.dart';

void main() {
  group('DeckState Scratch Bank Tests', () {
    test('Initial state has no scratch banks active', () {
      final state = DeckState(side: DeckSide.A);
      expect(state.isScratchBankActive, false);
      expect(state.scratchBanks, isEmpty);
    });

    test('copyWith updates isScratchBankActive', () {
      final state = DeckState(side: DeckSide.A);
      final newState = state.copyWith(isScratchBankActive: true);
      expect(newState.isScratchBankActive, true);
    });

    test('copyWith updates scratchBanks', () {
      final state = DeckState(side: DeckSide.A);
      final bank = const ScratchBank(label: 'Test', filePath: 'path/to/file');
      final newState = state.copyWith(scratchBanks: [bank]);
      expect(newState.scratchBanks.length, 1);
      expect(newState.scratchBanks.first.label, 'Test');
    });
  });
}
