import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:design_project/Entity/EntityProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../resources.dart';
import 'ChatScreen.dart';

class ChatRoomListScreen extends StatefulWidget {
  @override
  _ChatRoomListScreenState createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> {
  List<chatRoom> list = List.empty(growable: true);
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadMyChats().then((value) => setState(() {
          isLoaded = true;
        }));
  }

  Future<void> _loadMyChats() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection("UserChatData")
        .doc(uid)
        .get();
    if (doc.exists) {
      List<dynamic> recvUids = doc.get("chat");
      List<dynamic> groupList = doc.get("group_chat");
      for (String str in recvUids) {
        str = str.replaceAll("-", "").replaceAll(uid, "");
        EntityProfiles _profile = EntityProfiles(str);
        await _profile.loadProfile();
        list.add(chatRoom(false, null, str, _profile.name));
      }
      for (int postId in groupList) {
        list.add(chatRoom(true, postId, null, null));
      }
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('채팅방', style: TextStyle(color: Colors.black, fontSize: 19)),
        backgroundColor: Colors.white,
      ),
      body: isLoaded
          ? ListView.separated(
              itemCount: list.length,
              separatorBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Divider(
                  //구분선
                  color: Colors.black,
                  thickness: 1.5,
                ),
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
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
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.message, size: 20, color: Colors.black,),
                              SizedBox(width: 20,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20,),
                                  Text('${list[index].isGroupChat
                                      ? postManager.list[list[index].postId!].getPostHead()
                                      : "${list[index].nickname} 님과의 대화"}'),
                                  SizedBox(height: 20,),
                                ],
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios_outlined, size: 25,)
                        ],
                      )
                    ),
                  )
                );
              },
            )
          : Center(
              child: SizedBox(
                  height: 65,
                  width: 65,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: colorSuccess,
                  ))),
    );
  }
}

class chatRoom {
  late bool isGroupChat;
  int? postId;
  String? recvUserId;
  String? nickname;

  chatRoom(this.isGroupChat, this.postId, this.recvUserId, this.nickname);
}
