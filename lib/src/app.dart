import 'package:flutter/material.dart';
import 'ui/auth/auth_gate.dart';

class VedicMateApp extends StatelessWidget {
  const VedicMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VedicMate',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        brightness: Brightness.light,
      ),
      home: AuthGate(),
    );
  }
}
