import 'dart:convert';

import 'package:data_gathering/matching_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MatchingDetailPage extends StatefulWidget {
  final MatchingModel matchingModel;
  const MatchingDetailPage({super.key, required this.matchingModel});

  @override
  State<MatchingDetailPage> createState() {
    return _MatchingDetailPage();
  }
}

class _MatchingDetailPage extends State<MatchingDetailPage> {
  Map<String, Image> images = {};

  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'Authorization': 'Bearer ${prefs.getString('accessToken')}',
    };
  }

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  loadImage() async {
    Map<String, Image> imageList = {};
    List<String> angles = ["front", "back", "top"];
    Map<String, String> header = await getHeaders();

    var dataURL =
        Uri.http("10.0.2.2:8080", "/matching/${widget.matchingModel.id}");
    http.Response response = await http.get(dataURL, headers: header);
    Map<String, dynamic> body = jsonDecode(response.body);
    print(body);
    final dio = Dio();
    for (String angle in angles) {
      final queryParameters = {
        'angle': angle,
      };
      final response = await dio.get(
          "http://10.0.2.2:8080/matching/image/${body['id']}",
          queryParameters: queryParameters,
          options: Options(responseType: ResponseType.bytes, headers: header));
      Image image = Image.memory(
        response.data,
        fit: BoxFit.cover,
      );
      imageList.addAll({angle: image});
    }
    setState(() {
      images = imageList;
    });
  }

  Widget getImageContainer(String angle) {
    return Container(
      width: MediaQuery.of(context).size.width / 3,
      height: MediaQuery.of(context).size.width / 3,
      child: PhotoView(
        imageProvider: images[angle]?.image,
        backgroundDecoration:
            BoxDecoration(borderRadius: BorderRadius.circular(8)),
        maxScale: PhotoViewComputedScale.contained * 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: images.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  children: [
                    getImageContainer("front"),
                    getImageContainer("back"),
                    getImageContainer("top"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text("매칭 현황: ${widget.matchingModel.status.name}"),
                    ),
                  ],
                ),
                Divider(),
              ],
            ),
    );
  }
}
