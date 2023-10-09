import 'dart:async';

import 'package:design_project/boards/search/search_post_list.dart';
import 'package:design_project/main.dart';
import 'package:design_project/meeting/models/location_data.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:design_project/resources/resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'models/location_manager.dart';

class PageShareLocation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageShareLocation();
}

class _PageShareLocation extends State<PageShareLocation> with AutomaticKeepAliveClientMixin<PageShareLocation>{
  // 인자 전달받기
  var meetingId = Get.arguments;

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  LocationManager _locManager = LocationManager();
  LocationGroupData? _locationGroupList;
  LatLng _initCameraPosition = LatLng(0, 0);
  bool _groupListLoading = true;

  Timer? _locationUpdateTimer;

  LatLng _myLatLng = LatLng(0, 0);

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
                    _groupListLoading ? SizedBox() : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colorLightGrey)
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 3 / 8,
                      child: GoogleMap(
                        markers: Set.from(_positionMarkers),
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: _initCameraPosition ?? LatLng(36.833068, 127.178419),
                          zoom: 16.75,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          if (!_controller.isCompleted) _controller.complete(controller);
                          changeMapMode(controller);
                        },
                        scrollGesturesEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                    ),
                    Text("약속 장소까지 ${getDistanceString(Geolocator.distanceBetween(_myLatLng.latitude, _myLatLng.longitude, _initCameraPosition!.latitude, _initCameraPosition!.longitude))}")
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
    _uploadPositionAndReload();
    _initTimer();
    super.initState();
  }


  @override
  void deactivate() {
    super.deactivate();
    _locationUpdateTimer?.cancel();
  }

  // 위치 자동 업데이트 타이머
  void _initTimer() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 8), (timer) {
      _uploadPositionAndReload();
    });
  }

  void _uploadPositionAndReload() {
    _locManager.uploadMyPosition(meetingId, isOnlyTesting: true).then((value) {
      Future.delayed(Duration(milliseconds: 100), () {
        if(mounted) {
          _myLatLng = value == null ? _myLatLng : LatLng(value.latitude, value.longitude);
          _loadMeetingPosition().then((value) => setState((){}));
        }
      });
    });
  }

  Future<void> _loadMeetingPosition() async {
    _positionMarkers.clear();
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
  }

  @override
  bool get wantKeepAlive => true;
}
