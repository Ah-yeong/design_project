import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/alert/models/alert_manager.dart';
import 'package:design_project/meeting/share_location.dart';
import 'package:design_project/resources/resources.dart';
import 'package:design_project/settings/reset.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
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
              Get.off(() => MyHomePage());
              await FirebaseAuth.instance.signOut().then((value) {});
              await FCMController()..removeUserTokenDB();
              await showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: Text("로그아웃"),
                    content: Column(
                      children: [Text("어플을 재실행하세요!.")],
                    ),
                    actions: [CupertinoDialogAction(child: Text("확인"), onPressed: () => Navigator.pop(context))],
                  ));
              exit(0);
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
            title: Text('채팅 로컬데이터 삭제'),
            onTap: () {
              LocalStorage!.getKeys().forEach((element) {
                if (element.contains("_ChatData_")) {
                  LocalStorage!.remove(element);
                  print("삭제 완료 : $element");
                }
              });
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
                  alertType: AlertType.TO_SHARE_LOCATION,
                  clickAction: {"meeting_id": "47"},
                  isRead: false);
              var manager = AlertManager(LocalStorage!);
              manager.sendAlert(title: "DB테스트1", body: rd.toString(), alertType: AlertType.TO_CHAT_ROOM, userUUID: myUuid!, withPushNotifications: false, clickAction: {"meeting_id": "63"});
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
              title: Text('전체 데이터 초기화'),
              onTap: () {
                if(myUuid == "dBfF9GPpQqVvxY3SxNmWpdT1er43" || myUuid == "ki654uiWotZTum8GetnSC7HTgIk2")
                  Get.to(() => PageReset());
              }
          ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
              title: Text('remove'),
              onTap: () async {
                myProfileEntity!.removeMyPost(5);
              }
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
