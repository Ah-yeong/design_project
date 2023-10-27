import 'dart:async';

import 'package:design_project/resources/loading_indicator.dart';
import 'package:design_project/resources/resources.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart' as rt;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../alert/models/alert_manager.dart';
import '../alert/models/alert_object.dart';
import '../boards/post_list/page_hub.dart';
import '../entity/profile.dart';
import '../main.dart';
import '../resources/fcm.dart';
import 'models/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'chat_screen.dart';
import 'models/chat_data_model.dart';
import 'models/chat_storage.dart';

class ChatMessage extends StatefulWidget {
  final int? postId;
  final String? recvUser;
  final List<String>? members;

  const ChatMessage({Key? key, this.postId, this.recvUser, this.members,}) : super(key: key);

  @override
  _ChatMessageState createState() => _ChatMessageState(postId, recvUser, members);
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

  bool calculateChecker = false;
  bool spLoaded = false;
  bool dbLoaded = false;


  late ChatStorage? _savedChat;

  @override
  void initState() {
    super.initState();

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
    chatDocName = isGroupChat ? postId.toString() : getNameChatRoom(sendUserId, recvUserId!);
    chatColName = isGroupChat ? "PostGroupChat" : "Chat";
    return;
  }

  Future<void> _removeReadChat(
      List<ChatDataModel> removeList, List<ChatDataModel> readList, List<ChatDataModel> saveList) async {
    try {
      final ref = FirebaseDatabase.instance.ref(chatColName).child(chatDocName).child("messages");
      await ref.runTransaction((Object? messages) {
        if (messages == null) {
          print("Messages is null");
          return rt.Transaction.abort();
        }

        Map<String, dynamic> _messages = Map<String, dynamic>.from(messages as Map);
        List<String> removeKeys = [];
        for (var key in _messages.keys) {
          bool isRemovedChat = false;
          var msg = _messages[key];
          for (int j = 0; j < removeList.length; j++) {
            if (removeList[j].text == msg["message"] &&
                removeList[j].ts.millisecondsSinceEpoch == msg['timestamp']) {
              removeKeys.add(key);
              isRemovedChat = true;
              break;
            }
          }
          if (isRemovedChat) continue;
          for (int j = 0; j < readList.length; j++) {
            if (readList[j].text == msg['message'] &&
                readList[j].ts.millisecondsSinceEpoch == msg['timestamp']) {
              List<dynamic> readBy = msg['readBy'] ?? [];
              _messages[key]['readBy'] = []..addAll(readBy)..add(sendUserId);
              break;
            }
          }
          for (int j = 0; j < saveList.length; j++) {
            if (saveList[j].text == msg['message'] &&
                saveList[j].ts.millisecondsSinceEpoch == msg['timestamp']) {
              List<dynamic> savedBy = msg['savedBy'] ?? [];
              _messages[key]['savedBy'] = []..addAll(savedBy)..add(sendUserId);
              break;
            }
          }
        }

        _messages.removeWhere((key, value) => removeKeys.contains(key));
        return rt.Transaction.success(_messages);
      });
      return;
    } catch (e) {
      print('Error updating message: $e');
    }
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
    return !(spLoaded && dbLoaded && (members != null || !isGroupChat))
        ? buildLoadingProgress()
        : SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 2,
              ),
              // 채팅 내용 (버블)
              StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance.ref(chatColName).child(chatDocName).child("messages").onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return buildLoadingProgress();
                  }
                  var chatDocs = {};
                  if ( snapshot.data!.snapshot.exists ) {
                    chatDocs= snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  }

                  final membersCount = isGroupChat ? members!.length : 2;
                  List<ChatBubble> bubbles = [];
                  DateTime? currentDate;

                  // Timestamp 순으로 정렬하기 위해 Comparator 선언 후 정렬
                  chatDocs = Map.fromEntries(chatDocs.entries.toList()..sort((a, b) => (a.value['timestamp']).compareTo(b.value['timestamp'])));

                  List<ChatDataModel> tempBubbleStorage = [];
                  List<ChatDataModel> localBubbleStorage = [];
                  bool nextLongBubble = false;
                  if (calculateChecker == false) {
                    //calculateChecker = true;
                    List<ChatDataModel> _removeList = List.empty(growable: true);
                    List<ChatDataModel> _readList = List.empty(growable: true);
                    List<ChatDataModel> _saveList = List.empty(growable: true);
                    for (var key in chatDocs.keys) {
                      final chat = chatDocs[key];

                      final timestamp = Timestamp.fromMillisecondsSinceEpoch(chat['timestamp']);

                      List<dynamic> readBy = chat["readBy"] ?? [];
                      List<dynamic> savedBy = chat["savedBy"] ?? [];
                      String text = chat["message"];
                      String nick = chat["nickname"];
                      String sender = chat["sender"];

                      ChatDataModel chatModel = ChatDataModel(text: text, ts: timestamp, nickName: nick, uuid: sender);
                      // readBy에 내가 포함되어있지 않을 경우 (= SavedBy는 0개임)
                      bool isLocalSave = false;
                      bool addReadBy = false;

                      if (!readBy.contains(user!.uid)) {
                        final bool isReadedAll = readBy.length + 1 >= membersCount;
                        if (isReadedAll) {
                          // 다 읽었음 = 로컬에 저장
                          final bool isSavedAll = savedBy.length + 1 >= membersCount;
                          if (isSavedAll) {
                            _removeList.add(chatModel);
                          } else {
                            _savedChat!.savedChatList.add(chatModel);
                            _savedChat!.save();
                            isLocalSave = true;
                            _saveList.add(chatModel);
                          }
                        }
                        addReadBy = true;
                        _readList.add(chatModel);
                      } else if (!savedBy.contains(user.uid)) {
                        if (readBy.length >= membersCount) {
                          final bool isSavedAll = savedBy.length + 1 >= membersCount;
                          if (isSavedAll) {
                            _removeList.add(chatModel);
                          }
                          _savedChat!.savedChatList.add(chatModel);
                          _savedChat!.save();
                          isLocalSave = true;
                          _saveList.add(chatModel);
                        }
                      } else {
                        isLocalSave = true;
                      }
                      if (!isLocalSave) {
                        tempBubbleStorage.add(ChatDataModel(
                            text: text,
                            ts: timestamp,
                            nickName: nick,
                            unreadCount: membersCount - readBy.length + (addReadBy ? 1 : 0),
                        uuid: sender));
                      }
                    }
                    if (_removeList.length + _readList.length + _saveList.length > 0) {
                      _removeReadChat(_removeList, _readList, _saveList).then((value) {
                        //-> 데이터베이스에서 삭제 및 읽음 표시
                        _removeList.clear();
                        _readList.clear();
                        _saveList.clear();
                        calculateChecker = false;
                      });
                    } else {
                      calculateChecker = false;
                    }
                  }

                  // 로컬에서 채팅 불러오기
                  for (int i = 0; i < _savedChat!.savedChatList.length; i++) {
                    final chat = _savedChat!.savedChatList[i];
                    final timestamp = chat.ts;
                    // 채팅 구분 표시 위젯
                    final userName = chat.nickName;
                    localBubbleStorage
                        .add(ChatDataModel(text: chat.text, ts: timestamp, nickName: userName, unreadCount: 0, uuid: chat.uuid));
                  }

                  localBubbleStorage.addAll(tempBubbleStorage);
                  for (int i = 0; i < localBubbleStorage.length; i++) {
                    ChatDataModel chat = localBubbleStorage[i];
                    int unreadCount = chat.unreadCount!;
                    bool isMe = chat.nickName == myProfileEntity!.name;
                    final String text = chat.text;
                    final String userName = chat.nickName;
                    final timestamp = chat.ts;
                    final sender = chat.uuid;
                    final dateTime = timestamp.toDate();
                    final year = dateTime.year;
                    final month = dateTime.month;
                    final day = dateTime.day;
                    final String formattedTime = DateFormat.jm().format(dateTime);

                    // 날짜가 바뀌면 날짜를 표시
                    if (currentDate == null ||
                        currentDate.year != year ||
                        currentDate.month != month ||
                        currentDate.day != day) {
                      currentDate = DateTime(year, month, day);
                      final formattedDate = DateFormat('yyyy-MM-dd E').format(currentDate);
                      // 날짜구부 표시 위젯
                      bubbles.add(ChatBubble(
                        "",
                        true,
                        "",
                        formattedDate,
                        isDayDivider: true,
                      ));
                      nextLongBubble = true;
                    }

                    bool isFirst = i - 1 >= 0
                        ? localBubbleStorage[i - 1].nickName != localBubbleStorage[i].nickName
                            ? true
                            : false
                        : true;
                    bool isLast = i + 1 < localBubbleStorage.length
                        ? localBubbleStorage[i + 1].nickName != localBubbleStorage[i].nickName
                            ? true
                            : false
                        : true;
                    if (nextLongBubble) {
                      bubbles.add(ChatBubble(text, isMe, userName, formattedTime,
                        invisibleTime: false,
                        unreadUserCount: unreadCount, uuid: sender,));
                      nextLongBubble = false;
                    }
                    else if (isFirst && isLast) {
                      bubbles.add(ChatBubble(
                        text,
                        isMe,
                        userName,
                        formattedTime,
                        unreadUserCount: unreadCount,
                        uuid: sender,
                      ));
                    } else if (isFirst) {
                      bubbles.add(ChatBubble(text, isMe, userName, formattedTime,
                          invisibleTime: localBubbleStorage[i + 1].ts != localBubbleStorage[i].ts,
                          unreadUserCount: unreadCount, uuid: sender,));
                      nextLongBubble = false;
                    } else if (isLast) {
                      bubbles.add(ChatBubble(text, isMe, userName, formattedTime,
                          longBubble: true, unreadUserCount: unreadCount, uuid: sender));
                    } else {
                      final bool isEqualsTime =
                          DateFormat.jm().format(localBubbleStorage[i + 1].ts.toDate()) == formattedTime;
                      bubbles.add(ChatBubble(text, isMe, userName, formattedTime,
                          longBubble: true, invisibleTime: isEqualsTime, unreadUserCount: unreadCount, uuid: sender));
                    }
                  }
                  return Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 10),
                      reverse: true,
                      children: bubbles.reversed.toList(),
                    ),
                  );
                },
              ),
            ],
          ));
  }
}

getNameChatRoom(String sendId, String recvId) {
  return recvId.compareTo(sendId) < 0 ? "$recvId-$sendId" : "$sendId-$recvId";
}
