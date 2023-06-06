import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/Entity/EntityLatLng.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EntityProfiles {
  var profileId;
  var name;
  var age;
  var major; // 학과
  var profileImagePath;
  var mannerGroup; // 소모임 매너지수
  var nickname;
  var hobby;
  var mbti;
  var mbtiIndex;
  var commute;
  var commuteIndex;
  var birth;
  var gender;
  var textInfo;
  var post;
  int postCount = 0;
  bool isLoading = true;
  // bool isLoaded = false;

  EntityProfiles(var this.profileId) {
    print("프로필 연결됨");
  }

  Future<void> loadProfile() async {
    // 포스팅 로드
    print(profileId);
    await FirebaseFirestore.instance.collection("UserProfile").doc(
        profileId.toString()).get().then((ds) {
      birth = ds.get("birth");
      age = 23;
      profileImagePath = "assets/images/userImage.png";
      commute = ds.get("commute");
      commuteIndex = ds.get("commuteIndex");
      // gender = ds.get("gender");
      hobby = ds.get("hobby");
      // _hobbyIndex = ds.get("hobbyIndex");
      mbti = ds.get("mbti");
      mbtiIndex = ds.get("mbtiIndex");
      name = ds.get("nickName");
      major = "소프트웨어학과";
      textInfo = ds.get("textInfo");
      mannerGroup = ds.get("mannerGroup");
      post = ds.get("post");
      print(post);
    });
    isLoading = false;
    print("프로필 정보 불러오기 성공");
  }

  String getProfileId() => profileId;

  makeTestingProfile() {
    name = "홍길동";
    age = 23;
    major = "소프트웨어학과";
    profileImagePath = "assets/images/userImage.png";
    mannerGroup = 80;

    nickname = "테스트";
    hobby = ["술", "영화"];
    birth = "1999-10-19";
    commute = "통학";
  }

  Future<bool> addPostId() async {
    try {
      int? new_post_id;
      DocumentReference<Map<String, dynamic>> ref =
      await FirebaseFirestore.instance.collection("Post").doc("postData");
      await ref.get().then((DocumentSnapshot ds) {
        new_post_id = ds.get("last_id");
        if (new_post_id == -1) return false; // 업로드 실패
      });
      await FirebaseFirestore.instance.collection("UserProfile").doc(profileId.toString())
          .update({
        "post": FieldValue.arrayUnion([new_post_id]),
        //"post" : new_post_id,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}

