import 'package:design_project/Chat/chat_screen.dart';
import 'package:design_project/main.dart';
import 'package:design_project/profiles/profile_first_setting/input_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'boards/post_list/page_hub.dart';

class PageAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          '알림목록',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: 10, // 알림 개수
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () async {
              if (index == 0) {
                await FirebaseAuth.instance.signOut().then((value) {
                  Get.off(() => MyHomePage());
                });
              } else if (index == 1) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          recvUserId: "EM4L1plnXrOJDvRkfkX9k1DJRX32",
                        )));
              } else if (index == 2) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          recvUserId: "dBfF9GPpQqVvxY3SxNmWpdT1er43",
                        )));
              } else if (index == 3) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          recvUserId: "ki654uiWotZTum8GetnSC7HTgIk2",
                        )));
              } else if (index == 4) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          postId: 1,
                          members: [
                            "EM4L1plnXrOJDvRkfkX9k1DJRX32",
                            "dBfF9GPpQqVvxY3SxNmWpdT1er43",
                            "ki654uiWotZTum8GetnSC7HTgIk2"
                          ],
                        )));
              } else if (index == 5) {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => NameSignUpScreen()));
              }
            },
            child: Card(
                child: ListTile(
                    leading: Icon(Icons.alarm),
                    title: Text(customAlertText(index)),
                    subtitle: Text(customAlertComment(index)),
                    trailing: Text('10시간 전') // 알림 발생 시각
                    )),
          );
        },
      ),
    );
  }

  String customAlertText(int index) {
    switch (index) {
      case 0:
        return "로그아웃";
      case 1:
        return "부계정과 대화하기";
      case 2:
        return "본계정과 대화하기";
      case 3:
        return "세번째 계정과 대화하기";
      case 4:
        return "그룹채팅 대화하기 (본,부1,부2)";
      case 5:
        return "프로필 재설정";
    }
    return "알림 제목 $index";
  }

  String customAlertComment(int index) {
    switch (index) {
      case 0:
        return "제곧내";
      case 1:
        return "현재 : ${myUuid}";
      case 2:
        return "현재 : ${myUuid}}";
      case 3:
        return "현재 : ${myUuid}}";
      case 4:
        return "limkg999, jongwon1019, gitlimjw";
      case 5:
        return "처음 계정 생성 시 설정 필요";
    }
    return "알림 내용 $index";
  }
}
