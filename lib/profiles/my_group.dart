import 'package:design_project/meeting/models/meeting.dart';
import 'package:design_project/meeting/models/meeting_manager.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../boards/post.dart';
import '../entity/entity_post.dart';
import '../entity/profile.dart';

import '../resources/resources.dart';
import '../boards/post_list/page_hub.dart';
import '../boards/post_list/post_list.dart';

class PageMyGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageMyGroup();
}

class _PageMyGroup extends State<PageMyGroup> {
  List<EntityPost> myGroupList = List.empty(growable: true);
  List<Meeting> myMeetingList = [];

  bool _isLoadingPost = true;
  bool _isLoadingMeeting = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "진행 예정 모임",
          style: TextStyle(color: Colors.black, fontSize: 19),
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
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: (_isLoadingPost || _isLoadingMeeting)
          ? buildLoadingProgress()
          : (myGroupList.length != 0 || myMeetingList.length != 0)
              ? SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: const Color(0xFFEAEAEA),
                            boxShadow: [BoxShadow(offset: Offset(0, 0.5), blurRadius: 0.5, color: Colors.grey)],
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Text("성사된 모임 및 계획")),
                      ),
                    ),
                    myMeetingList.length != 0
                        ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: myMeetingList
                            .map((meeting) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), child: meeting.buildMeetingCard()))
                            .toList(),
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text("대기중인 모임이 없어요", style: TextStyle(color: colorGrey, fontSize: 11)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: const Color(0xFFEAEAEA),
                            boxShadow: [BoxShadow(offset: Offset(0, 0.5), blurRadius: 0.5, color: Colors.grey)],
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Text("모임 성사 대기중")),
                      ),
                    ),
                    myGroupList.length != 0
                        ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: myGroupList.map((group) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                SizedBox(height: 5,),
                                Container(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => BoardPostPage(postId: group.getPostId()),
                                      ));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(7),
                                      child: _buildPostCard(group),
                                    ),
                                  ),
                                ),
                                Divider(thickness: 1, height: 0, color: colorLightGrey),
                              ],
                            )
                          );
                        }).toList(),
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25.0),
                      child: Text("대기중인 모임이 없어요", style: TextStyle(color: colorGrey, fontSize: 13)),
                    ),
                  ]),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "모임이 없어요\n",
                        style: TextStyle(color: colorGrey, fontSize: 13),
                      ),
                      Text("지금 바로 모임에 참여해보세요!")
                    ],
                  ),
                ),
    );
  }

  @override
  void initState() {
    super.initState();
    var meetingManager = MeetingManager();
    meetingManager.getUserMeetingData(myUuid!, isMeetingPost: true).then((postList) async {
      Future.forEach(postList, (postId) async {
        var myGroup = EntityPost(postId);
        await myGroup.loadPost().then((value) => myGroupList.add(myGroup));
      }).then((value) => setState(() => _isLoadingPost = false));
    });
    meetingManager.getUserMeetingData(myUuid!, isMeetingPost: false).then((meetingList) async {
      Future.forEach(meetingList, (meetingId) async {
        await meetingManager.getMeeting(meetingId).then((meeting) {
          if (meeting != null) myMeetingList.add(meeting);
        });
      }).then((value) => setState(() => _isLoadingMeeting = false));
    });
  }

  Widget _buildPostCard(EntityPost entity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Row(children: [
                  SizedBox(width: 35, child: Icon(CupertinoIcons.person_3_fill)),
                  Text(
                    '${entity.getPostHead()}', // 글 제목
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                ]),
              ]),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 5)),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: colorGrey, size: 13),
                Text(" ${entity.getLLName().AddressName}", style: TextStyle(fontSize: 11, color: Color(0xFF858585))),
                SizedBox(height: 1),
              ],
            ),
            SizedBox(height: 5),
          ],
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(getMeetTimeText(entity.getTime())+" 모임", style: const TextStyle(color: colorGrey, fontSize: 13)),
            ),
            Icon(Icons.arrow_forward_ios),
          ],
        )
      ],
    );
  }
}
