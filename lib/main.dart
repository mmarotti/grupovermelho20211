import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mainMenu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

// Root widget of your application.

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Times tables game',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MainMenu(),
    );
  }
}
