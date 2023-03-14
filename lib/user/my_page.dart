import 'package:data_gathering/dio/Dios.dart';
import 'package:data_gathering/login/login.dart';
import 'package:data_gathering/main.dart';
import 'package:data_gathering/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transition/transition.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyPage();
  }
}

class _MyPage extends State<MyPage> {
  UserModel? user;

  Widget getTextInput() {
    return TextField();
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  Future getUserInfo() async {
    var dio = await authDio(context);
    var response = await dio.get("/member/info");
    setState(() {
      user = UserModel.fromJson(response.data);
    });
  }

  getInfoTextStyle() {
    return TextStyle(fontSize: 15, color: Colors.black54);
  }

  logout() async {
    var pref = await SharedPreferences.getInstance();
    pref.clear();
    Navigator.popUntil(context, (route) => false);
    Navigator.push(
        context,
        Transition(
          child: MyApp(),
          transitionEffect: TransitionEffect.SCALE,
        ));
  }

  getPadding() {
    return Padding(padding: EdgeInsets.symmetric(vertical: 5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: user == null
            ? Center(child: CircularProgressIndicator())
            : Column(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      "https://neowine.com/theme/a03/img/ci.png")
                                  .image,
                              height: 40,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text("내 정보"),
                          ),
                        ])),
                    Divider(
                      color: Colors.black,
                      height: 1,
                    ),
                    Row(
                      children: [
                        Icon(Icons.person_2_rounded,
                            size: 50, color: Colors.black54),
                        Text(
                          user!.name,
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "내 정보",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          getPadding(),
                          Row(
                            children: [
                              Icon(Icons.email_outlined),
                              Text("이메일 (아이디)"),
                            ],
                          ),
                          Text(
                            "${user!.email}",
                            style: getInfoTextStyle(),
                          ),
                          getPadding(),
                          Row(
                            children: [
                              Icon(Icons.phone),
                              Text(
                                "연락처",
                              )
                            ],
                          ),
                          Text(
                            user!.phoneNumber,
                            style: getInfoTextStyle(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                    onPressed: () => logout(),
                    icon: const Icon(Icons.logout),
                    label: Text("logout"))
              ]));
  }
}
