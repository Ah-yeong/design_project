import 'package:google_maps_flutter/google_maps_flutter.dart';

class LLName {
  LatLng _latLng;
  String _addressName;

  LLName(this._latLng, this._addressName);

  String get AddressName => _addressName;

  LatLng get latLng => _latLng;

  set latLng(LatLng value) => _latLng = value;

  set AddressName(String value) => _addressName = value;

  LLName.fromJson(Map<String, dynamic> json)
      : _latLng = LatLng(json['lat'], json['lng']),
        _addressName = json['address'] as String;

  Map<String, dynamic> toJson() => {
        'lat': _latLng.latitude,
        'lng': _latLng.longitude,
        'address': _addressName,
      };
}
