import 'dart:convert';
import 'dart:math';

import 'package:design_project/Boards/BoardMain.dart';
import 'package:design_project/Boards/BoardPostPage.dart';
import 'package:design_project/Entity/EntityProfile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:async';

import '../Entity/EntityPost.dart';
import '../resources.dart';

class BoardLocationPage extends StatefulWidget {
  const BoardLocationPage({super.key});

  @override
  State<StatefulWidget> createState() => _BoardLocationPage();
}

class _BoardLocationPage extends State<BoardLocationPage> {
  int markerid = 2;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<BitmapDescriptor> _markerIcons = List.empty(growable: true);
  String? nowPosition;
  List<Marker> _markers = [];
  EntityProfiles? profileEntity;

  double lat = 36.833068;
  double lng = 127.178419;
  CameraPosition temp = CameraPosition(target: LatLng(36.833068, 127.178419), zoom: 16.3);

  bool isMarkerSeleced = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: postManager.isLoading ? Center(
            child: SizedBox(
                height: 65,
                width: 65,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: colorSuccess,
                ))) :
        SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                        child: SizedBox(
                      child: GoogleMap(
                        mapToolbarEnabled: false,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: false,
                        myLocationButtonEnabled: false,
                        compassEnabled: false,
                        buildingsEnabled: false,
                        gestureRecognizers: {
                          Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer())
                        },
                        markers: Set.from(_markers),
                        mapType: MapType.normal,
                        initialCameraPosition: temp,
                        onMapCreated: (GoogleMapController controller) {
                          changeMapMode(controller);
                          _controller.complete(controller);
                        },
                        onCameraMove: ((_position) =>
                            _updatePosition(_position)),
                        onCameraIdle: (() => _getPlaceAddress()),
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: 50,
                  child: Center(
                    child: Text("${nowPosition ?? "불러오는 중"}"),
                  ),
                )
              ],
            )));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _addCustomIcons() async {
    final List<String> assetImageUrl = [
      "assets/images/myMarker.png", // 0 = 내 위치 마커
      "assets/images/foodMarker.png", // 1 = 밥 카테고리
      "assets/images/drinkMarker.png", // 2 = 술 카테고리
      "assets/images/hobbyMarker.png", // 3 = 취미 카테고리
    ];
    for (int i = 0; i < assetImageUrl.length; i++) {
      await getBytesFromAsset(assetImageUrl[i], i == 0 ? 127 : 100)
          .then((value) => _markerIcons.add(BitmapDescriptor.fromBytes(value)));
    }
    _initMarkers();
  }

  // 맵 스타일 변경
  void changeMapMode(GoogleMapController mapController) {
    getJsonFile("assets/map_style.json")
        .then((value) => mapController.setMapStyle(value));
  }

  // Json 디코딩
  Future<String> getJsonFile(String path) async {
    ByteData byte = await rootBundle.load(path);
    var list = byte.buffer.asUint8List(byte.offsetInBytes, byte.lengthInBytes);
    return utf8.decode(list);
  }

  void _updatePosition(CameraPosition _position) {
    lat = _position.target.latitude;
    lng = _position.target.longitude;
    setState(() {});
  }

  Widget _buildModalSheet(BuildContext context, int markerId) {
    EntityPost postEntity = postManager.list[markerId];
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 40,
            width: MediaQuery.of(context).size.width - 16,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => BoardPostPage(postId: postEntity.getPostId())));
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Color(0xD7EEEEEE),),
                child: Center(
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            "게시물 보기",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black,
                              ),
                            )),
                      ],
                    )),
              ),
            ),
          ),
          SizedBox(
            height: 5
          ),
          Container(
              margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                  padding: EdgeInsets.all(13),
                  child: buildPostContext(postEntity, profileEntity!))),
        ],
      ),
    );
  }

  void _initMarkers() {
    Random rd = Random();
    for (int i = 0; i < postManager.list.length; i++) {
      _markers.add(
        Marker(
            markerId: MarkerId("$markerid"),
            position: postManager.list[i].getLLName().latLng,
            onTap: () {
              profileEntity = EntityProfiles(postManager.list[i].getWriterId());
              profileEntity!.makeTestingProfile();
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildModalSheet(context, i),
                  backgroundColor: Colors.transparent);
              //postLoad(ep.getPostId());
            },
            draggable: true,
            icon: _markerIcons[rd.nextInt(3) + 1]),
      );
      markerid++;
    }
    _initLocations();
  }

  Future<void> _getPlaceAddress() async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyDBMRfh4ETwbEdvkQav0Rp4PWLHCMvTE7w&language=ko';
      final res = await http.get(Uri.parse(url));
      var value = jsonDecode(res.body)['results'][0]['address_components'];
      setState(() {
        nowPosition =
            "${value[3]['long_name']} ${value[2]['long_name']} ${value[1]['long_name']} ${value[0]['long_name']}";
      });
    } catch (e) {
      nowPosition = "불러오는 중";
    }
  }

  _initLocations() async {
    await determinePosition().then((pos) {
      setState(() {
        try {
          LatLng newLatLng = LatLng(pos.latitude, pos.longitude);
          _controller.future.then((value) =>
              value.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                target: LatLng(lat, lng),
                zoom: 16.3,
              ))));
          _getPlaceAddress();
          _markers.add(
            Marker(
                markerId: MarkerId('1'),
                position: newLatLng,
                onTap: () {},
                draggable: true,
                icon: _markerIcons[0]),
          );
        } catch (e) {
          print(e);
          _markers.add(
            Marker(
                markerId: MarkerId('1'),
                position: LatLng(lat, lng),
                onTap: () {},
                draggable: true,
                icon: _markerIcons[0]),
          );
        }
      });
    });
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
  }

  _loading() async {
    if (postManager.isLoading) {
      await Future.delayed(Duration(milliseconds: 1000)).then((value) => _loading());
      return;
    } else {
      _addCustomIcons();
    }
  }

  @override
  void initState() {
    super.initState();
    _loading();
  }
}
