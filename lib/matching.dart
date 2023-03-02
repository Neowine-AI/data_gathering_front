import 'package:data_gathering/Dios.dart';
import 'package:data_gathering/matching_detail.dart';
import 'package:data_gathering/matching_model.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:transition/transition.dart';
import 'package:intl/intl.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() {
    return _MatchingPage();
  }
}

class _MatchingPage extends State<MatchingPage> {
  late MatchingModel matchingModel;
  List<MatchingModel> matchings = [];
  List<Image> matchingImages = [];
  bool showCompleted = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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
            Expanded(
              child: Row(
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
                      padding: const EdgeInsets.only(left: 10),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              matchings[i].itemName,
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              DateFormat.yMMMd('en_US')
                                  .format(matchings[i].createdTime),
                              style: TextStyle(
                                  color: Colors.black45, fontSize: 15),
                            )
                          ],
                        ),
                      )),
                ],
              ),
            ),
            Container(
              alignment: Alignment.topRight,
              child: Row(
                children: [
                  Text(matchings[i].status.name),
                  Icon(Icons.adjust_rounded,
                      color: colors[matchings[i].status]),
                ],
              ),
            ),
          ],
        ));
  }

  Map<Status, Color> colors = {
    Status.REJECTED: Colors.red,
    Status.WAIT: Colors.orange,
    Status.CONFIRMED: Colors.green
  };

  ListView getListView() => ListView.separated(
        itemCount: matchings.length,
        itemBuilder: (BuildContext context, int position) {
          return ListTile(
              title: getRow(position),
              onTap: () {
                Navigator.push(
                  context,
                  Transition(
                      child: MatchingDetailScreen(
                        matchingModel: matchings[position],
                      ),
                      transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
                );
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
        const SizedBox(height: 20),
        Container(
          height: 48,
          child: Row(children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "내 매칭 현황",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            Switch(
                value: showCompleted,
                onChanged: (value) {
                  setState(() {
                    showCompleted = value;
                    loadMatchings();
                  });
                }),
          ]),
        ),
        Divider(
          color: Colors.black,
        ),
        Expanded(
          child: SmartRefresher(
            enablePullUp: false,
            enablePullDown: true,
            controller: _refreshController,
            onRefresh: () =>
                {loadMatchings(), _refreshController.refreshCompleted()},
            child: getListView(),
          ),
        ),
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
    var dio = await authDio();
    var dataURL = Uri.http("10.0.2.2:8080", "/matching");
    var response = await dio.get('/matching');
    List body = response.data;
    for (var element in body) {
      final response = await dio.get(
          "http://10.0.2.2:8080/matching/image/${element['id']}",
          options: Options(responseType: ResponseType.bytes, headers: header));
      Image image = Image.memory(response.data);
      imageList.add(image);
    }
    List<MatchingModel> matchingList = body
        .map(
          (e) => MatchingModel.fromJson(e),
        )
        .toList();
    setState(() {
      matchings = matchingList;
      matchingImages = imageList;
    });
  }
}

class MatchingDetailScreen extends StatelessWidget {
  final MatchingModel matchingModel;
  MatchingDetailScreen({super.key, required this.matchingModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'matching_screen',
      home: MatchingDetailPage(
        matchingModel: matchingModel,
      ),
    );
  }
}
