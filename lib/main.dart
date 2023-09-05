import 'package:flutter/material.dart';
import 'login_page.dart';
import 'camera_page.dart';
import 'history.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/camera': (context) => CameraPage(),
        '/history': (context) => HistoryPage(),
      },
    );
  }
}





