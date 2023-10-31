import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/boards/post.dart';
import 'package:design_project/boards/post_list/post_list.dart';
import 'package:design_project/chat/models/chat_storage.dart';
import 'package:design_project/entity/entity_post.dart';
import 'package:design_project/entity/profile.dart';
import 'package:design_project/main.dart';
import 'package:design_project/meeting/share_location.dart';
import 'package:design_project/resources/fcm.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:design_project/resources/resources.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:side_sheet/side_sheet.dart';
import '../alert/models/alert_manager.dart';
import '../alert/models/alert_object.dart';
import '../boards/post_list/page_hub.dart';
import '../meeting/models/location_manager.dart';
import 'chat_message.dart';

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

  EntityPost? _post;
  Timer? timeSetTimer;
  StateSetter? timeSetter;

  late EntityProfiles recvUser;
  late bool isGroupChat;

  bool isInit = Get.arguments == "initMessageSend";
  FocusNode? myFocus;
  final _chatController = TextEditingController();
  bool sendMessageCoolDown = false;
  bool isFirstChatted = true;
  String? chatDocName;
  String? chatColName;
  String? sendUserId;
  Map<String, EntityProfiles> _memberProfiles = {};
  bool profileLoaded = false;

  @override
  void initState() {
    super.initState();
    isGroupChat = postId != null;
    myFocus = FocusNode();

    _initDatabases();

    timeSetTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (timeSetter != null) {
        if (mounted)
          timeSetter!(() {});
        else
          timer.cancel();
      }
    });

    isInChat = true;
    _savedChat = ChatStorage(postId == null ? recvUserId! : postId.toString());
    _savedChat!.init().then((value) {
      setState(() {
        _chatLoaded = true;
        _sendInitMessage();
      });
    });

    _loadProfiles().then((value) => setState(() {
          profileLoaded = true;
          _sendInitMessage();
        }));

    if (recvUserId != null) {
      recvUser = EntityProfiles(recvUserId);
      recvUser.loadProfile().then((value) {
        FCMController.chatRoomName = recvUser.name;
        setState(() {
          _isLoaded = true;
          _sendInitMessage();
        });
      });
    } else {
      FCMController.chatRoomName = "[Post]$postId";
      _initGroupChat().then((value) {
        Future.forEach(members!, (uuid) async {
          await preloadAvatar(uuid: uuid);
        }).then((value) {
          setState(() {
            _loadProfiles().then((value) => setState(() {
              _isLoaded = true;
              _sendInitMessage();
            }));
          });
        });
      });
    }
  }

  _sendInitMessage() {
    if (_isLoaded && _chatLoaded && profileLoaded && isInit) {
      _sendMessage(isInits: true);
    }
  }

  _initDatabases() async {
    if (recvUserId != null && postId != null) return; // 둘 다 입력되었을 때는 예외로 함
    // 보내는 유저 이름에 대하여 채팅 Collection, Document 이름 설정
    sendUserId = FirebaseAuth.instance.currentUser!.uid;
    chatDocName = isGroupChat ? postId.toString() : getNameChatRoom(sendUserId!, recvUserId!);
    chatColName = isGroupChat ? "PostGroupChat" : "Chat";
    return;
  }

  @override
  void dispose() {
    _chatController.dispose();
    timeSetTimer?.cancel();
    updateChatList(myUuid!);
    if (nestedChatOpenSignal) {
      nestedChatOpenSignal = false;
    } else {
      FCMController.chatRoomName = "";
      isInChat = false;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        title: Text(
            _isLoaded == false
                ? "불러오는 중"
                : isGroupChat && _post != null
                    ? "${_post!.getPostHead()}".length > 12
                        ? "${_post!.getPostHead().replaceRange(12, null, "...")} (${members!.length}명)"
                        : "${_post!.getPostHead()} (${members!.length}명)"
                    : !isGroupChat
                        ? recvUser.name
                        : members == null
                            ? "알 수 없음"
                            : "종료된 모임 (${members!.length}명)",
            style: TextStyle(color: Colors.black, fontSize: 19)),
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
        ),
        actions: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
              onTap: () => SideSheet.right(body: _showProfileList(), context: context, width: MediaQuery.of(context).size.width * 0.7),
              child: SizedBox(width: 55, height: 55, child: Icon(CupertinoIcons.line_horizontal_3, color: Colors.black, size: 25,),)),
        ],
      ),
      body: (_isLoaded == false || _chatLoaded == false)
          ? buildLoadingProgress()
          : SafeArea(
              bottom: true,
              child: Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Container(
                        child: Column(
                      children: [
                        Expanded(
                          child: ChatMessage(
                            postId: postId,
                            recvUser: recvUserId,
                            members: members,
                          ),
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.white, boxShadow: [BoxShadow(offset: Offset(0, -1), color: colorLightGrey, blurRadius: 0.8, spreadRadius: 0.5)]),
                            width: double.infinity,
                            height: 50,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
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
                                textInputAction: TextInputAction.newline,
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
                    )),
                  ),
                  isGroupChat && _post != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 13),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: Colors.white.withAlpha(180), borderRadius: BorderRadius.circular(6)),
                                  child: StatefulBuilder(
                                    builder: (BuildContext context, StateSetter timeRemainSetter) {
                                      timeSetter = timeRemainSetter;
                                      int gapSeconds = _post!.getTimeRemainInSeconds();
                                      return Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_filled_rounded,
                                            size: 20,
                                            color: gapSeconds > 1800 ? colorGrey : Colors.indigoAccent,
                                          ),
                                          Text(
                                            "${getMeetTimeText(_post!.getTime()).replaceAll("전", "전에 완료").replaceAll("후", "후 모임 시작")}",
                                            style: TextStyle(
                                                color: gapSeconds > 1800 ? colorGrey : Colors.indigoAccent, fontSize: 14, fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      );
                                    },
                                  )),
                            ),
                            StatefulBuilder(
                              builder: (BuildContext context, StateSetter rowSetState) {
                                return Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 13, top: 13),
                                      child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: _post!.getTimeRemainInSeconds() < 60 * 10 * -1 ? colorLightGrey : Colors.white,
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(color: colorGrey),
                                            boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 0.5, spreadRadius: 0.5, color: colorGrey)],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(15),
                                              onTap: () {
                                                rowSetState(() {});
                                                final int _remain = _post!.getTimeRemainInSeconds();
                                                if (_remain < 60 * 10 * -1) {
                                                  showAlert("모임이 완료되었어요!", context, colorError);
                                                  return;
                                                }
                                                Get.to(() => BoardPostPage(postId: postId), arguments: true)!.then((value) => rowSetState(() {}));
                                              },
                                              overlayColor:
                                                  MaterialStateProperty.all(_post!.getTimeRemainInSeconds() < 60 * 10 * -1 ? colorLightGrey : colorSuccess),
                                              child: const Icon(
                                                Icons.file_copy,
                                                size: 25,
                                                color: colorGrey,
                                              ),
                                            ),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 13, top: 13),
                                      child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: (_post!.isVoluntary() ||
                                                    _post!.getTimeRemainInSeconds() > 60 * 15 ||
                                                    _post!.getTimeRemainInSeconds() < 60 * 10 * -1)
                                                ? colorLightGrey
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(color: colorGrey),
                                            boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 0.5, spreadRadius: 0.5, color: colorGrey)],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(15),
                                              onTap: () async {
                                                rowSetState(() {});
                                                if (_post!.isVoluntary()) {
                                                  showAlert("위치 서비스가 지원되지 않는 모임 방식이에요!", context, colorGrey);
                                                  return;
                                                }
                                                final int _remain = _post!.getTimeRemainInSeconds();
                                                if (_remain > 60 * 15) {
                                                  showAlert("모임 시간 15분 전부터 이용 가능해요!", context, colorError);
                                                  return;
                                                }
                                                if (_remain < 60 * 10 * -1) {
                                                  showAlert("모임이 완료되었어요!", context, colorError);
                                                  return;
                                                }
                                                try {
                                                  LocationManager existTest = LocationManager();
                                                  await existTest.getLocationGroupData(postId!);
                                                  Get.to(() => PageShareLocation(), arguments: postId)!.then((value) => rowSetState(() {}));
                                                } catch (e) {
                                                  showAlert("위치 공유 지원이 종료된 모임이에요!.", context, colorGrey);
                                                }
                                              },
                                              overlayColor: MaterialStateProperty.all((_post!.isVoluntary() ||
                                                      _post!.getTimeRemainInSeconds() > 60 * 15 ||
                                                      _post!.getTimeRemainInSeconds() < 60 * 10 * -1)
                                                  ? colorLightGrey
                                                  : colorSuccess),
                                              child: const Icon(
                                                Icons.location_on,
                                                size: 28,
                                                color: colorGrey,
                                              ),
                                            ),
                                          )),
                                    ),
                                  ],
                                );
                              },
                            )
                          ],
                        )
                      : SizedBox(),
                ],
              ),
            ),
    );
  }

  // 메시지 전송 메서드
  Future<void> _sendMessage({bool? isInits}) async {
    // 1:1 채팅인 경우, 이름 순서가 바뀐 Document가 있는지 검사 후 해당 Document이름으로 chatDocName 변경.
    if (sendMessageCoolDown) return;
    sendMessageCoolDown = true;
    Future.delayed(Duration(milliseconds: 500), () => sendMessageCoolDown = false);

    bool init = isInits != null && isInits == true;
    if (isFirstChatted) {
      isFirstChatted = false;
      if (init || isGroupChat) {
        addChatDataList(true, postId: postId, members: members);
      } else {
        addChatDataList(uid: FirebaseAuth.instance.currentUser!.uid, false, recvUserId: recvUserId!);
        addChatDataList(uid: recvUserId!, false, recvUserId: FirebaseAuth.instance.currentUser!.uid);
      }
    }

    final message = init ? "모임 채팅방이 개설되었어요.\n여기서 자유롭게 대화해보세요!" : _chatController.text.trim(); // 좌우 공백 제거된 전송될 내용
    final timestamp = Timestamp.now(); // 전송 시간
    Map<String, bool> alarmSendList = {};
    try {
      final _chatDB = FirebaseDatabase.instance.ref(chatColName).child(chatDocName!);

      var ds;
      if (init && isGroupChat) {
        ds = await FirebaseFirestore.instance.collection("ProcessingPost").doc(postId.toString()).get();
      }

      DataSnapshot _roomRef = await _chatDB.get();
      if (!_roomRef.exists) {
        // 새로운 채팅방 생성
        Map<String, bool> newAlarmStatus = {};
        if (isGroupChat) {
          members!.forEach((uuid) {
            newAlarmStatus[uuid] = true;
          });
        } else {
          newAlarmStatus[recvUserId!] = true;
          newAlarmStatus[sendUserId!] = true;
        }
        _chatDB.set({
          "roomName": isGroupChat && init ? ds.get("head") : "none",
          "members": newAlarmStatus,
          "alarmReceives": newAlarmStatus
        });
      } else {
        // 이미 존재하는 채팅방일때
        Map<String, dynamic> roomDocMap = Map<String, dynamic>.from(_roomRef.value as Map);
        if ( roomDocMap["alarmReceives"] != null)
        alarmSendList = Map<String, bool>.from(roomDocMap["alarmReceives"]);
      }

      final _messageDB = _chatDB.child("messages").child(timestamp.millisecondsSinceEpoch.toString());
      _messageDB.set({
        "sender": sendUserId,
        "readBy": [sendUserId],
        "savedBy": [],
        "message": message,
        "timestamp": timestamp.millisecondsSinceEpoch,
        "nickname": myProfileEntity!.name
      });
    } catch (e) {
      print("Error updating message: $e");
    }
    FCMController fcm = FCMController();
    EntityProfiles? profile;
    if (init) {
      for (String member in members!) {
        updateChatList(member);
        if (member == myUuid!) continue;
        AlertManager alertManager = AlertManager(LocalStorage!);
        alertManager.sendAlert(
            title: "모임이 성사되었어요 🙌🏻",
            body: "지금 바로 모임 채팅방을 통해 이야기를 나눠보세요!",
            alertType: AlertType.TO_CHAT_ROOM,
            userUUID: member,
            withPushNotifications: true,
            clickAction: {
              "chat_id": postId.toString(),
              "is_group_chat": "true",
            });
      }
    } else {
      _chatController.clear();
      myFocus!.requestFocus();

      if (isGroupChat) {
        for (String member in members!) {
          updateChatList(member);
          if (alarmSendList[member] != null && alarmSendList[member] == false) return;
          if (member == myUuid!) continue;
          profile = _memberProfiles[member]!;
          fcm.sendMessage(userToken: profile.fcmToken, title: myProfileEntity!.name, body: message, type: AlertType.TO_CHAT_ROOM, clickAction: {
            "chat_id": postId.toString(),
            "is_group_chat": "true",
          }).then((value) => print(value));
        }
      } else {
        updateChatList(recvUserId!);
        if (alarmSendList[recvUserId] != null && alarmSendList[recvUserId] == false) return;
        profile = _memberProfiles[recvUserId]!;
        fcm.sendMessage(userToken: profile.fcmToken, title: "${myProfileEntity!.name}", body: message, type: AlertType.TO_CHAT_ROOM, clickAction: {
          "chat_id": myProfileEntity!.profileId,
        }).then((value) => print(value));
      }
    }
    return;
  }

  Future<void> _loadProfiles() async {
    EntityProfiles profile;
    if (isGroupChat) {
      if (members == null) return;
      await Future.forEach(members!, (uuid) async {
        profile = EntityProfiles(uuid);
        await profile.loadProfile();
        _memberProfiles[profile.profileId] = profile;
      });
    } else {
      profile = EntityProfiles(recvUserId);
      await profile.loadProfile();
      _memberProfiles[profile.profileId] = profile;
    }
    return;
  }

  Future<void> _initGroupChat() async {
    _post = EntityPost(postId!, isProcessing: true);
    if (Get.arguments == "initMessageSend") {
      await Future.delayed(Duration(milliseconds: 1000), () {});
    }
    try {
      await _post!.loadPost();
    } catch (e) {
      print("[ChatScreen] 포스트 null 처리");
      _post = null;
    }
    if (members == null) {
      var dataSnapshot = await FirebaseDatabase.instance.ref("PostGroupChat").child(postId.toString()).child("members").get();
      if (dataSnapshot.exists) {
        members = [];
        Map<String, bool> dataList = Map<String, bool>.from(dataSnapshot.value as Map);
        for (dynamic data in dataList.keys) {
          members!.add(data.toString());
        }
      }
    }
    return;
  }

  Widget _showProfileList() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Align(alignment: Alignment.topCenter, child:
            Center(child: Text("채팅방 구성원", style: TextStyle(fontSize: 16),),),),
          const Divider(thickness: 1.5,),
          SizedBox(
            height: MediaQuery.of(context).size.height-126,
            child: ListView.separated(physics: NeverScrollableScrollPhysics(), itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(6, 5, 0, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      drawProfile(_memberProfiles[members![index]]!, context),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            showAlert("신고 개발중입니다.", context, colorLightGrey);
                          },
                          child: Icon(CupertinoIcons.person_crop_circle_fill_badge_exclam, color: colorError,),
                        ),
                      )
                    ],
                  ),
                );
            }, separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 1,), itemCount: isGroupChat ? _memberProfiles.length : 2, padding: EdgeInsets.zero,),
          ),
        ],
      ),
    );
  }
}

// uid에 해당하는 UserChatData에 채팅방 postId 또는 채팅 상대 recvUserId 연결
Future<void> addChatDataList(
  bool isGroupChat, {
  String? uid,
  String? recvUserId,
  int? postId,
  List<String>? members,
}) async {
  String colName = "UserChatData";
  var doc;
  if (isGroupChat) {
    for (String uuid in members!) {
      doc = await FirebaseFirestore.instance.collection(colName).doc(uuid).get();
      if (!doc.exists) {
        // 그룹채팅방인데, 각 인원에 대해 documents가 없는 경우
        await FirebaseFirestore.instance.collection(colName).doc(uuid).set({
          "chat": [],
          "group_chat": [postId]
        });
      } else {
        // 그룹채팅방인데, 각 인원에 대해 documents가 존재하는 경우
        late List<dynamic> groupChatList;
        await FirebaseFirestore.instance.collection(colName).doc(uuid).get().then((ds) {
          groupChatList = ds.get("group_chat");
        });
        if (groupChatList.contains(postId!)) return;
        groupChatList.add(postId);
        await FirebaseFirestore.instance.collection(colName).doc(uuid).update({"group_chat": groupChatList});
      }
    }
  } else {
    doc = await FirebaseFirestore.instance.collection(colName).doc(uid).get();
    if (!doc.exists) {
      // 그룹채팅방이 아닌데, Documents가 없을 경우
      await FirebaseFirestore.instance.collection(colName).doc(uid).set({
        "chat": [getNameChatRoom(uid!, recvUserId!)],
        "group_chat": []
      });
    } else {
      // 그룹채팅방이 아닌데, Documents가 존재할 경우
      late List<dynamic> chatList;
      await FirebaseFirestore.instance.collection(colName).doc(uid).get().then((ds) {
        chatList = ds.get("chat");
      });
      if (chatList.contains(getNameChatRoom(uid!, recvUserId!))) return;
      chatList.add(getNameChatRoom(uid, recvUserId));
      await FirebaseFirestore.instance.collection(colName).doc(uid).update({"chat": chatList});
    }
  }
  return;
}
