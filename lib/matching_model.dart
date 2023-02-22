import 'dart:ffi';

import 'package:flutter/material.dart';

class MatchingModel {
  final int id;
  final String? rejectMessage;
  final String itemName;
  final Status status;

  MatchingModel(
      {required this.id,
      this.rejectMessage,
      required this.itemName,
      required this.status});

  factory MatchingModel.fromJson(Map<String, dynamic> json) {
    return MatchingModel(
        id: json["id"],
        status: Status.getByCode(json["status"]),
        itemName: json["itemName"],
        rejectMessage: json["rejectMessage"]);
  }
}

enum Status {
  WAIT('WAIT', '대기 중'),
  REJECTED('REJECTED', '반려'),
  CONFIRMED('CONFIRMED', '승인'),
  UNDEFINED('UNDEFINED', '확인되지 않음');

  const Status(this.code, this.name);
  final String code;
  final String name;

  factory Status.getByCode(String code) {
    return Status.values.firstWhere((value) => value.code == code,
        orElse: () => Status.UNDEFINED);
  }
}
