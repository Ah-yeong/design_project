import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/Entity/EntityLatLng.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Chat/ChatScreen.dart';

class EntityPost {
  int _postId;
  var _writerId;
  var _writerNick;
  var _head;
  var _body;
  var _gender;
  var _maxPerson;
  var _currentPerson;
  var _minAge;
  var _maxAge;
  var _time;
  var _llName;
  var _category;

  double _distance = 0.0;

  double get distance => _distance;
  set distance(double value) => _distance = value;

  set llName(value) => _llName = value;

  late String _upTime;
  var viewCount;
  bool _isLoaded = false;
  var user;

  EntityPost(int this._postId) {}

  Future<void> applyToPost(String userId) async {
    try {
      await FirebaseFirestore.instance.collection("Post").doc(_postId.toString()).update({
        "user": FieldValue.arrayUnion([{"id": userId, "status": 0}])
      });
    } catch (e) {
      print("신청 실패: $e");
    }
  }

  Future<void> acceptToPost(String userId) async {
    try {
      var postDoc = await FirebaseFirestore.instance.collection("Post").doc(_postId.toString()).get();
      var users = postDoc.data()?["user"] as List<dynamic>;
      var index = users.indexWhere((user) => user["id"] == userId);

      if (index != -1) {
        users[index]["status"] = 1;
        await FirebaseFirestore.instance.collection("Post").doc(_postId.toString()).update({
          "user": users,
        });
      }
    } catch (e) {
      print("수락 실패: $e");
    }
  }

  Future<void> rejectToPost(String userId) async {
    try {
      var postDoc = await FirebaseFirestore.instance.collection("Post").doc(_postId.toString()).get();
      var users = postDoc.data()?["user"] as List<dynamic>;
      var index = users.indexWhere((user) => user["id"] == userId);

      if (index != -1) {
        users[index]["status"] = 2;
        await FirebaseFirestore.instance.collection("Post").doc(_postId.toString()).update({
          "user": users,
        });
      }
    } catch (e) {
      print("거절 실패: $e");
    }
  }

  Future<void> loadPost() async {
    _isLoaded = true;
    await FirebaseFirestore.instance.collection("Post").doc(_postId.toString()).get().then((ds) {
      _writerId = ds.get("writer_id");
      _head = ds.get("head");
      _body = ds.get("body");
      _gender = ds.get("gender");
      _maxPerson = ds.get("maxPerson");
      _currentPerson = ds.get("currentPerson");
      _writerNick = ds.get("writer_nick");
      _minAge = ds.get("minAge");
      _maxAge = ds.get("maxAge");
      _time = ds.get("time");
      _upTime = ds.get("upTime");
      _category = ds.get("category");
      viewCount = ds.get("viewCount");
      user = ds.get("user");
      _llName = LLName(LatLng(ds.get("lat"), ds.get("lng")), ds.get("name"));
    });
  }

  makeTestingPost() {
    _postId = 1;
    _writerId = "jongwon1019";
    _head = "제목 테스트 - 영화 볼 사람?!";
    _minAge = -1;
    _maxAge = 25;
    _body = "내용입니다. \n다른 이유는 없습니다.";
    _gender = 2;
    _maxPerson = 5;
    _currentPerson = 2;
    _category = "기타";
    _time = "2023-04-22 11:10:05";
    _llName = LLName(LatLng(36.833068, 127.178419), "천안시 동남구 안서동 300");
    _upTime = "2023-04-16 13:27:00";
    viewCount = "1342";
    _isLoaded = true;
  }

  // Getter, (ReadOnly)
  int getPostId() => _postId;
  String getWriterId() => _writerId;
  String getPostHead() => _head;
  String getPostBody() => _body;
  int getPostGender() => _gender;
  int getPostMaxPerson() => _maxPerson;
  int getPostCurrentPerson() => _currentPerson;
  String getWriterNick() => _writerNick;
  String getTime() => _time;
  String getCategory() => _category;
  String getUpTime() => _upTime;
  LLName getLLName() => _llName;
  int getMinAge() => _minAge;
  int getMaxAge() => _maxAge;
  bool isLoad() => _isLoaded;
  List<dynamic> getUser() => user;

  String getDateString(bool hour, bool minute) {
    if (_upTime.isEmpty) return "";
    DateTime upTime = DateTime.parse(_upTime);
    return "${upTime.month}월 ${upTime.day}일${hour ? " ${upTime.hour}시" : ""} ${minute ? " ${upTime.minute}분" : ""}";
  }



}
String getTimeBefore(String upTime) {
  DateTime currentTime = DateTime.now();
  currentTime = currentTime.toUtc(); // 한국 시간
  DateTime beforeTime = DateTime.parse(upTime);
  Duration timeGap = currentTime.difference(beforeTime);

  if(timeGap.inDays > 365) {
    return "${timeGap.inDays ~/ 365}년 전";
  } else if (timeGap.inDays >= 30) {
    return "${timeGap.inDays ~/ 30}개월 전";
  } else if (timeGap.inDays >= 1) {
    return timeGap.inDays == 1 ? "하루 전" : ("${timeGap.inDays}일 전");
  } else if (timeGap.inHours >= 1) {
    return "${timeGap.inHours}시간 전";
  } else if (timeGap.inMinutes >= 1) {
    return "${timeGap.inMinutes}분 전";
  } else {
    return "방금 전";
  }
}

Future<bool> addPost(String head, String body, int gender, int maxPerson, String time, LLName llName, String upTime, String category, int minAge, int maxAge, String writerNick) async {
  try {
    int? new_post_id;
    DocumentReference<Map<String, dynamic>> ref =
    await FirebaseFirestore.instance.collection("Post").doc("postData");
    await ref.get().then((DocumentSnapshot ds) {
      new_post_id = ds.get("last_id") + 1;
      if (new_post_id == -1) return false; // 업로드 실패
    });
    await ref.update({"last_id" : new_post_id});
    String uuid = await FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("Post").doc(new_post_id.toString())
        .set({
      "post_id" : new_post_id,
      "writer_id" : uuid,
      "head" : head,
      "body" : body,
      "gender" : gender,
      "maxPerson" : maxPerson,
      "time" : time,
      "lat" : llName.latLng.latitude,
      "lng" : llName.latLng.longitude,
      "name" : llName.AddressName,
      "currentPerson" : 1,
      "category" : category,
      "minAge" : minAge,
      "writer_nick" : writerNick,
      "maxAge" : maxAge,
      "upTime" : upTime,
      "viewCount" : 1,
      "user": FieldValue.arrayUnion([]),
    });
    return true;
  } catch (e) {
    return false;
  }
}