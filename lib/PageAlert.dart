import 'package:design_project/Chat/ChatScreen.dart';
import 'package:design_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          '알림목록',
          style: TextStyle(
              fontSize: 18,
              color: Colors.black
          ),
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
              } else if ( index == 1) {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatScreen(recvUserId: "EM4L1plnXrOJDvRkfkX9k1DJRX32",)));
              } else if ( index == 2) {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatScreen(recvUserId: "dBfF9GPpQqVvxY3SxNmWpdT1er43",)));
              }
            },
           child: Card(
               child: ListTile(
                   leading: Icon(Icons.alarm),
                   title: Text('${index == 0 ? "로그아웃" : index == 1 ? "부계정과 대화하기" : index == 2 ? "본계정과 대화하기" : "알림제목 $index"}'),
                   subtitle: Text('알림 내용 $index'),
                   trailing: Text('10시간 전')// 알림 발생 시각
               )
           ),
          );
        },
      ),
    );
  }
}

