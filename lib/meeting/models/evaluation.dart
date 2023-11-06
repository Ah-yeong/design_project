import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Evaluation{
  List<String> _evaluatedUsers;
  CollectionReference _evaluationInstance = FirebaseFirestore.instance.collection("Evaluation");
  CollectionReference _userProfileInstance = FirebaseFirestore.instance.collection("UserProfile");

  Evaluation(this._evaluatedUsers);

  DocumentReference getEvaluationDocument() {
    return _evaluationInstance.doc(FirebaseAuth.instance.currentUser!.uid);
  }

  bool isDateUpdate(String existingDate, DateTime now){
    DateTime addSevenDays = DateFormat('yyyy-MM-dd').parse(existingDate).add(Duration(days: 7));
    return now.isAfter(addSevenDays);
  }

  Future<void> upload() async {
    DateTime now = DateTime.now();
    String currentTime = now.toLocal().toString();

    for (String uid in _evaluatedUsers) {
      DocumentReference evalDocument = _evaluationInstance.doc(uid);

      final documentSnapshot = await evalDocument.get();
      if (!documentSnapshot.exists) {
        await evalDocument.set({"users": {FirebaseAuth.instance.currentUser!.uid: [currentTime]}});
      } else {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        if(data["users"] == null) {
          await evalDocument.update({"users": {FirebaseAuth.instance.currentUser!.uid: [currentTime]}});
        } else {
          Map<String, dynamic> usersData = data["users"];

          if (usersData.containsKey(FirebaseAuth.instance.currentUser!.uid)) {
            List<dynamic> timestamps = List.from(usersData[FirebaseAuth.instance.currentUser!.uid])..add(currentTime);
            usersData[FirebaseAuth.instance.currentUser!.uid] = timestamps;
          } else {
            usersData[FirebaseAuth.instance.currentUser!.uid] = [currentTime];
          }
          data["users"] = usersData;
          await evalDocument.update(data);
        }
      }
    }
  }

  Future<void> count(int meetingId, Map<String, dynamic> notAttendedUser, int memberCount) async {
    for (String uid in notAttendedUser.keys) {
      if(notAttendedUser[uid] == true){
        DocumentReference evalDocument = _evaluationInstance.doc(uid);
        final userSnapshot = await evalDocument.get();
        if(userSnapshot.exists) {
          final userData = userSnapshot.data() as Map<String, dynamic>;
          if(userData["meetings"] != null) {  // meetings 있음
            final meetingsData = userData["meetings"];
            Map<String, dynamic> meetingData = {};
            if(meetingsData.containsKey(meetingId.toString())) { // meetings에 meetingId 있음
              meetingData = meetingsData[meetingId.toString()];
              meetingData["count"] = meetingData["count"] + 1;
            } else { // meetings에 meetingId 없음
              meetingData[meetingId.toString()] = {};
              meetingData["count"] = 1;
              meetingData["memberCount"] = memberCount;
            }

            if(meetingData["count"] == meetingData["memberCount"]){
              resetMannerGroup(uid);
            }

            meetingsData[meetingId.toString()] = meetingData;
            userData["meetings"] = meetingsData;
            await evalDocument.set(userData);
          } else {  // meetings 없음 user는 있을수도 ?
            userData.addAll({"meetings": {meetingId.toString(): {"count": 1, "memberCount" : memberCount}}});
            await evalDocument.set(userData);
          }
        } else {
          await evalDocument.set({"meetings": {meetingId.toString(): {"count": 1, "memberCount" : memberCount}}});
        }
      }
    }
  }

  Future<void> resetMannerGroup(uid) async {
    DocumentReference userDocument = _userProfileInstance.doc(uid);
    var documentSnapshot = await userDocument.get();
    Map<String, dynamic> userProfile = documentSnapshot.data() as Map<String, dynamic>;
    userProfile["mannerGroup"] = userProfile["mannerGroup"] + 3; // 불참시 마이너스 된 매너 지수 회복 ex) 3점
    if(userProfile["mannerGroup"] > 100) { userProfile["mannerGroup"] = 100; }
    userDocument.update(userProfile);
  }

  Future<void> updateMannerGroup(score) async {
    for (String uid in _evaluatedUsers) {
      DocumentReference userDocument = _userProfileInstance.doc(uid);
      DocumentReference evalDocument = _evaluationInstance.doc(uid);

      var documentSnapshot = await userDocument.get();
      Map<String, dynamic> userProfile = documentSnapshot.data() as Map<String, dynamic>;
      num mannerGroup = userProfile["mannerGroup"];

      documentSnapshot = await evalDocument.get();
      Map<String, dynamic> evaluation = documentSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> usersEval= evaluation["users"];

      int count = usersEval[FirebaseAuth.instance.currentUser!.uid].length;
      double newScore = getNewScore(score[uid]);
      double countRate = (100 - ((count-1)*30)) / 100;
      if (countRate < 0) { countRate = 0; }
      double rate = 1 / score.length;

      num newMannerGroup = mannerGroup + (newScore-3) * countRate * 0.5 * rate;
      if(newMannerGroup > 100){ newMannerGroup = 100; }
      userProfile["mannerGroup"]  = double.parse(newMannerGroup.toStringAsFixed(2));
      userDocument.update(userProfile);
    }
  }

  double getNewScore(int score) {
    if (score == 1) {
      return 0;
    } else if (score == 2) {
      return 2;
    } else if (score == 3) {
      return 3.5;
    } else if (score == 4) {
      return 5;
    } else {
      return 7;
    }
  }
}