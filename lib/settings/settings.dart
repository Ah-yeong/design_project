import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/alert/models/alert_manager.dart';
import 'package:design_project/meeting/share_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../alert/models/alert_object.dart';
import '../boards/post_list/page_hub.dart';
import '../main.dart';
import '../resources/fcm.dart';

Timer? tempTimer;
int a = 0;
class PageSettings extends StatelessWidget {
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
                FCMController()..removeUserTokenDB();
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
              AlertObject testObj = AlertObject(
                  title: "DB테스트",
                  body: rd.toString(),
                  time: DateTime.now(),
                  alertType: AlertType.TO_SHARE_LOCATION_PAGE,
                  clickAction: {"meeting_id": "47"},
                  isRead: false);
              var manager = AlertManager(LocalStorage!);
              manager.sendAlert(title: "DB테스트1", body: rd.toString(), alertType: AlertType.NONE, userUUID: myUuid!, withPushNotifications: false);
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
              bool result = await manager.sendAlert(
                  title: title,
                  body: rd.toString(),
                  alertType: AlertType.NONE,
                  userUUID: "ki654uiWotZTum8GetnSC7HTgIk2",
                  withPushNotifications: true);
            },
          ),
          ListTile(
            title: Text('위치 업데이트 시작'),
            onTap: () async {
              if (tempTimer != null) {
                tempTimer!.cancel();
              }
              tempTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
                a++;
                DocumentReference _locationInstance = FirebaseFirestore.instance.collection("updateTest").doc("test");
                await FirebaseFirestore.instance.runTransaction((transaction) => transaction.get(_locationInstance).then((snapshot) async {
                      transaction.update(_locationInstance, {
                        myUuid!: {"nickname": a}
                      });
                    }));
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
            title: Text('json 출력'),
            onTap: () async {
              print(jsonEncode(AlertObject(title: "aa", body: "body", time: DateTime.now(), alertType: AlertType.NONE, isRead: false, clickAction: {"aa": "bb", "cc": "dd"})));
            },
          ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
        ],
      ),
    );
  }
}
