import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:design_project/Chat/models/MessageFormat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../resources.dart';
import 'ChatBubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'ChatScreen.dart';

class Messages extends StatefulWidget {
  final int? postId;
  final String? recvUser;
  const Messages({Key? key, this.postId, this.recvUser}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState(postId, recvUser);
}

class _MessagesState extends State<Messages> {
  final int? postId;
  final String? recvUserId;
  _MessagesState(this.postId, this.recvUserId);

  late SharedPreferences _preferences;
  final _chatController = TextEditingController();
  late List<Map<String, dynamic>> savedChatData;

  late bool isGroupChat;
  late String chatDocName;
  late String chatColName;
  late String sendUserId;
  bool isFirstChatted = true;

  bool spLoaded = false;
  bool dbLoaded = false;

  @override
  void initState() {
    super.initState();
    print("11 $postId / $recvUserId");
    _initDatabases().then((value) => setState(() {dbLoaded = true;     print("db load"); print("-- $chatDocName");}));
    _initSharedPreferences().then((value) => setState(() {spLoaded = true;    print("sp load");}));
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _initDatabases() async {
    if (recvUserId != null && postId != null)
      return; // 둘 다 입력되었을 때는 예외로 함
    isGroupChat = recvUserId == null; // userId, postId 둘 중 하나만 들어와야 함

    // 보내는 유저 이름에 대하여 채팅 Collection, Document 이름 설정
    sendUserId = FirebaseAuth.instance.currentUser!.uid;
    chatDocName = isGroupChat
        ? postId.toString()
        : getNameChatRoom(sendUserId, recvUserId!);
    chatColName = isGroupChat ? "PostGroupChat" : "Chat";

    return;
  }

  // 메시지 전송 메서드
  Future<void> _sendMessage() async {
    // 1:1 채팅인 경우, 이름 순서가 바뀐 Document가 있는지 검사 후 해당 Document이름으로 chatDocName 변경.

    if ( isFirstChatted && !isGroupChat) {
      isFirstChatted = false;
      addChatDataList(FirebaseAuth.instance.currentUser!.uid, false, recvUserId: recvUserId!);
      addChatDataList(recvUserId!, false, recvUserId: FirebaseAuth.instance.currentUser!.uid);
    }

    final message = _chatController.text.trim(); // 좌우 공백 제거된 전송될 내용
    final timestamp = Timestamp.now(); // 전송 시간

    var documentSnapshots = await FirebaseFirestore.instance.collection(
        chatColName).doc(chatDocName).get();
    if (!documentSnapshots.exists) { // document가 존재하지 않으면 members 초기화 후 삽입
      await FirebaseFirestore.instance.collection(chatColName)
          .doc(chatDocName)
          .set({
        "members": ["$recvUserId", "$sendUserId"],
        "contents": [{
          "sender": sendUserId
          , "readBy": [sendUserId]
          , "message": message
          , "timestamp": timestamp
          , "nickname" : myProfileEntity.name
        }
        ]
      });
    } else { // document가 이미 존재하면 메시지 추가
      List<dynamic> contents = documentSnapshots.data()!["contents"];
      contents.add({
        "sender": sendUserId
        , "readBy": [sendUserId]
        , "message": message
        , "timestamp": timestamp
        , "nickname" : myProfileEntity.name
      });
      await FirebaseFirestore.instance.collection(chatColName)
          .doc(chatDocName)
          .update({"contents": contents});


    }

    _chatController.clear();
    //savedChatData.add(MessageModel(senderUid: sendUserId, message: message, timestamp: timestamp.toString(), nickName: myProfileEntity.name).toMap());
    //_preferences.setString('chat_data_${isGroupChat ? postId : recvUserId}', json.encode(savedChatData));
    return;
  }

  Future<void> _initSharedPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    //savedChatData = _getSavedChatData() ?? [];
    setState(() {}); // _preferences를 초기화한 후에 다시 build 되도록 setState 호출
  }


  List<Map<String, dynamic>>? _getSavedChatData() {
    if ( isGroupChat ) {
      if (_preferences.containsKey('chat_data_$postId'))
        return json.decode(_preferences.getString('chat_data_$postId')!) as List<Map<String, dynamic>>;
    } else {
      if (_preferences.containsKey('chat_data_$recvUserId'))
        return json.decode(_preferences.getString('chat_data_$recvUserId')!) as List<Map<String, dynamic>>;
    }
    return null;
  }


  Future<void> _removeReadChat(List<int> removeList) async {
    List<dynamic> messageList;
    await FirebaseFirestore.instance.collection(chatColName).doc(chatDocName).get().then((ds) {
      messageList = ds.get("contents");
      int removedCount = 0;
      for (int i = 0; i < removeList.length; i++) {
        messageList.removeAt(i - removedCount);
      }
      FirebaseFirestore.instance.collection(chatColName).doc(chatDocName).update({"contents" : messageList});
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // _chatRef.onChildAdded.listen((event) {
    //   final chatData = event.snapshot.value as Map<dynamic, dynamic>;
    //   final isMe = chatData['userID'] == user!.uid;
    //
    //   // 상대방의 화면에 채팅 메시지 표시
    //   if (!isMe) {
    //     setState(() {
    //       savedChatData.add(chatData['text']);
    //     });
    //   }
    // });

    return !(spLoaded && dbLoaded) ? Center(
      child: Center(
          child: SizedBox(
              height: 65,
              width: 65,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: colorSuccess,
              ))),
    ) : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      stream: FirebaseFirestore.instance
          .collection(chatColName)
          .doc(chatDocName).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final List<dynamic> chatDocs = !snapshot.data!.exists ? [] : snapshot.data!.get("contents");
        final List<dynamic> members = !snapshot.data!.exists ? [] : snapshot.data!.get("members");
        final membersCount = members.length;

        List<Widget> chatWidgets = [];
        DateTime? currentDate;

        // // Timestamp 순으로 정렬하기 위해 Comparator 선언 후 정렬
        // Comparator<dynamic> comparator = (a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp']);
        // chatDocs.sort(comparator);
        List<int> _list = List.empty(growable: true);
        for (int i = 0; i < chatDocs.length; i++) {
          final chat = chatDocs[i];
          final isMe = chat['sender'] == user!.uid;
          final timestamp = chat['timestamp'] as Timestamp;
          final dateTime = timestamp.toDate();
          final year = dateTime.year;
          final month = dateTime.month;
          final day = dateTime.day;

          if (!chat['readBy'].contains(user.uid)) {
            final bool isReadedAll = chat['readBy'].length + 1 == membersCount;
            if (isReadedAll) {
              _list.add(i);
            }
          }

          //final weekday = dateTime.weekday;

          // 날짜가 바뀌면 날짜를 표시
          if (currentDate == null || currentDate.year != year ||
              currentDate.month != month || currentDate.day != day) {
            currentDate = DateTime(year, month, day);
            final formattedDate = DateFormat('yyyy-MM-dd E').format(
                currentDate);
            chatWidgets.add(
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          final formattedTime = DateFormat.jm().format(dateTime);
          final userName = chat['nickname'];
          chatWidgets.add(
            Row(
              mainAxisAlignment: isMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (isMe)
                  Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ChatBubble(chat['message'], isMe, userName ?? 'Unknown'),
                if (!isMe)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        }

        //_removeReadChat(_list); -> 데이터베이스에서 삭제

        return SafeArea(
            child: Column(
          children: [
            Expanded(
              child: ListView(
                reverse: true,
                children: chatWidgets.reversed.toList(),
              ),
            ),
            Container(
              width: 382,
              height: 40,
              margin: EdgeInsets.only(bottom: 16.0), // 상단 여백 조정
              child: TextField(
                controller: _chatController,
                onSubmitted: (value) {
                  _sendMessage();
                },
                decoration: InputDecoration(
                  hintText: ' 메시지 입력',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _sendMessage();
                    },
                    icon: Icon(Icons.send),
                  ),
                ),
              ),
            ),
          ],
        ));
      },
    );
  }
}

getNameChatRoom(String sendId, String recvId) {
  return recvId.compareTo(sendId) < 0 ? "$recvId-$sendId" : "$sendId-$recvId";
}