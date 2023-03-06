import 'dart:ffi';
import 'dart:io';
import 'package:data_gathering/dio/dioInterceptor.dart';
import 'package:data_gathering/main.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';

import 'package:data_gathering/item/item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemDetailPage extends StatefulWidget {
  final ItemModel itemModel;
  final Image image;

  const ItemDetailPage(
      {super.key, required this.itemModel, required this.image});

  @override
  State<ItemDetailPage> createState() {
    return _ItemPage();
  }
}

enum Angle { front, back, top }

class _ItemPage extends State<ItemDetailPage> {
  File? _image;
  File? _image_front;
  File? _image_back;
  File? selectedFile;
  int selectedIndex = 0;
  List<File?> _images = [];

  @override
  void initState() {
    _images.addAll([_image, _image_front, _image_back]);
    print(widget.itemModel.id);
  }

  final picker = ImagePicker();
  Widget showImage(int index) {
    return Padding(
      padding: EdgeInsets.only(left: 5, right: 5),
      child: Column(
        children: [
          InkWell(
              onTap: () {
                setState(() => selectedIndex = index);
              },
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: Radius.circular(8),
                dashPattern: index == selectedIndex ? [4, 1] : [8, 4],
                strokeWidth: index == selectedIndex ? 2.5 : 1,
                color: index == selectedIndex
                    ? Color.fromARGB(255, 104, 239, 236)
                    : Colors.black,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                        image: _images[index] == null
                            ? Image.asset("assets/images/image.png").image
                            : FileImage(File(_images[index]!.path)),
                        fit: BoxFit.cover),
                  ),
                  width: MediaQuery.of(context).size.width / 3.5,
                  height: MediaQuery.of(context).size.width / 3.5,
                ),
              )),
          Text(
            Angle.values[index].name,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future getImage(ImageSource imageSource) async {
    final image = await picker.pickImage(source: imageSource);

    setState(() {
      _images[selectedIndex] = File(image!.path);
    });
  }

  Widget getItemInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.itemModel.articleName,
                  style: TextStyle(color: Colors.black, fontSize: 35),
                ),
                Text(
                  widget.itemModel.modelName,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 20,
                  ),
                )
              ],
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width / 1.5,
              child: PhotoView(
                imageProvider: widget.image.image,
                maxScale: PhotoViewComputedScale.covered * 1,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            getItemInfo(),
            const Divider(
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            Container(
              height: 50,
              padding: EdgeInsets.only(
                bottom: 10,
              ),
              alignment: Alignment.center,
              child: Text(
                "촬영 이미지",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                showImage(0),
                showImage(1),
                showImage(2),
              ],
            ),
            SizedBox(
              height: 50.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: "take pic",
                  child: _images[selectedIndex] == null
                      ? Icon(Icons.add_a_photo)
                      : Icon(Icons.refresh),
                  tooltip: 'take picture',
                  onPressed: () {
                    getImage(ImageSource.camera);
                  },
                ),
                FloatingActionButton(
                  heroTag: "pick from gallery",
                  child: Icon(Icons.wallpaper),
                  tooltip: 'pick image',
                  onPressed: () {
                    getImage(ImageSource.gallery);
                  },
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: checkImages()
            ? () {
                final List<MultipartFile> files = _images
                    .map((e) => MultipartFile.fromFileSync(e!.path))
                    .toList();
                var data = FormData.fromMap({'images': files});
                createMatching(data);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApp(),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            elevation: 10,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: SizedBox(
          width: 60,
          child: Row(children: const [
            Icon(Icons.add),
            Text("전송"),
          ]),
        ),
      ),
    );
  }

  checkImages() {
    for (int i = 0; i < 3; i++) {
      if (_images[i] == null) {
        return false;
      }
    }
    return true;
  }

  Future<dynamic> createMatching(dynamic input) async {
    final prefs = await SharedPreferences.getInstance();
    var dio = Dio();
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] =
              "Bearer ${prefs.getString("accessToken")}";
          return handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            final accessToken = await prefs.getString("accessToken");
            final refreshToken = await prefs.getString("refreshToken");
            var refreshDio = Dio();

            refreshDio.interceptors.clear();

            refreshDio.interceptors
                .add(InterceptorsWrapper(onError: (error, handler) async {
              // 다시 인증 오류가 발생했을 경우: RefreshToken의 만료
              if (error.response?.statusCode == 401) {
                // 기기의 자동 로그인 정보 삭제
                await prefs.clear();

                // . . .
                // 로그인 만료 dialog 발생 후 로그인 페이지로 이동
                // . . .
              }
              return handler.next(error);
            }));

            refreshDio.options.headers['Authorization'] = 'Bearer $accessToken';
            refreshDio.options.headers['Refresh'] = 'Bearer $refreshToken';
          }
        },
      ),
    );
    try {
      dio.options.contentType = 'multipart/form-data';
      dio.options.maxRedirects.isFinite;
      dio.options.queryParameters = {'itemId': widget.itemModel.id};
      await dio.post("http://10.0.2.2:8080/matching", data: input);
    } catch (e) {
      print(e);
    }
  }
}
