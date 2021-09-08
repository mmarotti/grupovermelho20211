import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mainMenu.dart';

// Root widget of application, responsible for starting firestore, creating a new player
// and rendering MainMenu passing created player and application theme

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
