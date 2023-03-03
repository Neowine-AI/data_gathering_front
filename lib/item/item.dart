import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'package:transition/transition.dart';

import '../main.dart';
import 'item_model.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() {
    return _ItemPage();
  }
}

class _ItemPage extends State<ItemPage> {
  List<dynamic> widgets = [];

  List<Image> images = [];
  final _dropDownValues = ["TEST", "TEST2"];
  var _selected = "TEST";
  int _selectedIndex = 0;
  late ItemModel itemModel;
  String? query;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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
                  image: ExtendedImage(
                    enableMemoryCache: true,
                    image: images[i].image,
                  ).image,
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

      Image image = response.data == null
          ? Image.asset("assets/images/image.png")
          : Image.memory(response.data, fit: BoxFit.cover);
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

  @override
  void initState() {
    super.initState();
    loadData(_selected);
    query = null;
  }

  @override
  Widget build(BuildContext context) {
    return getItemBody();
  }
}
