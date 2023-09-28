import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color colorSuccess = const Color(0xFF6ACA89);
const Color colorGrey = const Color(0xFF777777);
const Color colorWarning = const Color(0xFFFFae69);
const Color colorError = const Color(0xFFEE7070);
const Color colorLightGrey = const Color(0xFFCCCCCC);

var CategoryList = List.of([
  "술",
  "밥",
  "영화",
  "산책",
  "공부",
  "취미",
  "운동",
  "기타",
  "음악",
  "게임",
  "공예",
  "공연",
  "여행",
  "쇼핑",
]);

Color getColorForScore(int score) {
  if (score < 20) {
    return Colors.red;
  } else if (score < 40) {
    return Colors.orange;
  } else if (score < 60) {
    return Colors.lime;
  } else if (score < 80) {
    return Colors.green;
  } else {
    return Colors.blue;
  }
}

void updateChatList(String uuid) {
  Random rd = Random();
  FirebaseFirestore.instance.collection("UserChatData").doc(uuid).update({"streamIO": rd.nextInt(100000000).toInt()});
}

void showAlert(String message, BuildContext cont, Color color) {
  final snackBar = SnackBar(
    elevation: 2,
    content: Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: 15),
      textAlign: TextAlign.center,
    ),
    duration: Duration(milliseconds: 1300),
    backgroundColor: color,
  );

  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  ScaffoldMessenger.of(cont).showSnackBar(snackBar);
} // 메시지 박스 띄우기

extension TimestampToDateFormat on Timestamp {
  String toFormattedString() {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    DateTime dt = this.toDate();
    return "${dateFormatter.format(dt)} ${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}:${dt.second.toString().padLeft(2, "0")}";
  }
}
