import 'dart:async';
import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:design_project/Boards/List/BoardPostListPage.dart';
import 'package:design_project/Resources/LoadingIndicator.dart';
import 'package:flutter/material.dart';
import '../Entity/EntityPost.dart';
import '../Entity/EntityProfile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:design_project/Resources/resources.dart';
import '../Boards/BoardProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BoardPostPage extends StatefulWidget {
  final int? postId;

  const BoardPostPage({super.key, required this.postId});

  @override
  State<StatefulWidget> createState() => _BoardPostPage();
}

class _BoardPostPage extends State<BoardPostPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  User? loggedUser; // loggedUser 변수 선언

  final List<Marker> _markers = [];
  bool isSameId = false;

  static const CameraPosition _kSeoul = CameraPosition(
    target: LatLng(36.833068, 127.178419),
    zoom: 17.4746,
  );

  var postId;
  EntityPost? postEntity;
  EntityProfiles? profileEntity;
  bool isLoaded = false;
  bool postTimeIsLoaded = false;
  var postTime;
  bool isRequestLoading = true;
  Size? mediaSize;
  String userID = FirebaseAuth.instance.currentUser!.uid;

  late Future<List<EntityProfiles>> requestUsers;
  late Future<List<EntityProfiles>> acceptUsers;

  Future<List<EntityProfiles>> getRequestProfiles(List<String> uuids) async {
    List<EntityProfiles> requestList = [];
    var requestProfiles = postEntity!.getUser().where((element) => element['status'] == 0);
    List<String> requestUuids = [];
    requestProfiles.forEach((element) => requestUuids.add(element['id']));
    for (String uuid in uuids) {
      if (requestUuids.contains(uuid)) {
        EntityProfiles profiles = EntityProfiles(uuid);
        await profiles.loadProfile();
        requestList.add(profiles);
      }
    }
    return requestList;
  }

  Future<List<EntityProfiles>> getAcceptProfiles(List<String> uuids) async {
    List<EntityProfiles> acceptList = [];
    var acceptProfiles = postEntity!.getUser().where((element) => element['status'] == 1);
    List<String> acceptUuids = [];
    acceptProfiles.forEach((element) => acceptUuids.add(element['id']));
    for (String uuid in uuids) {
      if (acceptUuids.contains(uuid)) {
        EntityProfiles profiles = EntityProfiles(uuid);
        await profiles.loadProfile();
        acceptList.add(profiles);
      }
    }
    return acceptList;
  }

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    return !isLoaded
        ? buildLoadingProgress()
        : Scaffold(
            appBar: AppBar(
              title: const Text(
                "게시글",
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
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(offset: Offset(0, -1), color: colorLightGrey, blurRadius: 1)
                ]
              ),
              width: double.infinity,
              height: 105,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: InkWell(
                    onTap: () async {
                      if (isSameId) {
                        showModalBottomSheet(
                            isDismissible: false,
                            context: context,
                            builder: (BuildContext context) => _buildModalSheet(postEntity!.getPostId()),
                            backgroundColor: Colors.transparent);
                      } else if (postEntity!.getRequestState(myUuid!) == "none") {
                        await postEntity!.applyToPost(userID).then((requestSuccess) async {
                          await _loadPost(isReload: true).then((value) {
                            setState(() {
                              if (requestSuccess) {
                                showAlert("신청이 완료되었어요!", context, colorSuccess);
                              } else {
                                showAlert("이미 신청한 적이 있는 게시글이에요!", context, colorError);
                              }
                            });
                          });
                        });
                      } else if (postEntity!.getRequestState(myUuid!) == "wait") {
                        showAlert("아직 참가 요청이 처리되지 않았어요!", context, colorGrey);
                      } else if (postEntity!.getRequestState(myUuid!) == "accept") {
                        showAlert("참여자를 봅니다.", context, Colors.lightBlueAccent);
                      } else if (postEntity!.getRequestState(myUuid!) == "reject") {
                        Navigator.of(context).pop();
                      }
                    },
                    child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 30,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isSameId
                                ? Colors.indigoAccent
                                : postEntity!.getRequestState(myUuid!) == "none"
                                    ? colorSuccess
                                    : postEntity!.getRequestState(myUuid!) == "wait"
                                        ? colorWarning
                                        : postEntity!.getRequestState(myUuid!) == "accept"
                                            ? Colors.indigoAccent
                                            : colorGrey,
                            boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 4.5)]),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              !isSameId && postEntity!.getRequestState(myUuid!) == "none"
                                  ? Icon(
                                      Icons.emoji_people,
                                      color: Colors.white,
                                    )
                                  : SizedBox(),
                              Text(
                                _getRequestButtonText(),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.white,
            body: Stack(children: [
              SingleChildScrollView(
                  child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 3 / 8,
                      child: GoogleMap(
                        markers: Set.from(_markers),
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: postEntity!.getLLName().latLng,
                          zoom: 17.4746,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          if (!_controller.isCompleted) _controller.complete(controller);
                        },
                      ),
                    ),
                    // 지도 표시 구간
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
                    ),

                    // 제목 및 카테고리
                    buildPostContext(postEntity!, profileEntity!, context),
                    // Text("Max Person : ${postEntity!.getPostMaxPerson()}"),
                    // Text("Gender Limit : ${postEntity!.getPostGender()}"),
                  ]),
                ),
              )),
              isRequestLoading ? buildContainerLoading(30) : SizedBox(),
            ]),
          );
  }

  @override
  void initState() {
    super.initState();
    postId = widget.postId;
    postEntity = EntityPost(postId);
    _loadPost().then((value) {
      postEntity!.addViewCount(myUuid!);
      setState(() => isRequestLoading = false);
    });
  }

  Future<void> _loadPost({bool? isReload}) async {
    await postEntity!.loadPost().then((value) async {
      profileEntity = EntityProfiles(postEntity!.getWriterId());
      await profileEntity!.loadProfile().then((value) {
        if (isReload != true) {
          _markers.add(Marker(markerId: const MarkerId('1'), draggable: true, onTap: () {}, position: postEntity!.getLLName().latLng));
          _checkWriterId(postEntity!.getWriterId());
          loadPostTime();
        }
      });
    });
    List<String> profileList = [];
    postEntity!.getUser().forEach((element) => profileList.add(element["id"].toString()));
    requestUsers = getRequestProfiles(profileList);
    acceptUsers = getAcceptProfiles(profileList);
    return;
  }

  loadPostTime() {
    String pTime = getTimeBefore(postEntity!.getUpTime());
    postTime = pTime;
    setState(() {
      postTimeIsLoaded = true;
      isLoaded = true;
    });
  }

  _checkWriterId(writerId) {
    if (writerId != Null) {
      if (FirebaseAuth.instance.currentUser!.uid == writerId) isSameId = true;
    }
  }

  String _getRequestButtonText() {
    String text = "";
    if (isSameId) {
      text += "[신청자 관리, 모임 성사]  현재 ${postEntity!.getPostCurrentPerson()}";
      if (postEntity!.getPostMaxPerson() != -1) {
        text += "/${postEntity!.getPostMaxPerson()}";
      }
      text += "명 (대기 ${postEntity!.getNewRequest()}명)";
    } else {
      if (postEntity!.getRequestState(myUuid!) == "none") {
        text += "  [신청하기]  ";
        if (postEntity!.getPostMaxPerson() == -1) {
          text += "현재 인원 ${postEntity!.getPostCurrentPerson()}명";
        } else {
          text += "현재 인원 ${postEntity!.getPostCurrentPerson()} / ${postEntity!.getPostMaxPerson()}";
        }
      } else if (postEntity!.getRequestState(myUuid!) == "wait") {
        text += "[참가 요청중]  ";
        if (postEntity!.getPostMaxPerson() == -1) {
          text += "현재 인원 ${postEntity!.getPostCurrentPerson()}명";
        } else {
          text += "현재 인원 ${postEntity!.getPostCurrentPerson()} / ${postEntity!.getPostMaxPerson()}";
        }
      } else if (postEntity!.getRequestState(myUuid!) == "accept") {
        text = "[참여 완료]  참가자 보기";
      } else if (postEntity!.getRequestState(myUuid!) == "reject") {
        text = "[참여 거절]  다른 모임도 찾아보세요!";
      } else {
        text = "오류 발생, 문의 부탁드립니다!";
      }
    }
    return text;
  }

  Widget _buildModalSheet(int postId) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(padding: EdgeInsets.all(13), child: buildPostMember(profileEntity!, postEntity!, context)),
      ),
    );
  }

  Widget _showApplyUserList(EntityPost post, StateSetter modalStateSetter) {
    bool hasApplicantsWithStatusZero = post.user?.any((userMap) => userMap['status'] == 0) ?? false;
    return hasApplicantsWithStatusZero
        ? FutureBuilder(
            future: requestUsers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return buildLoadingProgress();
              }
              List<EntityProfiles> requestList = snapshot.data!;
              post.getUser().where((element) => element['status'] == 0);
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 5),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  EntityProfiles userProfile = requestList[index];
                  final color = getColorForScore(userProfile.mannerGroup);
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => BoardProfilePage(profileId: userProfile.profileId)));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                userProfile.profileImagePath,
                                width: 45,
                                height: 45,
                              ),
                              const Padding(padding: EdgeInsets.only(left: 10)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${userProfile.name}",
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const Padding(padding: EdgeInsets.only(top: 4)),
                                  Text(
                                    "${userProfile.major}, ${userProfile.age}세",
                                    style: const TextStyle(color: Color(0xFF777777), fontSize: 13),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "매너 지수 ${userProfile.mannerGroup}점",
                                style: const TextStyle(color: Color(0xFF777777), fontSize: 12),
                              ),
                              SizedBox(
                                  height: 6,
                                  width: 120,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: userProfile.mannerGroup / 100,
                                      valueColor: AlwaysStoppedAnimation<Color>(color),
                                      backgroundColor: color.withOpacity(0.3),
                                    ),
                                  )),
                              SizedBox(
                                width: 120,
                                height: 35,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          _showDialog(userProfile.name, userProfile.profileId, 'accept', postId, modalStateSetter);
                                        },
                                        style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: colorSuccess, minimumSize: Size(0, 25)),
                                        child: Text('수락')),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          _showDialog(userProfile.name, userProfile.profileId, 'reject', postId, modalStateSetter);
                                        },
                                        style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.grey, minimumSize: Size(0, 25)),
                                        child: Text('거절'))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: snapshot.data!.length,
              );
            })
        : Column(
            children: [
              Divider(thickness: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text("신청자가 없어요.", style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
            ],
          );
  }

  Widget _showAcceptUserList(EntityPost post) {
    return FutureBuilder(
      future: acceptUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildLoadingProgress();
        }
        List<EntityProfiles> requestList = snapshot.data!;
        if (!requestList.contains(myProfileEntity!)) {
          requestList.add(myProfileEntity!);
        }
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            EntityProfiles userProfile = requestList[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => BoardProfilePage(profileId: userProfile.profileId)));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              userProfile.profileImagePath,
                              width: 45,
                              height: 45,
                            ),
                            const Padding(padding: EdgeInsets.only(left: 10)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${userProfile.name}",
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Padding(padding: EdgeInsets.only(top: 4)),
                                Text(
                                  "${userProfile.major}, ${userProfile.age}세",
                                  style: const TextStyle(color: Color(0xFF777777), fontSize: 13),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_right, size: 30)
                ],
              ),
            );
          },
          itemCount: snapshot.data!.length,
        );
      },
    );
  }

  _showDialog(String name, String profileId, String status, int postId, StateSetter modalStateSetter) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(30, 20, 20, 30),
        // 다이얼로그의 내용 패딩을 균일하게 조정
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text(status == 'accept' ? '${name}님의 모임 참가를 수락하시겠습니까 ?' : '${name}님의 모임 참가를 거절하시겠습니까 ?', style: TextStyle(fontSize: 16)),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (isRequestLoading) return;
                      isRequestLoading = true;
                      Navigator.of(context).pop();
                      if (status == 'accept') {
                        await _acceptRequest(profileId, postId);
                      }
                      if (status == 'reject') {
                        await _rejectRequest(profileId, postId);
                      }
                      await _loadPost(isReload: true).then((value) {
                        modalStateSetter(() {
                          isRequestLoading = false;
                        });
                      });
                    },
                    child: Text('예'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                      minimumSize: Size(50, 30),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('아니오'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                      minimumSize: Size(50, 30),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acceptRequest(String profileId, int postId) async {
    EntityPost? postEntity;
    EntityProfiles? profileEntity;

    postEntity = EntityPost(postId);
    await postEntity.acceptToPost(profileId);
    profileEntity = EntityProfiles(profileId);
    await profileEntity.addGroupId(postId);

    return;
  }

  Future<void> _rejectRequest(String profileId, int postId) async {
    EntityPost? postEntity;
    postEntity = EntityPost(postId);
    await postEntity.rejectToPost(profileId);

    return;
    // post 객체의 user에 해당 id의 status를 2로 변경
  }

  StatefulBuilder buildPostMember(EntityProfiles profiles, EntityPost post, BuildContext context) {
    return StatefulBuilder(builder: (BuildContext context, StateSetter modalState) {
      return Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  height: 30,
                  width: 30,
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "신청자 관리",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 30),
            ],
          ),
          _showApplyUserList(post, modalState),
          Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              "참가자 현황",
              style: TextStyle(color: Colors.black, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Divider(thickness: 1),
          _showAcceptUserList(post),
        ],
      );
    });
  }
}

Widget drawProfile(EntityProfiles profileEntity, BuildContext context) {
  final color = getColorForScore(profileEntity.mannerGroup);
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => BoardProfilePage(profileId: profileEntity.profileId)));
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              profileEntity.profileImagePath,
              width: 45,
              height: 45,
            ),
            const Padding(padding: EdgeInsets.only(left: 10)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${profileEntity.name}",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Padding(padding: EdgeInsets.only(top: 4)),
                Text(
                  "${profileEntity.major}, ${profileEntity.age}세",
                  style: const TextStyle(color: Color(0xFF777777), fontSize: 13),
                )
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 7, top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "매너 지수 ${profileEntity.mannerGroup}점",
                style: const TextStyle(color: Color(0xFF777777), fontSize: 12),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 2),
              ),
              SizedBox(
                  height: 6,
                  width: 105,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: profileEntity.mannerGroup / 100,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      backgroundColor: color.withOpacity(0.3),
                    ),
                  ))
            ],
          ),
        )
      ],
    ),
  );
}

Column buildPostContext(EntityPost post, EntityProfiles profiles, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(post.getPostHead(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: const Color(0xFFBFBFBF)),
                child: Padding(
                  padding: EdgeInsets.only(right: 5, left: 5, top: 3, bottom: 3),
                  child: Text(post.getCategory(), style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 1, right: 1),
              ),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: const Color(0xFFBFBFBF)),
                child: Padding(
                  padding: EdgeInsets.only(right: 5, left: 5, top: 3, bottom: 3),
                  child: Text(getGenderText(post), style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 1, right: 1),
              ),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: const Color(0xFFBFBFBF)),
                child: Padding(
                  padding: EdgeInsets.only(right: 5, left: 5, top: 3, bottom: 3),
                  child: Text(getAgeText(post), style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 1, right: 1),
              ),
            ],
          )
        ],
      ),

      const Padding(
        padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
        child: Divider(
          thickness: 1,
        ),
      ),
      drawProfile(profiles, context),
      // 프로필
      const Padding(
        padding: EdgeInsets.fromLTRB(0, 4, 0, 12),
        child: Divider(
          thickness: 1,
        ),
      ),
      Text(post.getPostBody(), style: const TextStyle(fontSize: 15)),
      // 내용
      const Padding(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
      ),
      Text("조회수 ${post.getViewCount()}, ${getTimeBefore(post.getUpTime())}", style: const TextStyle(fontSize: 12.5, color: Color(0xFF888888))),
      // 조회수 및 게시글 시간
      const Padding(
        padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
        child: Divider(
          thickness: 1,
        ),
      ),
      // const Text("모임 장소 및 시간",
      //     style: TextStyle(
      //         fontWeight: FontWeight.bold, fontSize: 16)),
      const Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
      ),
      Text("시간 : ${getMeetTimeText(post)}"),
      Text("장소 : ${post.getLLName().AddressName}"),
      SizedBox(
        height: 20,
      ),
    ],
  );
}
