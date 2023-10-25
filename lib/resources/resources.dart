import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/entity/profile.dart';
import 'package:design_project/main.dart';
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

Widget getAvatar(EntityProfiles? profile, double radius, {Icon? nullIcon, Color? backgroundColor}) {
  if (profile == null) {
    if (nullIcon != null) {
      return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? colorLightGrey,
          child: Center(child: nullIcon)
      );
    } else {
      return Image.asset("assets/images/userImage.png", width: radius * 2, height: radius * 2);
    }
  } else {
    if (userTempImage[profile.profileId] != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? colorLightGrey,
        backgroundImage: userTempImage[profile.profileId],
      );
    }
    if (profile.imagePath == null) {
      return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? colorLightGrey,
          child: Center(child: nullIcon ?? const SizedBox())
      );
    } else {
      userTempImage[profile.profileId] = NetworkImage(profile.imagePath!);
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? colorLightGrey,
        backgroundImage: userTempImage[profile.profileId],
      );
    }
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

void showAlert(String message, BuildContext cont, Color color, {Duration duration = const Duration(milliseconds: 1300)}) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    width: MediaQuery.of(cont).size.width - 20,
    padding: EdgeInsets.all(14),
    elevation: 2,
    content: Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
    duration: duration,
    backgroundColor: color,
  );

  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  ScaffoldMessenger.of(cont).hideCurrentSnackBar();
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

showConfirmBox(BuildContext context, {Widget? title, Widget? body, Function()? onAccept, Function()? onDeny}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      contentPadding: EdgeInsets.fromLTRB(30, 20, 30, 20),
      // 다이얼로그의 내용 패딩을 균일하게 조정
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(title != null) const SizedBox(height: 20),
            if(title != null) title,
            if(body != null) const SizedBox(height: 20),
            if(body != null) body,
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onAccept != null) onAccept();
                  },
                  child: Text('예'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    minimumSize: Size(50, 30),
                    elevation: 1
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onDeny != null) onDeny();
                  },
                  child: Text('아니오'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    minimumSize: Size(50, 30),
                    elevation: 1
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}