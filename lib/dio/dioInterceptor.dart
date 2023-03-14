import 'dart:async';

import 'package:data_gathering/dio/Dios.dart';
import 'package:data_gathering/login/login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioInterceptors extends Interceptor {
  BuildContext context;

  DioInterceptors({required this.context});

  @override
  FutureOr<dynamic> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();

    options.headers['Authorization'] =
        "Bearer ${prefs.getString("accessToken")}";
    return handler.next(options);
  }

  @override
  FutureOr<dynamic> onError(DioError e, ErrorInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
      final accessToken = await prefs.getString("accessToken");
      final refreshToken = await prefs.getString("refreshToken");
      print(accessToken);
      var refreshDio = new Dio();
      refreshDio.options.baseUrl = "http://data.neowine.com";
      refreshDio.options.contentType = "application/json";

      refreshDio.interceptors.clear();

      refreshDio.interceptors
          .add(InterceptorsWrapper(onError: (error, handler) async {
        // 다시 인증 오류가 발생했을 경우: RefreshToken의 만료
        if (error.response?.statusCode == 401) {
          // 기기의 자동 로그인 정보 삭제
          await prefs.clear();
          print("TEST");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      }));
      var data = {
        "accessToken": '$accessToken',
        "refreshToken": "$refreshToken"
      };
      final refreshResponse = await refreshDio
          .post("http://data.neowine.com/member/reissue", data: data);
      prefs.setString("accessToken", refreshResponse.data['newAccessToken']);

      return handler.next(e);
    }
  }
}
