import 'package:design_project/boards/post_list/page_hub.dart';
import 'package:design_project/resources/icon_set.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../entity/latlng.dart';

class LocationData {
  double? _latitude;
  double? _longitude;
  String _uuid;
  String _nickname;

  LocationData(this._latitude, this._longitude, this._uuid, this._nickname);

  bool isValidPosition() => _latitude == null || _longitude == null;

  void printThis() {
    print("[Debug] - latitude : $_latitude   longitude : $_longitude   uuid : $_uuid   nickname : $_nickname\n");
  }
}

class LocationGroupData {
  List<LocationData>? _userLocationList;
  List<String>? _members;
  LLName? _meetingPosition;
  
  LocationGroupData(this._userLocationList, this._members, this._meetingPosition);
  
  List<Marker> getMapMarkerList() {
    List<Marker> markerList = [];
    if ( _userLocationList == null ) return markerList;
    for (int i = 0; i < _userLocationList!.length; i++) {
      if (!_userLocationList![i].isValidPosition()){
        if ( _userLocationList![i]._uuid != myUuid!) {
          markerList.add(Marker(markerId: MarkerId("${i+1}")
              , position: LatLng(_userLocationList![i]._latitude!, _userLocationList![i]._longitude!)
              , icon: MyIcon.randomIcon(startIndex: 1)));
        }
      }
    }
    return markerList;
  }

  Marker getMeetingLocationMarker() {
    return Marker(markerId: MarkerId("0"), position: _meetingPosition!.latLng);
  }

  void printThis({bool? isPrintChild}) {
    print("[Debug] - _userLocationList : ${_userLocationList?.length}개   _members : ${_members.toString()}   _meetingPosition : ${_meetingPosition!.AddressName}, ${_meetingPosition!.latLng.toString()}");
    if (isPrintChild == true) {
      _userLocationList?.forEach((element) {element.printThis();});
    }
  }
}
