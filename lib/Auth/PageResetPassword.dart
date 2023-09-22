import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Resources/resources.dart';
import '../main.dart';

class PageResetPassword extends StatefulWidget {
  const PageResetPassword({super.key});

  @override
  State<PageResetPassword> createState() => _StatePageResetPassword();
}

class _StatePageResetPassword extends State<PageResetPassword> {
  // About final value
  final String STORAGE_NAME = "last_send_reset_mail";
  final _argEmail = Get.arguments;
  bool? _argIsValid;

  TextEditingController _emailController = TextEditingController();
  String? _infoText;
  
  DateTime? _storageTime;
  SharedPreferences? _localStorage;

  @override
  void initState() {
    _loadStorage();

    _argIsValid = (_argEmail != null && _argEmail != "없음");
    if ( _argIsValid! ) {
      _emailController.text = "$_argEmail";
      _infoText = "$_argEmail@sangmyung.kr";
    } else {
      _infoText = "< >";
    }
    super.initState();
  }
  
  _loadStorage() async {
    _localStorage = await SharedPreferences.getInstance();
  }

  _sendResetMail(String email) async {
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
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
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
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
                            color: _emailController.text == ""
                                ? colorGrey
                                : Colors.black,
                            decoration: _emailController.text == ""
                                ? TextDecoration.none
                                : TextDecoration.underline)),
                    SizedBox(
                      height: 7,
                    ),
                    Text("위 이메일로 재설정 이메일이 전송돼요!",
                        style: TextStyle(fontSize: 14, color: colorGrey))
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                !_argIsValid! ? Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          if (value == "")
                            _infoText = "< >";
                          else
                            _infoText = "$value@sangmyung.kr";
                        });
                      },
                      controller: _emailController,
                      style: TextStyle(fontSize: 15),
                      maxLength: 9,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        hintText: "학번",
                        hintStyle: TextStyle(fontSize: 15),
                        border: InputBorder.none,
                        counterText: "",
                      ),
                    ),
                  ),
                ) : SizedBox(),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_emailController.value.text.length != 9 || !_emailController.value.text.isNumericOnly) {
                        showAlert("학번을 제대로 입력해주세요!", context, colorError);
                        return;
                      }
                      _sendResetMail("${_emailController.value.text}@sangmyung.kr");
                    },
                    child: const Text(
                      '재설정 메일 보내기',
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
      ),
    );
  }
}
