import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/Entity/EntityLatLng.dart';
import 'package:design_project/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Resources/resources.dart';

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
  var _viewCount;
  var _isVoluntary;

  var user;

  DocumentReference? _postDocRef;

  double _distance = 0.0;

  double get distance => _distance;

  set distance(double value) => _distance = value;

  set llName(value) => _llName = value;

  late String _upTime;

  bool _isLoaded = false;

  EntityPost(int this._postId) {
    _postDocRef = FirebaseFirestore.instance.collection("Post").doc(_postId.toString());
  }

  Future<bool> applyToPost(String userId) async {
    bool requestSuccess = true;
    DocumentReference ref = FirebaseFirestore.instance.collection("Post").doc(_postId.toString());
    try {
      await FirebaseFirestore.instance
          .collection("Post")
          .doc(_postId.toString())
          .get()
          .then((DocumentSnapshot ds) async {
        List<Map<String, dynamic>> userList = (ds.get("user") as List).map((e) => e as Map<String, dynamic>).toList();
        if (userList.where((element) => element["id"] == userId).length != 0) {
          // 이미 신청을 했던 적이 있는 유저일 경우
          requestSuccess = false;
        } else {
          await ref.update({
            "user": FieldValue.arrayUnion([
              {"id": userId, "status": 0}
            ])
          });
        }
      });
    } catch (error) {
      if (error.toString().contains("field does not exist within the DocumentSnapshotPlatform")) {
        await ref.update({
          "user": FieldValue.arrayUnion([
            {"id": userId, "status": 0}
          ])
        });
      } else {
        print("[신청하기 오류] : $error");
      }
    }
    return requestSuccess;
  }

  Future<void> acceptToPost(String userId) async {
    try {
      DocumentReference reference = FirebaseFirestore.instance.collection("Post").doc(_postId.toString());
      var postDoc = await reference.get();
      var users = postDoc.get("user") as List<dynamic>;
      var index = users.indexWhere((user) => user["id"] == userId);

      if (index != -1) {
        users[index]["status"] = 1;
        reference.update({
          "user": users,
        }).then((value) async {
          reference.update({"currentPerson": FieldValue.increment(1)});
        });
      }
    } catch (e) {
      print("수락 실패: $e");
    }
  }

  Future<void> rejectToPost(String userId) async {
    try {
      var postDoc = await _postDocRef!.get();
      var users = postDoc.get("user") as List<dynamic>;
      var index = users.indexWhere((user) => user["id"] == userId);

      if (index != -1) {
        users[index]["status"] = 2;
        _postDocRef!.update({
          "user": users,
        });
      }
    } catch (e) {
      print("거절 실패: $e");
    }
  }

  _loadField(DocumentSnapshot ds) {
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
    _viewCount = ds.get("viewCount");
    _isVoluntary = ds.get("voluntary");
    user = ds.get("user");
    _llName = LLName(LatLng(ds.get("lat"), ds.get("lng")), ds.get("name"));
  }

  Future<void> loadPost() async {
    _isLoaded = true;
    DocumentReference doc = FirebaseFirestore.instance.collection("Post").doc(_postId.toString());
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot ds = await transaction.get(doc);
      if (!ds.exists) return;
      try {
        _loadField(ds);
      } catch (e) {
        Map<String, dynamic> map = ds.data() as Map<String, dynamic>;
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          for (String key in postFieldDefault.keys) {
            if (!map.containsKey(key)) {
              await transaction.update(doc, {key: postFieldDefault[key]});
            }
          }
        });
        _loadField(ds);
      }
    });
  }

  bool isFull() {
    return _maxPerson != -1 && _currentPerson >= _maxPerson;
  }

  int getNewRequest() {
    List<Map<String, dynamic>> userList = (user as List).map((e) => e as Map<String, dynamic>).toList();
    return userList.where((element) => element["status"] == 0).length;
  }

  String getRequestState(String uuid) {
    List<Map<String, dynamic>> userList = (user as List).map((e) => e as Map<String, dynamic>).toList();
    userList.retainWhere((element) => element["id"] == uuid);
    if (userList.length == 0) {
      return "none";
    }
    Map<String, dynamic> userStatus = userList.first;
    return userStatus["status"] == 0
        ? "wait"
        : userStatus["status"] == 1
            ? "accept"
            : "reject";
  }

  addViewCount(String uuid) async {
    const PREFIX_COOL = "[PCD]_";
    int? coolDown = LocalStorage!.getInt("${PREFIX_COOL}$_postId");
    int standardTime = 1000 * 60 * 30; // milliseconds.
    if (coolDown == null || DateTime.now().millisecondsSinceEpoch - coolDown > standardTime) {
      _viewCount += 1;
      _postDocRef!.update({"viewCount": FieldValue.increment(1)});
      LocalStorage!.setInt("${PREFIX_COOL}$_postId", DateTime.now().millisecondsSinceEpoch);
    }
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

  bool isVoluntary() => _isVoluntary;

  String getCategory() => _category;

  String getUpTime() => _upTime;

  LLName getLLName() => _llName;

  int getMinAge() => _minAge;

  int getMaxAge() => _maxAge;

  int getViewCount() => _viewCount;

  bool isLoad() => _isLoaded;

  List<dynamic> getUser() => user;

  String getDateString(bool hour, bool minute) {
    if (_upTime.isEmpty) return "";
    DateTime upTime = DateTime.parse(_upTime);
    return "${upTime.month}월 ${upTime.day}일${hour ? " ${upTime.hour}시" : ""} ${minute ? " ${upTime.minute}분" : ""}";
  }

  List<String> getCompletedMembers() {
    List<String> memberList = [];
    List<Map<String, dynamic>> userList = (user as List).map((e) => e as Map<String, dynamic>).toList();
    userList.retainWhere((element) => element["status"] == 1);
    userList.forEach((element) => memberList.add(element["id"]));
    return memberList;
  }
}

String getTimeBefore(String upTime) {
  DateTime currentTime = DateTime.now();
  currentTime = currentTime.toUtc(); // 한국 시간
  DateTime beforeTime = DateTime.parse(upTime);
  Duration timeGap = currentTime.difference(beforeTime);

  if (timeGap.inDays > 365) {
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

Future<bool> addPost({required String head, required String body, required int gender,
  required int maxPerson, required String time, required LLName llName, required String upTime,
  required String category, required int minAge, required int maxAge, required String writerNick,
required bool isVoluntary}) async {
  try {
    int? new_post_id;
    DocumentReference<Map<String, dynamic>> ref = await FirebaseFirestore.instance.collection("Post").doc("postData");
    await ref.get().then((DocumentSnapshot ds) {
      new_post_id = ds.get("last_id") + 1;
      if (new_post_id == -1) return false; // 업로드 실패
    });
    await ref.update({"last_id": new_post_id});
    String uuid = await FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("Post").doc(new_post_id.toString()).set({
      "post_id": new_post_id,
      "writer_id": uuid,
      "head": head,
      "body": body,
      "gender": gender,
      "maxPerson": maxPerson,
      "time": time,
      "lat": llName.latLng.latitude,
      "lng": llName.latLng.longitude,
      "name": llName.AddressName,
      "currentPerson": 1,
      "category": category,
      "minAge": minAge,
      "writer_nick": writerNick,
      "maxAge": maxAge,
      "upTime": upTime,
      "viewCount": 1,
      "user": FieldValue.arrayUnion([]),
      "voluntary" : isVoluntary
    });
    return true;
  } catch (e) {
    return false;
  }
}
