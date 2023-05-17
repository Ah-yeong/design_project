import 'package:design_project/Boards/BoardHomePage.dart';
import 'package:design_project/Boards/BoardWritingPage.dart';
import 'package:design_project/Chat/ChatScreen.dart';
import 'package:design_project/Profiles/PageProfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../PageAlert.dart';

class BoardPageDesign extends StatefulWidget {
  const BoardPageDesign({super.key});

  @override
  State<StatefulWidget> createState() => _BoardPageDesign();
}

class _BoardPageDesign extends State<BoardPageDesign> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1,),
              Expanded(child: GestureDetector(
                onTap: () {
                  setState(() {
                    _page = 1; // 홈 페이지
                  });
                },
                  child: SizedBox(height: 50, width: 50, child: Icon(Icons.home_outlined, color: _page == 1 ? Colors.lime : Colors.black)))
              ),
              const Spacer(flex: 1,),
              Expanded(child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _page = 2; // 채팅 페이지
                    });
                  },
                  child: SizedBox(height: 50, width: 50, child: Icon(Icons.mark_unread_chat_alt_outlined, color: _page == 2 ? Colors.lime : Colors.black)))
              ),
              const Spacer(flex: 3,),
              Expanded(child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _page = 3; // 알림 페이지
                    });
                  },
                  child: SizedBox(height: 50, width: 50, child: Icon(Icons.notifications_active_outlined, color: _page == 3 ? Colors.lime : Colors.black)))
              ),
              const Spacer(flex: 1,),
              Expanded(child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _page = 4; // 내 정보 페이지
                    });
                  },
                  child: SizedBox(height: 50, width: 50, child: Icon(Icons.person_outline, color: _page == 4 ? Colors.lime : Colors.black)))
              ),
              const Spacer(flex: 1,),
            ],
          ),
        ), // 바텀 앱바
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SizedBox(
                height: 67,
                width: 67,
                child: FittedBox(
                  child: FloatingActionButton.small(
                    heroTag: "fab1",
                    backgroundColor: const Color(0xDD00CC88),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => BoardWritingPage()));
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
              ), // 글쓰기 플로팅 버튼
        body: SafeArea(
            child: _pageStruct(_page),
        ),);
  }

  Widget _pageStruct(int index) {
    Widget ret;

    switch(index) {
      case 1: ret = BoardHomePage(); break;
      case 2: ret = ChatScreen(); break;
      case 3: ret = PageAlert(); break;
      case 4: ret = PageProfile(); break;
      default: ret = BoardHomePage(); break;
    }

    return ret;
  }

  @override
  void initState() {
    super.initState();
  }
}
