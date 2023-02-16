import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:data_gathering/item.dart';
import 'package:data_gathering/item_model.dart';
import 'package:image/image.dart' as img;
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> widgets = [];
  List<Image> images = [];
  final _dropDownValues = ["TEST", "TEST2"];
  var _selected = "TEST";
  int _selectedIndex = 0;
  late ItemModel itemModel;

  @override
  void initState() {
    super.initState();
    loadData(_selected);
  }

  showLoadingDialog() {
    if (widgets.length == 0) {
      return true;
    }

    return false;
  }

  getBody() {
    if (showLoadingDialog()) {
      return getProgressDialog();
    } else {
      return getListView();
    }
  }

  getProgressDialog() {
    return Center(child: CircularProgressIndicator());
  }

  ListView getListView() => ListView.separated(
        itemCount: widgets.length,
        itemBuilder: (BuildContext context, int position) {
          return ListTile(
              title: getRow(position),
              onTap: () {
                getOneItem(widgets[position]["itemId"]);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemScreen(
                      itemModel: itemModel,
                      image: images[position],
                    ),
                  ),
                );
              });
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(thickness: 1);
        },
      );

  Widget getRow(int i) {
    return Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          children: [
            Container(
              height: 100,
              width: 200,
              child: images[i],
            ),
            Column(children: <Widget>[
              Text("제품명: ${widgets[i]['articleName']}"),
              Text("모델명: ${widgets[i]['modelName']}")
            ]),
          ],
        ));
  }

  getDropDownMenu() {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 5.0),
      child: Center(
        child: DropdownButton(
          value: _selected,
          items: _dropDownValues.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(e),
            );
          }).toList(),
          onChanged: (value) => setState(() {
            _selected = value!;
            loadData(value);
          }),
        ),
      ),
    );
  }

  loadData(String category) async {
    final queryParameters = {
      'category': category,
    };
    List<Image> imageList = [];

    var dataURL = Uri.http("10.0.2.2:8080", "/item", queryParameters);
    http.Response response = await http.get(dataURL);
    List items = jsonDecode(response.body)['content'];
    final dio = Dio();
    for (var element in items) {
      final response = await dio.get(
          "http://10.0.2.2:8080/item/image/${element['itemId']}",
          options: Options(responseType: ResponseType.bytes));
      Image image = Image.memory(response.data);
      imageList.add(image);
    }

    setState(() {
      widgets = jsonDecode(response.body)['content'];
      images = imageList;
    });
  }

  getOneItem(int id) async {
    var dataURL = Uri.http("10.0.2.2:8080", "/item/$id");
    http.Response response = await http.get(dataURL);
    var body = jsonDecode(response.body);
    ItemModel itemModel = ItemModel(
        id: body["itemId"],
        articleName: body["articleName"],
        modelName: body["modelName"],
        resolved: body["resolved"]);

    setState(() {
      this.itemModel = itemModel;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_camera),
              label: 'photo',
            ),
          ],
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(children: [
              getDropDownMenu(),
              Text(
                _selected,
                style: TextStyle(fontSize: 25),
              ),
            ]),
            const Divider(
              color: Colors.black,
            ),
            Expanded(child: getBody())
          ],
        ));
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: ItemPage(
        itemModel: itemModel,
        image: image,
      ),
    );
  }
}
