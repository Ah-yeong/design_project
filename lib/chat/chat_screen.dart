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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

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

  @override
  void initState() {
    super.initState();

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
      });
    });
    isGroupChat = postId != null;
    if (recvUserId != null) {
      recvUser = EntityProfiles(recvUserId);
      recvUser.loadProfile().then((value) {
        FCMController.chatRoomName = recvUser.name;
        setState(() {
          _isLoaded = true;
        });
      });
    } else {
      FCMController.chatRoomName = "[Post]$postId";
      _initGroupChat().then((value) => setState(() => _isLoaded = true));
    }
  }

  @override
  void dispose() {
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
      appBar: AppBar(
        elevation: 1,
        title: Text(
            _isLoaded == false
                ? "불러오는 중"
                : isGroupChat && _post != null
                    ? "${_post!.getPostHead()}".length > 12
                        ? "${_post!.getPostHead().replaceRange(12, null, "...")} (${members!.length}명)"
                        : "${_post!.getPostHead()} (${members!.length}명)"
                    : _post != null
                        ? recvUser.name
                        : "종료된 모임 (${members!.length}명)",
            style: TextStyle(color: Colors.black, fontSize: 19)),
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
        ),
      ),
      body: (_isLoaded == false || _chatLoaded == false)
          ? buildLoadingProgress()
          : Stack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: Container(
                      child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ChatMessage(
                        postId: postId,
                        recvUser: recvUserId,
                        members: members,
                        isInit: Get.arguments == "initMessageSend",
                      ),
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
                                            overlayColor: MaterialStateProperty.all(
                                                _post!.getTimeRemainInSeconds() < 60 * 10 * -1 ? colorLightGrey : colorSuccess),
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
    );
  }

  Future<void> _initGroupChat() async {
    _post = EntityPost(postId!, isProcessing: true);
    if (Get.arguments == "initMessageSend") {
      await Future.delayed(Duration(milliseconds: 1000), () {});
    }
    try {
      await _post!.loadPost();
    } catch (e) {
      print(e);
      print("null 처리");
      _post = null;
    }
    if (members == null) {
      await FirebaseFirestore.instance.collection("PostGroupChat").doc(postId.toString()).get().then((ds) {
        members = [];
        for (dynamic data in ds.get("members")) {
          members!.add(data.toString());
        }
      });
    }

    return;
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
