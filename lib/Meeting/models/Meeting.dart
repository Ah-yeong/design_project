import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/Entity/EntityLatLng.dart';

class Meeting {
  int _meetingId;
  DateTime _meetTime;
  List<String> _memberUuids;
  LLName _meetLocation;
  bool _isVoluntary;

  CollectionReference _instance = FirebaseFirestore.instance.collection("Meetings");

  Meeting(this._meetingId, this._meetTime, this._memberUuids, this._meetLocation, this._isVoluntary);

  DocumentReference getMeetingDocument() {
    return _instance.doc(_meetingId.toString());
  }

  Future<void> upload({required bool? init}) async {
    if (init!) {
      await getMeetingDocument().set({
       "id" : _meetingId,
        "meetTime" : _meetTime,
        "members" : _memberUuids,
        "location" : _meetLocation.toJson(),
        "isVoluntary" : _isVoluntary
      });
    }
  }

  void printMeeting() {
    print("\n--------- [Debug] --------- \nid : $_meetingId\nmeetTime : $_meetTime\nmembers : $_memberUuids\nlocation : ${_meetLocation.AddressName}\n---------------------------");
  }
}