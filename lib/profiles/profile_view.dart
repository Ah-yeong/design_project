import 'package:design_project/boards/post_list/page_hub.dart';
import 'package:design_project/profiles/profile_edit.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';
import '../entity/profile.dart';
import 'package:design_project/profiles/profile_main.dart';

import '../resources/resources.dart';

class BoardProfilePage extends StatefulWidget {
  final String profileId;

  const BoardProfilePage({super.key, required this.profileId});

  @override
  State<StatefulWidget> createState() => _BoardProfilePage();
}

class _BoardProfilePage extends State<BoardProfilePage> {
  var profileId;
  EntityProfiles? profileEntity;
  MannerTemperatureWidget? mannerWidget;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLoading ? "불러오는 중" : "${profileEntity!.name}님의 프로필",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const SizedBox(
            height: 55,
            width: 55,
            child: Icon(
              Icons.close_rounded,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 40,
        elevation: 1,
      ),
      bottomNavigationBar: myUuid! != profileEntity!.profileId
          ? Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(offset: Offset(0, -1), color: colorLightGrey, blurRadius: 1)]),
              width: double.infinity,
              height: 105,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: StatefulBuilder(builder: (context, reloadButtonState) {
                    return InkWell(
                      onDoubleTap: () {},
                      onTap: () {
                        if (profileEntity!.getProfileId() == myProfileEntity!.getProfileId()) return;
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatScreen(recvUserId: profileEntity!.getProfileId())));
                      },
                      child: SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width - 30,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: colorSuccess,
                              boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 4.5)]),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  " ${profileEntity!.name} 님에게 연락하기",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            )
          : const SizedBox(),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          !_isLoading
              ? SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 25),
                        child: SizedBox(
                          height: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 10, right: 20),
                                child: getAvatar(profileEntity!, 40),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${profileEntity!.name}",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${profileEntity!.major}, ${profileEntity!.age}세",
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        profileEntity!.addr1 == null
                                            ? Text(
                                                textAlign: TextAlign.left,
                                                "지역 비공개",
                                                style: TextStyle(fontSize: 13, color: Colors.grey),
                                              )
                                            : Text(
                                                textAlign: TextAlign.left,
                                                "${profileEntity!.addr1 != null ? profileEntity!.addr1 + ' ' : ''}"
                                                "${profileEntity!.addr2 != null ? profileEntity!.addr2 + ' ' : ''}"
                                                "${profileEntity!.addr3 != null ? profileEntity!.addr3 : ''}",
                                                style: TextStyle(fontSize: 13, color: colorGrey),
                                              ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Divider(thickness: 1, height: 1),
                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
                          // padding: EdgeInsets.all(20),
                          child: Container(
                            // padding:  EdgeInsets.all(15),
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(10),
                            //   border: Border.all(
                            //     width: 2,
                            //     color: Color(0xFF6ACA89),
                            //   ),
                            // ),
                            child: Column(
                              children: [
                                MannerTemperatureWidget(mannerScore: profileEntity!.mannerGroup),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
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
                                                  child: Text(profileEntity!.mbtiIndex == -1 ? "비공개" : mbtiList[profileEntity!.mbtiIndex],
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontSize: 13, color: profileEntity!.mbtiIndex == -1 ? Colors.grey : Colors.black)),
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
                                                    profileEntity!.hobby.length == 0 ? '비공개' : profileEntity!.hobby?.join(', '),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(fontSize: 13, color: profileEntity!.hobby.length == 0 ? Colors.grey : Colors.black),
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
                                                    profileEntity!.commute ?? "비공개",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(fontSize: 13, color: profileEntity!.commute == null ? Colors.grey : Colors.black),
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
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
                                                  child: Text(profileEntity!.textInfo == null || profileEntity!.textInfo == "" ? "없음" : profileEntity!.textInfo,
                                                      textAlign: TextAlign.center,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              profileEntity!.textInfo == null || profileEntity!.textInfo == "" ? Colors.grey : Colors.black)),
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ))
                      // 추가적인 프로필 정보를 이곳에 추가할 수 있습니다.
                    ],
                  ),
                )
              : SizedBox(),
          _isLoading ? buildContainerLoading(135) : SizedBox()
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print("작성자 프로필 로드");
    print(widget.profileId);
    profileEntity = EntityProfiles(widget.profileId);
    profileEntity!.loadProfile().then((n) {
      mannerWidget = MannerTemperatureWidget(mannerScore: profileEntity!.mannerGroup);
      setState(() {
        _isLoading = false;
      });
    });
  }
}
