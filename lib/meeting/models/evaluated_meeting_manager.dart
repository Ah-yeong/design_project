import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/entity/latlng.dart';
import 'package:design_project/entity/entity_post.dart';

import 'evaluated_meeting.dart';
import 'meeting.dart';

class EvaluatedMeetingManager {
  CollectionReference _evalMeetingInstance = FirebaseFirestore.instance.collection("EvaluatedMeetings");
  CollectionReference _userInstance = FirebaseFirestore.instance.collection("UserMeetings");

  Future<List<int>> getUserEndMeetingData(String uuid) async {
    DocumentReference reference = _userInstance.doc(uuid);
    List<int> endMeetingData = [];
    await reference.get().then((snapshot) async {
      try {
        endMeetingData = snapshot.get("endMeetings").cast<int>();
      } catch (e) {}
    });
    return endMeetingData;
  }
}