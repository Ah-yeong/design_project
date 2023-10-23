import 'package:geolocator/geolocator.dart';

Future<Position> determinePosition(LocationAccuracy accuracy) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
}
final LocationSettings locationSettings = AppleSettings(
  accuracy: LocationAccuracy.bestForNavigation,
  activityType: ActivityType.other,
  distanceFilter: 3, // 업데이트 이벤트가 생성되는 최소 거리 (m)
  pauseLocationUpdatesAutomatically: true,
  showBackgroundLocationIndicator: true,
);
