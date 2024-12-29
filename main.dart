import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'widgets/navigation_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IOT Drop-Off System',
      theme: ThemeData(
        primaryColor: Colors.blueGrey[800],
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.tealAccent),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const NavigationController(),
    );
  }
}
