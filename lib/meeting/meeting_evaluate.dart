import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../Boards/post_list/page_hub.dart';
import '../Profiles/completed_group.dart';
import '../entity/profile.dart';
import '../resources/loading_indicator.dart';
import '../resources/resources.dart';
import 'models/evaluation.dart';
import 'models/evaluation_manager.dart';

class PageMeetingEvaluate extends StatefulWidget {
  final List<String>? members;
  final bool voluntary;
  final Map<String, dynamic> arrivals;
  final int meetingId;

  const PageMeetingEvaluate({super.key, required this.members, required this.voluntary, required this.arrivals, required this.meetingId});

  @override
  State<StatefulWidget> createState() => _PageMeetingEvaluate(members, voluntary, arrivals, meetingId);
}

class _PageMeetingEvaluate extends State<PageMeetingEvaluate> {
  List<String>? members;
  bool voluntary;
  bool isAttending = false;
  bool _isLoading = true;
  int meetingId;
  Map<String, dynamic> arrivals;
  Map<String, dynamic> notAttendedUser = {};

  _PageMeetingEvaluate(this.members, this.voluntary, this.arrivals, this.meetingId);

  List<EntityProfiles> userProfileList = [];
  List<EntityProfiles> attendedProfiles = [];
  List<EntityProfiles> notAttendedProfiles = [];

  Map<String, int> scores = {}; // 각 사람의 점수를 저장할 맵

  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: const Text('모임 평가', style: TextStyle(fontSize: 18, color: Colors.black)),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                '모임 구성원에 대한 개별 평가가 가능해요.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                '평가 점수는 매너점수에 반영되니,\n신중하게 평가해주세요.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  if (!voluntary && attendedProfiles.length != 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(7, 10, 7, 7),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        width: double.infinity,
                        decoration: BoxDecoration(color: const Color(0xFFEAEAEA), borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Text("참석인원")),
                      ),
                    ),
                  if (voluntary || (!voluntary && attendedProfiles.length != 0))
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: voluntary ? userProfileList.length : attendedProfiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        EntityProfiles? userProfile = voluntary ? userProfileList[index] : attendedProfiles[index];
                        String userId = userProfile.profileId;
                        if (!scores.containsKey(userId)) {
                          scores[userId] = 5; // 클릭하지 않았을 때 기본값으로 5 설정
                        }
                        int? score = scores[userId];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Row(
                              children: <Widget>[
                                SizedBox(width: 5),
                                getAvatar(userProfile, 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      SizedBox(height: 6),
                                      Text(
                                        userProfile.name,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Text(
                                            userProfile.major,
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            " (${userProfile.age})",
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (i) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      scores[userId] = i + 1;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    child: Icon(
                                      i < score! ? Icons.star : Icons.star_border,
                                      color: Colors.yellow,
                                      size: 25,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider();
                      },
                    ),
                  if (!voluntary && notAttendedProfiles.isNotEmpty)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(7, 10, 7, 7),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            width: double.infinity,
                            decoration: BoxDecoration(color: const Color(0xFFEAEAEA), borderRadius: BorderRadius.circular(8)),
                            child: Center(child: Text("미참석인원")),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: notAttendedProfiles.length,
                          itemBuilder: (BuildContext context, int index) {
                            EntityProfiles? userProfile = notAttendedProfiles[index];
                            String userId = userProfile.profileId;
                            return Column(
                              children: [
                                ListTile(
                                  title: Row(
                                    children: <Widget>[
                                      SizedBox(width: 5),
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage('https://picsum.photos/id/237/200/300'),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            SizedBox(height: 6),
                                            Text(
                                              userProfile?.name,
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Text(
                                                  userProfile?.major,
                                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  " (${userProfile?.age})",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      isAttending
                                          ? ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  isAttending = false;
                                                  notAttendedUser[userId] = false;
                                                });
                                              },
                                              child: Text('참여 취소하기', style: TextStyle(fontSize: 13)),
                                            )
                                          : ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF6ACA9A)),
                                              onPressed: () {
                                                setState(() {
                                                  isAttending = true;
                                                  notAttendedUser[userId] = true;
                                                });
                                              },
                                              child: Text('참여 인정하기', style: TextStyle(fontSize: 13)),
                                            ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                  child: Divider(thickness: 1, height: 1),
                                )
                              ],
                            );
                          },
                        )
                      ],
                    ),
                ],
              )
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              child: Text(
                '저장',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Color(0xFF6ACA9A),
              ),
              onPressed: () async {
                EvaluationManager manager = EvaluationManager();
                print(notAttendedUser); // 이거 왜 notAttendedUser이 적용이 안되는지 모르겟음
                // await manager.evaluationCreate(members, scores, notAttendedUser, meetingId);
                // await manager.updateMannerGroup(scores);
                // await manager.evaluationEnd(meetingId);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
        if (_isLoading) buildContainerLoading(135)
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    getMemberProfiles(members!).then((profileList) {
      for (String uuid in profileList.keys) {
        if (voluntary) {
          userProfileList.add(profileList[uuid]!);
        } else {
          if (arrivals[uuid]) {
            attendedProfiles.add(profileList[uuid]!);
          } else {
            notAttendedUser[uuid] = false;
            notAttendedProfiles.add(profileList[uuid]!);
          }
        }
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<Map<String, EntityProfiles>> getMemberProfiles(List<String> uuids) async {
    Map<String, EntityProfiles> profileList = {};
    for (String uuid in uuids) {
      if (uuid != FirebaseAuth.instance.currentUser!.uid) {
        EntityProfiles profiles = EntityProfiles(uuid);
        await profiles.loadProfile();
        profileList[uuid] = profiles;
      }
    }
    return profileList;
  }
}
