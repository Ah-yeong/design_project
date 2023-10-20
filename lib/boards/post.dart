import 'dart:async';
import 'package:design_project/chat/chat_screen.dart';
import 'package:design_project/main.dart';
import 'package:design_project/meeting/models/location_manager.dart';
import 'package:design_project/meeting/models/meeting_manager.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:design_project/boards/post_list/page_hub.dart';
import 'package:design_project/boards/post_list/post_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../entity/entity_post.dart';
import '../entity/profile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:design_project/resources/resources.dart';
import '../profiles/profile_view.dart';
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

  bool? isProcessing = Get.arguments;

  var postId;
  EntityPost? postEntity;
  EntityProfiles? profileEntity;
  bool isLoaded = false;
  bool isRequestLoading = true;
  bool isAllLoading = false;
  bool postTimeIsLoaded = false;

  var postTime;
  bool _btnClickDelay = false;
  bool _btnClickDelay_startMeeting = false;
  Size? mediaSize;
  String userID = FirebaseAuth.instance.currentUser!.uid;

  late Future<List<EntityProfiles>> requestUsers;
  late Future<List<EntityProfiles>> acceptUsers;
  List<dynamic> _loadedUserList = [];
  double _completeButtonOpacity = 1;
  Timer? timer;
  StateSetter? modalSetter;

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

  List<String> getAcceptUuids(){
    var acceptProfiles = postEntity!.getUser().where((element) => element['status'] == 1);
    List<String> acceptUuids = [];
    acceptProfiles.forEach((element) => acceptUuids.add(element['id']));
    return acceptUuids;
  }

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        Scaffold(
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
        bottomNavigationBar: !isLoaded
            ? buildLoadingProgress()
            : isProcessing! ? SizedBox() : Container(
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
                        onTap: () async {
                          if (!_btnClickDelay) {
                            _btnClickDelay = true;
                            if (!(postEntity!.isFull() &&
                                    (postEntity!.getRequestState(myUuid!) == "none" || postEntity!.getRequestState(myUuid!) == "wait")) ||
                                isSameId) {
                              await _loadPost(isReload: true).then((loadSuccessful) async {
                                if (!loadSuccessful) return;
                                if (isSameId) {
                                  showModalBottomSheet(
                                          isDismissible: false,
                                          context: context,
                                          isScrollControlled: true,
                                          enableDrag: false,
                                          builder: (BuildContext context) => _buildModalSheet(postEntity!.getPostId()),
                                          backgroundColor: Colors.transparent)
                                      .then((value) => reloadButtonState(() {
                                            timer!.cancel();
                                          }));
                                } else if (postEntity!.getRequestState(myUuid!) == "none") {
                                  if (postEntity!.isFull()) {
                                    showAlert("더 이상 참여할 수 없어요!", context, colorGrey);
                                  } else {
                                    await postEntity!.applyToPost(userID).then((requestSuccess) async {
                                      await _loadPost(isReload: true).then((_) {
                                        setState(() {
                                          if (requestSuccess) {
                                            showAlert("신청이 완료되었어요!", context, colorSuccess);
                                          } else {
                                            showAlert("신청한 적이 있거나, 만료되었어요!", context, colorError);
                                          }
                                        });
                                      });
                                    });
                                  }
                                } else if (postEntity!.getRequestState(myUuid!) == "wait") {
                                  if (postEntity!.isFull()) {
                                    showAlert("이미 인원이 모두 찼어요!", context, colorGrey);
                                  } else {
                                    showAlert("아직 참가 요청이 처리되지 않았어요!", context, colorGrey);
                                  }
                                } else if (postEntity!.getRequestState(myUuid!) == "accept") {
                                  showAlert("참여자를 봅니다.", context, Colors.lightBlueAccent);
                                } else if (postEntity!.getRequestState(myUuid!) == "reject") {
                                  Navigator.of(context).pop();
                                }
                              });
                            }
                            reloadButtonState(() {});
                            Timer(Duration(seconds: 2), () => _btnClickDelay = false);
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
                                        ? postEntity!.isFull()
                                            ? colorGrey
                                            : colorSuccess
                                        : postEntity!.getRequestState(myUuid!) == "wait"
                                            ? postEntity!.isFull()
                                                ? colorGrey
                                                : colorWarning
                                            : postEntity!.getRequestState(myUuid!) == "accept"
                                                ? Colors.indigoAccent
                                                : colorGrey,
                                boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 4.5)]),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  !isSameId && postEntity!.getRequestState(myUuid!) == "none" && !postEntity!.isFull()
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
                      );
                    }),
                  ),
                ),
              ),
        backgroundColor: Colors.white,
        body: !isLoaded
            ? buildLoadingProgress()
            : Stack(children: [
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
                          myLocationButtonEnabled: false,
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
                isRequestLoading ? buildLoadingProgress() : SizedBox(),
              ]),
      ),
        if(isAllLoading) buildContainerLoading(135)
      ]
    );
  }

  @override
  void initState() {
    super.initState();
    isProcessing = isProcessing != null && isProcessing == true;
    postId = widget.postId;
    postEntity = EntityPost(postId, isProcessing: isProcessing);
    _loadPost().then((value) {
      if (!isProcessing!) postEntity!.addViewCount(myUuid!);
      setState(() => isRequestLoading = false);
    });
  }

  Future<bool> _loadPost({bool? isReload}) async {
    try {
      await postEntity!.loadPost().then((value) async {
        if (isReload != true) {
          profileEntity = EntityProfiles(postEntity!.getWriterId());
          await profileEntity!.loadProfile().then((value) {
            _markers.add(Marker(markerId: const MarkerId('1'), draggable: true, onTap: () {}, position: postEntity!.getLLName().latLng));
            _checkWriterId(postEntity!.getWriterId());
            _loadPostTime();
          });
        }
      });

      // 중복 체크
      if(!isProcessing!) {
        List<String> loadedProfileList = [];
        postEntity!.getUser().forEach((element) => loadedProfileList.add(element["id"].toString()));
        if (postEntity!.getUser().length == 0 || _loadedUserList.toString() != postEntity!.getUser().toString()) {
          requestUsers = getRequestProfiles(loadedProfileList);
          acceptUsers = getAcceptProfiles(loadedProfileList);
          _loadedUserList = postEntity!.getUser();
        }
      }
    } catch (e) {
      Navigator.of(context).pop(false);
      Future.delayed(Duration(milliseconds: 350), () => showAlert("게시글이 삭제되었거나, 모임이 이미 완료되었어요!!", navigatorKey.currentContext!, colorError));
      return false;
    }
    return true;
  }

  _setButtonOpacityTimer() {
    if (modalSetter != null && (timer == null || !timer!.isActive)) {
      Timer(Duration(milliseconds: 100), () {
        modalSetter!(() {
          _completeButtonOpacity == 0.7 ? _completeButtonOpacity = 1 : _completeButtonOpacity = 0.7;
        });
      });
      timer = Timer.periodic(Duration(milliseconds: 1100), (timer) {
        if (mounted)
          modalSetter!(() {
            _completeButtonOpacity == 0.7 ? _completeButtonOpacity = 1 : _completeButtonOpacity = 0.7;
          });
      });
    }
  }

  _loadPostTime() {
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
        if (postEntity!.isFull()) {
          text += "  인원이 마감되었어요";
        } else {
          text += "  [신청하기]  ";
          if (postEntity!.getPostMaxPerson() == -1) {
            text += "현재 인원 ${postEntity!.getPostCurrentPerson()}명";
          } else {
            text += "현재 인원 ${postEntity!.getPostCurrentPerson()} / ${postEntity!.getPostMaxPerson()}";
          }
        }
      } else if (postEntity!.getRequestState(myUuid!) == "wait") {
        if (postEntity!.isFull()) {
          text += "  인원이 마감되었어요";
        } else {
          text += "[참가 요청중]  ";
          if (postEntity!.getPostMaxPerson() == -1) {
            text += "현재 인원 ${postEntity!.getPostCurrentPerson()}명";
          } else {
            text += "현재 인원 ${postEntity!.getPostCurrentPerson()} / ${postEntity!.getPostMaxPerson()}";
          }
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
    return StatefulBuilder(builder: (BuildContext context, StateSetter modalState) {
      modalSetter = modalState;
      _setButtonOpacityTimer();
      return Column(
        mainAxisAlignment: postEntity!.isFull() ? MainAxisAlignment.center : MainAxisAlignment.end,
        children: [
          SizedBox(
            height: postEntity!.isFull() ? 40 : 0,
          ),
          Container(
            constraints: BoxConstraints(minHeight: 0, maxHeight: 532),
            margin: EdgeInsets.fromLTRB(8, 20, 8, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
                padding: EdgeInsets.only(top: 13, right: 13, left: 13, bottom: postEntity!.isFull() ? 0 : 13),
                child: buildPostMember(profileEntity!, postEntity!, context, modalState)),
          ),
          postEntity!.isFull()
              ? AnimatedOpacity(
                  opacity: _completeButtonOpacity,
                  duration: Duration(milliseconds: 1000),
                  curve: _completeButtonOpacity == 1.0 ? Curves.easeOutCubic : Curves.easeInCubic,
                  child: GestureDetector(
                    onTap: () async {
                      // 모임 성사
                      if (!_btnClickDelay_startMeeting) {
                        timer?.cancel();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        setState(() {
                          isAllLoading = true;
                        });
                        _btnClickDelay_startMeeting = true;
                        MeetingManager meetManager = MeetingManager();
                        await meetManager.meetingCreate(postEntity!);
                        // if (위치공유 모임이면)
                        List<String> members = getAcceptUuids()..add(myUuid!);
                        LocationManager locManager = LocationManager();
                        await locManager.createShareLocation(postEntity!.getPostId(), postEntity!.getLLName(), members);
                        await postEntity!.postMoveToProcess();
                        Get.to(() => ChatScreen(postId: postEntity!.getPostId(), members: members,), arguments: "initMessageSend");
                        _btnClickDelay_startMeeting = false;
                      }
                    },
                    onDoubleTap: () {},
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 16,
                      margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
                      decoration: BoxDecoration(
                          color: colorSuccess,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(offset: Offset(0, 0.5), blurRadius: 1, spreadRadius: 0.5, color: colorSuccess)]),
                      child: Center(
                        child: Text(
                          "모임 시작하기!",
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      );
    });
  }

  Widget _showApplyUserList(EntityPost post, StateSetter modalStateSetter) {
    bool hasApplicantsWithStatusZero = post.user?.any((userMap) => userMap['status'] == 0) ?? false;
    return hasApplicantsWithStatusZero
        ? Container(
      decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: colorLightGrey))),
            constraints: BoxConstraints(
              maxHeight: 200,
              minHeight: 70,
            ),
            child: FutureBuilder(
                future: requestUsers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return buildLoadingProgress();
                  }
                  List<EntityProfiles> requestList = snapshot.data!;
                  post.getUser().where((element) => element['status'] == 0);
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    physics: requestList.length <= 3 ? NeverScrollableScrollPhysics() : null,
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
                }),
          )
        : Column(
            children: [
              Divider(thickness: 1,height: 2, color: colorLightGrey,),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text("신청자가 없어요", style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
              Divider(thickness: 1, height: 0, color: colorLightGrey),
            ],
          );
  }

  Widget _showAcceptUserList(EntityPost post) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 70,
        maxHeight: post.isFull() ? 300 : 200,
      ),
      decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: colorLightGrey))),
      child: FutureBuilder(
        future: acceptUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoadingProgress();
          }
          List<EntityProfiles> acceptList = snapshot.data!;
          if (!acceptList.contains(myProfileEntity!)) {
            acceptList.add(myProfileEntity!);
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 5),
            shrinkWrap: true,
            physics: acceptList.length <= 3 ? NeverScrollableScrollPhysics() : null,
            itemBuilder: (context, index) {
              EntityProfiles userProfile = acceptList[index];
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
      ),
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
                      backgroundColor: Colors.grey,
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
                      backgroundColor: Colors.grey,
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

    postEntity = EntityPost(postId);
    await postEntity.acceptToPost(profileId);

    var meetingManager = MeetingManager();
    await meetingManager.addMeetingPost(profileId, postId);

    return;
  }

  Future<void> _rejectRequest(String profileId, int postId) async {
    EntityPost? postEntity;
    postEntity = EntityPost(postId);
    await postEntity.rejectToPost(profileId);

    return;
    // post 객체의 user에 해당 id의 status를 2로 변경
  }

  Widget buildPostMember(EntityProfiles profiles, EntityPost post, BuildContext context, StateSetter modalState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
                postEntity!.isFull() ? "모임을 시작해보세요!" : "신청자 관리",
                style: TextStyle(color: Colors.black, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 30),
          ],
        ),
        postEntity!.isFull() ? SizedBox() : Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _showApplyUserList(post, modalState),
        ),
        !postEntity!.isFull() ? Padding(
          padding: const EdgeInsets.all(5.0),
          child:
              Text(
                  "참가자 현황",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
        ) : SizedBox(),
        SizedBox(height: 5,),
        _showAcceptUserList(post),
        SizedBox(height: postEntity!.isFull() ? 3 : 25)
      ],
    );
  }

  @override
  void dispose() {
    if (timer != null && mounted) timer!.cancel();
    super.dispose();
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
      Text("시간 : ${getMeetTimeText(post.getTime())}"),
      Text("장소 : ${post.getLLName().AddressName}"),
      SizedBox(
        height: 20,
      ),
    ],
  );
}
