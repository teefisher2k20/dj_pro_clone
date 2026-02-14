import 'package:flutter/material.dart';

class SyncButtonWidget extends StatelessWidget {
  final VoidCallback onSync;
  final bool isActive;
  final bool isMaster; // If this deck is master
  final bool isSyncing; // Transient state

  const SyncButtonWidget({
    super.key,
    required this.onSync,
    this.isActive = false,
    this.isMaster = false,
    this.isSyncing = false,
  });

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Colors.grey;
    String label = 'SYNC';

    if (isSyncing) {
      buttonColor = const Color(0xFFFFD700); // Yellow while syncing
    } else if (isActive) {
      buttonColor = const Color(0xFF00FF00); // Green when synced
    } else if (isMaster) {
      buttonColor = const Color(0xFF00D9FF); // Blue for Master
    }

    return GestureDetector(
      onTap: onSync,
      child: Container(
        width: 60,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.2),
          border: Border.all(color: buttonColor, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: buttonColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
