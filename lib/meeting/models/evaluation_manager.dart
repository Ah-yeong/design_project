import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'evaluation.dart';

class EvaluationManager {
  CollectionReference _meetingInstance = FirebaseFirestore.instance.collection("EvaluatedMeetings");

  Future<void> evaluation(members, score, notAttendedUser, arrivals, meetingId) async {
    Evaluation newEvaluation = convertScoreToUserId(score);
    await newEvaluation.upload();
    await newEvaluation.count(meetingId, notAttendedUser, CountArrivalsTrue(arrivals));
    await updateMannerGroup(score);
    await evaluationEnd(meetingId);
    return;
  }

  int CountArrivalsTrue(Map<String, dynamic> arrivals){
    arrivals.removeWhere((key, value) => value == false);
    return arrivals.length;
  }

  Evaluation convertScoreToUserId(score) {
    List<String> userIds = score.keys.toList();
    return Evaluation(userIds);
  }

  Future<void> updateMannerGroup(score) async {
    Evaluation newEvaluation = convertScoreToUserId(score);
    await newEvaluation.updateMannerGroup(score);
  }

  Future<void> evaluationEnd(meetingId) async {
    DocumentReference meetingDocument = _meetingInstance.doc(meetingId.toString());
    final documentSnapshot = await meetingDocument.get();
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    if (data["end"] == null || data["end"] is! Map<String, dynamic>) {
      data["end"] = {};
    }
    data["end"][FirebaseAuth.instance.currentUser!.uid] = true;
    await meetingDocument.set(data);
  }

}