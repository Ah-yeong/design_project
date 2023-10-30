import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/entity/latlng.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../chat/chat_screen.dart';
import '../../resources/resources.dart';
import '../../boards/post_list/post_list.dart';
import '../meeting_evaluate.dart';

class EvaluatedMeeting {
  int _meetingId;
  DateTime _meetTime;
  List<String> _members;
  String _address;
  bool _isVoluntary;
  Map<String, dynamic> _arrivals;

  CollectionReference _meetingInstance = FirebaseFirestore.instance.collection("Meetings");
  CollectionReference _evalMeetingInstance = FirebaseFirestore.instance.collection("EvaluatedMeetings");

  EvaluatedMeeting(this._address, this._arrivals, this._isVoluntary, this._meetTime, this._meetingId, this._members);

  getMeetTime() {return this._meetTime;}

  DocumentReference getMeetingDocument() {
    return _meetingInstance.doc(_meetingId.toString());
  }

  bool isOverDeadline(String date){
    DateTime deadline = DateFormat('yyyy-MM-dd').parse(date).add(Duration(days: 3));
    DateTime currentDate = DateTime.now();
    return currentDate.isBefore(deadline) || currentDate.isAtSameMomentAs(deadline);
  }

  int calculateDeadline(String date){
    DateTime deadline = DateFormat('yyyy-MM-dd').parse(date).add(Duration(days: 3));
    DateTime currentDate = DateTime.now();
    Duration difference = deadline.difference(currentDate);
    int daysRemaining = difference.inDays;
    return daysRemaining;
  }

  Future<bool> isEnd() async {
    DocumentReference evalMeeting = _evalMeetingInstance.doc(_meetingId.toString());
    final documentSnapshot = await evalMeeting.get();
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    if (data["end"] == null || data["end"] is! Map<String, dynamic>) {
      return false;
    }
    Map<String, dynamic> endUser = data["end"];
    if(endUser.containsKey(FirebaseAuth.instance.currentUser!.uid)) {
      if(endUser[FirebaseAuth.instance.currentUser!.uid]) { return true; }
      else { return false; }
    } else {
      return false;
    }
  }

  Future<Widget> buildEndMeetingCard() async {
    String timeText = getMeetTimeText(_meetTime.toString());
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Row(children: [
                      SizedBox(width: 35, child: Icon(CupertinoIcons.person_3_fill)),
                      Text(
                        '$timeText 모임', // 글 제목
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                    ]),
                  ]),
                const Padding(padding: EdgeInsets.only(bottom: 5)),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: colorGrey, size: 13),
                    Text(" ${_address}", style: TextStyle(fontSize: 11, color: Color(0xFF858585))),
                    SizedBox(height: 1),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.emoji_people, color: colorGrey, size: 13),
                    Text(_isVoluntary ? " 자율 참여" : " 위치 공유",
                        style: TextStyle(fontSize: 11, color: Color(0xFF858585))),
                    SizedBox(height: 1),
                  ],
                ),
                SizedBox(height: 5),
              ],
            ),
            await isEnd() ?
            Container(
              width: 90,
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("평가 마감 ", style: TextStyle(color: colorLightGrey, fontWeight: FontWeight.bold, fontSize: 15))
                ],
              ),
            ) :
            isOverDeadline(DateFormat('yyyy-MM-dd').format(_meetTime))?
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.indigoAccent, borderRadius: BorderRadius.circular(10)),
                  width: 90,
                  height: 35,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      overlayColor: MaterialStateProperty.all(Colors.white38),
                      onTap: () {
                        Get.off(() => PageMeetingEvaluate(
                          members: _members,
                          voluntary: _isVoluntary,
                          arrivals: _arrivals,
                          meetingId : _meetingId,
                        ));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("평가하기 ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 15,),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6,),
                calculateDeadline(DateFormat('yyyy-MM-dd').format(_meetTime)) == 0 ?
                Text(
                  '오늘까지 !', // 글 제목
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                  textAlign: TextAlign.right,
                ) :
                Text(
                  '${calculateDeadline(DateFormat('yyyy-MM-dd').format(_meetTime))}일 남음', // 글 제목
                  style: const TextStyle(fontSize: 12, color: colorGrey),
                  textAlign: TextAlign.right,
                )
              ],
            ) : Container(
              width: 90,
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("평가 완료 ", style: TextStyle(color: colorLightGrey, fontWeight: FontWeight.bold, fontSize: 15))
                ],
              ),
            )
          ],
        ),
        Divider(thickness: 1,)
      ],
    );
  }
}
