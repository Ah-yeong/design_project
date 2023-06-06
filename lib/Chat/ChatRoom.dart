
import 'package:design_project/Chat/ChatScreen.dart';
import 'package:flutter/material.dart';
import 'package:design_project/Entity/EntityPost.dart';
//import 'package:firebase_database/firebase_database.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primaryColor: Color(0xFF6ACA89),
      ),
      home: ChatRoomListScreen(), // 채팅방 리스트 화면으로 시작
    );
  }
}

class ChatRoomListScreen extends StatefulWidget {
  @override
  _ChatRoomListScreenState createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> {
  EntityPost postEntity = EntityPost(10); //임시 postId


  @override
  void initState() {
    super.initState();
    postEntity.loadPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅방'),
        backgroundColor: Color(0xFF6ACA89), // 앱바 색상 변경
      ),
      body: FutureBuilder<void>(
        future: postEntity.loadPost(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final chatRoomNumber = postEntity.getPostId();
            return ListView.separated(
              itemCount: 10, //예시로 10개 설정
              separatorBuilder: (context, index) => Divider(  //구분선
                color: Colors.grey[400]!,
                thickness: 1.5,
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Chat Room $chatRoomNumber'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(postId: chatRoomNumber),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
