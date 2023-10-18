import 'dart:async';
import 'dart:collection';

import 'package:design_project/boards/post.dart';
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

import '../entity/profile.dart';
import '../resources/icon_set.dart';
import 'models/location_manager.dart';

class PageShareLocation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageShareLocation();
}

class _PageShareLocation extends State<PageShareLocation> {
  // 인자 전달받기
  var _meetingId = Get.arguments;

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  LocationManager _locManager = LocationManager();
  LocationGroupData? _locationGroupList;
  LatLng _initCameraPosition = LatLng(0, 0);
  bool _groupListLoading = true;
  bool _myLocationLoading = true;

  List<EntityProfiles> _memberProfiles = [];

  Timer? _locationUpdateTimer;
  Timer? _myLocationTimer;
  bool isVisibleMembers = true;

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
              "${_meetingId == null ? "모임원 위치 찾기" : "위치 공유 : ${postManager.list[postManager.getIndexByPostId(_meetingId)].getPostHead()}"}",
              style: const TextStyle(fontSize: 16.5, color: Colors.black),
            ),
            leading: BackButton(
              color: Colors.black,
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: _groupListLoading || _myLocationLoading
                ? SizedBox()
                : Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: colorLightGrey)),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 7),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isVisibleMembers = !isVisibleMembers;
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                decoration:
                                    BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(), color: colorLightGrey.withAlpha(190)),
                                height: 35,
                                child: Center(
                                  child: Icon(isVisibleMembers ? Icons.arrow_downward : Icons.arrow_upward),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 50),
                            child: SizedBox(
                              width: double.infinity,
                              child: AnimatedCrossFade(
                                firstChild: Container(
                                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 3 / 8, minHeight: 100),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: colorGrey.withAlpha(220)),
                                    color: Colors.white.withAlpha(235),
                                  ),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemBuilder: (BuildContext context, int index) {
                                      double dist = _locationGroupList!.getDistance(_memberProfiles[index].profileId);
                                      return Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/images/userImage.png",
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    "  ${_memberProfiles[index].name}",
                                                    overflow: TextOverflow.clip,
                                                  )
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "약속 장소까지",
                                                    style: TextStyle(fontSize: 13),
                                                  ),
                                                  Text(
                                                    "${dist > 200 ? "150m 이상" : dist == -1 ? "알 수 없음" : getDistanceString(dist)}",
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Flexible(
                                              flex: 1,
                                              fit: FlexFit.loose,
                                              child: Container(
                                                width: 70,
                                                height: 30,
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color:
                                                dist == -1 ? Colors.grey : dist < 30 ? colorSuccess :  Colors.indigoAccent),
                                                child: Center(
                                                  child: Text(
                                                    "${dist == -1 ? "미공개" : dist < 30 ? "도착" : "이동중"}",
                                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                    itemCount: _memberProfiles.length,
                                    padding: EdgeInsets.all(10),
                                    separatorBuilder: (BuildContext context, int index) {
                                      return Divider(
                                        thickness: 1,
                                      );
                                    },
                                  ),
                                ),
                                secondChild: SizedBox(),
                                crossFadeState: isVisibleMembers ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                duration: Duration(milliseconds: 750),
                                sizeCurve: Curves.decelerate,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
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
      if (i >= 4) timer.cancel();
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
      lat += locationValue.latitude;
      lng += locationValue.longitude;
    });
    myPosition = LatLng(lat / 5, lng / 5);
    _positionMarkers.removeWhere((element) => element.markerId.value == "myPos");
    _positionMarkers
        .add(Marker(markerId: MarkerId("myPos"), position: LatLng(myPosition!.latitude, myPosition!.longitude), icon: MyIcon.my_position));
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
    _locManager.uploadMyPosition(_meetingId, myPosition ?? LatLng(0, 0), isOnlyTesting: true).then((value) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          _loadMeetingPosition().then((value) => setState(() {}));
        }
      });
    });
  }

  Future<void> _loadMeetingPosition() async {
    _positionMarkers.retainWhere((marker) {
      return marker.markerId.value == "myPos";
    });
    try {
      await _locManager.getLocationGroupData(_meetingId).then((groupData) async {
        _locationGroupList = groupData;

        if (_locationGroupList != null) {
          // initMarkers
          _positionMarkers.add(_locationGroupList!.getMeetingLocationMarker());
          _positionMarkers.addAll(_locationGroupList!.getMapMarkerList());

          // initCameraPosition
          if (_initFlag) {
            _initCameraPosition = _locationGroupList!.getMeetingLocationMarker().position;
          }
        }
        if (_initFlag) {
          _locationGroupList!.getProfiles().then((profileList) {
            _memberProfiles = profileList;
            setState(() {
              _groupListLoading = false;
              _initFlag = false;
            });
          });
        }
      });
    } catch (e) {
      showAlert("지원이 종료된 모임입니다.", context, colorError);
    }

    return;
  }

  @override
  void deactivate() {
    super.deactivate();
    _locationUpdateTimer?.cancel();
    _myLocationTimer?.cancel();
  }
}
