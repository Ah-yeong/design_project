import 'dart:async';

import 'package:design_project/Auth/PageResendVerifyMail.dart';
import 'package:design_project/Auth/PageResetPassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Boards/List/BoardMain.dart';
import '../Resources/resources.dart';
import '../main.dart';

class PageEmailVerified extends StatefulWidget {
  const PageEmailVerified({super.key});

  @override
  State<PageEmailVerified> createState() => _StatePageEmailVerified();
}

class _StatePageEmailVerified extends State<PageEmailVerified> {
  bool isSignin = false;

  var _user = FirebaseAuth.instance.currentUser;

  _checkEmailVerified() {
    if (_user != null) {
      try {
        _user!.reload().then((event) {
          _user = FirebaseAuth.instance.currentUser;
          if (_user!.emailVerified) {
            Get.off(() => BoardPageMainHub());
          } else {
            print("what?");
            showAlert("이메일 인증이 완료되지 않았어요!", context, colorWarning);
          }
        });
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
                  Text(" 인증 메일을 확인해주세요!",
                      style: TextStyle(fontSize: 14, color: colorGrey)),
                  Text(
                      "현재 로그인된 학번 : ${_user == null ? "없음" : _user!.email!.split("@")[0]}",
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
                  style: ElevatedButton.styleFrom(
                      elevation: 0, backgroundColor: colorSuccess),
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
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: colorGrey))),
                      child: Row(
                        children: [
                          Icon(
                            Icons.outgoing_mail,
                            size: 13,
                            color: colorGrey,
                          ),
                          Text(" 인증 메일 재전송",
                              style: TextStyle(fontSize: 14, color: colorGrey)),
                        ],
                      ),
                    ),
                    onTap: () {
                      Get.to(() => PageResendVerifyMail(),
                          arguments:
                              "${_user == null ? "없음" : _user!.email!.split("@")[0]}");
                    },
                  ),
                  Text("  또는  ",
                      style: TextStyle(fontSize: 14, color: colorGrey)),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      height: 18,
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: colorGrey))),
                      child: Row(
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 13,
                            color: colorGrey,
                          ),
                          Text(" 처음으로 돌아가기 ",
                              style: TextStyle(fontSize: 14, color: colorGrey)),
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
}
