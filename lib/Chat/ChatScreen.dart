import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:design_project/Chat/models/ChatStorage.dart';
import 'package:design_project/Entity/EntityProfile.dart';
import 'package:design_project/Resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChatMessage.dart';

class ChatScreen extends StatefulWidget {
  final int? postId;
  final List<String>? members;
  final String? recvUserId;
  const ChatScreen({Key? key, this.postId, this.recvUserId, this.members}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState(postId, recvUserId, members);
}

class _ChatScreenState extends State<ChatScreen> {
  User? loggedUser;
  final int? postId;
  List<String>? members;
  final String? recvUserId;
  _ChatScreenState(this.postId, this.recvUserId, this.members);

  ChatStorage? _savedChat;

  bool _chatLoaded = false;
  bool _isLoaded = false;

  late EntityProfiles recvUser;
  late bool isGroupChat;

  @override
  void initState() {
    super.initState();
    _savedChat = ChatStorage(postId == null ? recvUserId! : postId.toString());
    _savedChat!.init().then((value) {
      setState(() {
        _chatLoaded = true;
      });
    });
    if (recvUserId != null) {
      recvUser = EntityProfiles(recvUserId);
      recvUser.loadProfile().then((value) {
        setState(() {
          _isLoaded = true;
        });
      });
    } else {
      if (members == null) {
        _initGroupChat().then((value) => setState(() => _isLoaded = true));
      } else {
        _isLoaded = true;
      }
    }
    isGroupChat = postId != null;
  }

  @override
  void dispose() {
    updateChatList(myUuid!);
    super.dispose();
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: Text(_isLoaded == false ? "불러오는 중" : isGroupChat ? "그룹채팅 (${members!.length} 명)" : recvUser.name, style: TextStyle(color: Colors.black, fontSize: 19)),
          backgroundColor: Colors.white,
          leading: BackButton(
            color: Colors.black,
          ),
        ),
        body: (_isLoaded == false || _chatLoaded == false) ? Center(
          child: CircularProgressIndicator(),
        ) : GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(child:
        Stack(
          fit: StackFit.expand,
          children: [
            ChatMessage(postId: postId, recvUser: recvUserId, members: members,),
            // Align(
            //   alignment: Alignment.topCenter,
            //   child: Padding(
            //     padding: EdgeInsets.only(top: 10),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Expanded(
            //           child: Padding(
            //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
            //             child: FloatingActionButton.extended(
            //               elevation: 0,
            //               onPressed: () {
            //                 _savedChat!.getStorage().remove("${myUuid}_ChatData_${isGroupChat ? postId : recvUserId}");
            //                 // Navigator.push(
            //                 //   context,
            //                 //   MaterialPageRoute(
            //                 //       builder: (context) => GoogleMapPage()),
            //                 // );
            //               },
            //               label: Container(
            //                 width: 100,
            //                 child: Text('위치 공유',
            //                   textAlign: TextAlign.center,
            //                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            //                 ),
            //               ),
            //               backgroundColor: colorError,
            //               heroTag: null,
            //             ),
            //           ),
            //         ),
            //         Expanded(
            //           child: Padding(
            //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
            //             child: FloatingActionButton.extended(
            //               elevation: 0,
            //               onPressed: () {
            //                 showDialog(
            //                   context: context,
            //                   builder: (BuildContext context) {
            //                     return AlertDialog(
            //                       title: Text('모임'),
            //                       content: Container(
            //                         width: double.maxFinite,
            //                         child: Column(
            //                           mainAxisSize: MainAxisSize.min,
            //                           crossAxisAlignment: CrossAxisAlignment.start,
            //                           children: <Widget>[
            //                             Text(
            //                               '시간: 18:30 PM',
            //                               style: TextStyle(fontSize: 18),
            //                             ),
            //                             SizedBox(height: 10),
            //                             Text(
            //                               '장소: 안서 동보 앞 GS25',
            //                               style: TextStyle(fontSize: 18),
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                       actions: <Widget>[
            //                         TextButton(
            //                           onPressed: () {
            //                             Navigator.of(context).pop();
            //                           },
            //                           child: Text('닫기'),
            //                         ),
            //                       ],
            //                     );
            //                   },
            //                 );
            //               },
            //               label: Container(
            //                 width: 100,
            //                 child: Text('모임 일정',
            //                   textAlign: TextAlign.center,
            //                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            //                 ),
            //               ),
            //               backgroundColor: Color(0xFF999999),
            //               heroTag: null,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        )
        ),)
      );
    }
    
    Future<void> _initGroupChat() async {
      await FirebaseFirestore.instance.collection("PostGroupChat").doc(postId.toString()).get().then((ds) {
        members = List.empty(growable: true);
        for (dynamic data in ds.get("members")) {
          members!.add(data.toString());
        }
      });
    }
}

// uid에 해당하는 UserChatData에 채팅방 postId 또는 채팅 상대 recvUserId 연결
Future<void> addChatDataList(bool isGroupChat, {String? uid, String? recvUserId, int? postId, List<String>? members,}) async {
  String colName = "UserChatData";
  var doc;
  if(isGroupChat) {
    for (String uuid in members!) {
      doc = await FirebaseFirestore.instance.collection(colName).doc(uuid).get();
      if (!doc.exists) {  // 그룹채팅방인데, 각 인원에 대해 documents가 없는 경우
        await FirebaseFirestore.instance.collection(colName).doc(uuid).set({"chat" : []
          , "group_chat" : [postId]});
      } else {  // 그룹채팅방인데, 각 인원에 대해 documents가 존재하는 경우
        late List<dynamic> groupChatList;
        await FirebaseFirestore.instance.collection(colName).doc(uuid).get().then((ds) {
          groupChatList = ds.get("group_chat");
        });
        if(groupChatList.contains(postId!)) return;
        groupChatList.add(postId);
        await FirebaseFirestore.instance.collection(colName).doc(uuid).update({"group_chat" : groupChatList});
      }
    }
  } else {
    doc = await FirebaseFirestore.instance.collection(colName).doc(uid).get();
    if ( !doc.exists ) { // 그룹채팅방이 아닌데, Documents가 없을 경우
      await FirebaseFirestore.instance.collection(colName).doc(uid).set({"chat" : [getNameChatRoom(uid!, recvUserId!)]
        , "group_chat" : []});
    } else { // 그룹채팅방이 아닌데, Documents가 존재할 경우
      late List<dynamic> chatList;
      await FirebaseFirestore.instance.collection(colName).doc(uid).get().then((ds) {
        chatList = ds.get("chat");
      });
      if(chatList.contains(getNameChatRoom(uid!, recvUserId!))) return;
      chatList.add(getNameChatRoom(uid, recvUserId));
      await FirebaseFirestore.instance.collection(colName).doc(uid).update({"chat" : chatList});
    }
  }
  return;
}