import 'package:design_project/meeting/meeting_evaluate.dart';
import 'package:design_project/meeting/models/Evaluated_meeting_manager.dart';
import 'package:design_project/meeting/models/evaluation_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../entity/profile.dart';
import '../meeting/models/evaluatedMeeting.dart';
import '../resources/loading_indicator.dart';
import '../resources/resources.dart';

class PageMyEndGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageMyEndGroup();
}

class _PageMyEndGroup extends State<PageMyEndGroup> {
  EntityProfiles? myProfile;
  List<EvaluatedMeeting> myEndMeetingList = [];
  Map<String, List<EvaluatedMeeting>> _groupedMeetings = {};
  bool _isLoadingPost = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "종료된 모임",
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
        body: !_isLoadingPost ? buildLoadingProgress()
          : myEndMeetingList.length != 0 ?
            SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _groupedMeetings.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final dateKey = _groupedMeetings.keys.elementAt(index);
                  final meetings = _groupedMeetings[dateKey];
                  return Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 3),
                          Text(
                            dateKey,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Divider(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      // isOverDeadline(DateAddThreeDays(dateKey)) ?
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(7, 10, 7, 7),
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(vertical: 6.0),
                      //     width: double.infinity,
                      //     decoration: BoxDecoration(
                      //         color: const Color(0xFFEAEAEA),
                      //         borderRadius: BorderRadius.circular(8)),
                      //     child: Center(
                      //         child: Text("${DateAddThreeDays(dateKey)} 까지 평가 가능")),
                      //   ),
                      // ) : Container(),
                      Column(
                        children: meetings!.map((meeting) {
                          return Container(
                            child: GestureDetector(
                              onTap: () {
                                // 모임 채팅방으로 이동해야 되나 ?
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(7, 7, 7, 0),
                                child: meeting.buildEndMeetingCard(),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              )
            )
            : Center (
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("아직 종료된 모임이 없습니다.",
                      style: TextStyle(color: colorGrey),)
                  ],
                ),
              )
    );
  }

  @override
  void initState() {
    super.initState();
    var evalMeetingManager = EvaluatedMeetingManager();
    evalMeetingManager.getUserEndMeetingData(FirebaseAuth.instance.currentUser!.uid).then((meetingList) async {
      Future.forEach(meetingList, (meetingId) async {
        await evalMeetingManager.getEvaluatedMeeting(meetingId).then((meeting) {
          if (meeting != null) myEndMeetingList.add(meeting);
          if (meetingList.length == myEndMeetingList.length) {
            myEndMeetingList.sort((a, b) =>
                a.getMeetTime().compareTo(b.getMeetTime()));
            Map<String, List<EvaluatedMeeting>> evaluableMeetings = {};
            Map<String, List<EvaluatedMeeting>> notEvaluableMeetings = {};

            for (var meeting in myEndMeetingList) {
              final dateKey = DateFormat('yyyy-MM-dd').format(
                  meeting.getMeetTime());
              if (isOverDeadline(DateAddThreeDays(dateKey))){
                if (!evaluableMeetings.containsKey(dateKey)) {
                  evaluableMeetings[dateKey] = [];
                }
                evaluableMeetings[dateKey]!.add(meeting);
              }
              else{
                if (!notEvaluableMeetings.containsKey(dateKey)) {
                  notEvaluableMeetings[dateKey] = [];
                }
                notEvaluableMeetings[dateKey]!.add(meeting);
              }
            }
            evaluableMeetings.addAll(notEvaluableMeetings);
            setState(() => _groupedMeetings = evaluableMeetings);
          }
        });
      }).then((value) => setState(() => _isLoadingPost = true));
    });
  }

  String DateAddThreeDays(String datakey) {
    DateTime date = DateFormat('yyyy-MM-dd').parse(datakey);
    DateTime addThreeDays = date.add(Duration(days: 3));
    String newDate = DateFormat('yyyy-MM-dd').format(addThreeDays);
    return newDate;
  }

  bool isOverDeadline(String date){
    DateTime deadline = DateFormat('yyyy-MM-dd').parse(date);
    DateTime currentDate = DateTime.now();
    // print("${deadline}, ${currentDate}");
    return currentDate.isBefore(deadline) || currentDate.isAtSameMomentAs(deadline);
  }

}