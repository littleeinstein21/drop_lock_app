import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  void listenForNotifications(BuildContext context) {
    // Listener untuk notifikasi biasa
    _database.child("ultrasonic/notification").onValue.listen((event) {
      final notification = event.snapshot.value?.toString();
      if (notification != null && notification.isNotEmpty) {
        _showNotificationDialog(context, "Notification", notification);
      }
    });

    // Listener untuk notifikasi prolonged
    _database.child("ultrasonic/prolongedNotification").onValue.listen((event) {
      final prolongedNotification = event.snapshot.value?.toString();
      if (prolongedNotification != null && prolongedNotification.isNotEmpty) {
        _showNotificationDialog(context, "Prolonged Notification", prolongedNotification);
      }
    });
  }

  void _showNotificationDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
          TextButton(
            onPressed: () {
              _unlockDoor(context);
              Navigator.pop(context);
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  void _unlockDoor(BuildContext context) async {
    try {
      await _database.child("doorControl").set("unlock");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Door unlock command sent!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send unlock command: $e")),
      );
    }
  }
}
