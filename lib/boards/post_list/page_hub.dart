import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/boards/post.dart';
import 'package:design_project/boards/post_list/bottom_appbar.dart';
import 'package:design_project/boards/post_list/post_list.dart';
import 'package:design_project/chat/chat_list.dart';
import 'package:design_project/chat/chat_screen.dart';
import 'package:design_project/entity/profile.dart';
import 'package:design_project/profiles/profile_main.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:design_project/resources/resources.dart';
import 'package:design_project/boards/post_list/post_list_hub.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../main.dart';
import '../../alert/page_alert.dart';
import '../../meeting/models/location_manager.dart';
import '../../meeting/share_location.dart';
import '../../resources/fcm.dart';
import '../write/writing_form.dart';

class BoardPageMainHub extends StatefulWidget {
  const BoardPageMainHub({super.key});

  @override
  State<StatefulWidget> createState() => _BoardPageMainHub();
}

EntityProfiles? myProfileEntity;
String? myUuid;
StateSetter? hubLoadingStateSetter;
bool hubLoadingContainerVisible = false;

class _BoardPageMainHub extends State<BoardPageMainHub> with WidgetsBindingObserver{
  static List<Widget> _pages = <Widget>[BoardHomePage(), ChatRoomListScreen(), PageAlert(), PageProfile()];


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      versionCheck(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _pageController!.dispose();
  }

  StateSetter? appbarStateSetter;
  PageController? _pageController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: StatefulBuilder(
            builder: (BuildContext context, StateSetter bottomAppbarSetState) {
              bAppbarStateSetter = bottomAppbarSetState;
              return BoardBottomAppBar(pageController: _pageController!);
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: SizedBox(
            height: 67,
            width: 67,
            child: FittedBox(
              child: FloatingActionButton.small(
                heroTag: "fab1",
                backgroundColor: const Color(0xDD00CC88),
                onPressed: () async {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => BoardWritingPage())).then((value) =>
                      setState(() {
                        if (listStateSetter != null) {
                          listStateSetter!(() {});
                        }
                      }));
                },
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey, width: 0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.draw_sharp,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
          // 글쓰기 플로팅 버튼
          body: SafeArea(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: _pages,
              )),
        ),
        StatefulBuilder(builder: (BuildContext context, StateSetter stateSetter) {
          hubLoadingStateSetter = stateSetter;
          return hubLoadingContainerVisible ? buildContainerLoading(135) : const SizedBox();
        },),
        postManager.isLoading ? buildContainerLoading(135) : SizedBox()
      ],
    );
  }

  Future<void> _myProfileLoad() async {
    myProfileEntity = EntityProfiles(FirebaseAuth.instance.currentUser!.uid);
    DocumentReference reference = FirebaseFirestore.instance.collection("UserProfile").doc(myUuid!);
    await reference.get().then((ds) async {
      await myProfileEntity!.loadProfile();
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _myProfileLoad().then((value) => setupGetMessages());

    if (postManager.isLoading) postManager.loadPages("").then((_) =>
        setState(() {
          if (listStateSetter != null) {
            listStateSetter!(() {});
          }
        }));
    _pageController = PageController();
  }

  Future<void> setupGetMessages() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async {
    if (message.notification == null) return;
    if (message.data.containsKey("type")) {
      final String CHAT_ID = 'chat_id';
      final String IS_GROUP_CHAT = 'is_group_chat';
      final String POST_ID = 'post_id';
      final String MEETING_ID = 'meeting_id';

      // 채팅방
      if (message.data[CHAT_ID] != null) {
        if (message.data[IS_GROUP_CHAT] == null && FCMController.chatRoomName == message.notification!.title) { // 개인 채팅방에 접속해 있을 경우
          return;
        } else if (message.data[IS_GROUP_CHAT] == "true" && FCMController.chatRoomName == "[Post]${message.data[CHAT_ID]}") { // 모임 채팅방에 접속해 있을 경우
          return;
        }
        if (message.data[IS_GROUP_CHAT] != null) {
          final int postId = int.parse(message.data[CHAT_ID]);
          Get.to(() => ChatScreen(postId: postId));
        } else {
          Get.to(() => ChatScreen(recvUserId: message.data[CHAT_ID]));
        }
      } else if (message.data[POST_ID]) { // 게시물
        final int postId = int.parse(message.data[POST_ID]);
        Get.to(() => BoardPostPage(postId: postId));
      } else if (message.data[MEETING_ID] != null) {
        final int meeting_id = int.parse(message.data[MEETING_ID]);
        Get.to(() => ChatScreen(postId: meeting_id));
        try {
          LocationManager existTest = LocationManager();
          await existTest.getLocationGroupData(meeting_id);
          Get.to(() => PageShareLocation(), arguments: meeting_id);
        } catch (e) {
          showAlert("위치 공유 지원이 종료된 모임이에요!", navigatorKey.currentContext!, colorError);
        }
      }
    }
  }
}
