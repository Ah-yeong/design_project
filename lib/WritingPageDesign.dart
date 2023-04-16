import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/services.dart';
import 'resources.dart';

final key = GlobalKey<CustomRadioButtonState>();

class WritingPageDesign extends StatefulWidget {
  const WritingPageDesign({super.key});

  @override
  State<StatefulWidget> createState() => _WritingPageDesign();
}

class _WritingPageDesign extends State<WritingPageDesign>
    with SingleTickerProviderStateMixin {
  TextEditingController? head;
  TextEditingController? body;
  bool? isSelectedSex = false;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        child: SafeArea(
            child: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      const SliverAppBar(
                        leading: BackButton(
                          color: Colors.black,
                        ),
                        toolbarHeight: 35,
                        pinned: false,
                        backgroundColor: Colors.white,
                        title: Text(
                          "글 작성",
                          style: TextStyle(color: Colors.black, fontSize: 19),
                        ),
                      ),
                      const SliverPersistentHeader(
                          pinned: true, delegate: TabBarDelegate()),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      friendsForm(),
                      taxiForm()
                    ],
                  )),
            )));
  }

  // 사람 만나기 작성 폼
  Widget friendsForm() {
    return Padding(padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              maxLines: 1,
              maxLength: 20,
              controller: head,
              cursorColor: Colors.black,
              decoration: const InputDecoration(
                  hintText: "글 제목 (최대 20자)",
                  counterText: "",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54))),
            ),
            TextField(
              maxLines: 5,
              maxLength: 500,
              maxLengthEnforcement: MaxLengthEnforcement.none,
              controller: head,
              cursorColor: Colors.black,
              decoration: const InputDecoration(
                  hintText: "내용 작성 (최대 500자)",
                  counterText: "",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54))),
            ),
          AnimatedPadding(padding: !isSelectedSex!
          ? EdgeInsets.only(top: 15, bottom: 0)
          : EdgeInsets.only(top: 15, bottom: 10)
          , duration: Duration(milliseconds: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("성별 선택",
                    style: TextStyle(color: Color(0xFF777777), fontSize: 16),),
                  Row(
                    children: [
                      CustomRadioButton(buttonLables: const [
                        "무관",
                        "남자만",
                        "여자만",
                      ],
                        buttonValues: const [
                          "any",
                          "man",
                          "woman",
                        ],
                        radioButtonValue: (value) {
                          selectSex(value);
                        },
                        unSelectedColor: Colors.white,
                        selectedColor: Strings.styleColor,
                        elevation: 1,
                        selectedBorderColor: const Color(0xFF777777),
                        unSelectedBorderColor: const Color(0xFF777777),
                        defaultSelected: "any",
                      )
                    ],
                  ),
                ],
              ),
            ),
            (isSelectedSex! ? const Text("성별이 선택된 경우 매칭이 느려질 수 있습니다.", style: TextStyle(color: Color(0xAAAA0000)),) : const Text('')),
            const Divider(thickness: 1,),
          ],
        ));
  }

  // 택시 같이 타기 작성 폼
  Widget taxiForm() {
    return TextField(
      maxLines: 1,
      maxLength: 20,
      controller: head,
      cursorColor: Colors.black,
      decoration: const InputDecoration(
          hintText: "글 제목",
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black12),
          ),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black54))),
    );
  }

  selectSex(var value) {
    setState(() {
      if(value == "any") {
        isSelectedSex = false;
      } else {
        isSelectedSex = true;
      }
    });
  }
}

class TabBarDelegate extends SliverPersistentHeaderDelegate {
  const TabBarDelegate();

  @override
  Widget build(BuildContext context, double shrinkOffset,
      bool overlapsContent) {
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
                    Icon(CupertinoIcons.person_3_fill),
                    Padding(padding: EdgeInsets.only(left: 20)),
                    Text(
                      "만날 사람 찾기",
                    ),
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
                    Icon(CupertinoIcons.car_detailed),
                    Padding(padding: EdgeInsets.only(left: 20)),
                    Text(
                      "택시 같이 타기",
                    ),
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
