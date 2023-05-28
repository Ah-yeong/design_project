import 'dart:convert';

import 'package:design_project/Entity/EntityLatLng.dart';
import 'package:design_project/resources.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class BoardSelectPositionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BoardSelectPositionPage();
}

class _BoardSelectPositionPage extends State<BoardSelectPositionPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  String? nowPosition;
  List<Marker> _markers = [];

  double lat = 36.833068;
  double lng = 127.178419;

  static const CameraPosition _kSeoul = CameraPosition(
    target: LatLng(36.833068, 127.178419),
    zoom: 17.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(33.450701, 126.578667),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("위치 지정", style: TextStyle(color: Colors.black, fontSize: 17),),
          backgroundColor: Colors.white,
          elevation: 1,
          toolbarHeight: 40,
        ),
        body: Stack(
          children: [
            SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: GoogleMap(
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer())
                },
                markers: Set.from(_markers),
                mapType: MapType.normal,
                initialCameraPosition: _kSeoul,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onCameraMove: ((_position) => _updatePosition(_position)),
                onCameraIdle: (() => _getPlaceAddress()),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 50,
                  child: Center(
                    child: Stack(children: [
                      Text(
                        "${nowPosition ?? "불러오는 중"}",
                        style: TextStyle(
                          fontSize: 17,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3.5
                            ..color = Colors.white,
                        ),
                      ),
                      Text(
                        "${nowPosition ?? "불러오는 중"}",
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ]),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: InkWell(
                      onTap: () =>
                          Navigator.pop(context, LLName(LatLng(lat, lng), nowPosition ?? "알 수 없음")),
                      child: SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width - 40,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: colorSuccess,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(1, 1),
                                    blurRadius: 4.5)
                              ]),
                          child: Center(
                            child: Text(
                              "위치 적용",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )),
                )
              ],
            )
          ],
        ));
  }

  void _updatePosition(CameraPosition _position) {
    var m = _markers.firstWhere((p) => p.markerId == MarkerId('1'));
    _markers.remove(m);
    _markers.add(
      Marker(
        markerId: MarkerId('1'),
        position: LatLng(_position.target.latitude, _position.target.longitude),
        draggable: true,
      ),
    );
    lat = _position.target.latitude;
    lng = _position.target.longitude;
    setState(() {});
  }

  Future<void> _getPlaceAddress() async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyDBMRfh4ETwbEdvkQav0Rp4PWLHCMvTE7w&language=ko';
    final res = await http.get(Uri.parse(url));
    try {
      var value = jsonDecode(res.body)['results'][0]['address_components'];
      setState(() {
        nowPosition =
        "${value[3]['long_name']} ${value[2]['long_name']} ${value[1]['long_name']} ${value[0]['long_name']}";
      });
    } catch (e) {
      nowPosition = "알 수 없음";
    }
  }

  @override
  void initState() {
    super.initState();
    _markers.add(Marker(
        markerId: MarkerId('1'),
        draggable: true,
        onTap: () => print("marker tap"),
        position: LatLng(33.450701, 126.578667)));
  }
}
