import 'dart:async';

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

  const ChatMessage({Key? key, this.postId, this.recvUser, this.members}) : super(key: key);

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
    chatDocName = isGroupChat ? postId.toString() : getNameChatRoom(sendUserId, recvUserId!);
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
        addChatDataList(uid: FirebaseAuth.instance.currentUser!.uid, false, recvUserId: recvUserId!);
        addChatDataList(uid: recvUserId!, false, recvUserId: FirebaseAuth.instance.currentUser!.uid);
      }
    }

    final message = _chatController.text.trim(); // 좌우 공백 제거된 전송될 내용
    final timestamp = Timestamp.now(); // 전송 시간
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference ref = await FirebaseFirestore.instance.collection(chatColName).doc(chatDocName);
        var documentSnapshots = await transaction.get(ref);
        if (!documentSnapshots.exists) {
          // document가 존재하지 않으면 members 초기화 후 삽입
          await ref.set({
            "members": !isGroupChat ? ["$recvUserId", "$sendUserId"] : members,
          });
        }
        CollectionReference colRef = ref.collection("messages");
        DocumentSnapshot snapshot = await transaction.get(colRef.doc(timestamp.millisecondsSinceEpoch.toString()));
        transaction.set(snapshot.reference, {
          "sender": sendUserId,
          "readBy": [sendUserId],
          "savedBy": [],
          "message": message,
          "timestamp": timestamp,
          "nickname": myProfileEntity!.name
        });
      });
    } catch (e) {
      print("Error updating message: $e");
    }
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
      List<ChatDataModel> removeList, List<ChatDataModel> readList, List<ChatDataModel> saveList) async {
    print("removeReadChat 호출 ");
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        CollectionReference _collection =
            FirebaseFirestore.instance.collection(chatColName).doc(chatDocName).collection("messages");

        await _collection.get().then((QuerySnapshot qs) async {
          List<DocumentSnapshot> chatDocList = [];
          for (QueryDocumentSnapshot queryDocumentSnapshot in qs.docs)
            await transaction.get(queryDocumentSnapshot.reference).then((value) => {chatDocList.add(value)});
          for (int i = 0; i < chatDocList.length; i++) {
            bool isRemovedChat = false;
            for (int j = 0; j < removeList.length; j++) {
              if (removeList[j].text == chatDocList[i].get("message") &&
                  removeList[j].ts == chatDocList[i].get("timestamp")) {
                transaction.delete(chatDocList[i].reference);
                chatDocList.remove(i);
                isRemovedChat = true;
                break;
              }
            }
            if (isRemovedChat) continue;
            for (int j = 0; j < readList.length; j++) {
              if (readList[j].text == chatDocList[i].get("message") &&
                  readList[j].ts == chatDocList[i].get("timestamp")) {
                List<dynamic> readBy = chatDocList[i].get("readBy");
                readBy.add(sendUserId);
                transaction.update(chatDocList[i].reference, {"readBy": readBy});
                break;
              }
            }
            for (int j = 0; j < saveList.length; j++) {
              if (saveList[j].text == chatDocList[i].get("message") &&
                  saveList[j].ts == chatDocList[i].get("timestamp")) {
                List<dynamic> savedBy = chatDocList[i].get("savedBy");
                savedBy.add(sendUserId);
                transaction.update(chatDocList[i].reference, {"savedBy": savedBy});
                break;
              }
            }
          }
        });
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

                  // 서버에서 채팅 불러오기
                  List<ChatDataModel> tempBubbleStorage = [];
                  List<ChatDataModel> localBubbleStorage = [];
                  if (calculateChecker == false) {
                    calculateChecker = true;
                    List<ChatDataModel> _removeList = List.empty(growable: true);
                    List<ChatDataModel> _readList = List.empty(growable: true);
                    List<ChatDataModel> _saveList = List.empty(growable: true);
                    for (int i = 0; i < chatDocs.length; i++) {
                      final chat = chatDocs[i];
                      final timestamp = chat['timestamp'] as Timestamp;

                      List<dynamic> readBy = chat.get("readBy");
                      List<dynamic> savedBy = chat.get("savedBy");
                      String text = chat.get("message");
                      String nick = chat.get("nickname");

                      ChatDataModel chatModel = ChatDataModel(text: text, ts: timestamp, nickName: nick);
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
                        if (readBy.length == membersCount) {
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
                            unreadCount: membersCount - readBy.length + (addReadBy ? 1 : 0)));
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
                      final formattedDate = DateFormat('yyyy-MM-dd E').format(currentDate);
                      // 날짜구부 표시 위젯
                      bubbles.add(ChatBubble(
                        "",
                        true,
                        "",
                        formattedDate,
                        isDayDivider: true,
                      ));
                    }
                    // 채팅 구분 표시 위젯
                    final userName = chat.nickName;
                    localBubbleStorage
                        .add(ChatDataModel(text: chat.text, ts: timestamp, nickName: userName, unreadCount: 0));
                  }

                  localBubbleStorage.addAll(tempBubbleStorage);
                  for (int i = 0; i < localBubbleStorage.length; i++) {
                    int unreadCount = localBubbleStorage[i].unreadCount!;
                    bool isMe = localBubbleStorage[i].nickName == myProfileEntity!.name;
                    String text = localBubbleStorage[i].text;
                    String userName = localBubbleStorage[i].nickName;
                    String formattedTime = DateFormat.jm().format(localBubbleStorage[i].ts.toDate());

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
                    if (isFirst && isLast) {
                      bubbles.add(ChatBubble(
                        text,
                        isMe,
                        userName,
                        formattedTime,
                        unreadUserCount: unreadCount,
                      ));
                    } else if (isFirst) {
                      bubbles.add(ChatBubble(text, isMe, userName, formattedTime,
                          invisibleTime: localBubbleStorage[i + 1].ts != localBubbleStorage[i].ts,
                          unreadUserCount: unreadCount));
                    } else if (isLast) {
                      bubbles.add(ChatBubble(text, isMe, userName, formattedTime,
                          longBubble: true, unreadUserCount: unreadCount));
                    } else {
                      final bool isEqualsTime =
                          DateFormat.jm().format(localBubbleStorage[i + 1].ts.toDate()) == formattedTime;
                      bubbles.add(ChatBubble(text, isMe, userName, formattedTime,
                          longBubble: true, invisibleTime: isEqualsTime, unreadUserCount: unreadCount));
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
                              if (_chatController.text.length != 0) _sendMessage();
                            },
                            icon: Icon(Icons.arrow_upward_outlined),
                            color: Colors.greenAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: colorGrey, width: 1.5),
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
