import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:design_project/settings/reset.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../boards/post_list/page_hub.dart';
import '../main.dart';
import '../resources/fcm.dart';
import '../resources/resources.dart';

class PageResignation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageResignation();
}


class _PageResignation extends State<PageResignation> {
  TextEditingController _passwordController = TextEditingController();
  bool isProcessing = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            elevation: 1,
            title: const Text('회원 탈퇴', style: TextStyle(fontSize: 19, color: Colors.black)),
            backgroundColor: Colors.white,
            leading: BackButton(
              color: Colors.black,
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("회원 탈퇴시 다음 내역이 모두 삭제돼요 :\n", style: TextStyle(fontSize: 15, color: Colors.black)),
                      Text("- 기본 회원 정보\n- 기기 내부의 채팅 등 각종 데이터\n- 설정된 프로필 및 모임 내역\n- 작성한 모든 게시글\n- 참여했던 모임 내역 및 매너지수",
                          style: TextStyle(fontSize: 14, color: colorGrey)),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
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
                        },
                        controller: _passwordController,
                        style: TextStyle(fontSize: 15),
                        obscureText: true,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          hintText: "비밀번호 입력",
                          hintStyle: TextStyle(fontSize: 15),
                          border: InputBorder.none,
                          counterText: "",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool isVerify = false;
                        setState(() {
                          isProcessing = true;
                        });
                        UserCredential? credential;
                        try {
                          credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: FirebaseAuth.instance.currentUser!.email!, password: _passwordController.value.text);  
                          isVerify = true;
                        } catch (e) {
                          showAlert("비밀번호가 일치하지 않아요.", context, colorError);
                        }
                        if (isVerify) {
                          _showResignationPopup(credential!);
                        } else {
                          setState(() {
                            isProcessing = false;
                          });
                        }
                        //_showResignationPopup();
                      },
                      child: const Text(
                        '회원 탈퇴',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: colorError),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isProcessing) buildContainerLoading(135)
      ],
    );
  }

  Future<void> _showResignationPopup(UserCredential credential) async {
    final action = CupertinoActionSheet(
      title: Text(
        "탈퇴할까요?",
        style: TextStyle(fontSize: 15),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("회원 탈퇴"),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            setState(() {
              isProcessing = true;
            });
            await deleteUserData();
            await credential.user!.delete();
            await showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                      title: Text("탈퇴 완료"),
                      content: Column(
                        children: [Text("이용해주셔서 감사합니다.")],
                      ),
                      actions: [CupertinoDialogAction(child: Text("확인"), onPressed: () => Navigator.pop(context))],
                    ));
            exit(0);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("취소"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    await showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  Future<void> deleteUserData() async {
    final instance = FirebaseFirestore.instance;
    await instance.collection("UserProfile").doc(myUuid!).delete();
    try {
      await instance.collection("Alert").doc(myUuid!).delete();
    } catch (e) {}
    try {
      await instance.collection("Nick").doc(myUuid!).delete();
    } catch (e) {}
    try {
      await instance.collection("Nick").doc(myUuid!).delete();
    } catch (e) {}
    try {
      await instance.collection("UserChatData").doc(myUuid!).delete();
    } catch (e) {}
    try {
      await instance.collection("UserMeetings").doc(myUuid!).delete();
    } catch (e) {}
    try {
      await instance.collection("Nick").doc(myUuid!).delete();
    } catch (e) {}
    try {
      await instance.collection("Evaluation").doc(myUuid!).delete();
    } catch (e) {}
    try {
      final storageInstance = FirebaseStorage.instance;
      Reference storageRef = storageInstance.ref("profile_image/${myUuid}");
      await storageRef.delete();
    } catch (e) {}
    await Future.forEach(LocalStorage!.getKeys(), (key) {
      if (key.contains("${myUuid}_ChatData")) LocalStorage!.remove(key);
    });
    return;
  }
}
