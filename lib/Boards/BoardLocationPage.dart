import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class BoardLocationPage extends StatefulWidget {
  const BoardLocationPage({super.key});

  @override
  State<StatefulWidget> createState() => _BoardLocationPage();
}

class _BoardLocationPage extends State<BoardLocationPage> {
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
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(child:
                  SizedBox(
                    child: GoogleMap(
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
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
                  )
                  )
                ],
              ),
              SizedBox(
                height: 50,
                child: Center(
                  child: Text("${nowPosition ?? "불러오는 중"}"),
                ),
              )
            ],
          )
        ));
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
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
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyDBMRfh4ETwbEdvkQav0Rp4PWLHCMvTE7w&language=ko';
    final res = await http.get(Uri.parse(url));
    var value = jsonDecode(res.body)['results'][0]['address_components'];
    setState(() {
      nowPosition = "${value[3]['long_name']} ${value[2]['long_name']} ${value[1]['long_name']} ${value[0]['long_name']}";
    });
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
