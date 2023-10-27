import 'package:design_project/profiles/profile_main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../resources/resources.dart';

class BoardBottomAppBar extends StatefulWidget {
  final PageController pageController;

  const BoardBottomAppBar({Key? key, required this.pageController}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BoardBottomAppbar(this.pageController);
}

class _BoardBottomAppbar extends State<BoardBottomAppBar> {
  int _selectedIdx = 0;
  PageController _pageController;

  _BoardBottomAppbar(this._pageController);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Container(
        height: 50.7,
        child: Column(
          children: [
            Divider(
              height: 0.7,
              thickness: 0.7,
              color: colorLightGrey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(
                  flex: 1,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onTappedItem(0),
                    behavior: HitTestBehavior.translucent,
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(_selectedIdx == 0 ? Icons.home : Icons.home_outlined,
                                color: _selectedIdx == 0 ? colorSuccess : colorGrey, size: 26),
                          ),
                          //buildAlertPoint()
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _onTappedItem(1),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(_selectedIdx == 1 ? CupertinoIcons.chat_bubble_2_fill : CupertinoIcons.chat_bubble_2,
                                color: _selectedIdx == 1 ? colorSuccess : colorGrey, size: 26),
                          ),
                          // if(newChat) buildAlertPoint()
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(
                  flex: 3,
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _onTappedItem(2),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(_selectedIdx == 2 ? Icons.notifications : Icons.notifications_none,
                                color: _selectedIdx == 2 ? colorSuccess : colorGrey, size: 26),
                          ),
                          // if(newAlert) buildAlertPoint()
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _onTappedItem(3),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(_selectedIdx == 3 ? Icons.person : Icons.person_outline,
                                color: _selectedIdx == 3 ? colorSuccess : colorGrey, size: 26),
                          ),
                          //buildAlertPoint()
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _onTappedItem(int idx) {
    setState(() {
      _selectedIdx = idx;
      _pageController.jumpToPage(idx);
    });
  }

  Align buildAlertPoint() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 11, right: 3),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
