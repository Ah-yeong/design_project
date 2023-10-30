import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'evaluation.dart';

class EvaluationManager {
  CollectionReference _meetingInstance = FirebaseFirestore.instance.collection("EvaluatedMeetings");

  Future<void> evaluationCreate(members, score, notAttendedUser, meetingId) async {
    Evaluation newEvaluation= convertScoreToUserId(score);
    await uploadUser(newEvaluation);
    await uploadCount(Evaluation(members), notAttendedUser, meetingId);
    return;
  }

  Evaluation convertScoreToUserId(score) {
    List<String> userIds = score.keys.toList();
    return Evaluation(userIds);
  }

  Evaluation convertNotAttendedUserToEval(notAttendedUser) {
    List<String> userIds = notAttendedUser.keys.toList();
    return Evaluation(userIds);
  }

  Future<void> uploadUser(Evaluation evaluation) async {
    DocumentReference reference = evaluation.getEvaluationDocument();
    await reference.get().then((ds) async {
      await evaluation.upload();
    });
  }

  Future<void> uploadCount(Evaluation evaluation, notAttendedUser, meetingId) async {
    DocumentReference reference = evaluation.getEvaluationDocument();
    await reference.get().then((ds) async {
      await evaluation.count(meetingId, notAttendedUser);
    });
  }

  Future<void> updateMannerGroup(score) async {
    Evaluation newEvaluation= convertScoreToUserId(score);
    DocumentReference reference = newEvaluation.getEvaluationDocument();
    await reference.get().then((ds) async {
      await newEvaluation.updateMannerGroup(score);
    });
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