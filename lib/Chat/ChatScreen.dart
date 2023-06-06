import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:design_project/Entity/EntityProfile.dart';
import 'package:design_project/resources.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChatMessage.dart';
import 'PageUserPosition.dart';

class ChatScreen extends StatefulWidget {
  final int? postId;
  final String? recvUserId;
  const ChatScreen({Key? key, this.postId, this.recvUserId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState(postId, recvUserId);
}

class _ChatScreenState extends State<ChatScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  final int? postId;
  final String? recvUserId;
  _ChatScreenState(this.postId, this.recvUserId);

  bool isLoaded = false;

  late EntityProfiles recvUser;
  late bool isGroupChat;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    if (recvUserId != null) {
      recvUser = EntityProfiles(recvUserId);
      recvUser.loadProfile().then((value) {
        setState(() {
          isLoaded = true;
        });
      });
    } else {
      isLoaded = true;
    }
    isGroupChat = postId != null;
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
      }
    } catch (e) {
      print(e);
    }
  }
/*

 */
  // T
  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: Text('${isGroupChat ? postManager.list[postId!].getPostHead() : isLoaded == true ? recvUser.name : "불러오는 중"} ', style: TextStyle(color: Colors.black, fontSize: 19),),
          backgroundColor: Colors.white,
          leading: BackButton(
            color: Colors.black,
          ),
        ),
        body: isLoaded == false ? Center(
          child: CircularProgressIndicator(),
        ) : Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: FloatingActionButton.extended(
                        elevation: 0,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GoogleMapPage()),
                          );
                        },
                        label: Container(
                          width: 100,
                          child: Text('위치 공유',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        backgroundColor: Color(0x996ACA89),
                        heroTag: null,

                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: FloatingActionButton.extended(
                        elevation: 0,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('모임'),
                                content: Container(
                                  width: double.maxFinite,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '시간: 18:30 PM',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '장소: 안서 동보 앞 GS25',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('닫기'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        label: Container(
                          width: 100,
                          child: Text('모임 일정',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        backgroundColor: Color(0x996ACA89),
                        heroTag: null,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Messages(postId: postId, recvUser: recvUserId,),
              ),
              //NewMessage(),
            ],
          ),
        ),
      );
    }
}

Future<void> addChatDataList(String uid, bool isGroupChat, {int? postId, String? recvUserId}) async {
  String colName = "UserChatData";
  final doc = await FirebaseFirestore.instance.collection(colName).doc(uid).get();
  if ( !doc.exists ) {
    if (isGroupChat) {
      await FirebaseFirestore.instance.collection(colName).doc(uid).set({"chat" : []
      , "group_chat" : postId!});
    } else {
      await FirebaseFirestore.instance.collection(colName).doc(uid).set({"chat" : [getNameChatRoom(uid, recvUserId!)]
        , "group_chat" : []});
    }
  } else {
    if (isGroupChat) {
      late List<int> groupChatList;
      await FirebaseFirestore.instance.collection(colName).doc(uid).get().then((ds) {
        groupChatList = ds.get("group_chat");
      });
      if(groupChatList.contains(postId!)) return;
      groupChatList.add(postId);
      await FirebaseFirestore.instance.collection(colName).doc(uid).update({"group_chat" : groupChatList});
    } else {
      late List<dynamic> chatList;
      await FirebaseFirestore.instance.collection(colName).doc(uid).get().then((ds) {
        chatList = ds.get("chat");
      });
      if(chatList.contains(getNameChatRoom(uid, recvUserId!))) return;
      chatList.add(getNameChatRoom(uid, recvUserId));
      await FirebaseFirestore.instance.collection(colName).doc(uid).update({"chat" : chatList});
    }
  }
  return;
}