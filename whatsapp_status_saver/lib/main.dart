import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_status_saver/screens/status_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Initializing Firebase...');
  await Firebase.initializeApp();
  print('Firebase Initialized!');

  await requestPermissions();

  runApp(MyApp());
}

Future<void> requestPermissions() async {
  var status = await Permission.storage.request();

  if (status.isGranted) {
    print('Storage permission granted');
  } else {
    print('Storage permission denied');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Building MyApp');
    return MaterialApp(
      home: StatusScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
