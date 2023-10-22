import 'package:design_project/boards/post_list/page_hub.dart';
import 'package:design_project/entity/profile.dart';
import 'package:design_project/resources/icon_set.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../entity/latlng.dart';

class LocationData {
  double? _latitude;
  double? _longitude;
  bool? _isArrival;
  String _uuid;
  String _nickname;

  LocationData(this._latitude, this._longitude, this._uuid, this._nickname, this._isArrival);

  bool isInvalidPosition() => _latitude == null || _longitude == null;
  bool isArrival() => _isArrival != null && _isArrival == true;

  void printThis() {
    print("[Debug] - latitude : $_latitude   longitude : $_longitude   uuid : $_uuid   nickname : $_nickname\n");
  }
}

class LocationGroupData {
  List<LocationData>? _userLocationList;
  List<String>? _members;
  LLName? _meetingPosition;
  LLName? get meetingPosition => _meetingPosition;

  final VISIBLE_MARKER_DISTANCE = 80;

  LocationGroupData(this._userLocationList, this._members, this._meetingPosition);
  
  List<Marker> getMapMarkerList() {
    List<Marker> markerList = [];
    if ( _userLocationList == null ) return markerList;
    for (int i = 0; i < _userLocationList!.length; i++) {
      if (!_userLocationList![i].isInvalidPosition() && getDistance(_userLocationList![i]._uuid) <= VISIBLE_MARKER_DISTANCE)  {
        if ( _userLocationList![i]._uuid != myUuid!) {
          markerList.add(Marker(markerId: MarkerId("${i+1}")
              , position: LatLng(_userLocationList![i]._latitude!, _userLocationList![i]._longitude!)
              , icon: MyIcon.randomIcon(startIndex: 1)));
        }
      }
    }
    return markerList;
  }

  Future<List<EntityProfiles>> getProfiles() async {
    List<EntityProfiles> profileList = [];
    await Future.forEach(_members!, (element) async {
      EntityProfiles profile = EntityProfiles(element);
      await profile.loadProfile();
      profileList.add(profile);
    });
    return profileList;
  }

  bool isArrival(String uuid) {
    LocationData data = _userLocationList!.where((locationData) => locationData._uuid == uuid).first;
    return data.isArrival();
  }

  Marker getMeetingLocationMarker() {
    return Marker(markerId: MarkerId("0"), position: _meetingPosition!.latLng);
  }

  double getDistance(String uuid, {LatLng? position}) {
    LocationData data = _userLocationList!.where((locationData) => locationData._uuid == uuid).first;
    if (data.isInvalidPosition()) {
      return -1;
    }
    double result;
    if ( position != null ) {
      result = Geolocator.distanceBetween(data._latitude!, data._longitude!, position.latitude, position.longitude);
    } else {
      result = Geolocator.distanceBetween(data._latitude!, data._longitude!, _meetingPosition!.latLng.latitude, _meetingPosition!.latLng.longitude);
    }

    return result;
  }

  void printThis({bool? isPrintChild}) {
    print("[Debug] - _userLocationList : ${_userLocationList?.length}개   _members : ${_members.toString()}   _meetingPosition : ${_meetingPosition!.AddressName}, ${_meetingPosition!.latLng.toString()}");
    if (isPrintChild == true) {
      _userLocationList?.forEach((element) {element.printThis();});
    }
  }
}
