import 'package:flutter/material.dart';

class ItemModel {
  final int id;
  final String articleName;
  final String modelName;
  final bool resolved;

  ItemModel(
      {required this.id,
      required this.articleName,
      required this.modelName,
      required this.resolved});
}
