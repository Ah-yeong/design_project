import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

const Color colorSuccess = const Color(0xFF6ACA89);
const Color colorGrey = const Color(0xFF777777);
const Color colorWarning = const Color(0xFFFFae69);
const Color colorError = const Color(0xFFEE7070);
const Color colorLightGrey = const Color(0xFFCCCCCC);

const Map<String, dynamic> postFieldDefault = {
  "writer_id": null,
  "head": "제목",
  "body": "내용",
  "gender": 0,
  "maxPerson": 2,
  "currentPerson": 1,
  "writer_nick": "UserName",
  "minAge": -1,
  "maxAge": -1,
  "time": "2025-10-19 07:00:00",
  "upTime": "1999-10-19 07:00:00",
  "category": ["술"],
  "viewCount": 1,
  "user": [],
  "voluntary": false,
  "lat": 36.833068,
  "lng": 127.178419,
  "name": "상명대학교"
};

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

SnackBar getAlert(String message, Color color) {
  return SnackBar(
    elevation: 2,
    content: Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: 15),
      textAlign: TextAlign.center,
    ),
    duration: Duration(milliseconds: 1300),
    backgroundColor: color,
  );
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


// 맵 스타일 변경
void changeMapMode(GoogleMapController mapController) {
  getJsonFile("assets/map_style.json").then((value) => mapController.setMapStyle(value));
}

// Json 디코딩
Future<String> getJsonFile(String path) async {
  ByteData byte = await rootBundle.load(path);
  var list = byte.buffer.asUint8List(byte.offsetInBytes, byte.lengthInBytes);
  return utf8.decode(list);
}

// Asset 에서 getBytes
Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}