import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Resources/resources.dart';
import '../main.dart';

class PageResendVerifyMail extends StatefulWidget {
  const PageResendVerifyMail({super.key});

  @override
  State<PageResendVerifyMail> createState() => _StatePageResendVerifyMail();
}

class _StatePageResendVerifyMail extends State<PageResendVerifyMail> {
  // About final value
  final String STORAGE_NAME = "last_send_verify_mail";
  final _argEmail = Get.arguments;
  bool? _argIsValid;

  String? _infoText;
  final _user = FirebaseAuth.instance.currentUser;

  DateTime? _storageTime;
  SharedPreferences? _localStorage;

  @override
  void initState() {
    _loadStorage();

    _argIsValid = (_argEmail != null && _argEmail != "없음");
    if ( _argIsValid! ) {
      _infoText = "$_argEmail@sangmyung.kr";
    }
    super.initState();
  }

  _loadStorage() async {
    _localStorage = await SharedPreferences.getInstance();
  }

  _sendVerifyMail() async {
    if ( _localStorage!.getString(STORAGE_NAME) != null ) {
      _storageTime = DateTime.parse(_localStorage!.getString(STORAGE_NAME)!);
    }
    if ( _storageTime != null ) {
      DateTime _nowTime = DateTime.now();
      int remainSecond = 300 - _nowTime.difference(_storageTime!).inSeconds;
      if ( remainSecond > 0 ) {
        showAlert("$remainSecond초 뒤에 재전송이 가능해요!", context, colorSuccess);
        return;
      }
    }

    try {
      _user!.sendEmailVerification();
      showAlert("성공! 메일을 확인해주세요!", context, colorSuccess);
      _localStorage!.setString(STORAGE_NAME, DateTime.now().toString());
    } catch(e) {
      showAlert("이런! 계정을 찾을 수 없어요!", context, colorError);
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
              Column(
                children: [
                  Text(_infoText!,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          decoration: TextDecoration.underline)),
                  SizedBox(
                    height: 7,
                  ),
                  Text("위 이메일로 인증 메일이 전송돼요!",
                      style: TextStyle(fontSize: 14, color: colorGrey))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sendVerifyMail();
                  },
                  child: const Text(
                    '인증 메일 재전송',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                      elevation: 0, backgroundColor: colorSuccess),
                ),
              ),
              Center(
                child: SizedBox(
                  height: 35,
                  width: 100,
                  child: GestureDetector(
                    child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, size: 14, color: colorGrey),
                            Text(
                              " 이전으로",
                              style: TextStyle(fontSize: 15, color: colorGrey),
                            ),
                          ],
                        )),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
