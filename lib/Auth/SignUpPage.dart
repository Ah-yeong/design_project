import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../resources.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  TextEditingController? controllerId;
  TextEditingController? controllerPw;
  TextEditingController? controllerPwConfirm;
  TextEditingController? controllerNick;
  TextEditingController? controllerClassId;
  bool isSignin = false;

  final _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("회원가입"),
      ),
      body: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 3, bottom: 7),
                                ),
                                Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Icon(
                                        Icons.mail,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        keyboardType: TextInputType.emailAddress,
                                        controller: controllerId,
                                        decoration: InputDecoration(
                                          hintText: "아이디"
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                                  child: Divider(
                                    thickness: 1.5,
                                    height: 0,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Icon(
                                        Icons.lock,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Expanded(
                                        child: TextFormField(
                                          controller: controllerPw,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              hintText: "아이디"
                                          ),
                                        ))
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                                  child: Divider(
                                    thickness: 1.5,
                                    height: 0,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Icon(
                                        Icons.lock_clock,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Expanded(
                                        child: TextFormField(
                                          controller: controllerPwConfirm,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              hintText: "아이디"
                                          ),
                                        ))
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 7, bottom: 0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: colorGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 3, bottom: 7),
                                ),
                                Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Icon(
                                        CupertinoIcons.person_fill,
                                        color: CupertinoColors.secondaryLabel,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        keyboardType: TextInputType.name,
                                        controller: controllerNick,
                                        decoration: InputDecoration(
                                            hintText: "닉네임"
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                                  child: Divider(
                                    thickness: 1.5,
                                    height: 0,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Icon(
                                        CupertinoIcons.number,
                                        color: CupertinoColors.secondaryLabel,
                                      ),
                                    ),
                                    Expanded(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          controller: controllerClassId,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              hintText: "학번"
                                          ),
                                        ))
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 7, bottom: 0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signup,
                        child: const Text('회원가입'),
                      ),
                    )
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
        await users.doc('nickNames').get().then((DocumentSnapshot snapshot) {
          try {
            if(snapshot.get(controllerNick!.value.text) != null) {
              throw FirebaseAuthException(code: "nickname-already-in-use");
            }
          } catch (e) {
            e.toString();
          }
        });
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
        var nickList = await FirebaseFirestore.instance.collection('NickClassData')
            .doc('nickNames').get();
        var classIdList = await FirebaseFirestore.instance.collection('NickClassData')
            .doc('classIds').get();
        print(nickList.data().toString());
        print(classIdList.data().toString());
        showAlert("이메일로 인증 주소가 발급되었습니다!", context, colorSuccess);
        if (credential.user != null) {
            await FirebaseFirestore.instance
              .collection('UserData')
              .doc(credential.user!.uid)
              .set({
            'emailAddress' : controllerId!.value.text,
            'password' : controllerPw!.value.text,
            'nickName' : controllerNick!.value.text,
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
              .doc('nickNames')
              .update({controllerNick!.value.text : '1'});
          await FirebaseFirestore.instance
              .collection('NickClassData')
              .doc('classIds')
              .update({controllerClassId!.value.text : '1'});
          setState(() {
            isSignin = true;
            controllerPw!.clear();
          });
        }
      } on FirebaseAuthException catch (e) {
        String message = '';

        if(e.code == 'email-already-in-use') {
          message = '이메일이 이미 사용중입니다.';
        } else if (e.code == 'nickname-already-in-use') {
          message = '닉네임이 이미 사용중입니다.';
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
    controllerNick = TextEditingController();
    controllerClassId = TextEditingController();
  }
}
