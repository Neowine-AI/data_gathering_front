import 'package:data_gathering/item/item_detail.dart';
import 'package:data_gathering/item/item_model.dart';
import 'package:data_gathering/login/login.dart';
import 'package:data_gathering/matching/matching.dart';

import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

void main() {
  FlavorConfig(
    name: "NORMAL",
    color: Colors.red,
    variables: {"isAdmin": false},
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print(FlavorConfig.instance.variables["isAdmin"]);

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
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
      home: ItemDetailPage(
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
