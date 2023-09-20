import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:design_project/Resources/LoadingIndicator.dart';
import 'package:design_project/Resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/ChatBubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'ChatScreen.dart';
import 'models/ChatDataModel.dart';
import 'models/ChatStorage.dart';

class ChatMessage extends StatefulWidget {
  final int? postId;
  final String? recvUser;
  final List<String>? members;

  const ChatMessage({Key? key, this.postId, this.recvUser, this.members})
      : super(key: key);

  @override
  _ChatMessageState createState() =>
      _ChatMessageState(postId, recvUser, members);
}

class _ChatMessageState extends State<ChatMessage> {
  final int? postId;
  final String? recvUserId;
  final List<String>? members;

  _ChatMessageState(this.postId, this.recvUserId, this.members);

  final _chatController = TextEditingController();

  late bool isGroupChat;
  late String chatDocName;
  late String chatColName;
  late String sendUserId;
  bool isFirstChatted = true;

  bool calculateChecker = false;
  bool spLoaded = false;
  bool dbLoaded = false;

  FocusNode? myFocus;
  late ChatStorage? _savedChat;

  @override
  void initState() {
    super.initState();
    myFocus = FocusNode();
    _savedChat = ChatStorage(postId == null ? recvUserId! : postId!.toString());
    _savedChat!.init().then((value) => setState(() {
          spLoaded = true;
          _savedChat!.load();
        }));
    _initDatabases().then((value) => setState(() => dbLoaded = true));
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _initDatabases() async {
    if (recvUserId != null && postId != null) return; // 둘 다 입력되었을 때는 예외로 함
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

    if (isFirstChatted) {
      isFirstChatted = false;
      if (isGroupChat) {
        addChatDataList(true, postId: postId, members: members);
      } else {
        addChatDataList(
            uid: FirebaseAuth.instance.currentUser!.uid,
            false,
            recvUserId: recvUserId!);
        addChatDataList(
            uid: recvUserId!,
            false,
            recvUserId: FirebaseAuth.instance.currentUser!.uid);
      }
    }

    final message = _chatController.text.trim(); // 좌우 공백 제거된 전송될 내용
    final timestamp = Timestamp.now(); // 전송 시간
    _savedChat!.savedChatList.add(ChatDataModel(
        text: message, ts: timestamp, nickName: myProfileEntity!.name));
    _savedChat!.save();
    var documentSnapshots = await FirebaseFirestore.instance
        .collection(chatColName)
        .doc(chatDocName)
        .get();
    if (!documentSnapshots.exists) {
      // document가 존재하지 않으면 members 초기화 후 삽입
      await FirebaseFirestore.instance
          .collection(chatColName)
          .doc(chatDocName)
          .set({
        "members": !isGroupChat ? ["$recvUserId", "$sendUserId"] : members,
        "contents": [
          {
            "sender": sendUserId,
            "readBy": [sendUserId],
            "message": message,
            "timestamp": timestamp,
            "nickname": myProfileEntity!.name
          }
        ]
      });
    } else {
      // document가 이미 존재하면 메시지 추가
      List<dynamic> contents = documentSnapshots.data()!["contents"];
      contents.add({
        "sender": sendUserId,
        "readBy": [sendUserId],
        "message": message,
        "timestamp": timestamp,
        "nickname": myProfileEntity!.name
      });
      await FirebaseFirestore.instance
          .collection(chatColName)
          .doc(chatDocName)
          .update({"contents": contents});
    }

    _chatController.clear();
    FocusScope.of(context).requestFocus(myFocus);
    if (isGroupChat) {
      for (String member in members!) updateChatList(member);
    } else {
      updateChatList(recvUserId!);
    }

    //savedChatData.add(MessageModel(senderUid: sendUserId, message: message, timestamp: timestamp.toString(), nickName: myProfileEntity.name).toMap());
    //_preferences.setString('chat_data_${isGroupChat ? postId : recvUserId}', json.encode(savedChatData));
    return;
  }

  Future<void> _removeReadChat(
      List<ChatDataModel> removeList, List<ChatDataModel> readList) async {
    List<dynamic> messageList;
    await FirebaseFirestore.instance
        .collection(chatColName)
        .doc(chatDocName)
        .get()
        .then((ds) {
      if (ds.data() == null || !ds.data()!.containsKey("contents")) return;
      messageList = ds.get("contents");
      messageList.removeWhere((message) {
        // 일단 삭제할 거 다 삭제
        for (int i = 0; i < removeList.length; i++) {
          if (removeList[i].text == message['message'] &&
              removeList[i].ts == message['timestamp']) {
            return true;
          }
        }
        return false;
      });
      for (int i = 0; i < messageList.length; i++) {
        // 삭제하고 남은 각 메시지에 대해서
        for (int j = 0; j < readList.length; j++) {
          if (messageList[i]['message'] == readList[j].text &&
              messageList[i]['timestamp'] == readList[j].ts) {
            List<dynamic> list = messageList[i]['readBy'];
            list.add(sendUserId); // 읽음 표시
            messageList[i]['readBy'] = list;
            break;
          }
        }
      }
      FirebaseFirestore.instance
          .collection(chatColName)
          .doc(chatDocName)
          .update({"contents": messageList});
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
    return !(spLoaded && dbLoaded)
        ? buildLoadingProgress()
        : SafeArea(
            child: Column(
            children: [
              SizedBox(
                height: 2,
              ),
              // 채팅 내용 (버블)
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
                stream: FirebaseFirestore.instance
                    .collection(chatColName)
                    .doc(chatDocName)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: buildLoadingProgress(),
                    );
                  }
                  final List<dynamic> chatDocs = !snapshot.data!.exists
                      ? []
                      : snapshot.data!.get("contents");
                  final List<dynamic> members = !snapshot.data!.exists
                      ? []
                      : snapshot.data!.get("members");
                  final membersCount = members.length;

                  List<ChatBubble> bubbles = [];
                  DateTime? currentDate;

                  // // Timestamp 순으로 정렬하기 위해 Comparator 선언 후 정렬
                  // Comparator<dynamic> comparator = (a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp']);
                  // chatDocs.sort(comparator);
                  for (int i = 0; i < _savedChat!.savedChatList.length; i++) {
                    final chat = _savedChat!.savedChatList[i];
                    final isMe = chat.nickName == myProfileEntity!.name;
                    final timestamp = chat.ts;
                    final dateTime = timestamp.toDate();
                    final year = dateTime.year;
                    final month = dateTime.month;
                    final day = dateTime.day;

                    // 날짜가 바뀌면 날짜를 표시
                    if (currentDate == null ||
                        currentDate.year != year ||
                        currentDate.month != month ||
                        currentDate.day != day) {
                      currentDate = DateTime(year, month, day);
                      final formattedDate =
                          DateFormat('yyyy-MM-dd E').format(currentDate);
                      // 날짜구부 표시 위젯
                      bubbles.add(ChatBubble(
                        "",
                        true,
                        "",
                        formattedDate,
                        isDayDivider: true,
                      ));
                    }
                    final formattedTime = DateFormat.jm().format(dateTime);
                    // 채팅 구분 표시 위젯
                    final userName = chat.nickName;
                    bool isFirst = i - 1 >= 0
                        ? _savedChat!.savedChatList[i - 1].nickName != userName
                            ? true
                            : false
                        : true;
                    bool isLast = i + 1 < _savedChat!.savedChatList.length
                        ? _savedChat!.savedChatList[i + 1].nickName != userName
                            ? true
                            : false
                        : true;
                    if (isFirst && isLast) {
                      bubbles.add(
                          ChatBubble(chat.text, isMe, userName, formattedTime));
                    } else if (isFirst) {
                      bubbles.add(ChatBubble(
                        chat.text,
                        isMe,
                        userName,
                        formattedTime,
                        invisibleTime:
                            _savedChat!.savedChatList[i + 1].ts == timestamp,
                      ));
                    } else if (isLast) {
                      bubbles.add(ChatBubble(
                        chat.text,
                        isMe,
                        userName,
                        formattedTime,
                        longBubble: true,
                      ));
                    } else {
                      final bool isEqualsTime = DateFormat.jm().format(
                              _savedChat!.savedChatList[i + 1].ts.toDate()) ==
                          formattedTime;
                      bubbles.add(ChatBubble(
                          chat.text, isMe, userName, formattedTime,
                          longBubble: true, invisibleTime: isEqualsTime));
                    }
                  }
                  if (calculateChecker == false) {
                    calculateChecker = true;
                    List<ChatDataModel> _removeList =
                        List.empty(growable: true);
                    List<ChatDataModel> _readList = List.empty(growable: true);
                    for (int i = 0; i < chatDocs.length; i++) {
                      final chat = chatDocs[i];
                      final timestamp = chat['timestamp'] as Timestamp;

                      if (!chat['readBy'].contains(user!.uid)) {
                        final bool isReadedAll =
                            chat['readBy'].length + 1 == membersCount;
                        if (isReadedAll) {
                          _removeList.add(ChatDataModel(
                              text: chat['message'],
                              ts: timestamp,
                              nickName: chat['nickname']));
                        } else {
                          _readList.add(ChatDataModel(
                              text: chat['message'],
                              ts: timestamp,
                              nickName: chat['nickname']));
                        }
                        _savedChat!.savedChatList.add(ChatDataModel(
                            text: chat['message'],
                            ts: timestamp,
                            nickName: chat['nickname']));
                        _savedChat!.save();
                      } else {
                        continue;
                      }
                    }
                    if (_removeList.length + _readList.length > 0) {
                      _removeReadChat(_removeList, _readList).then((value) {
                        //-> 데이터베이스에서 삭제 및 읽음 표시
                        _removeList.clear();
                        _readList.clear();
                        calculateChecker = false;
                      });
                    } else {
                      calculateChecker = false;
                    }
                  }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      children: bubbles.reversed.toList(),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                width: double.infinity,
                height: 40,
                margin: EdgeInsets.only(bottom: 16.0, right: 12, left: 12),
                // 상단 및 양쪽 여백 조정
                child: Theme(data: Theme.of(context).copyWith(primaryColor: Colors.red), child: TextField(
                  focusNode: myFocus,
                  controller: _chatController,
                  onSubmitted: (value) {
                    if (_chatController.text.length != 0)
                      _sendMessage();
                  },
                  maxLength: 200,
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  maxLines: 1,
                  cursorColor: colorGrey,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    suffixIcon: IconButton(
                        onPressed: () {
                          if (_chatController.text.length != 0)
                            _sendMessage();
                        },
                        icon: Icon(Icons.arrow_upward_outlined), color: Colors.greenAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: colorGrey, width: 1.5),
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                  ),
                ),)
              ),
            ],
          ));
  }
}

getNameChatRoom(String sendId, String recvId) {
  return recvId.compareTo(sendId) < 0 ? "$recvId-$sendId" : "$sendId-$recvId";
}
