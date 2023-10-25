import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import '../boards/post_list/page_hub.dart';
import '../meeting/models/meeting_manager.dart';

class EntityProfiles {
  var profileId;
  var name;
  var age;
  var major; // 학과
  var profileImagePath;
  var mannerGroup; // 소모임 매너지수
  var hobby;
  var hobbyIndex;
  var mbti;
  var mbtiIndex;
  var commute;
  var birth;
  var gender;
  var textInfo;
  var post;
  bool isLoading = true;
  // bool isLoaded = false;
  var addr1;
  var addr2;
  var addr3;
  var fcmToken;
  String? _imagePath;

  String? get imagePath => _imagePath;

  EntityProfiles(var this.profileId) {}

  Future<void> loadProfile() async {
    // 포스팅 로드
    if (userTempImage[profileId] == null) {
      try {
        _imagePath = await FirebaseStorage.instance.ref().child("profile_image/${profileId}").getDownloadURL();
      } catch (e) {
        _imagePath = null;
      }
    }

    await FirebaseFirestore.instance.collection("UserProfile").doc(
        profileId.toString()).get().then((ds) {
      birth = ds.get("birth");
      age = ds.get("age");
      profileImagePath = "assets/images/userImage.png";
      commute = ds.get("commute");
      gender = ds.get("gender");
      hobby = ds.get("hobby");
      hobbyIndex = ds.get("hobbyIndex");
      mbtiIndex = ds.get("mbtiIndex");
      name = ds.get("nickName");
      major = "소프트웨어학과";
      textInfo = ds.get("textInfo");
      mannerGroup = ds.get("mannerGroup");
      post = ds.get("post");
      addr1 = ds.get("addr1");
      addr2 = ds.get("addr2");
      addr3 = ds.get("addr3");
      fcmToken = ds.get("fcmToken");
    });
    isLoading = false;
  }

  String getProfileId() => profileId;

  makeTestingProfile() {
    name = "홍길동";
    age = 23;
    major = "소프트웨어학과";
    profileImagePath = "assets/images/userImage.png";
    mannerGroup = 80;
    hobby = ["술", "영화"];
    birth = "1999-10-19";
    commute = "통학";
  }

  Future<int> addPostId() async {
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
      return Future.value(new_post_id);
    } catch (e) {
      return -1;
    }
  }

  // 수락된 게시물 아이디 추가 (내가 속한 그룹)
  Future<void> addGroupId(postId) async {
    await MeetingManager().addMeetingPost(profileId.toString(), postId);
  }

  Future<void> removeMyPost(int postId) async {
    DocumentReference ref = FirebaseFirestore.instance.collection("UserProfile").doc(profileId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(ref, {"post" : FieldValue.arrayRemove([postId])});
    });
  }
}

