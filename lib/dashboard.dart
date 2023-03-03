import 'dart:convert';
import 'dart:io';

import 'package:data_gathering/item/item_model.dart';
import 'package:data_gathering/matching/matching.dart';
import 'package:dio/dio.dart';
import 'package:transition/transition.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'item/item.dart';
import 'login/login_model.dart';
import 'main.dart';

class DashBoard extends StatelessWidget {
  const DashBoard({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: "main page",
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String _selected = 'TEST';
  final _dropDownValues = ["TEST", "TEST2"];

  final List<Widget> _widgetOptions = <Widget>[
    const ItemPage(),
    const MatchingPage()
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 40,
          title: Image(
            image:
                Image.network("https://neowine.com/theme/a03/img/ci.png").image,
          ),
          backgroundColor: Colors.white,
          actions: [
            DropdownButton(
              value: _selected,
              items: _dropDownValues.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                _selected = value!;
              }),
            ),
            IconButton(
              onPressed: () {
                null;
              },
              icon: Icon(Icons.search),
              color: Colors.black,
            )
          ]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera),
            label: 'matching',
          ),
        ],
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
      body: _widgetOptions[_selectedIndex],
    );
  }
}
