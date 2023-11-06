import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/meeting/models/evaluated_meeting_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../entity/profile.dart';
import '../meeting/models/evaluated_meeting.dart';
import '../resources/loading_indicator.dart';
import '../resources/resources.dart';

class PageMyEndGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageMyEndGroup();
}

class _PageMyEndGroup extends State<PageMyEndGroup> {
  List<EvaluatedMeeting> myEndMeetingList = [];
  Map<String, List<EvaluatedMeeting>> _groupedMeetings = {};
  bool _isLoadingPost = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "종료된 모임 및 평가",
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
        body: !_isLoadingPost ? buildLoadingProgress()
          : myEndMeetingList.length != 0 ?
            SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _groupedMeetings.length,
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
                      Column(
                        children: meetings!.map((meeting) {
                          return Container(
                            child: GestureDetector(
                              onTap: () {
                                // 모임 채팅방으로 이동해야 될지 여부를 결정하거나 다른 작업을 수행
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 7, 0, 0),
                                child: FutureBuilder<Widget>(
                                  future: meeting.buildEndMeetingCard(),
                                  builder: (context, snapshot) {
                                    if (snapshot.data != null) {
                                      return snapshot.data!;
                                    } else {
                                      return buildLoadingProgress();
                                    }
                                  },
                                ),
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
      CollectionReference reference = FirebaseFirestore.instance.collection("EvaluatedMeetings");
      QuerySnapshot qs = await reference.get();
      List<DocumentSnapshot> evaluatedMeeting = qs.docs;
      evaluatedMeeting.retainWhere((ds) => meetingList.contains(int.parse(ds.reference.id)));
      evaluatedMeeting.forEach((snapshot){
        bool isVoluntary = snapshot.get("isVoluntary");
        Map<String, dynamic> arrivals = isVoluntary ? {} : Map<String, dynamic>.from(snapshot.get("arrivals"));
        EvaluatedMeeting evalMeetingData = EvaluatedMeeting(
            snapshot.get("address"),
            arrivals,
            snapshot.get("isVoluntary"),
            (snapshot.get("meetTime") as Timestamp).toDate(),
            snapshot.get("meetingId"),
            snapshot.get("members").cast<String>(),
            snapshot.get("meetingName")
        );
        myEndMeetingList.add(evalMeetingData);
      });
      myEndMeetingList.sort((a, b) =>
          b.getMeetTime().compareTo(a.getMeetTime()));
      Map<String, List<EvaluatedMeeting>> groupedMeetings = {};

      for (var meeting in myEndMeetingList) {
        final dateKey = DateFormat('yyyy-MM-dd').format(meeting.getMeetTime());
        if (!groupedMeetings.containsKey(dateKey)) {
          groupedMeetings[dateKey] = [];
        }
        groupedMeetings[dateKey]!.add(meeting);
      }
      _isLoadingPost = true;
      setState(() => _groupedMeetings = groupedMeetings);
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