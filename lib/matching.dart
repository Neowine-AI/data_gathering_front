import 'dart:convert';

import 'package:data_gathering/matching_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() {
    return _MatchingPage();
  }
}

class _MatchingPage extends State<MatchingPage> {
  late MatchingModel matchingModel;
  List<dynamic> matchings = [];
  List<Image> matchingImages = [];
  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'Authorization': 'Bearer ${prefs.getString('accessToken')}',
    };
  }

  Widget getRow(int i) {
    return Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          children: [
            Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black12,
                    image: DecorationImage(
                        image: matchingImages[i].image, fit: BoxFit.cover),
                  ),
                  height: 100,
                  width: 100,
                ),
                Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Container(
                      child: Text(
                        "${matchings[i]['itemName']}",
                      ),
                    )),
              ],
            ),
            SizedBox(
              height: 100,
              width: 150,
            ),
            Row(
              children: [
                Text(matchings[i]['status']),
                Icon(
                  Icons.adjust_rounded,
                  color: matchings[i]['status'] == "WAIT"
                      ? Colors.orange
                      : Colors.red,
                ),
              ],
            ),
          ],
        ));
  }

  ListView getListView() => ListView.separated(
        itemCount: matchings.length,
        itemBuilder: (BuildContext context, int position) {
          return ListTile(
              title: getRow(position),
              onTap: () {
                null;
              });
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(thickness: 1);
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        SizedBox(height: 30),
        Row(children: const [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "내 매칭 현황",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ]),
        Divider(
          color: Colors.black,
        ),
        Expanded(
          child: getListView(),
        )
      ],
    ));
  }

  @override
  void initState() {
    loadMatchings();
    super.initState();
  }

  Future<void> loadMatchings() async {
    Map<String, String> header = await getHeaders();
    final queryParameters = {
      'status': "WAIT",
    };
    List<Image> imageList = [];

    var dataURL =
        Uri.http("10.0.2.2:8080", "/matching/status", queryParameters);
    http.Response response = await http.get(dataURL, headers: header);
    List body = jsonDecode(response.body)['content'];
    final dio = Dio();
    for (var element in body) {
      final response = await dio.get(
          "http://10.0.2.2:8080/matching/image/${element['id']}",
          options: Options(responseType: ResponseType.bytes, headers: header));
      Image image = Image.memory(response.data);
      imageList.add(image);
    }
    setState(() {
      matchings = body;
      matchingImages = imageList;
    });
  }
}
