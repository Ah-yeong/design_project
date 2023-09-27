import 'package:design_project/Auth/PageEmailVerified.dart';
import 'package:design_project/Resources/LoadingIndicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../Resources/resources.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> with SingleTickerProviderStateMixin {
  TextEditingController? _controllerId;
  TextEditingController? _controllerPw;
  TextEditingController? _controllerPwConfirm;

  String? _infoText;
  bool? _infoTextHighlight;
  bool _isLoading = false;

  final _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(40),
              child: Form(
                key: _formKey,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "회원가입",
                          style: TextStyle(
                            fontSize: 33,
                            color: Colors.black87,
                            fontFamily: "logo",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFE8E8E8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextFormField(
                                controller: _controllerId,
                                style: TextStyle(fontSize: 15),
                                maxLength: 9,
                                decoration: InputDecoration(
                                  hintText: "학번",
                                  hintStyle: TextStyle(fontSize: 15),
                                  border: InputBorder.none,
                                  counterText: "",
                                )),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFE8E8E8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextFormField(
                                controller: _controllerPw,
                                obscureText: true,
                                style: TextStyle(fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: "비밀번호",
                                  hintStyle: TextStyle(fontSize: 15),
                                  border: InputBorder.none,
                                  counterText: "",
                                )),
                          )),
                      const SizedBox(height: 2),
                      Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFE8E8E8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextFormField(
                                controller: _controllerPwConfirm,
                                obscureText: true,
                                style: TextStyle(fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: "비밀번호 확인",
                                  hintStyle: TextStyle(fontSize: 15),
                                  border: InputBorder.none,
                                  counterText: "",
                                )),
                          )),
                      const SizedBox(
                        height: 7.5,
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: _infoTextHighlight! ? colorError : colorGrey,
                                size: 13,
                              ),
                              Text(
                                " ${_infoText}",
                                style: TextStyle(
                                    fontWeight: _infoTextHighlight! ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                    color: _infoTextHighlight! ? colorError : colorGrey),
                              )
                            ],
                          )),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                            });
                            _signup();
                          },
                          child: const Text(
                            "가입하기",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: colorSuccess),
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
            _isLoading ? buildContainerLoading(135) : SizedBox()
          ],
        ),
      ),
    );
  }

  _loadingCompleted() {
    setState(() {
      _isLoading = false;
    });
  }

  _signup() async {
    if (_controllerId!.value.text.length != 9 || !_controllerId!.value.text.isNumericOnly) {
      print(_controllerId!.value.text.length);
      print(_controllerId!.value.text.isNumericOnly);
      showAlert("학번을 제대로 입력해주세요!", context, colorError);
      _loadingCompleted();
      return;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
            email: "${_controllerId!.value.text}@sangmyung.kr", password: _controllerPw!.value.text);
        credential.user!.sendEmailVerification();
        if (credential.user != null) {
          showAlert("이메일로 인증 주소가 발급되었습니다!", context, colorSuccess);
          await FirebaseFirestore.instance
              .collection('UserProfile')
              .doc(credential.user!.uid)
              .set({'uid': _auth.currentUser!.uid});
          Get.offAll(() => const PageEmailVerified());
        }
      } on FirebaseAuthException catch (e) {
        String message = '';

        if (e.code == 'email-already-in-use') {
          message = '학번이 이미 사용중입니다.';
          _infoTextHighlight = true;
          _infoText = "계정이 도용당했다면, 비밀번호 재설정을 이용하세요!";
          setState(() {});
        } else if (e.code == 'weak-password') {
          message = '비밀번호가 너무 취약합니다.';
        } else {
          message = e.code;
        }
        showAlert(message ?? "", context, colorError);
      }
    }
    _loadingCompleted();
  }

  @override
  void initState() {
    super.initState();
    _controllerId = TextEditingController();
    _controllerPw = TextEditingController();
    _controllerPwConfirm = TextEditingController();
    _infoTextHighlight = false;
    _infoText = "학교 이메일(@sangmyung.kr)로 메일이 발송돼요!";
  }
}
