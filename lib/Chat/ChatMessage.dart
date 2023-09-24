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

    DocumentReference ref = await FirebaseFirestore.instance.collection(chatColName).doc(chatDocName);

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
    var documentSnapshots = await ref.get();
    if (!documentSnapshots.exists) {
      // document가 존재하지 않으면 members 초기화 후 삽입
      await ref.set({
        "members": !isGroupChat ? ["$recvUserId", "$sendUserId"] : members,
      });
    }
    CollectionReference colRef = ref.collection("messages");
    await colRef.get().then((QuerySnapshot qs) {
      colRef.doc(timestamp.millisecondsSinceEpoch.toString()).set({
        "sender": sendUserId,
        "readBy": [sendUserId],
        "message": message,
        "timestamp": timestamp,
        "nickname": myProfileEntity!.name
      });
    });

    _chatController.clear();
    myFocus!.requestFocus();
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

    CollectionReference _collection = FirebaseFirestore.instance
        .collection(chatColName)
        .doc(chatDocName)
        .collection("messages");

    await _collection.get().then((QuerySnapshot qs) {
      List<QueryDocumentSnapshot> chatDocList = qs.docs;
      for (int i = 0; i < chatDocList.length; i++) {
        bool isRemovedChat = false;
        for (int j = 0; j < removeList.length; j++) {
          if (removeList[j].text == chatDocList[i].get("message") &&
              removeList[j].ts == chatDocList[i].get("timestamp")) {
            _collection.doc(chatDocList[i].id).delete();
            chatDocList.remove(i);
            isRemovedChat = true;
            break;
          }
        }
        if (isRemovedChat) continue;
        for (int j = 0; j < readList.length; j++) {
          if (readList[i].text == chatDocList[i].get("message") &&
              readList[j].ts == chatDocList[i].get("timestamp")) {
            List<dynamic> readBy = chatDocList[i].get("readBy");
            readBy.add(sendUserId);
            _collection.doc(chatDocList[i].id).update({"readBy" : readBy});
            break;
          }
        }
      }
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
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>?>(
                stream: FirebaseFirestore.instance
                    .collection(chatColName)
                    .doc(chatDocName)
                    .collection("messages")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: buildLoadingProgress(),
                    );
                  }
                  List<QueryDocumentSnapshot> chatDocs = snapshot.data!.docs;
                  final membersCount = isGroupChat ? members!.length : 2;

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

                      List<dynamic> readBy = chat.get("readBy");
                      String text = chat.get("message");
                      String nick = chat.get("nickname");
                      if (!readBy.contains(user!.uid)) {
                        final bool isReadedAll =
                            readBy.length + 1 == membersCount;
                        ChatDataModel chatModel = ChatDataModel(text: text, ts: timestamp, nickName: nick);
                        if (isReadedAll) {
                          _removeList.add(chatModel);
                        } else {
                          _readList.add(chatModel);
                        }
                        _savedChat!.savedChatList.add(chatModel);
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
                  child: Theme(
                    data: Theme.of(context).copyWith(primaryColor: Colors.red),
                    child: TextField(
                      focusNode: myFocus,
                      controller: _chatController,
                      onSubmitted: (value) {
                        if (value.length != 0) {
                          _sendMessage();
                        }
                      },
                      maxLength: 200,
                      maxLengthEnforcement: MaxLengthEnforcement.none,
                      maxLines: 1,
                      cursorColor: colorGrey,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        suffixIcon: IconButton(
                            onPressed: () {
                              if (_chatController.text.length != 0)
                                _sendMessage();
                            },
                            icon: Icon(Icons.arrow_upward_outlined),
                            color: Colors.greenAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: colorGrey, width: 1.5),
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                      ),
                    ),
                  )),
            ],
          ));
  }
}

getNameChatRoom(String sendId, String recvId) {
  return recvId.compareTo(sendId) < 0 ? "$recvId-$sendId" : "$sendId-$recvId";
}
