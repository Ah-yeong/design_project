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

class _SignUpPage extends State<SignUpPage> {
  TextEditingController? controllerId;
  TextEditingController? controllerPw;
  TextEditingController? controllerPwConfirm;
  TextEditingController? controllerClassId;
  bool isSignin = false;

  final _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                    const SizedBox(height: 30,),
                    Text("아이디 관련", style: TextStyle(fontSize: 15),),
                    const SizedBox(height: 2,),
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
                              controller: controllerId,
                              style: TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: "이메일 아이디",
                                hintStyle: TextStyle(fontSize: 15),
                                border: InputBorder.none,
                                counterText: "",
                              )),
                        )),
                    const SizedBox(height: 2,),
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
                              controller: controllerPw,
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
                              controller: controllerPwConfirm,
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
                      height: 20,
                    ),
                    Text("학교 관련", style: TextStyle(fontSize: 15),),
                    const SizedBox(height: 2,),
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
                              controller: controllerClassId,
                              obscureText: true,
                              style: TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: "학번",
                                hintStyle: TextStyle(fontSize: 15),
                                border: InputBorder.none,
                                counterText: "",
                              )),
                        )),
                    const SizedBox(
                      height: 4,
                    ),
                    Align(
                     alignment: Alignment.center,
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.info_outline, color: Colors.grey, size: 13,),
                         Text(" 동일한 아이디, 학번으로 계정을 생성할 수 없어요!", style: TextStyle(fontSize: 12, color: Colors.grey),),
                       ],
                     )
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signup,
                        child: const Text("가입하기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                        style:
                        ElevatedButton.styleFrom(elevation: 0, backgroundColor: colorSuccess),
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
                                  style: TextStyle(
                                      fontSize: 15, color: colorGrey),
                                ),
                              ],
                            )
                          ),
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ],
                )),
          )),
    );
  }

  _signup () async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        CollectionReference users = FirebaseFirestore.instance.collection('NickClassData');
        await users.doc('classIds').get().then((DocumentSnapshot snapshot) {
          try {
            if(snapshot.get(controllerClassId!.value.text) != null) {
              throw FirebaseAuthException(code: "classid-already-in-use");
            }
          } catch (e) {
            e.toString();
          }
        });
        final credential = await _auth.createUserWithEmailAndPassword(
            email: controllerId!.value.text, password: controllerPw!.value.text);
        FirebaseAuth.instance.currentUser!.sendEmailVerification();
        // var nickList = await FirebaseFirestore.instance.collection('NickClassData')
        //     .doc('nickNames').get();
        // var classIdList = await FirebaseFirestore.instance.collection('NickClassData')
        //     .doc('classIds').get();
        showAlert("이메일로 인증 주소가 발급되었습니다!", context, colorSuccess);
        if (credential.user != null) {
            await FirebaseFirestore.instance
              .collection('UserData')
              .doc(credential.user!.uid)
              .set({
            'emailAddress' : controllerId!.value.text,
            'password' : controllerPw!.value.text,
            'classId' : controllerClassId!.value.text,
          });
            await FirebaseFirestore.instance
                .collection('UserProfile')
                .doc(credential.user!.uid)
                .set({
              'uid' : _auth.currentUser!.uid
            });
          await FirebaseFirestore.instance
              .collection('NickClassData')
              .doc('classIds')
              .update({controllerClassId!.value.text : '1'});
          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        String message = '';

        if(e.code == 'email-already-in-use') {
          message = '이메일이 이미 사용중입니다.';
        } else if (e.code == 'classid-already-in-use') {
          message = '학번이 이미 사용중입니다.';
        } else if (e.code == 'weak-password'){
          message = '비밀번호가 너무 취약합니다.';
        } else {
          message = e.code;
        }

        showAlert(message ?? "", context, colorError);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    controllerId = TextEditingController();
    controllerPw = TextEditingController();
    controllerPwConfirm = TextEditingController();
    controllerClassId = TextEditingController();
  }
}
