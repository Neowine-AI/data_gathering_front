import 'dart:convert';
import 'dart:developer';

import 'package:data_gathering/Dios.dart';
import 'package:data_gathering/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_model.dart';

const users = const {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
};

class LoginScreen extends StatelessWidget {
  // Future<LoginModel> Login() async {
  //   Dio dio = Dio();
  //   return null;
  // }
  Duration get loginTime => Duration(milliseconds: 2250);

  Future<String?> test(LoginData data) async {
    var requestBody = {'id': data.name, 'password': data.password};
    var dio = await noAuthDio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) async {
          var prefs = await SharedPreferences.getInstance();
          prefs.setString("accessToken", response.data['accessToken']);
          prefs.setString("refreshToken", response.data['refreshToken']);

          return handler.next(response);
        },
      ),
    );
    try {
      var response = await dio.post(
        "/member/login",
        data: requestBody,
      );
      if (response.statusCode == 200) {
        return null;
      } else {
        return "user not exists";
      }
    } catch (e) {
      return "user not exists";
    }
  }

  Future<String?> _signupUser(SignupData data) {
    var requestBody = {
      'id': data.name,
      'password': data.password,
    };
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlutterLogin(
          onLogin: test,
          onSignup: _signupUser,
          hideForgotPasswordButton: true,
          additionalSignupFields: [
            UserFormField(keyName: "name"),
            UserFormField(keyName: "phoneNumber")
          ],
          logo: Image.network("https://neowine.com/theme/a03/img/ci.png").image,
          onSubmitAnimationCompleted: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => DashBoard(),
            ));
          },
          onRecoverPassword: _recoverPassword,
          loginAfterSignUp: false,
        ),
      ),
    );
  }
}
