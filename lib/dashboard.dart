import 'package:data_gathering/matching/matching.dart';
import 'package:data_gathering/user/my_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

import 'dio/Dios.dart';
import 'item/item.dart';
import 'user/user_model.dart';

class DashBoard extends StatelessWidget {
  const DashBoard({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(),
      // themeMode: ThemeMode.dark,
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
  late String _selected = 'TEST';
  final _dropDownValues = ["TEST", "TEST2"];

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
    var page = ItemPage(
      category: _selected,
    );
    final List<Widget> _widgetOptions = <Widget>[
      page,
      const MatchingPage(),
      MyPage()
    ];

    return Scaffold(
      // appBar: AppBar(
      //     toolbarHeight: 40,
      //     title: Image(
      //       image:
      //           Image.network("https://neowine.com/theme/a03/img/ci.png").image,
      //     ),
      //     backgroundColor: Colors.white,
      //     actions: [
      //       DropdownButton(
      //         value: _selected,
      //         items: _dropDownValues.map((e) {
      //           return DropdownMenuItem(
      //             value: e,
      //             child: Text(e),
      //           );
      //         }).toList(),
      //         onChanged: (value) => setState(() {
      //           _selected = value!;
      //         }),
      //       ),
      //       IconButton(
      //         onPressed: () {
      //           null;
      //         },
      //         icon: Icon(Icons.search),
      //         color: Colors.black,
      //       )
      //     ]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '?????????',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera),
            label: '?????? ??????',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '??? ??????',
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
