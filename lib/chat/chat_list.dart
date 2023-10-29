import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/chat/chat_message.dart';
import 'package:design_project/chat/models/chat_storage.dart';
import 'package:design_project/entity/profile.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../entity/entity_post.dart';
import '../resources/resources.dart';
import '../boards/post_list/page_hub.dart';
import '../main.dart';
import 'chat_screen.dart';
import 'models/chat_room.dart';

class ChatRoomListScreen extends StatefulWidget {
  @override
  _ChatRoomListScreenState createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> with AutomaticKeepAliveClientMixin {
  bool isLoaded = false;
  Stream<List<ChatRoom>>? chatStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    chatStream = FirebaseFirestore.instance.collection("UserChatData").doc(myUuid).snapshots().asyncMap(
        (chats) => Future.wait([for (var room in chats['chat']) _loadRooms(false, room), for (var room in chats['group_chat']) _loadRooms(true, room)]));
    super.initState();
  }

  Future<ChatRoom> _loadRooms(bool isGroupChat, dynamic receiveId) async {
    final String chatColName = isGroupChat ? "PostGroupChat" : "Chat";
    final String chatDocName = isGroupChat ? receiveId.toString() : receiveId;
    final ChatRoom room = ChatRoom(isGroupChat: isGroupChat, unreadCount: 0);

    try {
      var ref = FirebaseDatabase.instance.ref(chatColName).child(chatDocName);
      var snapshot = await ref.get();
      if (snapshot.exists) {
        Map<String, dynamic> roomDoc = Map<String, dynamic>.from(snapshot.value as Map);

        // 알림
        try {
          Map<String, bool> alarmReceives = Map<String, bool>.from(roomDoc["alarmReceives"]);
          room.alarmReceive = alarmReceives[myUuid] ?? true;
        } catch (e) {
          room.alarmReceive = true;
        }

        if (isGroupChat) {
          room.roomName = roomDoc["roomName"];
          room.postId = receiveId;
        } else {
          receiveId = receiveId.replaceAll("-", "").replaceAll(myUuid!, "");
          EntityProfiles _profile = EntityProfiles(receiveId);
          await _profile.loadProfile();
          room.recvUserId = receiveId;
          room.recvUserNick = _profile.name;
          room.profile = _profile;
        }
        Map<String, dynamic> chatDocs = {};
        if ( roomDoc["messages"] != null ) {
          chatDocs = Map<String, dynamic>.from(roomDoc["messages"]);
        }
        if (chatDocs.length != 0) {
          // 읽은 메시지 카운트
          int checkCount = 0;
          var keys = chatDocs.keys.toList()..sort();
          for (var key in keys) {
            List<dynamic> readByList = chatDocs[key]["readBy"];
            if (!readByList.contains(myUuid!)) {
              // 읽지 않은 index에 도착한다면 전체 길이에서 index 값을 뺀 만큼이 읽지 않은 메시지의 개수
              room.unreadCount = keys.length - checkCount;
              break;
            }
            checkCount += 1;
          }

          // 메시지 및 타임스탬프 설정

          room.lastChat = chatDocs[keys.last]["message"];
          await room
              .getLastChatting(Timestamp.fromMillisecondsSinceEpoch(chatDocs[keys.last]["timestamp"]))
              .then((value) => room.lastTimeStampString = value.split("#")[0]);
        } else {
          // 새로 온 메시지가 없을 경우
          await room.getLastChatting(null).then((value) {
            room.lastTimeStampString = value.split("#")[0]; // 타임스탬프
            room.lastChat = value.split("#")[1]; // 로컬 저장 마지막 채팅
          });
        }
      } else {
        if (isGroupChat) {
          room.roomName = "(알 수 없음)";
          room.postId = receiveId;
        } else {
          receiveId = receiveId.replaceAll("-", "").replaceAll(myUuid!, "");
          EntityProfiles _profile = EntityProfiles(receiveId);
          await _profile.loadProfile();
          room.recvUserId = receiveId;
          room.recvUserNick = _profile.name;
          room.profile = _profile;
        }
        room.lastTimeStamp = Timestamp(0, 0);
        room.lastTimeStampString = "-"; // 타임스탬프
        room.lastChat = ""; // 로컬 저장 마지막 채팅
      }
    } catch (e) {
      print("error : ${e.toString()}");
      room.lastTimeStamp = Timestamp(0, 0);
      room.lastTimeStampString = "-"; // 타임스탬프
      room.lastChat = "(알 수 없음)"; // 로컬 저장 마지막 채팅
    }
    return Future.value(room);
  }
  
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('나의 채팅', style: TextStyle(color: Colors.black, fontSize: 19)),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          StreamBuilder<List<ChatRoom>>(
              stream: chatStream,
              builder: (context, snapshot) {
                List<ChatRoom> list;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return buildLoadingProgress();
                }
                if (!snapshot.hasData) {
                  list = [];
                } else {
                  list = snapshot.data!;
                  list.sort();
                }

                return list.length != 0
                    ? SlidableAutoCloseBehavior(
                        child: ListView.separated(
                          itemCount: list.length + 2,
                          separatorBuilder: (context, index) => Divider(
                            //구분선
                            color: colorLightGrey,
                            thickness: 0.7,
                            height: 0.7,
                          ),
                          itemBuilder: (context, index) {
                            if (index == 0 || index == list.length + 1) return const SizedBox();
                            index = index - 1;
                            return Slidable(
                              groupTag: '0',
                              endActionPane: ActionPane(
                                motion: ScrollMotion(),
                                children: [
                                  CustomSlidableAction(
                                    flex: 1,
                                    onPressed: (context) async {
                                      setState(() {
                                        _isProcessing = true;
                                      });
                                      await list[index].toggleRoomAlert();
                                      setState(() {
                                        _isProcessing = false;
                                      });
                                    },
                                    autoClose: true,
                                    backgroundColor: colorGrey,
                                    child: Icon(
                                      list[index].alarmReceive != null && list[index].alarmReceive! == true ? CupertinoIcons.bell_fill : CupertinoIcons.bell_slash,
                                      size: 23,
                                      color: Colors.white,
                                    ),
                                  ),
                                  CustomSlidableAction(
                                    flex: 1,
                                    onPressed: (context) async {
                                      setState(() {
                                        _isProcessing = true;
                                      });
                                      DocumentReference doc = FirebaseFirestore.instance.collection("UserChatData").doc(myUuid!);
                                      if (list[index].isGroupChat) {
                                        doc.update({"group_chat": FieldValue.arrayRemove([list[index].postId])}).then((value) => setState(() => _isProcessing = false));
                                        ChatStorage(list[index].postId.toString())..remove();
                                      } else {
                                        doc.update({"chat": FieldValue.arrayRemove([getNameChatRoom(myUuid!, list[index].recvUserId!)])}).then((value) => setState(() => _isProcessing = false));
                                        ChatStorage(list[index].recvUserId!)..remove();
                                      }
                                    },
                                    autoClose: true,
                                    backgroundColor: colorError,
                                    child: Icon(
                                      Icons.delete,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                                extentRatio: 0.4,
                              ),
                              child: Container(
                                padding: EdgeInsets.fromLTRB(15, 17, 15, 17),
                                child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) {
                                                isInChat = true;
                                                if (list[index].isGroupChat) {
                                                  return ChatScreen(
                                                    postId: list[index].postId,
                                                  );
                                                } else {
                                                  return ChatScreen(
                                                    recvUserId: list[index].recvUserId,
                                                  );
                                                }
                                              },
                                              settings: ModalRoute.of(context)!.settings))
                                          .then((_) => isInChat = false);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        // 프로필 이미지 (구현 필요)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(3, 0, 15, 0),
                                          child: getAvatar(list[index].profile, 22.5,
                                              nullIcon: const Icon(
                                                CupertinoIcons.person_3_fill,
                                                color: Colors.white,
                                                size: 35,
                                              ),
                                              backgroundColor: colorGrey),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  // 닉네임 표시
                                                  Text('${list[index].isGroupChat ? list[index].roomName : "${list[index].recvUserNick}"}',
                                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                                  // 마지막 내용 표시
                                                  Text("${list[index].lastTimeStampString}"),
                                                ],
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  // 마지막 채팅 시간 표시
                                                  list[index].lastChat != null
                                                      ? Text(
                                                          list[index].lastChat!.length > 15
                                                              ? "${list[index].lastChat!.substring(0, 15)}..."
                                                              : "${list[index].lastChat}",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: (list[index].unreadCount! > 0 ? Colors.black : Colors.grey),
                                                              fontWeight: (list[index].unreadCount! > 0 ? FontWeight.bold : FontWeight.normal)),
                                                        )
                                                      : SizedBox(),
                                                  // 읽지 않은 메시지 개수 표시
                                                  list[index].unreadCount! > 0
                                                      ? Container(
                                                          width: (18 + 9 * (list[index].unreadCount!.toString().length - 1)),
                                                          height: 18,
                                                          decoration: BoxDecoration(color: colorSuccess, borderRadius: BorderRadius.circular(18)),
                                                          child: Center(
                                                            child: Text(
                                                              "${list[index].unreadCount}",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          "진행 중인 채팅이 없어요",
                          style: TextStyle(color: colorGrey),
                        ),
                      );
              }),
          if (_isProcessing) buildContainerLoading(100)
        ],
      ),
    );
  }
}
