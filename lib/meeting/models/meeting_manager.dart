import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/entity/latlng.dart';
import 'package:design_project/entity/entity_post.dart';

import 'meeting.dart';

class MeetingManager {
  // Meeting(this._meetTime, this._memberUuids, this._meetLocation, this._isVoluntary)
  CollectionReference _meetingInstance = FirebaseFirestore.instance.collection("Meetings");
  CollectionReference _userInstance = FirebaseFirestore.instance.collection("UserMeetings");

  // 게시물을 모임 객체로 전환
  Meeting convertPostToMeet(EntityPost post) {
    return Meeting(post.getPostId(), DateTime.parse(post.getTime()), post.getCompletedMembers()..insert(0, post.getWriterId()), post.getLLName(), post.isVoluntary(), post.getWriterId());
  }

  // 모임 결성 ( meetingPost 삭제, meetings 추가 )
  Future<void> meetingCreate(EntityPost post) async {
    Meeting newMeeting = convertPostToMeet(post);
    await uploadMeeting(newMeeting);
    await removeMeetingPost(meeting: newMeeting);
    return;
  }

  // UserMeetings 에 meetingPost 추가
  Future<void> addMeetingPost(String uuid, int postId) async { // postId == meetingId
    DocumentReference reference = _userInstance.doc(uuid);
    await reference.get().then((snapshot) async {
      if (!snapshot.exists) {
        await reference.set({"meetings" : [], "meetingPost" : [postId]});
      } else {
        await reference.update({"meetingPost" : FieldValue.arrayUnion([postId])});
      }
    });
  }

  // Meeting 에 대한 meetingPost 삭제
  Future<void> removeMeetingPost({int? meetingId, Meeting? meeting}) async {
    if ( meeting == null && meetingId == null ) return;
    Meeting? _meeting = meeting == null ? await getMeeting(meetingId!) : meeting;

    if ( _meeting == null ) return;
    _meeting.removeUserMeetingPosts();
  }

  // 성사된 모임 또는 게시글에 포함된 모임 목록 가져오기
  // [isMeetingPost] true : 게시글에 포함된 모임, false : 성사된 모임
  Future<List<int>> getUserMeetingData(String uuid, {required bool isMeetingPost}) async {
    DocumentReference reference = _userInstance.doc(uuid);
    List<int> meetingData = [];
    await reference.get().then((snapshot) async {
      try {
        meetingData = snapshot.get(isMeetingPost ? "meetingPost" : "meetings").cast<int>();
      } catch (e) {}
    });
    return meetingData;
  }


  // 모임(Meeting) 객체 업로드
  Future<void> uploadMeeting(Meeting meeting) async {
    DocumentReference reference = meeting.getMeetingDocument();
    await reference.get().then((ds) async {
      await meeting.upload(init: ds.exists ? false : true);
    });

  }

  // DB에서 모임(Meeting) 객체 가져오기
  Future<Meeting?> getMeeting(int meetingId) async {
    DocumentReference reference = _meetingInstance.doc(meetingId.toString());
    Meeting? MeetingData;
    await reference.get().then((snapshot) async {
      if (snapshot.exists) {
        MeetingData = Meeting(
            meetingId, (snapshot.get("meetTime") as Timestamp).toDate(),
            snapshot.get("members").cast<String>(),
            LLName.fromJson(snapshot.get("location")),
            snapshot.get("isVoluntary"),
            snapshot.get("organizerUuid")
        );
      }
    });
    return MeetingData;
  }
}