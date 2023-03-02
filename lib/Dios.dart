import 'package:data_gathering/dioInterceptor.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Dio> noAuthDio() async {
  var dio = Dio();

  dio.interceptors.clear();
  dio.options.baseUrl = "http://10.0.2.2:8080";
  dio.options.contentType = "application/json";

  return dio;
}

Future<Dio> authDio() async {
  var dio = Dio();
  final prefs = await SharedPreferences.getInstance();

  dio.interceptors.clear();
  dio.options.baseUrl = "http://10.0.2.2:8080";
  dio.interceptors.add(DioInterceptors());
  dio.options.contentType = "application/json";

  dio.options.headers['Authorization'] =
      "Bearer ${prefs.getString("accessToken")}";
  return dio;
}
