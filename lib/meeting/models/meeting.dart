import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/entity/latlng.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../chat/chat_screen.dart';
import '../../resources/resources.dart';
import '../../boards/post_list/post_list.dart';

class Meeting {
  int _meetingId;
  String _organizerUuid;
  DateTime _meetTime;
  List<String> _memberUuids;
  LLName _meetLocation;
  bool _isVoluntary;

  CollectionReference _meetingInstance = FirebaseFirestore.instance.collection("Meetings");
  CollectionReference _userInstance = FirebaseFirestore.instance.collection("UserMeetings");

  Meeting(this._meetingId, this._meetTime, this._memberUuids, this._meetLocation, this._isVoluntary, this._organizerUuid);

  DocumentReference getMeetingDocument() {
    return _meetingInstance.doc(_meetingId.toString());
  }

  Future<void> upload({required bool? init}) async {
    if (init!) {
      await getMeetingDocument()
          .set({"id": _meetingId, "meetTime": _meetTime, "members": _memberUuids, "location": _meetLocation.toJson(), "isVoluntary": _isVoluntary, "organizerUuid" : _organizerUuid});
    }
    await uploadMembers();
  }

  Future<void> uploadMembers() async {
    _memberUuids.forEach((uuid) async {
      await _userInstance.doc(uuid).get().then((snapshot) async {
        DocumentReference reference = _userInstance.doc(uuid);
        if (snapshot.exists) {
          await reference.update({
            "meetings": FieldValue.arrayUnion([_meetingId])
          }).then((value) {}, onError: (e) => print(e));
        } else {
          await reference.set({
            "meetings": [_meetingId],
            "meetingPost": []
          });
        }
      });
    });
  }

  // 모임에 있는 유저들의 해당 meetingPost 삭제
  Future<void> removeUserMeetingPosts() async {
    Future.forEach(_memberUuids, (uuid) {
      DocumentReference reference = _userInstance.doc(uuid);
      FirebaseFirestore.instance.runTransaction((transaction) => transaction.get(reference).then((snapshot) async {
            transaction.update(reference, {
              "meetingPost": FieldValue.arrayRemove([_meetingId])
            });
          }));
    });
  }

  // 내가 속한 모임에 표시될 Row
  Widget buildMeetingCard() {
    String timeText = getMeetTimeText(_meetTime.toString());

    // 모임이 이루어지기 전인지 후인지 분류
    bool isCompleted = timeText.contains("전");

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // 모임 채팅방으로 이동
        Get.off(() => ChatScreen(
          postId: _meetingId,
          members: _memberUuids,
        ));
      },
      child: Row(
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
                      '$timeText 모임', // 글 제목
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
                  Text(" ${_meetLocation.AddressName}", style: TextStyle(fontSize: 11, color: Color(0xFF858585))),
                  SizedBox(height: 1),
                ],
              ),
              SizedBox(height: 5),
            ],
          ),
          isCompleted
              ? Container(
                  decoration: BoxDecoration(color: Colors.indigoAccent, borderRadius: BorderRadius.circular(10)),
                  width: 90,
                  height: 35,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      overlayColor: MaterialStateProperty.all(Colors.white38),
                      onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("평가하기 ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 15,),
                          ],
                        ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text("모임 인원 ${_memberUuids.length}명", style: const TextStyle(color: colorGrey, fontSize: 13)),
                    ),
                    Icon(Icons.arrow_forward_ios),
                  ],
                )
        ],
      ),
    );
  }

  void printMeeting() {
    print(
        "\n--------- [Debug] --------- \nid : $_meetingId\nmeetTime : $_meetTime\nmembers : $_memberUuids\nlocation : ${_meetLocation.AddressName}\n---------------------------");
  }
}
