import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../entity/profile.dart';
import '../resources/loading_indicator.dart';
import '../resources/resources.dart';
import 'models/evaluation_manager.dart';

class PageMeetingEvaluate extends StatefulWidget {
  final List<String>? members;
  final bool voluntary;
  final Map<String, dynamic> arrivals;
  final int meetingId;
  final String meetingName;

  const PageMeetingEvaluate({super.key, required this.members, required this.voluntary, required this.arrivals, required this.meetingId, required this.meetingName});

  @override
  State<StatefulWidget> createState() => _PageMeetingEvaluate(members, voluntary, arrivals, meetingId, meetingName);
}

class _PageMeetingEvaluate extends State<PageMeetingEvaluate> {
  List<String>? members;
  bool voluntary;
  bool _isLoading = true;
  int meetingId;
  Map<String, dynamic> arrivals;
  Map<String, dynamic> notAttendedUser = {};
  String meetingName;

  _PageMeetingEvaluate(this.members, this.voluntary, this.arrivals, this.meetingId, this.meetingName);

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
            title: Text('모임 평가', style: TextStyle(fontSize: 18, color: Colors.black)),
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox(
                height: 55,
                width: 55,
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
              ),
            ),
            backgroundColor: Colors.white,
          ),
            backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    '"${meetingName}" 모임',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Center(
                  child: Text(
                    '모임 구성원에 대한 개별 평가가 가능해요.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Center(
                  child: Text(
                    '평가 점수는 매너점수에 반영돼요\n신중히 평가해주세요!',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                members!.length != 1 ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                  getAvatar(userProfile, 20, nullIcon: Icon(CupertinoIcons.person_fill, color: Colors.white,)),
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
                                        userProfile.name != "탈퇴한 사용자" ? Row(
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
                                        ) : const SizedBox(),
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
                          ListView.separated(
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
                                        getAvatar(userProfile, 20, nullIcon: Icon(CupertinoIcons.person_fill, color: Colors.white,)),
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
                                              userProfile.name != "탈퇴한 사용자" ? Row(
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
                                              ) : const SizedBox(),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        notAttendedUser[userId]
                                            ? ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: colorGrey,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    notAttendedUser[userId] = false;
                                                  });
                                                },
                                                child: Text('참여 취소하기', style: TextStyle(fontSize: 13)),
                                              )
                                            : ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: colorSuccess),
                                                onPressed: () {
                                                  setState(() {
                                                    notAttendedUser[userId] = true;
                                                  });
                                                },
                                                child: Text('참여 인정하기', style: TextStyle(fontSize: 13)),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return const Divider();
                            }
                          )
                        ],
                      ),
                  ],
                ) : SizedBox()
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
                  setState(() {
                    _isLoading = true;
                  });
                  EvaluationManager manager = EvaluationManager();
                  await manager.evaluation(members, scores, notAttendedUser, arrivals, meetingId); // notAttendedUser : 참여 인정 -> true
                  setState(() {
                    _isLoading = false;
                  });
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

    getMemberProfiles(members!).then((profileList) async {
      if (profileList.length <= 0) {
        final manager = EvaluationManager();
        await manager.evaluationEnd(meetingId);
        Navigator.of(context).pop();
        showAlert("평가할 구성원이 없어요", context, colorGrey);
        return;
      }
      for (String uuid in profileList.keys) {
        if(uuid != FirebaseAuth.instance.currentUser!.uid){
          if (voluntary) {
            userProfileList.add(profileList[uuid]!);
          } else {
            if (arrivals[uuid] == true) {
              attendedProfiles.add(profileList[uuid]!);
            } else {
              notAttendedUser[uuid] = false;
              notAttendedProfiles.add(profileList[uuid]!);
            }
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
    List<String> removeUuidList = [];
    for (String uuid in uuids) {
      if (uuid != FirebaseAuth.instance.currentUser!.uid) {
        EntityProfiles profiles = EntityProfiles(uuid);
        await profiles.loadProfile();
        if(!profiles.isValid) {
          removeUuidList.add(uuid);
        } else {
          profileList[uuid] = profiles;
        }
      }
    }
    members!.removeWhere((element) => removeUuidList.contains(element));
    return profileList;
  }
}
