import 'package:google_maps_flutter/google_maps_flutter.dart';

class LLName {
  LatLng _latLng;
  String _AddressName;
  LLName(this._latLng, this._AddressName);


  String get AddressName => _AddressName;
  LatLng get latLng => _latLng;
  set latLng(LatLng value) =>_latLng = value;
  set AddressName(String value) => _AddressName = value;
}