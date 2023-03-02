import 'dart:async';

import 'package:data_gathering/Dios.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioInterceptors extends Interceptor {
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
      var refreshDio = await authDio();

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
      var data = {
        "accessToken": '$accessToken',
        "refreshToken": "$refreshToken"
      };
      final refreshResponse = await refreshDio
          .post("http://10.0.2.2:8080/member/reissue", data: data);
    }
  }
}
