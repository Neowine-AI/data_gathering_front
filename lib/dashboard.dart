import 'dart:convert';

import 'package:data_gathering/item_model.dart';
import 'package:data_gathering/matching.dart';
import 'package:dio/dio.dart';
import 'package:transition/transition.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'login_model.dart';
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
  String? query;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final List<Widget> _widgetOptions = <Widget>[MatchingPage(), MatchingPage()];

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
      return SmartRefresher(
          enablePullUp: false,
          enablePullDown: true,
          controller: _refreshController,
          child: getListView(),
          onRefresh: () =>
              {loadData(_selected), _refreshController.refreshCompleted()});
    }
  }

  getProgressDialog() {
    return Center(child: CircularProgressIndicator());
  }

  Widget getItemBody() {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Row(children: [
          getDropDownMenu(),
          Expanded(
            child: Text(
              _selected,
              style: TextStyle(fontSize: 25),
            ),
          ),
          Container(
            width: 120,
            height: 30,
            child: TextField(
                maxLines: 1,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: '검색어',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(width: 1, color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(width: 1, color: Colors.blue),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                }),
          ),
          IconButton(
              onPressed: () {
                loadData(_selected);
                query = null;
              },
              icon: Icon(Icons.search)),
        ]),
        const Divider(
          color: Colors.black,
        ),
        Expanded(child: getBody())
      ],
    );
  }

  ListView getListView() => ListView.separated(
        itemCount: widgets.length,
        itemBuilder: (BuildContext context, int position) {
          return ListTile(
              title: getRow(position),
              onTap: () {
                getOneItem(widgets[position]["itemId"])
                    .then((value) => Navigator.push(
                          context,
                          Transition(
                            child: ItemScreen(
                              itemModel: itemModel,
                              image: images[position],
                            ),
                            transitionEffect: TransitionEffect.BOTTOM_TO_TOP,
                          ),
                        ));
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
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: images[i].image,
                  fit: BoxFit.cover,
                )),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${widgets[i]['articleName']}",
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  "${widgets[i]['modelName']}",
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 12, color: Colors.black38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    if (query != null) {
      queryParameters.addAll({'query': query!});
    }
    List<Image> imageList = [];

    var dataURL = Uri.http("10.0.2.2:8080", "/item", queryParameters);
    http.Response response = await http.get(dataURL);
    List items = jsonDecode(utf8.decode(response.bodyBytes))['content'];
    final dio = Dio();
    for (var element in items) {
      final response = await dio.get(
          "http://10.0.2.2:8080/item/image/${element['itemId']}",
          options: Options(responseType: ResponseType.bytes));
      Image image = Image.memory(
        response.data,
        fit: BoxFit.cover,
      );
      imageList.add(image);
    }

    setState(() {
      widgets = jsonDecode(utf8.decode(response.bodyBytes))['content'];
      images = imageList;
    });
  }

  Future<dynamic> getOneItem(int id) async {
    var dataURL = Uri.http("10.0.2.2:8080", "/item/$id");
    http.Response response = await http.get(dataURL);
    var body = jsonDecode(utf8.decode(response.bodyBytes));
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
              label: 'matching',
            ),
          ],
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
        ),
        body: _selectedIndex == 1
            ? _widgetOptions[_selectedIndex]
            : getItemBody());
  }

  Future<LoginModel?> login() async {
    final prefs = await SharedPreferences.getInstance();
    http.Response loginResponse = await http.post(
        Uri.http("10.0.2.2:8080", "/member/login"),
        headers: {"Content-Type": "application/json"},
        body: '{"id":"1234@naver.com","password":"12345678"}');
    if (loginResponse.statusCode == 200) {
      final loginInfoParsed = json.decode(loginResponse.body);
      final LoginModel loginInfo = LoginModel.fromJson(loginInfoParsed);
      await prefs.setString('accessToken', loginInfo.accessToken);
      await prefs.setString('refreshToken', loginInfo.refreshToken);
      return loginInfo;
    }
    return null;
  }
}
