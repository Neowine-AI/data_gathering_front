import 'dart:math';

import 'package:data_gathering/dio/Dios.dart';
import 'package:data_gathering/item/item.dart';
import 'package:data_gathering/item/item_detail.dart';
import 'package:data_gathering/item/item_model.dart';
import 'package:data_gathering/matching/matching_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:transition/transition.dart';

import '../main.dart';

enum MenuItems {
  delete('delete', "삭제"),
  confirm('confirm', "승인"),
  reject('reject', "반려");

  const MenuItems(this.code, this.name);
  final String code;
  final String name;
}

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
  late ItemModel item;
  late Image itemImage;
  List<String> angles = ["front", "back", "top"];
  late String rejectMessage;

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
    final matchingDio = await authDio(context);
    final itemDio = await noAuthDio(context);
    var response = await matchingDio.get(
      "/matching/${widget.matchingModel.id}",
    );
    Map<String, dynamic> body = response.data;
    var item = await itemDio.get("/item/${body['itemId']}");
    var itemImage = await itemDio.get("/item/image/${body['itemId']}",
        options: Options(
          responseType: ResponseType.bytes,
        ));
    final dio = await authDio(context);
    for (String angle in angles) {
      final queryParameters = {
        'angle': angle,
      };
      final response =
          await dio.get("http://data.neowine.com/matching/image/${body['id']}",
              queryParameters: queryParameters,
              options: Options(
                responseType: ResponseType.bytes,
              ));
      Image image = Image.memory(
        response.data,
        fit: BoxFit.cover,
      );
      imageList.addAll({angle: image});
    }
    setState(() {
      images = imageList;
      this.itemImage = Image.memory(itemImage.data);
      this.item = ItemModel.fromJson(item.data);
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

  Widget getItemWidget() {
    return Row(
      children: [
        Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: itemImage.image,
                  fit: BoxFit.cover,
                ))),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.modelName,
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                item.articleName,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 12, color: Colors.black38),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void deleteMatching() async {
    var dio = await authDio(context);
    var response = dio.patch("/matching/delete/${widget.matchingModel.id}");
    print(response);
    Navigator.pop(context);
  }

  void confirmMatching() async {
    var dio = await authDio(context);
    var response = dio
        .post("/matching/confirm", data: {"itemId": widget.matchingModel.id});
    Navigator.pop(context);
  }

  void rejectMatching(String message) async {
    var dio = await authDio(context);
    var response = dio.post("/matching/reject",
        data: {"itemId": widget.matchingModel.id, "rejectMessage": message});
    Navigator.pop(context);
  }

  PopupMenuItem<MenuItems> menuItem(MenuItems menu) {
    return PopupMenuItem<MenuItems>(value: menu, child: Text(menu.name));
  }

  Widget getDialog(MenuItems menu, BuildContext context) {
    switch (menu) {
      case MenuItems.delete:
        return CupertinoAlertDialog(
          title: Text("삭제"),
          content: Text("매칭을 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'OK');
                deleteMatching();
              },
              child: const Text('OK'),
            ),
          ],
        );
      case MenuItems.confirm:
        return CupertinoAlertDialog(
          title: Text("승인"),
          content: Text("매칭을 승인하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'OK');

                confirmMatching();
              },
              child: const Text('OK'),
            ),
          ],
        );
      case MenuItems.reject:
        return CupertinoAlertDialog(
          title: Text(
            "반려",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.label, context),
                fontWeight: FontWeight.w500),
          ),
          content: Column(children: [
            SizedBox(height: 10),
            Card(
              color: Colors.transparent,
              child: TextField(
                onChanged: (message) => setState(() {
                  this.rejectMessage = message;
                }),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(),
                  labelText: '반려사유를 입력해주세요',
                ),
              ),
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: Text("cancel")),
            TextButton(
                onPressed: () => rejectMatching(rejectMessage),
                child: Text("ok"))
          ],
        );
      default:
        return AlertDialog(
          title: Text(""),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    var matchingStatus = [
      Expanded(
        child: Text.rich(
          TextSpan(
            text: "매칭 현황: ",
            style: TextStyle(color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                  text: widget.matchingModel.status.name,
                  style: TextStyle(
                    color: widget.matchingModel.status == Status.CONFIRMED
                        ? Colors.green
                        : Colors.orange,
                  )),
            ],
          ),
        ),
      ),
      PopupMenuButton(
        onSelected: (menuitmes) => showDialog(
            context: context,
            builder: (context) => getDialog(menuitmes, context)),
        itemBuilder: (context) => <PopupMenuEntry<MenuItems>>[
          if (FlavorConfig.instance.variables["isAdmin"] == true)
            menuItem(MenuItems.confirm),
          if (FlavorConfig.instance.variables["isAdmin"] == true)
            menuItem(MenuItems.reject),
          menuItem(MenuItems.delete)
        ],
      ),
    ];

    var matchingInfos = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: matchingStatus,
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
    ];
    return Scaffold(
      body: images.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        child: getPhotoGallery(),
                      ),
                      BackButton(color: Colors.white),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        alignment: Alignment.bottomCenter,
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
                    padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: Column(children: [
                      Row(
                        children: [
                          Expanded(
                            child: getItemWidget(),
                          ),
                          IconButton(
                            onPressed: () => {
                              Navigator.push(
                                context,
                                Transition(
                                  child: ItemDetailPage(
                                    itemModel: item,
                                    image: itemImage,
                                  ),
                                  transitionEffect:
                                      TransitionEffect.BOTTOM_TO_TOP,
                                ),
                              )
                            },
                            icon: Icon(Icons.chevron_right),
                            iconSize: 40,
                          ),
                        ],
                      ),
                      Divider(thickness: 1),
                    ]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: Stack(
                      children: [
                        Column(
                          children: matchingInfos,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
