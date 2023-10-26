import 'dart:async';
import 'dart:collection';

import 'package:design_project/boards/post_list/page_hub.dart';
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

import '../boards/post_list/post_list.dart';
import '../entity/entity_post.dart';
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

  EntityPost? _post;
  int _remainTime = 1500;

  final Queue<LatLng> _myLocationQueue = Queue();
  LatLng? myPosition;

  bool _isLoading = true;
  bool _initFlag = true;
  final List<Marker> _positionMarkers = [];
  StreamSubscription<Position>? positionStream;

  final ARRIVAL_DISTANCE_BOUNDARY = 30;

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
              "${_meetingId == null || _isLoading || _post == null ? "모임원 위치 찾기" : "위치 공유 : ${_post!.getPostHead()}"}",
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, bottom: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.white.withAlpha(200), borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_filled_rounded,
                                    size: 20,
                                    color: Colors.indigoAccent,
                                  ),
                                  Text(
                                    "${getMeetTimeText(_post!.getTime()).replaceAll("전", "전에 완료").replaceAll("후", "후 모임 시작").replaceAll("잠시 전에", "방금 ")}",
                                    style: TextStyle(color: Colors.indigoAccent, fontSize: 14, fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
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
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(color: colorGrey),
                                    color: colorLightGrey.withAlpha(190)),
                                height: 35,
                                child: Center(
                                  child: Icon(isVisibleMembers ? Icons.arrow_downward : Icons.arrow_upward),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 7),
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
                                      bool isArrival = _locationGroupList!.isArrival(_memberProfiles[index].profileId);
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
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5),
                                                    color: dist == -1
                                                        ? Colors.grey
                                                        : dist < ARRIVAL_DISTANCE_BOUNDARY || isArrival
                                                            ? colorSuccess
                                                            : Colors.indigoAccent),
                                                child: Center(
                                                  child: Text(
                                                    "${dist == -1 ? "미연결" : dist < ARRIVAL_DISTANCE_BOUNDARY || isArrival ? "도착" : "이동중"}",
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
                                duration: Duration(milliseconds: 500),
                                sizeCurve: Curves.decelerate,
                              ),
                            ),
                          ),
                          _post != null && myUuid == _post!.getWriterId()
                              ? Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_locationGroupList!.isArrivalAll()) {
                                        // 다 도착했을 경우
                                        showConfirmBox(context,
                                            title: Text("구성원이 모두 도착했어요!", style: TextStyle(fontWeight: FontWeight.bold)),
                                            body: Text(
                                              "모임 완료 시, 일정 시간 뒤에 모임 게시글이 삭제되며, 위치 공유 서비스를 이용할 수 없어요.\n\n지금 모임을 완료할까요?",
                                              style: TextStyle(color: colorGrey, fontSize: 15),
                                            ),
                                            onAccept: () => null,
                                            onDeny: () => null);
                                      } else {
                                        // 다 도착하지 않았을 경우 (강제 성사)
                                        bool readWarning = false;
                                        showConfirmBox(context,
                                            title: Text(
                                              "구성원이 아직 모두 도착하지 않았어요!",
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            body: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "도착 여부에 관계없이 모두 도착으로 처리되므로, 신중히 선택해주세요.",
                                                  style: TextStyle(color: colorGrey, fontSize: 15),
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                  "이 기능을 고의적 노쇼 및 모임 해체 목적으로 사용 시, 계정 정지 혹은 매너지수 감소 등의 불이익을 받을 수 있으니 주의하세요!",
                                                  style: TextStyle(color: Colors.redAccent, fontSize: 15),
                                                ),
                                                const SizedBox(
                                                  height: 25,
                                                ),
                                                StatefulBuilder(
                                                  builder: (BuildContext context, StateSetter dialogSetter) {
                                                    return GestureDetector(
                                                      child: Row(
                                                        children: [
                                                          Transform.scale(
                                                              scale: 0.9,
                                                              child: SizedBox(
                                                                width: 24,
                                                                height: 24,
                                                                child: Checkbox(
                                                                  value: readWarning,
                                                                  onChanged: (_val) {
                                                                    dialogSetter(() {
                                                                      readWarning = _val!;
                                                                    });
                                                                  },
                                                                  activeColor: colorSuccess,
                                                                ),
                                                              )),
                                                          Text(
                                                            " 위 내용을 읽고, 확인했어요.",
                                                            style: TextStyle(fontSize: 15),
                                                          )
                                                        ],
                                                      ),
                                                      behavior: HitTestBehavior.translucent,
                                                      onTap: () {
                                                        dialogSetter(() {
                                                          readWarning = !readWarning;
                                                        });
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            onAccept: () {
                                              if (!readWarning) {
                                                showAlert("주의 사항 확인 체크가 필요해요!", context, colorError, duration: const Duration(milliseconds: 2000));
                                                return;
                                              } else {}
                                            },
                                            onDeny: () => null);
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(7), border: Border.all(color: colorGrey), color: Colors.indigoAccent),
                                      height: 50,
                                      child: Center(
                                        child: Text(
                                          "모임 완료",
                                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          const SizedBox(
                            height: 50,
                          )
                        ],
                      ),
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
    _initPostInfo();
    _initMyLocation();
    super.initState();
  }

  void _initPostInfo() async {
    await postManager.getPostById(_meetingId, true).then((value) {
      _post = value;
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _initMyLocation() {
    int i = 0;
    Timer.periodic(Duration(milliseconds: 200), (timer) async {
        i += 1;
        if (i >= 5) {
          timer.cancel();
        }
        await determinePosition(LocationAccuracy.best).then((position) {
          _myLocationQueue.add(LatLng(position.latitude, position.longitude));
          if (_myLocationQueue.length >= 5) {
            _setAveragePosition();
            _myLocationLoading = false;
            _uploadPositionAndReload();
          }
          if (i == 5) {
            _initMyLocationUpdate();
          }
        });

    });
    _initReloadTimer();
  }

  void _initMyLocationUpdate() {
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) {
      if (position != null) {
        _myLocationQueue.removeFirst();
        _myLocationQueue.add(LatLng(position.latitude, position.longitude));
        _setAveragePosition();
      }
    });

    // Timer(Duration(milliseconds: 2000), () {
    //   _myLocationTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
    //     await determinePosition(LocationAccuracy.best).then((position) {
    //       _myLocationQueue.removeFirst();
    //       _myLocationQueue.add(LatLng(position.latitude, position.longitude));
    //       _setAveragePosition();
    //     });
    //   });
    // });
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
      if (_remainTimeChecker()) {
        _uploadPositionAndReload();
      }
    });
  }

  // 시간 제한
  bool _remainTimeChecker() {
    _remainTime = _post!.getTimeRemainInSeconds();
    if (_remainTime < -600) {
      Navigator.of(context).pop();
      showAlert("위치 서비스 지원이 종료되었어요!", context, colorGrey);
      Future.delayed(Duration(milliseconds: 400), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
      return false;
    }
    return true;
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
      showAlert("지원이 종료된 모임이에요.", context, colorError);
      Navigator.of(context).pop();
    }

    return;
  }

  @override
  void deactivate() {
    super.deactivate();
    _locationUpdateTimer?.cancel();
    _myLocationTimer?.cancel();
    positionStream?.cancel();
  }
}
