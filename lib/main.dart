import 'package:data_gathering/item_detail.dart';
import 'package:data_gathering/item_model.dart';
import 'package:data_gathering/login.dart';
import 'package:data_gathering/matching.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: LoginScreen(),
    );
  }
}

class ItemScreen extends StatelessWidget {
  final ItemModel itemModel;
  final Image image;

  ItemScreen({super.key, required this.itemModel, required this.image});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'data_gathering',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(),
        primarySwatch: Colors.blue,
      ),
      home: ItemPage(
        itemModel: itemModel,
        image: image,
      ),
    );
  }
}

class MatchingScreen extends StatelessWidget {
  MatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'matching_screen',
      home: MatchingPage(),
    );
  }
}
