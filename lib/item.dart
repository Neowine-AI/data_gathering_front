import 'package:data_gathering/item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ItemPage extends StatefulWidget {
  final ItemModel itemModel;
  final Image image;

  const ItemPage({super.key, required this.itemModel, required this.image});

  @override
  State<ItemPage> createState() {
    return _ItemPage();
  }
}

class _ItemPage extends State<ItemPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: TextButton(
        child: Text("매칭 생성"),
        onPressed: () => print("TEST"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            widget.image,
            const SizedBox(
              height: 15,
            ),
            Row(
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
            )
          ],
        ),
      ),
    );
  }
}
