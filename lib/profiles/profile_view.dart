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
        title: const Text(
          "작성자 프로필",
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
      backgroundColor: Colors.white,
      body:
          // body: profileEntity!.isLoading ? Center(
          //     child: SizedBox(
          //         height: 65,
          //         width: 65,
          //         child: CircularProgressIndicator(
          //           strokeWidth: 4,
          //           color: colorSuccess,
          //         ))) :
          Stack(
        children: [
          !_isLoading
              ? SingleChildScrollView(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 10),
                              getAvatar(profileEntity!, 45),
                              SizedBox(width: 25),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    SizedBox(height: 6),
                                    Text(
                                      "${profileEntity!.name}",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "${profileEntity!.major}, ${profileEntity!.age}세",
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "${profileEntity!.textInfo}",
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 7),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "매너 지수 ${profileEntity!.mannerGroup}점",
                                            style: const TextStyle(color: Colors.black, fontSize: 12),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 2),
                                          ),
                                          SizedBox(
                                              height: 6,
                                              //width: 200,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: profileEntity!.mannerGroup / 100,
                                                  valueColor: AlwaysStoppedAnimation<Color>(_getColorForScore(profileEntity!.mannerGroup)),
                                                  backgroundColor: Color(0xFFBFBFBF).withOpacity(0.3),
                                                ),
                                              ))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        // Divider(thickness: 1, height: 1),
                        Container(
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
                                  Row(children: [
                                    Text(
                                      '취미',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${profileEntity!.hobby?.join(', ')}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                        maxLines: 2, // 텍스트가 2줄을 초과하면 다음 줄로 내려가도록 설정
                                        overflow: TextOverflow.ellipsis, // 텍스트가 오버플로우되는 경우 ...으로 표시
                                      ),
                                    )
                                  ]),
                                  SizedBox(
                                    height: 14,
                                  ),
                                  // Divider(thickness: 1, height: 1),
                                  // SizedBox(
                                  //   height: 7,
                                  // ),
                                  Row(children: [
                                    Text(
                                      'MBTI',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(
                                        child: Text(myProfileEntity!.mbtiIndex == -1 ? "비공개" : mbtiList[myProfileEntity!.mbtiIndex],
                                            textAlign: TextAlign.right,
                                            style: TextStyle(fontSize: 14, color: myProfileEntity!.mbtiIndex == -1 ? Colors.grey : Colors.black))
                                    )
                                  ]),
                                  SizedBox(
                                    height: 14,
                                  ),
                                  // Divider(thickness: 1, height: 1),
                                  // SizedBox(
                                  //   height: 7,
                                  // ),
                                  Row(children: [
                                    Text(
                                      '통학여부',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(
                                        child: Text(
                                          myProfileEntity!.commute ?? "비공개",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(fontSize: 14, color: myProfileEntity!.commute == null ? Colors.grey : Colors.black),
                                        ))
                                  ]),
                                  SizedBox(
                                    height: 14,
                                  ),
                                  // Divider(thickness: 1, height: 1),
                                  // SizedBox(
                                  //   height: 7,
                                  // ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 18),
                                      child: InkWell(
                                          onTap: () {
                                            if (profileEntity!.getProfileId() == myProfileEntity?.getProfileId()) return;
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(builder: (context) => ChatScreen(recvUserId: profileEntity!.getProfileId())));
                                          },
                                          child: SizedBox(
                                            height: 50,
                                            width: MediaQuery.of(context).size.width - 40,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),
                                                  color: colorSuccess,
                                                  boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 4.5)]),
                                              child: Center(
                                                  child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.chat_outlined,
                                                    color: Colors.white,
                                                    size: 17,
                                                  ),
                                                  Text(
                                                    " ${profileEntity!.name} 님에게 연락하기",
                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              )),
                                            ),
                                          )),
                                    ),
                                  )
                                ],
                              ),
                              // child: Row(
                              //     crossAxisAlignment: CrossAxisAlignment.center,
                              //     children: <Widget>[
                              //       Column(
                              //         crossAxisAlignment: CrossAxisAlignment.start,
                              //         children: <Widget>[
                              //           Text(
                              //             '취미',
                              //             style: TextStyle(
                              //               fontSize: 14,
                              //             ),
                              //           ),
                              //           SizedBox(height: 6),
                              //           Text(
                              //             'MBTI',
                              //             style: TextStyle(
                              //               fontSize: 14,
                              //             ),
                              //           ),
                              //           SizedBox(height: 6),
                              //           Text(
                              //             '통학여부',
                              //             style: TextStyle(
                              //               fontSize: 14,
                              //             ),
                              //           ),
                              //           SizedBox(height: 6),
                              //           Text(
                              //             '거주지',
                              //             style: TextStyle(
                              //               fontSize: 14,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       SizedBox(width: 20),
                              //       Expanded(
                              //         child: Column(
                              //           crossAxisAlignment: CrossAxisAlignment.start,
                              //           children: <Widget>[
                              //             Text(
                              //               '${profileEntity!.hobby?.join(', ')}',
                              //               style: TextStyle(
                              //                 fontSize: 14,
                              //               ),
                              //               maxLines: 2, // 텍스트가 2줄을 초과하면 다음 줄로 내려가도록 설정
                              //               overflow: TextOverflow.ellipsis, // 텍스트가 오버플로우되는 경우 ...으로 표시
                              //             ),
                              //             SizedBox(height: 6),
                              //             Text(
                              //               "${profileEntity!.mbti}",
                              //               style: TextStyle(
                              //                 fontSize: 14,
                              //               ),
                              //             ),
                              //             SizedBox(height: 6),
                              //             Text(
                              //               "${profileEntity!.commute}",
                              //               style: TextStyle(
                              //                 fontSize: 14,
                              //               ),
                              //             ),
                              //             SizedBox(height: 6),
                              //             Text(
                              //               '경기도 오산시',
                              //               style: TextStyle(
                              //                 fontSize: 14,
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ]
                              // )
                            ))
                        // 추가적인 프로필 정보를 이곳에 추가할 수 있습니다.
                      ],
                    ),
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

  Color _getColorForScore(int score) {
    if (score < 20) {
      return Colors.red;
    } else if (score < 40) {
      return Colors.orange;
    } else if (score < 60) {
      return Colors.yellow;
    } else if (score < 80) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }
}
