import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uni_work_x_01/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const UniWorkXApp());
}

class UniWorkXApp extends StatelessWidget {
  const UniWorkXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniWorkX',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}