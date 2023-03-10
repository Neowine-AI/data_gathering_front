import 'package:data_gathering/dio/Dios.dart';
import 'package:data_gathering/item/item_detail.dart';
import 'package:extended_image/extended_image.dart' hide MultipartFile;
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:transition/transition.dart';
import 'package:dio/dio.dart';

import 'item_model.dart';

class ItemPage extends StatefulWidget {
  String category;
  ItemPage({super.key, required this.category});

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
  File? image;

  final formKey = GlobalKey<FormState>();
  Map<String, dynamic> queryParams = {};

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Widget? getCreateItemButton() {
    if (FlavorConfig.instance.variables["isAdmin"] == true) {
      return FloatingActionButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text("아이템 생성"),
                ),
                const SizedBox(height: 15),
                Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: TextFormField(
                          decoration: InputDecoration(labelText: '제품명'),
                          onSaved: (articleName) => setState(
                            () {
                              queryParams['articleName'] = articleName;
                            },
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: TextFormField(
                          decoration: InputDecoration(labelText: '모델명'),
                          onSaved: (modelName) => setState(
                            () {
                              queryParams['modelName'] = modelName;
                            },
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: DropdownButtonFormField(
                          onSaved: (category) => setState(
                            () {
                              queryParams['category'] = category;
                            },
                          ),
                          decoration: InputDecoration(labelText: '카테고리'),
                          items: _dropDownValues.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                          onChanged: (value) {},
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: 100,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: image == null
                                ? Image.asset("assets/images/image.png").image
                                : FileImage(File(image!.path)),
                          )),
                          child: image == null
                              ? InkWell(
                                  onTap: () => getImage(ImageSource.gallery),
                                )
                              : null),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () {
                          createItem();
                          Navigator.pop(context);
                        },
                        child: const Text("생성")),
                    TextButton(
                      onPressed: () {
                        image = null;
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        child: Icon(Icons.add),
      );
    } else {
      return null;
    }
  }

  Future createItem() async {
    var dio = await authDio(context);
    formKey.currentState!.save();
    final List<MultipartFile> files = [MultipartFile.fromFileSync(image!.path)];

    queryParams['images'] = [
      files,
    ];
    var body = FormData.fromMap(queryParams);

    dio.options.contentType = "multipart/form-data";
    await dio.post("/item", data: body);
    image = null;
  }

  final picker = ImagePicker();
  Future getImage(ImageSource imageSource) async {
    final image = await picker.pickImage(source: imageSource);

    setState(() {
      if (image != null) {
        this.image = File(image.path);
      }
    });
  }

  showLoadingDialog() {
    if (widgets.isEmpty) {
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
        SizedBox(
          height: 30,
        ),
        Container(
          height: 48,
          child: Row(children: [
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Image(
                image: Image.network(
                  "https://neowine.com/theme/a03/img/ci.png",
                ).image,
                height: 40,
              ),
            ),
            Expanded(child: getDropDownMenu()),
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
        ),
        const Divider(
          color: Colors.black,
          height: 1,
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
                            child: ItemDetailPage(
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
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
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
      child: Row(children: [
        DropdownButton(
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
      ]),
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
    var dio = await noAuthDio(context);
    var response = await dio.get('/item', queryParameters: queryParameters);
    List items = response.data['content'];
    Image image;
    for (var element in items) {
      if (element['imageId'] == null) {
        image = Image.asset("assets/images/image.png");
      } else {
        final response = await dio.get(
            "http://data.neowine.com/item/image/${element['itemId']}",
            options: Options(responseType: ResponseType.bytes));

        image = Image.memory(response.data, fit: BoxFit.cover);
      }
      imageList.add(image);
    }

    setState(() {
      widgets = response.data['content'];
      images = imageList;
    });
  }

  Future<dynamic> getOneItem(int id) async {
    var dio = await noAuthDio(context);
    var response = await dio.get("/item/$id");
    ItemModel itemModel = ItemModel(
        id: response.data["itemId"],
        articleName: response.data["articleName"],
        modelName: response.data["modelName"],
        resolved: response.data["resolved"]);

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
    return Scaffold(
      body: getItemBody(),
      floatingActionButton: getCreateItemButton(),
    );
  }
}
