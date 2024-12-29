import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_locker_app/widgets/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String doorStatus = "Unknown";
  String notification = "No Data";
  String lastUID = "Unknown";
  String currentTime = "";
  String greeting = ""; // Greeting message based on the time of day
  late Timer _timer;
  bool isLocked = true;

  @override
  void initState() {
    super.initState();

    NotificationService().listenForNotifications(context);

    // Start the clock timer
    _startClock();

    // Listen for door control changes
    _database.child("doorControl").onValue.listen((event) {
      final status = event.snapshot.value?.toString();
      setState(() {
        doorStatus = (status == "unlock") ? "Unlocked" : "Locked";
        isLocked = (status == "unlock") ? false : true;
      });
    });

    // Listen for notifications
    _database.child("ultrasonic/notification").onValue.listen((event) {
      final notif = event.snapshot.value?.toString();
      setState(() {
        notification = notif ?? "No Data";
      });
    });

    // Listen for the last UID
    _database.child("fingerprint/lastUID").onValue.listen((event) {
      final uid = event.snapshot.value?.toString();
      setState(() {
        lastUID = uid ?? "Unknown";
      });
    });

    // Listen for objects detected closer than 15 cm
    _database.child("ultrasonic/distance").onValue.listen((event) {
      final distance = event.snapshot.value as double?;
      if (distance != null && distance < 15.0) {
        _showUnlockDialog();
      }
    });
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      setState(() {
        currentTime =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

        if (now.hour >= 5 && now.hour < 12) {
          greeting = "Hi, Good Morning";
        } else if (now.hour >= 12 && now.hour < 18) {
          greeting = "Hi, Good Afternoon";
        } else if (now.hour >= 18 && now.hour < 21) {
          greeting = "Hi, Good Evening";
        } else {
          greeting = "Hi, Good Night";
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _sendDoorCommand(String command) {
    _database.child("doorControl").set(command);
  }

  void _showUnlockDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Object Detected',
              style: TextStyle(color: Colors.teal)),
          content: const Text(
            'An object is detected within 15 cm. Would you like to unlock the door?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                _sendDoorCommand("unlock");
                Navigator.pop(context);
              },
              child:
                  const Text('Unlock', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitle(),
              const SizedBox(height: 20),
              _buildClock(),
              const SizedBox(height: 10),
              Text(
                greeting,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              _buildVerticalStatusCards(),
              const SizedBox(height: 30),
              _buildCircularDoorControl(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        'Drop & Lock ✨', // Added sparkle emoji to make the title more engaging
        style: GoogleFonts.bebasNeue(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.tealAccent,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.teal.withOpacity(0.5),
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClock() {
    return Center(
      child: Text(
        currentTime,
        style: GoogleFonts.robotoMono(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: 5.0,
              color: Colors.tealAccent,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalStatusCards() {
    return Column(
      children: [
        _buildStatusCard(
          "Notification",
          notification,
          Icons.notification_important,
          Colors.grey[850]!,
          120,
        ),
        const SizedBox(height: 16),
        _buildStatusCard(
          "Last UID",
          lastUID,
          Icons.fingerprint,
          Colors.grey[850]!,
          120,
        ),
      ],
    );
  }

  Widget _buildStatusCard(
      String title, String value, IconData icon, Color color, double height) {
    return Card(
      elevation: 4,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.tealAccent,
              radius: 30,
              child: Icon(icon, color: Colors.black, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: Colors.tealAccent,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularDoorControl() {
    return Center(
      child: GestureDetector(
        onTap: () {
          isLocked ? _sendDoorCommand("unlock") : _sendDoorCommand("lock");
        },
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLocked ? Colors.redAccent : Colors.greenAccent,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isLocked ? Icons.lock : Icons.lock_open,
              color: Colors.white,
              size: 56,
            ),
          ),
        ),
      ),
    );
  }
}
