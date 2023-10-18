import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/alert/models/alert_manager.dart';
import 'package:design_project/entity/profile.dart';
import 'package:design_project/meeting/share_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../alert/models/alert_object.dart';
import '../boards/post_list/page_hub.dart';
import '../main.dart';
import '../resources/fcm.dart';

class PageSettings extends StatelessWidget {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6ACA89),
        title: Text('설정'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('로그아웃'),
            onTap: () async {
              await FirebaseAuth.instance.signOut().then((value) {
                FCMController()
                  ..removeUserTokenDB();
                Get.off(() => MyHomePage());
              });
            },
          ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
            title: Text('알림 삭제'),
            onTap: () {
              var manager = AlertManager(LocalStorage!);
              LocalStorage!.remove(manager.ALERT_FIELD);
            },
          ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
            title: Text('위치 공유 화면'),
            onTap: () {
              Get.to(() => PageShareLocation(), arguments: 43);
            },
          ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          ListTile(
            title: Text('알림 추가'),
            onTap: () async {
              int rd = Random().nextInt(1000);
              AlertObject testObj = AlertObject(title: "DB테스트", body: rd.toString(), time: DateTime.now(), alertType: AlertType.TO_SHARE_LOCATION_PAGE, clickAction: {"meeting_id" : "47"}, isRead: false);
              await FirebaseFirestore.instance.collection("Alert").doc(myUuid).collection("alert").doc(DateTime.now().millisecondsSinceEpoch.toString()).set({"alertJson" : jsonEncode(testObj.toJson())});
              print("완료");
            },
          ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
            title: Text('알림 보내기 : test3'),
            onTap: () async {
              String title = "테스트 알림이에요!";
              String body = "히히";
              int rd = Random().nextInt(1000);
              AlertManager manager = AlertManager(LocalStorage!);
              bool result = await manager.sendAlert(title: title, body: rd.toString(), alertType: AlertType.NONE, userUUID: "ki654uiWotZTum8GetnSC7HTgIk2", withPushNotifications: true);
              },
          ),
        ],
      ),
    );
  }
}
