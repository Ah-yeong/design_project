import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:design_project/Entity/EntityLatLng.dart';
import 'package:design_project/Entity/EntityPost.dart';

import 'Meeting.dart';

class MeetingManager {
  // Meeting(this._meetTime, this._memberUuids, this._meetLocation, this._isVoluntary)
  CollectionReference _instance = FirebaseFirestore.instance.collection("Meetings");

  Meeting convertPostToMeet(EntityPost post) {
    return Meeting(post.getPostId(), DateTime.parse(post.getTime()), post.getCompletedMembers()..insert(0, post.getWriterId()), post.getLLName(), post.isVoluntary());
  }
  
  Future<void> uploadMeeting(Meeting meeting) async {
    DocumentReference reference = meeting.getMeetingDocument();
    await reference.get().then((ds) async {
      await meeting.upload(init: ds.exists ? false : true);
    });
  }
  
  Future<Meeting?> getMeeting(int meetingId) async {
    DocumentReference reference = _instance.doc(meetingId.toString());
    Meeting? MeetingData;
    await reference.get().then((ds) async {
      if (ds.exists) {
        MeetingData = Meeting(meetingId, (ds.get("meetTime") as Timestamp).toDate(), ds.get("members").cast<String>(), LLName.fromJson(ds.get("location")), ds.get("isVoluntary"));
      }
    });
    return MeetingData;
  }
}