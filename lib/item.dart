import 'dart:io';
import 'package:data_gathering/main.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import 'package:data_gathering/item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemPage extends StatefulWidget {
  final ItemModel itemModel;
  final Image image;

  const ItemPage({super.key, required this.itemModel, required this.image});

  @override
  State<ItemPage> createState() {
    return _ItemPage();
  }
}

enum Angle { front, back, top }

class _ItemPage extends State<ItemPage> {
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
            child: Container(
              decoration: index == selectedIndex
                  ? BoxDecoration(
                      color: Colors.black12,
                      border: Border.all(color: Colors.black))
                  : BoxDecoration(color: Colors.black12),
              width: MediaQuery.of(context).size.width / 3.5,
              height: MediaQuery.of(context).size.width / 3.5,
              child: Center(
                child: _images[index] == null
                    ? const Text(
                        'No image selected.',
                        textAlign: TextAlign.center,
                      )
                    : Image.file(File(_images[index]!.path)),
              ),
            ),
          ),
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
              padding: EdgeInsets.only(bottom: 10),
              alignment: Alignment.bottomCenter,
              child: Text(
                "매칭 이미지",
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
                  tooltip: 'pick Iamge',
                  onPressed: () {
                    getImage(ImageSource.camera);
                  },
                ),
                FloatingActionButton(
                  heroTag: "pick from gallery",
                  child: Icon(Icons.wallpaper),
                  tooltip: 'pick Iamge',
                  onPressed: () {
                    getImage(ImageSource.gallery);
                  },
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "create matching",
        child: Icon(Icons.add),
        tooltip: 'pick Iamge',
        onPressed: () {
          final List<MultipartFile> files =
              _images.map((e) => MultipartFile.fromFileSync(e!.path)).toList();
          var data = FormData.fromMap({'images': files});
          createMatching(data);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyApp(),
            ),
          );
        },
      ),
    );
  }

  Future<dynamic> createMatching(dynamic input) async {
    final prefs = await SharedPreferences.getInstance();
    var dio = new Dio();
    try {
      dio.options.contentType = 'multipart/form-data';
      dio.options.maxRedirects.isFinite;
      dio.options.queryParameters = {'itemId': widget.itemModel.id};
      dio.options.headers = {
        'Authorization': 'Bearer ${prefs.getString("accessToken")}'
      };

      await dio.post("http://10.0.2.2:8080/matching", data: input);
    } catch (e) {
      print(e);
    }
  }
}
