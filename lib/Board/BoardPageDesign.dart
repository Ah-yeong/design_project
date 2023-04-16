import 'package:design_project/Board/BoardSearchPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'BoardGroupListPage.dart';
import 'BoardLocationPage.dart';
import 'BoardTaxiListPage.dart';

class BoardPageDesign extends StatefulWidget {
  const BoardPageDesign({super.key});

  @override
  State<StatefulWidget> createState() => _BoardPageDesign();
}

class _BoardPageDesign extends State<BoardPageDesign>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  ScrollController? scrollController;
  bool isScrollTop = true;

  @override
  void dispose() {
    scrollController!.dispose();
    super.dispose();
  }

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
                onTap: () {},
                  child: const SizedBox(height: 50, width: 50, child: Icon(Icons.home_outlined),))
              ),
              const Spacer(flex: 1,),
              Expanded(child: GestureDetector(
                  onTap: () {},
                  child: const SizedBox(height: 50, width: 50, child: Icon(Icons.mark_unread_chat_alt_outlined),))
              ),
              const Spacer(flex: 3,),
              Expanded(child: GestureDetector(
                  onTap: () {},
                  child: const SizedBox(height: 50, width: 50, child: Icon(Icons.notifications_active_outlined),))
              ),
              const Spacer(flex: 1,),
              Expanded(child: GestureDetector(
                  onTap: () {},
                  child: const SizedBox(height: 50, width: 50, child: Icon(Icons.person_outline),))
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
            child: DefaultTabController(
          length: 3,
          child: Stack(
            children: [
              NestedScrollView(
                  controller: scrollController,
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        leading: const BackButton(
                          color: Colors.black,
                        ),
                        toolbarHeight: 40,
                        pinned: false,
                        backgroundColor: Colors.white,
                        title: const Text(
                          "바로 모임",
                          style: TextStyle(color: Colors.black, fontSize: 19),
                        ),
                        flexibleSpace: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 40,
                              height: 50,
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => BoardSearchPage()));
                                  },
                                  child: const Icon(Icons.search_rounded)),
                            ),
                            SizedBox(
                              width: 40,
                              height: 50,
                              child: GestureDetector(
                                  onTap: () {
                                    print("asdfqwef");
                                  },
                                  child: const Icon(Icons.settings)),
                            ),
                            const SizedBox(
                              width: 10,
                              height: 50,
                            )
                          ],
                        ),
                      ),
                      const SliverPersistentHeader(
                          pinned: true, delegate: TabBarDelegate()),
                    ];
                  },
                  body: const TabBarView(
                    children: [
                      BoardGroupListPage(),
                      BoardTaxiListPage(),
                      BoardLocationPage(),
                    ],
                  )),
              isScrollTop ? const SizedBox() : Positioned(
                bottom: 16,
                right: 16,
                child: SizedBox(
                height: 50,
                width: 50,
                child: FittedBox(
                  child: FloatingActionButton.small(
                    heroTag: "fab1",
                    backgroundColor: const Color(0xCCFFFFFF),
                    onPressed: () {
                      scrollController!.animateTo(
                        0,
                        duration: const Duration(milliseconds: 750),
                        curve: Curves.decelerate,
                      );
                    },
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey, width: 0.7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
              ),

              )
            ],
          )
        )));
  }

  /*TabBar get _tabBar => TabBar(tabs : <Tab>[
    Tab(child: Center(child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(CupertinoIcons.text_justify, color: Colors.black),
        Padding(padding: EdgeInsets.only(right:10),
        ),
        Text("글 목록", style: TextStyle(color: Colors.black),)
      ],
    ),) ,),
    Tab(icon: Icon(CupertinoIcons.location_solid, color: Colors.black), )
    ], controller: controller, indicatorColor: Colors.lime,
  );

  @override
  Widget build(BuildContext context) {
    // return CupertinoTabScaffold(tabBar: tabBar!,
    //     tabBuilder: (context, value) => value == 0 ? _boardListPage! : _boardLocationPage!);
    return Scaffold(
        appBar: AppBar(
        title: const Text('게시판 예제'),
        bottom: PreferredSize(
          preferredSize: _tabBar.preferredSize,
          child: Container(
            color: Colors.white,
            height: 30,
            child: _tabBar,
          ),
        ),
          backgroundColor: Strings.styleColor,
        ),
      body: TabBarView(
        controller: controller,
        children: <Widget>[BoardListPage(), BoardLocationPage()],
      ),
    );
  }*/

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    scrollController = ScrollController();
    scrollController!.addListener(() {
      setState(() {
        if (scrollController!.offset ==
                scrollController!.position.maxScrollExtent &&
            !scrollController!.position.outOfRange) {
          isScrollTop = false;
        } else {
          isScrollTop = true;
        }
      });
    });
    /*
    tabBar = CupertinoTabBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.text_justify), label: "게시글 목록"),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.location_solid), label: "한눈에 보기")
      ],
    );
    */
  }
}

class TabBarDelegate extends SliverPersistentHeaderDelegate {
  const TabBarDelegate();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: TabBar(
        tabs: [
          Tab(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(CupertinoIcons.text_justify, size: 20,),
                    Padding(padding: EdgeInsets.only(left: 7)),
                    Text(
                      "모임 찾기",
                     style: TextStyle(fontSize: 13)),
                  ],
                )),
          ),
          Tab(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(CupertinoIcons.car_detailed,size: 20,),
                    Padding(padding: EdgeInsets.only(left: 7)),
                    Text(
                        "택시 동승",
                        style: TextStyle(fontSize: 13)),
                  ],
                )),
          ),
          Tab(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(CupertinoIcons.location_solid,size: 20,),
                    Padding(padding: EdgeInsets.only(left: 5)),
                    Text(
                        "위치로 찾기",
                        style: TextStyle(fontSize: 13)),
                  ],
                )),
          ),
        ],
        indicatorWeight: 2,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        unselectedLabelColor: Colors.grey,
        labelColor: Colors.black,
        indicatorColor: Colors.lime,
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 48;

  @override
  // TODO: implement minExtent
  double get minExtent => 35;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
