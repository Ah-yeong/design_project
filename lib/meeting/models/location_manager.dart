import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../boards/post_list/page_hub.dart';
import '../../entity/latlng.dart';
import '../../entity/profile.dart';
import 'location_data.dart';

class LocationManager {
  CollectionReference _instance = FirebaseFirestore.instance.collection("ShareLocation");

  // 위치 경로 생성
  Future<void> createShareLocation(int meetingId, LLName meetingPos, List<String> uuids) async {
    Map<String, dynamic> initData = {"members": uuids};
    await Future.forEach(uuids, (uuid) async {
      EntityProfiles profile = EntityProfiles(uuid);
      await profile.loadProfile();
      initData[uuid] = {"nickname": profile.name};
    });
    initData["position"] = meetingPos.toJson();
    _instance.doc(meetingId.toString()).set(initData);
  }

  // 자신의 위치 업로드
  Future<void> uploadMyPosition(int meetingId, LatLng latLng, {bool? isOnlyTesting}) async {
    if (!myUuid!.contains("dBfF9GPpQqVvxY3SxNmWpdT1er43")) isOnlyTesting = false;
    try {
      DocumentReference _locationInstance = _instance.doc(meetingId.toString());
      await FirebaseFirestore.instance.runTransaction((transaction) => transaction.get(_locationInstance).then((snapshot) async {
        transaction.update(_locationInstance, {
          myUuid!: {
            "nickname": snapshot.get(myUuid!)["nickname"],
            "latitude": isOnlyTesting == true ? 36.831619 : latLng.latitude,
            "longitude": isOnlyTesting == true ? 127.174704 : latLng.longitude,
          }
        });
      }));
    } catch (e) {
    }
    return;
  }

  Future<LocationGroupData?> getLocationGroupData(int meetingId) async {
    DocumentReference _locationInstance = _instance.doc(meetingId.toString());
    LocationGroupData? resultData;

    await _locationInstance.get().then((snapshot) {
      resultData = LocationGroupData(_getAllPosition(snapshot)
          , (snapshot.get("members") as List).map((e) => e.toString()).toList(), LLName.fromJson(snapshot.get("position")));
    });

    return Future.value(resultData);
  }

  // 모든 유저의 위치 가져오기
  List<LocationData> _getAllPosition(DocumentSnapshot snapshot) {
    List<LocationData> locationList = [];
    List<dynamic> memberList = snapshot.get("members");
    for (String uuid in memberList) {
      try {
        Map<String, dynamic> data = snapshot.get(uuid);
        locationList.add(LocationData(data["latitude"], data["longitude"], uuid, data["nickname"]));
      } catch (e) {
        print(e);
      }
    }
    return locationList;
  }
}
