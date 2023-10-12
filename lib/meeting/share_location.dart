import 'dart:async';
import 'dart:collection';

import 'package:design_project/boards/search/search_post_list.dart';
import 'package:design_project/main.dart';
import 'package:design_project/meeting/models/location_data.dart';
import 'package:design_project/resources/geolocator.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:design_project/resources/resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../resources/icon_set.dart';
import 'models/location_manager.dart';

class PageShareLocation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageShareLocation();
}

class _PageShareLocation extends State<PageShareLocation>{
  // 인자 전달받기
  var meetingId = Get.arguments;

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  LocationManager _locManager = LocationManager();
  LocationGroupData? _locationGroupList;
  LatLng _initCameraPosition = LatLng(0, 0);
  bool _groupListLoading = true;
  bool _myLocationLoading = true;

  Timer? _locationUpdateTimer;
  Timer? _myLocationTimer;

  final Queue<LatLng> _myLocationQueue = Queue();
  LatLng? myPosition;

  bool _initFlag = true;
  final List<Marker> _positionMarkers = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 1,
            backgroundColor: Colors.white,
            toolbarHeight: 40,
            title: Text(
              "${meetingId == null ? "모임원 위치 찾기" : "위치 공유 : ${postManager.list[postManager.getIndexByPostId(meetingId)].getPostHead()}"}",
              style: const TextStyle(fontSize: 16.5, color: Colors.black),
            ),
            leading: BackButton(
              color: Colors.black,
            ),
          ),
          body: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    _groupListLoading || _myLocationLoading ? SizedBox() : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colorLightGrey)
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 3 / 8,
                      child: GoogleMap(

                        markers: Set.from(_positionMarkers),
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: _initCameraPosition,
                          zoom: 16.75,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          if (!_controller.isCompleted) _controller.complete(controller);
                          changeMapMode(controller);
                        },
                        scrollGesturesEnabled: true,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                    ),
                    if (!(_groupListLoading || _myLocationLoading)) Text("약속 장소까지 ${getDistanceString(Geolocator.distanceBetween(myPosition!.latitude, myPosition!.longitude, _initCameraPosition.latitude, _initCameraPosition.longitude))}"),
                    if (!(_groupListLoading || _myLocationLoading)) Text("myPosData\nlatitude : ${myPosition?.latitude}\nlongitude : ${myPosition?.longitude}"),
                  ],
                ),
              )
          ),
        ),
        if (_groupListLoading) buildContainerLoading(135)
      ],
    );
  }

  @override
  void initState() {
    _initMyLocation();
    _initMyLocationTimer();
    super.initState();
  }

  void _initMyLocation() {
    int i = 0;
    Timer.periodic(Duration(milliseconds: 200), (timer) async {
      if ( i >= 4 ) timer.cancel();
      i += 1;
      await determinePosition(LocationAccuracy.best).then((position) {
        _myLocationQueue.add(LatLng(position.latitude, position.longitude));
        if (_myLocationQueue.length >= 5) {
          _setAveragePosition();
          _myLocationLoading = false;
          _uploadPositionAndReload();
        }
      });
    });
    _initReloadTimer();
  }

  void _initMyLocationTimer() {
    Timer(Duration(milliseconds: 2000), () {
      _myLocationTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
        await determinePosition(LocationAccuracy.best).then((position) {
          _myLocationQueue.removeFirst();
          _myLocationQueue.add(LatLng(position.latitude, position.longitude));
          _setAveragePosition();
        });
      });
    });
  }

  void _setAveragePosition() {
    double lat = 0, lng = 0;
    _myLocationQueue.forEach((locationValue) {
      lat += locationValue.latitude; lng += locationValue.longitude;
    });
    myPosition = LatLng(lat / 5, lng / 5);
    _positionMarkers.removeWhere((element) => element.markerId.value == "myPos");
    _positionMarkers.add(Marker(markerId: MarkerId("myPos")
        , position: LatLng(myPosition!.latitude, myPosition!.longitude)
        , icon: MyIcon.my_position));
    // _setCameraPosition(myPosition!);
    setState(() {});
  }

  // void _setCameraPosition(LatLng newPosition) async {
  //   double zoomLevel = 16.0;
  //   await _controller.future.then((view) async {
  //     await view.getZoomLevel().then((value) => zoomLevel = value);
  //     await view.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //       // target: newLatLng
  //       target: myPosition!, // 애뮬레이터 테스트시 상명대학교 초기화
  //       zoom: zoomLevel,
  //     )));
  //   });
  // }

  // 위치 자동 업데이트 타이머
  void _initReloadTimer() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 7), (timer) {
      _uploadPositionAndReload();
    });
  }

  void _uploadPositionAndReload() {
    _locManager.uploadMyPosition(meetingId, myPosition ?? LatLng(0, 0), isOnlyTesting: true).then((value) {
      Future.delayed(Duration(milliseconds: 100), () {
        if(mounted) {
          _loadMeetingPosition().then((value) => setState((){}));
        }
      });
    });
  }

  Future<void> _loadMeetingPosition() async {
    _positionMarkers.retainWhere((marker) {
      return marker.markerId.value == "myPos";
    });
    await _locManager.getLocationGroupData(meetingId).then((groupData) {
      _locationGroupList = groupData;

      if ( _locationGroupList != null ) {
        // initMarkers
        _positionMarkers.add(_locationGroupList!.getMeetingLocationMarker());
        _positionMarkers.addAll(_locationGroupList!.getMapMarkerList());

        // initCameraPosition
        if ( _initFlag ) {
          _initCameraPosition = _locationGroupList!.getMeetingLocationMarker().position;
        }
      }
      if ( _initFlag ) {
        setState(() {
          _groupListLoading = false;
          _initFlag = false;
        });
      }
    });
    return;
  }

  @override
  void deactivate() {
    super.deactivate();
    _locationUpdateTimer?.cancel();
    _myLocationTimer?.cancel();
  }
}
