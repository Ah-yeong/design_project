import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:design_project/Entity/EntityProfile.dart';
import 'package:design_project/Resources/LoadingIndicator.dart';
import 'package:flutter/material.dart';

import '../Resources/resources.dart';
import 'ChatScreen.dart';
import 'models/ChatRoom.dart';

class ChatRoomListScreen extends StatefulWidget {
  @override
  _ChatRoomListScreenState createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen>
with AutomaticKeepAliveClientMixin{
  bool isLoaded = false;
  Stream<List<ChatRoom>>? chatStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    chatStream = FirebaseFirestore.instance
        .collection("UserChatData")
        .doc(myUuid)
        .snapshots()
        .asyncMap((chats) => Future.wait([
              for (var room in chats['chat']) _loadRooms(false, room),
              for (var room in chats['group_chat']) _loadRooms(true, room)
            ]));
    super.initState();
  }

  Future<ChatRoom> _loadRooms(bool isGroupChat, dynamic receiveId) async {
    final String chatColName = isGroupChat ? "PostGroupChat" : "Chat";
    final String chatDocName = isGroupChat ? receiveId.toString() : receiveId;
    final ChatRoom room = ChatRoom(isGroupChat: isGroupChat, unreadCount: 0);
    List<dynamic> chatDocs = List.empty(growable: true);
    await FirebaseFirestore.instance
        .collection(chatColName)
        .doc(chatDocName)
        .get()
        .then((ds) => chatDocs = ds.get("contents"));
    if (isGroupChat) {
      room.postId = receiveId;
    } else {
      receiveId = receiveId.replaceAll("-", "").replaceAll(myUuid!, "");
      EntityProfiles _profile = EntityProfiles(receiveId);
      await _profile.loadProfile();
      room.recvUserId = receiveId;
      room.recvUserNick = _profile.name;
    }
    // 읽지 않은 채팅이 있을 경우 (1:1의 경우만 해당)
    if (chatDocs.length != 0) {
      // 읽은 메시지 카운트
      int checkCount = 0;
      for (var readBy in chatDocs) {
        List<dynamic> readByList = readBy['readBy'];
        if (!readByList.contains(myUuid)) {
          // 읽지 않은 index에 도착한다면 전체 길이에서 index 값을 뺀 만큼이 읽지 않은 메시지의 개수
          room.unreadCount = chatDocs.length - checkCount;
          break;
        }
        checkCount += 1;
      }
      // 메시지 및 타임스탬프 설정
      room.lastChat = chatDocs.last['message'];
      await room
          .getLastChatting(chatDocs.last['timestamp'])
          .then((value) => room.lastTimeStampString = value.split("#")[0]);
    } else {
      // 새로 온 메시지가 없을 경우
      await room.getLastChatting(null).then((value) {
        room.lastTimeStampString = value.split("#")[0]; // 타임스탬프
        room.lastChat = value.split("#")[1]; // 로컬 저장 마지막 채팅
      });
    }

    return room;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title:
            Text('나의 채팅', style: TextStyle(color: Colors.black, fontSize: 19)),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          StreamBuilder<List<ChatRoom>>(
              stream: chatStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return buildLoadingProgress();
                }
                if (!snapshot.hasData) {
                  return buildLoadingProgress();
                }

                List<ChatRoom> list = snapshot.data!;
                list.sort();

                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Divider(
                      //구분선
                      color: colorGrey,
                      thickness: 0.7,
                      height: 0.7,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.fromLTRB(15, 17, 15, 17),
                      child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              if (list[index].isGroupChat) {
                                return ChatScreen(
                                  postId: list[index].postId,
                                );
                              } else {
                                return ChatScreen(
                                  recvUserId: list[index].recvUserId,
                                );
                              }
                            }));
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // 프로필 이미지 (구현 필요)
                              Image.asset(
                                "assets/images/userImage.png",
                                width: 45,
                                height: 45,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 닉네임 표시
                                        Text(
                                            '${list[index].isGroupChat ? postManager.list[list[index].postId!].getPostHead() : "${list[index].recvUserNick}"}',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
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
                                          list[index].lastChat!.length > 15 ? "${list[index].lastChat!.substring(0, 15)}..." : "${list[index].lastChat}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: (list[index].unreadCount! > 0
                                                  ? Colors.black
                                                  : Colors.grey),
                                              fontWeight: (list[index].unreadCount! > 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal)),
                                        ) : SizedBox(),
                                        // 읽지 않은 메시지 개수 표시
                                        list[index].unreadCount! > 0 ? Container(
                                          width: (18 +
                                              9 * (list[index].unreadCount!.toString().length-1)) ,
                                          height: 18,
                                          decoration: BoxDecoration(
                                              color: colorSuccess,
                                              borderRadius: BorderRadius.circular(18)
                                          ),
                                          child: Center(
                                            child: Text("${list[index].unreadCount}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),),
                                          ),
                                        ) : SizedBox(),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )),
                    );
                  },
                );
              }),
        ],
      ),
    );
  }
}
