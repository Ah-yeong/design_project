import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/auth/resend_verify_mail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../alert/models/alert_object.dart';
import '../boards/post_list/page_hub.dart';
import '../resources/fcm.dart';
import '../resources/resources.dart';
import '../main.dart';
import '../profiles/profile_first_set.dart';

class PageEmailVerified extends StatefulWidget {
  const PageEmailVerified({super.key});

  @override
  State<PageEmailVerified> createState() => _StatePageEmailVerified();
}

class _StatePageEmailVerified extends State<PageEmailVerified> {
  bool isSignin = false;

  var _user = FirebaseAuth.instance.currentUser;

  Future<void> _checkEmailVerified() async {
    if (_user != null) {
      try {
        await _user!.reload();
          _user = FirebaseAuth.instance.currentUser;
          if (_user!.emailVerified) {
            myUuid = FirebaseAuth.instance.currentUser!.uid;
            await getServerToken();
            await postManager.loadPages("");
            await _initializeFCM();
            Get.off(() => NameSignUpScreen());
          } else {
            print("what?");
            showAlert("이메일 인증이 완료되지 않았어요!", context, colorWarning);
          }
      } catch (e) {
        showAlert("알 수 없는 오류가 발생했어요", context, colorWarning);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 55),
                child: Text(
                  "마음 맞는, 사람끼리",
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.black87,
                    fontFamily: "logo",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(" 인증 메일을 확인해주세요!", style: TextStyle(fontSize: 14, color: colorGrey)),
                  Text("현재 로그인된 학번 : ${_user == null ? "없음" : _user!.email!.split("@")[0]}",
                      style: TextStyle(fontSize: 14, color: colorGrey))
                ],
              ),
              SizedBox(
                height: 45,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _checkEmailVerified();
                  },
                  child: const Text(
                    '이메일 인증 확인',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: colorSuccess),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colorGrey))),
                      child: Row(
                        children: [
                          Icon(
                            Icons.outgoing_mail,
                            size: 13,
                            color: colorGrey,
                          ),
                          Text(" 인증 메일 재전송", style: TextStyle(fontSize: 14, color: colorGrey)),
                        ],
                      ),
                    ),
                    onTap: () {
                      Get.to(() => PageResendVerifyMail(),
                          arguments: "${_user == null ? "없음" : _user!.email!.split("@")[0]}");
                    },
                  ),
                  Text("  또는  ", style: TextStyle(fontSize: 14, color: colorGrey)),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      height: 18,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colorGrey))),
                      child: Row(
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 13,
                            color: colorGrey,
                          ),
                          Text(" 처음으로 돌아가기 ", style: TextStyle(fontSize: 14, color: colorGrey)),
                        ],
                      ),
                    ),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut().then((value) {
                        Get.off(() => MyHomePage());
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _initializeFCM() async {
    // FCM 토큰 받아오기
    myUuid = FirebaseAuth.instance.currentUser!.uid;

    myToken = await FirebaseMessaging.instance.getToken();

    try {
      DocumentReference reference = FirebaseFirestore.instance.collection("UserProfile").doc(myUuid!);
      await reference.update({"fcmToken": myToken});
    } catch (e) {
      if (e.toString().contains("document was not found")) {
        FirebaseFirestore.instance.collection("UserProfile").doc(myUuid!).set({"fcmToken": myToken});
      }
    }

    // 토큰 만료 확인
    FCMController fcm = FCMController();
    await fcm.sendMessage(userToken: myToken!, title: "TestMessaging", body: "TestMessage", type: AlertType.FCM_TEST).then((value) {
      if (value == "전송 실패") {
        FirebaseMessaging.instance.deleteToken().then((value) async {
          myToken = await FirebaseMessaging.instance.getToken();
          try {
            DocumentReference reference = FirebaseFirestore.instance.collection("UserProfile").doc(myUuid!);
            await reference.update({"fcmToken": myToken});
          } catch (e) {
            if (e.toString().contains("document was not found")) {
              FirebaseFirestore.instance.collection("UserProfile").doc(myUuid!).set({"fcmToken": myToken});
            }
          }
        });
      }
    });

    // 토큰 리프레시
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      myToken = fcmToken;
      if (myProfileEntity != null) {
        myProfileEntity!.fcmToken = fcmToken;
      }
      DocumentReference reference = FirebaseFirestore.instance.collection("UserProfile").doc(myUuid!);
      await reference.update({"fcmToken": fcmToken});
      print("fcmToken 새로고침");
    }).onError((err) {
      // Error getting token
    });
    // 백그라운드 푸시알림
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 포어그라운드 푸시알림
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message != null) {
        if (message.notification != null) {
          if (message.data.containsKey("type")) {
            var fcm = FCMController();
            fcm.showNotificationSnackBar(title: message.notification!.title!, body: message.notification!.body!, clickActionValue: message.data);
            //_bottomAppbarRefresh(type);
            // else if ...
          }
        }
      }
    });
  }
}
