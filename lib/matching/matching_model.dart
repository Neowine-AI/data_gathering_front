import 'package:flutter/material.dart';

class MatchingModel {
  final int id;
  final String? rejectMessage;
  final String itemName;
  final Status status;
  final String memberName;
  final DateTime createdTime;

  MatchingModel(
      {required this.id,
      this.rejectMessage,
      required this.itemName,
      required this.status,
      required this.memberName,
      required this.createdTime});

  factory MatchingModel.fromJson(Map<String, dynamic> json) {
    return MatchingModel(
        id: json["id"],
        status: Status.getByCode(json["status"]),
        itemName: json["itemName"],
        rejectMessage: json["rejectMessage"],
        memberName: json["memberResponseDto"]["name"],
        createdTime: DateTime.parse(json["createdDate"]));
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
