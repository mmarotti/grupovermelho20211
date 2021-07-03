import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mainMenu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initializing player

  final database = FirebaseFirestore.instance;

  final CollectionReference _playersCollection = database.collection('players');
  final playerReference =
      await _playersCollection.add({"createdAt": new DateTime.now()});

  runApp(App(
    playerReference: playerReference,
  ));
}

// Root widget of your application.

class App extends StatelessWidget {
  App({Key? key, required this.playerReference}) : super(key: key);

  final DocumentReference playerReference;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Times tables game',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MainMenu(
        playerReference: playerReference,
      ),
    );
  }
}
