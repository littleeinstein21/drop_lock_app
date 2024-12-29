// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:iot_locker_app/widgets/status.card.dart';

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({super.key});

//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   final DatabaseReference _database = FirebaseDatabase.instance.ref();
//   String connectionStatus = "Not Connected";
//   double ultrasonicDistance = 15.0; // Default distance to 15 cm

//   @override
//   void initState() {
//     super.initState();

//     // Listen to connection status
//     _database.child(".info/connected").onValue.listen((event) {
//       final connected = event.snapshot.value as bool?;
//       setState(() {
//         connectionStatus = connected == true ? "Connected" : "Disconnected";
//       });
//     });
//   }

//   // Send the new ultrasonic distance to Firebase
//   void _updateUltrasonicDistance(double value) {
//     _database.child("ultrasonic/threshold").set(value); // Adjust path if needed
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('Settings'),
//         backgroundColor: Colors.blueGrey[800],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Connection status card
//             StatusCard(
//               title: "Connection Status",
//               value: connectionStatus,
//               icon: Icons.wifi,
//               color: Colors.blueGrey,
//             ),
//             const SizedBox(height: 30),
//             // Ultrasonic distance adjustment
//             const Text(
//               'Adjust Ultrasonic Distance (cm):',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             Slider(
//               value: ultrasonicDistance,
//               min: 5.0, // Minimum distance 5 cm
//               max: 100.0, // Maximum distance 100 cm
//               divisions: 95, // Allows fine adjustment
//               label: '${ultrasonicDistance.toStringAsFixed(1)} cm',
//               onChanged: (value) {
//                 setState(() {
//                   ultrasonicDistance = value;
//                 });
//                 _updateUltrasonicDistance(value); // Update Firebase
//               },
//             ),
//             Text(
//               'Current Distance: ${ultrasonicDistance.toStringAsFixed(1)} cm',
//               style: const TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
