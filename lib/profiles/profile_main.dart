import 'dart:io';

import 'package:design_project/boards/post_list/page_hub.dart';
import 'package:design_project/main.dart';
import 'package:design_project/profiles/completed_group.dart';
import 'package:design_project/profiles/my_group.dart';
import 'package:design_project/profiles/my_post.dart';
import 'package:design_project/profiles/profile_first_set.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../entity/entity_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../resources/fcm.dart';
import '../resources/resources.dart';
import '../settings/user_resignation.dart';
import 'profile_edit.dart';

class PageProfile extends StatefulWidget {
  @override
  _PageProfileState createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  List<EntityPost> myPostList = List.empty(growable: true);
  MannerTemperatureWidget? mannerWidget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('프로필', style: TextStyle(fontSize: 19, color: Colors.black)),
        backgroundColor: Colors.white,
        actions: [
          SizedBox(
              width: 55,
              height: 55,
              child: PullDownButton(
                itemBuilder: (context) => [
                  const PullDownMenuTitle(title: Text("프로필 옵션")),
                  PullDownMenuItem.selectable(
                    iconWidget: const Icon(CupertinoIcons.lock),
                    title: '로그아웃',
                    itemTheme: PullDownMenuItemTheme(textStyle: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      _showLogoutPopup();
                    },
                  ),
                  PullDownMenuItem.selectable(
                    iconWidget: const Icon(CupertinoIcons.lock_slash),
                    title: '회원 탈퇴',
                    itemTheme: PullDownMenuItemTheme(textStyle: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      Get.to(() => PageResignation());
                    },
                  ),
                  PullDownMenuItem.selectable(
                    iconWidget: const Icon(CupertinoIcons.exclamationmark_bubble),
                    title: '버그 제보',
                    itemTheme: PullDownMenuItemTheme(textStyle: TextStyle(color: Colors.black)),
                    onTap: () {
                      showAlert("gitlimjw@gmail.com\n문의 바랍니다", context, colorGrey, duration: Duration(milliseconds: 5000));
                    },
                  ),
                  PullDownMenuItem.selectable(
                    iconWidget: const Icon(CupertinoIcons.exclamationmark_bubble),
                    title: '프로필 처음 설정',
                    itemTheme: PullDownMenuItemTheme(textStyle: TextStyle(color: Colors.black)),
                    onTap: () {
                      Get.to(() => NameSignUpScreen());
                    },
                  ),
                ],
                buttonBuilder: (context, showMenu) => CupertinoButton(
                  onPressed: showMenu,
                  padding: EdgeInsets.zero,
                  child: const Icon(Icons.settings, color: Colors.black),
                ),
              ))
        ],
      ),
      backgroundColor: Colors.white,
      body: myProfileEntity!.isLoading
          ? Center(child: SizedBox(height: 65, width: 65, child: buildLoadingProgress()))
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(width: 10),
                          getAvatar(myProfileEntity, 50),
                          const SizedBox(width: 25),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                const SizedBox(height: 10),
                                Text(
                                  "${myProfileEntity!.name}",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${myProfileEntity!.major}, ${myProfileEntity!.age}세",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                myProfileEntity!.addr1 == null
                                    ? Text(
                                        textAlign: TextAlign.left,
                                        "지역 비공개",
                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                      )
                                    : Text(
                                        textAlign: TextAlign.left,
                                        "${myProfileEntity!.addr1 != null ? myProfileEntity!.addr1 + ' ' : ''}"
                                        "${myProfileEntity!.addr2 != null ? myProfileEntity!.addr2 + ' ' : ''}"
                                        "${myProfileEntity!.addr3 != null ? myProfileEntity!.addr3 : ''}",
                                        style: TextStyle(fontSize: 13, color: colorGrey),
                                      ),
                                const SizedBox(height: 6),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => PageProfileEdit())).then((value) {
                                        _reloadProfile().then((value) async {
                                          try {
                                            String url = await FirebaseStorage.instance.ref().child("profile_image/${myUuid!}").getDownloadURL();
                                            setState(() {
                                              userTempImage[myProfileEntity!.profileId] = NetworkImage(url);
                                            });
                                          } catch (e) {
                                            if (!e.toString().contains("No object exists")) {
                                              print("Profile image error : $e");
                                            }
                                          }
                                        });
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: colorSuccess, elevation: 0.5),
                                    child: Text('프로필 수정'))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: mannerWidget),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0.75,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                height: 90,
                                child: Column(
                                  children: [
                                    Text(
                                      'MBTI',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold
                                          //fontWeight: FontWeight.bold
                                          ),
                                    ),
                                    Expanded(
                                        child: Center(
                                      child: Text(myProfileEntity!.mbtiIndex == -1 ? "비공개" : mbtiList[myProfileEntity!.mbtiIndex],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 13, color: myProfileEntity!.mbtiIndex == -1 ? Colors.grey : Colors.black)),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0.75,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                height: 90,
                                child: Column(
                                  children: [
                                    Text(
                                      '취미',
                                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold
                                          //fontWeight: FontWeight.bold
                                          ),
                                    ),
                                    Expanded(
                                        child: Center(
                                      child: Text(
                                        myProfileEntity!.hobby.length == 0 ? '비공개' : myProfileEntity!.hobby?.join(', '),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 13, color: myProfileEntity!.hobby.length == 0 ? Colors.grey : Colors.black),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0.75,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                height: 90,
                                child: Column(
                                  children: [
                                    Text(
                                      '통학 여부',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold
                                          //fontWeight: FontWeight.bold
                                          ),
                                    ),
                                    Expanded(
                                        child: Center(
                                      child: Text(
                                        myProfileEntity!.commute ?? "비공개",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 13, color: myProfileEntity!.commute == null ? Colors.grey : Colors.black),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0.75,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                height: 80,
                                child: Column(
                                  children: [
                                    Text(
                                      '한줄 소개',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold
                                          //fontWeight: FontWeight.bold
                                          ),
                                    ),
                                    Expanded(
                                        child: Center(
                                      child: Text(myProfileEntity!.textInfo == null || myProfileEntity!.textInfo == "" ? "없음" : myProfileEntity!.textInfo,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: myProfileEntity!.textInfo == null || myProfileEntity!.textInfo == "" ? Colors.grey : Colors.black)),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PageMyPost(),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(17),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.doc_text,
                                  color: colorSuccess,
                                  size: 23,
                                ),
                                Text(
                                  '   작성한 모임 게시글',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 17,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(thickness: 1),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PageMyGroup(),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(17),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.calendar_today,
                                  color: colorSuccess,
                                  size: 23,
                                ),
                                Text(
                                  '   진행 예정 모임',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 17,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(thickness: 1),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PageMyEndGroup(),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(17),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.check_mark_circled,
                                  color: colorSuccess,
                                  size: 23,
                                ),
                                Text(
                                  '   종료된 모임 및 평가',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 17,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(thickness: 1),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void initState() {
    //setState(() {});
    super.initState();
    myProfileEntity!.loadProfile().then((n) {
      mannerWidget = MannerTemperatureWidget(mannerScore: myProfileEntity!.mannerGroup);
      // for( var postId in myProfileEntity!.post){
      //   EntityPost myPost = EntityPost(postId);
      //   myPost.loadPost().then((value) {
      //     myPostList.add(myPost);
      setState(() {});
      //   });
      // }
    });
  }

  Future<void> _reloadProfile() async {
    await myProfileEntity!.loadProfile().then((n) {
      setState(() {});
    });
  }

  Future<void> _showLogoutPopup() async {
    final action = CupertinoActionSheet(
      title: Text(
        "${myProfileEntity!.name} 계정에서 로그아웃 할까요?",
        style: TextStyle(fontSize: 15),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("로그아웃"),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            hubLoadingStateSetter!(() {
              hubLoadingContainerVisible = true;
            });
            await FirebaseAuth.instance.signOut().then((value) {});
            await FCMController()
              ..removeUserTokenDB();
            await showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                      title: Text("로그아웃 성공!"),
                      content: Column(
                        children: [Text("어플을 재실행하세요!.")],
                      ),
                      actions: [CupertinoDialogAction(child: Text("확인"), onPressed: () => Navigator.pop(context))],
                    ));
            exit(0);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("취소"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    await showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}

class MannerTemperatureWidget extends StatelessWidget {
  final double mannerScore;

  MannerTemperatureWidget({
    Key? key,
    required this.mannerScore,
  }) : super(key: key);

  final _tooltipController = SuperTooltipController();

  @override
  Widget build(BuildContext context) {
    final color = getColorForScore(mannerScore);
    return Column(
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.suit_heart_fill,
              color: color,
              size: 15,
            ),
            Text(
              ' 매너지수',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${mannerScore.toStringAsFixed(1)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async => await _tooltipController.showTooltip(),
                  child: SuperTooltip(
                    popupDirection: TooltipDirection.down,
                    arrowTipDistance: 7,
                    shadowSpreadRadius: 3,
                    shadowColor: Colors.black.withAlpha(150),
                    showDropBoxFilter: true,
                    showBarrier: true,
                    sigmaX: 1,
                    sigmaY: 1,
                    controller: _tooltipController,
                    content: Container(
                      width: MediaQuery.of(context).size.width * 9 / 10,
                      height: 200,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info,
                                  size: 16,
                                  color: colorGrey,
                                ),
                                Text(
                                  " 매너지수 : \n - 나의 매너와 신뢰도를 나타내는 점수\n - 다음과 같은 상황에서 매너지수가 상승 또는 하락",
                                  style: TextStyle(color: Colors.black, fontSize: 13),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info,
                                  size: 16,
                                  color: colorGrey,
                                ),
                                Text(
                                  " 매너지수 상승 : \n - 모임의 꾸준한 참여 \n - 모임 이후 사용자 상호 평가에서의 높은 평가 점수",
                                  style: TextStyle(color: Colors.black, fontSize: 13),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info,
                                  size: 16,
                                  color: colorGrey,
                                ),
                                Text(
                                  " 매너지수 하락 : \n - 위치 공유 서비스 기반 모임의 의도적 불참\n - 신고 누적에 의한 검토 이후 하락\n - 모임 이후 사용자 상호 평가에서의 낮은 평가 점수",
                                  style: TextStyle(color: Colors.black, fontSize: 13),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        String.fromCharCode(CupertinoIcons.question_circle.codePoint),
                        style: TextStyle(
                          inherit: false,
                          color: Colors.indigoAccent,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: CupertinoIcons.question_circle.fontFamily,
                          package: CupertinoIcons.question_circle.fontPackage,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
        SizedBox(height: 8.0),
        SizedBox(
          height: 7,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(width: 0.3, color: Colors.grey),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1800),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(
                  begin: 0,
                  end: mannerScore.toDouble(),
                ),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value / 100,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  backgroundColor: color.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
