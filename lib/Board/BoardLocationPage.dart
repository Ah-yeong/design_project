import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class BoardLocationPage extends StatefulWidget {
  const BoardLocationPage({super.key});

  @override
  State<StatefulWidget> createState() => _BoardLocationPage();
}

class _BoardLocationPage extends State<BoardLocationPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  List<Marker> _markers = [];

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
          child: Column(
            children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 2.184 / 3,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      markers: Set.from(_markers),
                      mapType: MapType.normal,
                      initialCameraPosition: _kSeoul,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      onCameraMove: ((_position) => _updatePosition(_position)),
                    ),
                  )
            ],
          ),
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
    setState(() {});
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
