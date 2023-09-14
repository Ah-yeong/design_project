import 'package:design_project/Boards/List/BoardHomePage.dart';
import 'package:design_project/Boards/Writing/BoardWritingPage.dart';
import 'package:design_project/Chat/ChatScreen.dart';
import 'package:design_project/Chat/ChatList.dart';
import 'package:design_project/Entity/EntityProfile.dart';
import 'package:design_project/Profiles/PageProfile.dart';
import 'package:design_project/Resources/resources.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../Entity/EntityPostPageManager.dart';
import '../../PageAlert.dart';

class BoardPageMainHub extends StatefulWidget {
  const BoardPageMainHub({super.key});

  @override
  State<StatefulWidget> createState() => _BoardPageMainHub();
}

final PostPageManager postManager = PostPageManager();
final EntityProfiles myProfileEntity = EntityProfiles(FirebaseAuth.instance.currentUser!.uid);

class _BoardPageMainHub extends State<BoardPageMainHub> {
  static List<Widget> _pages = <Widget>[BoardHomePage(), ChatRoomListScreen(), PageAlert(), PageProfile()];
  int _selectedIdx = 0;

  @override
  void dispose() {
    super.dispose();
    _pageController!.dispose();
  }

  PageController? _pageController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar:
        BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1,),
              Expanded(child: GestureDetector(
                  onTap: () => _onTappedItem(0),
                  child: SizedBox(height: 50, width: 50, child: Icon(Icons.home_outlined, color: _selectedIdx == 0 ? Colors.lime : Colors.black)))
              ),
              const Spacer(flex: 1,),
              Expanded(child: GestureDetector(
                  onTap: () => _onTappedItem(1),
                  child: SizedBox(height: 50, width: 50, child: Icon(Icons.mark_unread_chat_alt_outlined, color: _selectedIdx== 1 ? Colors.lime : Colors.black)))
              ),
              const Spacer(flex: 3,),
              Expanded(child: GestureDetector(
                  onTap: () => _onTappedItem(2),
                  child: SizedBox(height: 50, width: 50, child: Icon(Icons.notifications_active_outlined, color: _selectedIdx == 2 ? Colors.lime : Colors.black)))
              ),
              const Spacer(flex: 1,),
              Expanded(child: GestureDetector(
                  onTap: () => _onTappedItem(3),
                  child: SizedBox(height: 50, width: 50, child: Icon(Icons.person_outline, color: _selectedIdx == 3 ? Colors.lime : Colors.black)))
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
                    onPressed: () async {
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
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: _pages,
              onPageChanged: (page) {
                setState(() {
                  _selectedIdx = page;
                });
              },
            )
        ),);
  }

  _onTappedItem(int idx) {
    setState(() {
      _pageController!.animateToPage(idx, duration: Duration(milliseconds: 500), curve: Curves.easeOutCubic);
    });
  }

  @override
  void initState() {
    super.initState();
    myProfileEntity.loadProfile();
    _pageController = PageController();
  }
}
