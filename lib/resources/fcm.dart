import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/alert/models/alert_object.dart';
import 'package:design_project/boards/post_list/page_hub.dart';
import 'package:design_project/chat/chat_screen.dart';
import 'package:design_project/main.dart';
import 'package:design_project/resources/resources.dart';
import 'package:design_project/resources/serviceAccount.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class FCMController {

  // static init() async {
  //   AndroidInitializationSettings androidInitializationSettings = const AndroidInitializationSettings('mipmap/ic_launcher');
  //   DarwinInitializationSettings iosInitializationSettings = const DarwinInitializationSettings(
  //     requestAlertPermission: true,
  //     requestBadgePermission: true,
  //     requestSoundPermission: true,
  //   );
  //   InitializationSettings initializationSettings = InitializationSettings(
  //     android: androidInitializationSettings, iOS: iosInitializationSettings,
  //   );
  //   await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }

  // static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static Flushbar? nowFlushBar;
  static String chatRoomName = "";
  http.Response? _response;

  Future<String?> sendMessage({required String userToken, required String title, required String body, required AlertType type, Map<String, String>? clickAction, bool? resend}) async {
    if (userToken == "logOut") {
      return "로그아웃된 사용자";
    }
    try {
      if (clickAction != null) {
        clickAction["type"] = type.toJson();
      }
      _response = await http.post(
          Uri.parse(
            "https://fcm.googleapis.com/v1/projects/loginexampleproject-90ced/messages:send",
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode({
            "message": {
              "token": userToken,
              // "topic": "user_uid",
              "notification": {
                "title": title,
                "body": body,
              },
              "data": clickAction ?? {"click_action" : "FCM Test Click Action"},
              "android": {
                "notification": {
                  "click_action": "Android Click Action",
                }
              },
              "apns": {
                "payload": {
                  "aps": {
                    "category": "Message Category",
                    "content-available": 1,
                    "badge" : 0, // 뱃지 설정,
                    // 뱃지는 서버에서 계산해서 보내야한다고 한다.... 이를 우째
                  }
                }
              }
            }
          }));
      if (_response!.statusCode == 200) {
        return null;
      } else {
        if(resend == null) {
          await tokenTimestampCheck();
          String? result = await sendMessage(userToken: userToken, title: title, body: body, type: type, clickAction: clickAction, resend: true);
          return result;
        } else {
          print(_response!.body);
          return "전송 실패";
        }
      }
    } on HttpException catch (error) {
      return error.message;
    }
    return null;
  }

  Future<AccessToken> getAccessToken() async {
    final serviceAccount = await ServiceAccount.getServiceAccount();

    final accountCredentials = ServiceAccountCredentials.fromJson({
      "private_key_id" : serviceAccount.privateKeyId,
      "private_key" : serviceAccount.privateKey,
      "client_email" : serviceAccount.clientEmail,
      "client_id" : serviceAccount.clientId,
      "type" : serviceAccount.type,
    });

    final scopes = ["https://www.googleapis.com/auth/firebase.messaging"];

    final AuthClient authClient = await clientViaServiceAccount(accountCredentials, scopes)..close();
    return authClient.credentials.accessToken;
  }

  Future<void> removeUserTokenDB() async {
    FirebaseFirestore.instance.collection("UserProfile").doc(myUuid!).update({"fcmToken" : "logOut"});
  }

  void showChatNotificationSnackBar({required String title, required String body, Map<String, dynamic>? clickActionValue}) async {
    // 이미 접속해있는 채팅방인지 판별
    if ( clickActionValue != null ) {
      if ( clickActionValue["is_group_chat"] == null && chatRoomName == title) { // 개인 채팅방에 접속해 있을 경우
          return;
      } else if ( clickActionValue["is_group_chat"] == "true" && chatRoomName == "[Post]${clickActionValue["chat_id"]}") { // 모임 채팅방에 접속해 있을 경우
          return;
      }
    }

    // 이미 메시지가 띄워져 있는 경우 삭제하고 띄움
    if (nowFlushBar != null && !nowFlushBar!.isDismissed()) {
      nowFlushBar!.dismiss();
    }
    nowFlushBar = Flushbar(
      title: title,
      message: body,
      duration: const Duration(milliseconds: 3000),
      animationDuration: const Duration(milliseconds: 500),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      borderRadius: BorderRadius.circular(5),
      backgroundColor: const Color(0xBB000000),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      mainButton: const Icon(Icons.arrow_forward_ios, color: Colors.white,),
      onTap: (value) async {
        await value.dismiss();
        if (clickActionValue == null) return;
        if (clickActionValue["is_group_chat"] == null || clickActionValue["is_group_chat"] == "false") {
          if(isInChat) {
            nestedChatOpenSignal = true;
            Navigator.of(navigatorKey.currentContext!).pushReplacement(MaterialPageRoute(builder: (context) => ChatScreen(recvUserId: clickActionValue["chat_id"])));
          } else {
            Get.to(() => ChatScreen(recvUserId: clickActionValue["chat_id"]));
          }
        } else {
          if(isInChat) {
            nestedChatOpenSignal = true;
            Navigator.of(navigatorKey.currentContext!).pushReplacement(MaterialPageRoute(builder: (context) => ChatScreen(postId: int.parse(clickActionValue["chat_id"]))));
          } else {
            Get.to(() => ChatScreen(postId: int.parse(clickActionValue["chat_id"])));
          }
        }
      },
    )..show(navigatorKey.currentContext!);

  }

  // static Future<void> showLocalNotification({required String title, required String body, Map<String, dynamic>? clickAction} ) async {
  //   const NotificationDetails notificationDetails = NotificationDetails(
  //     iOS: DarwinNotificationDetails(badgeNumber: 1)
  //   );
  //
  //   await _flutterLocalNotificationsPlugin.show(
  //     0, 'test title', 'test body', notificationDetails
  //   );
  // }
}
