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
  int currentIndex = 0;
  List<String> angles = ["front", "back", "top"];

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
    Map<String, String> header = await getHeaders();

    var dataURL =
        Uri.http("10.0.2.2:8080", "/matching/${widget.matchingModel.id}");
    http.Response response = await http.get(dataURL, headers: header);
    Map<String, dynamic> body = jsonDecode(response.body);
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

  Widget getPhotoGallery() {
    List<Image> imageList = [];
    imageList.addAll(images.values);
    return PhotoViewGallery.builder(
      itemCount: images.length,
      builder: (context, index) => PhotoViewGalleryPageOptions(
          imageProvider: imageList[index].image,
          initialScale: PhotoViewComputedScale.contained * 1),
      loadingBuilder: (context, event) => Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            value: event == null ? 0 : 1,
          ),
        ),
      ),
      backgroundDecoration: BoxDecoration(color: Colors.black),
      pageController: PageController(),
      onPageChanged: onPageChanged,
    );
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: images.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(children: [
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    child: getPhotoGallery(),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "${this.angles[currentIndex]}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                        decoration: null,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text.rich(
                                  textAlign: TextAlign.start,
                                  TextSpan(
                                    text: "매칭 현황: ",
                                    style: TextStyle(color: Colors.black),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              widget.matchingModel.status.name,
                                          style: TextStyle(
                                            color:
                                                widget.matchingModel.status ==
                                                        Status.CONFIRMED
                                                    ? Colors.green
                                                    : Colors.orange,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              Icon(Icons.menu),
                            ],
                          ),
                          Divider(
                            thickness: 1,
                          ),
                          Row(
                            children: [
                              Text(
                                '작성자: ${widget.matchingModel.memberName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              widget.matchingModel.status == Status.REJECTED
                                  ? Text(
                                      "반려 사유: ${widget.matchingModel.rejectMessage}",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 15),
                                    )
                                  : SizedBox(
                                      height: 10,
                                    ),
                            ],
                          )
                        ],
                      ),
                    ],
                  )),
            ]),
    );
  }
}
