import 'dart:math';

import 'package:design_project/resources/resources.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyIcon {
  static bool isLoading = true;
  static final Map<int, BitmapDescriptor> _userIcon = {};
  static final Random _random = Random();

  static Future<void> loadUserIcon() async {
    if (_userIcon.length == 0) {
      final List<String> assetImageUrl = [
        "assets/images/myMarker.png", // 0 = 내 위치 마커
        "assets/images/foodMarker.png", // 1 = 밥 카테고리
        "assets/images/drinkMarker.png", // 2 = 술 카테고리
        "assets/images/hobbyMarker.png", // 3 = 취미 카테고리
      ];

      for(int i = 0; i < assetImageUrl.length; i++) {
        getBytesFromAsset(assetImageUrl[i], i == 0 ? 127 : 100)
            .then((value) => _userIcon[i] = BitmapDescriptor.fromBytes(value));
      }

      print("length : ${_userIcon.length}");
      isLoading = false;
    }
    return;
  }

  // 무작위 아이콘
  static BitmapDescriptor randomIcon({int? startIndex, int? endIndex}) {
    // startIndex = 5, endIndex = 11일때 총 개수가 15개 일 때,
    // 5, 6, 7, 8, 9, 10, 11 총 7개 => nextInt(6) + 5 => 0,1,2,3,4,5 + 5
    if (endIndex != null && endIndex >= _userIcon.length) {
      return _userIcon[0]!;
    }
    if (startIndex != null && endIndex != null) {
      if (endIndex < startIndex) {
        int temp = endIndex;
        endIndex = startIndex;
        startIndex = temp;
      }
      int rd = _random.nextInt(endIndex - startIndex);
      return _userIcon[rd + startIndex]!;
    } else if (endIndex != null && startIndex == null) {
      return _userIcon[_random.nextInt(endIndex)]!;
    } else if (endIndex == null && startIndex != null) {
      int rd = _random.nextInt(_userIcon.length - startIndex) + startIndex;
      return _userIcon[rd]!;
    } else {
      return _userIcon[_random.nextInt(_userIcon.length)]!;
    }
  }

  // 나의 위치 아이콘
  static BitmapDescriptor my_position = _userIcon[0]!;
}