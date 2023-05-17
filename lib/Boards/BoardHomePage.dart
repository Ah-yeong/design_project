import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Settings/PageSettings.dart';
import 'BoardGroupListPage.dart';
import 'BoardLocationPage.dart';
import 'BoardSearchPage.dart';

class BoardHomePage extends StatefulWidget {
  const BoardHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _BoardHomePage();
}

class _BoardHomePage extends State<BoardHomePage>
    with SingleTickerProviderStateMixin {
  int _page = 1;
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
        body: SafeArea(
            child: DefaultTabController(
                length: 2,
                child: Stack(
                  children: [
                    NestedScrollView(
                        controller: scrollController,
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverAppBar(
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
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => PageSettings()));
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
                            //BoardTaxiListPage(),
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
          // Tab(
          //   child: Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 0),
          //       color: Colors.white,
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: const [
          //           Icon(CupertinoIcons.car_detailed,size: 20,),
          //           Padding(padding: EdgeInsets.only(left: 7)),
          //           Text(
          //               "택시 동승",
          //               style: TextStyle(fontSize: 13)),
          //         ],
          //       )),
          // ),
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