import 'package:data_gathering/dio/dioInterceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Dio> noAuthDio(BuildContext context) async {
  var dio = Dio();

  dio.interceptors.clear();
  dio.options.baseUrl = "http://data.neowine.com";
  dio.options.contentType = "application/json";

  return dio;
}

Future<Dio> authDio(BuildContext context) async {
  var dio = Dio();
  final prefs = await SharedPreferences.getInstance();

  dio.interceptors.clear();
  dio.options.baseUrl = "http://data.neowine.com";
  dio.interceptors.add(DioInterceptors(context: context));
  dio.options.contentType = "application/json";

  dio.options.headers['Authorization'] =
      "Bearer ${prefs.getString("accessToken")}";
  return dio;
}
