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
        "assets/images/food_marker.png", // 1 = 밥 카테고리
        "assets/images/drink_marker.png", // 2 = 술 카테고리
        "assets/images/hobby_marker.png", // 3 = 취미 카테고리
        "assets/images/art_marker.png", // 4 = 공예 카테고리
        "assets/images/etc_marker.png", // 5 = 기타 카테고리
        "assets/images/game_marker.png", // 6 = 게임 카테고리
        "assets/images/gym_marker.png", // 7 = 운동 카테고리
        "assets/images/movie_marker.png", // 8 = 영화 카테고리
        "assets/images/music_marker.png", // 9 = 음악 카테고리
        "assets/images/shop_marker.png", // 10 = 쇼핑 카테고리
        "assets/images/show_marker.png", // 11 = 공연 카테고리
        "assets/images/study_marker.png", // 12 = 공부 카테고리
        "assets/images/trip_marker.png", // 13 = 여행 카테고리
        "assets/images/walk_marker.png", // 14 = 산책 카테고리
      ];

      for(int i = 0; i < assetImageUrl.length; i++) {
        getBytesFromAsset(assetImageUrl[i], i == 0 ? 127 : 100)
            .then((value) => _userIcon[i] = BitmapDescriptor.fromBytes(value));
      }

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

  /*
          "assets/images/myMarker.png", // 0 = 내 위치 마커
        "assets/images/food_marker.png", // 1 = 밥 카테고리
        "assets/images/drink_marker.png", // 2 = 술 카테고리
        "assets/images/hobby_marker.png", // 3 = 취미 카테고리
        "assets/images/art_marker.png", // 4 = 공예 카테고리
        "assets/images/etc_marker.png", // 5 = 기타 카테고리
        "assets/images/game_marker.png", // 6 = 게임 카테고리
        "assets/images/gym_marker.png", // 7 = 운동 카테고리
        "assets/images/movie_marker.png", // 8 = 영화 카테고리
        "assets/images/music_marker.png", // 9 = 음악 카테고리
        "assets/images/shop_marker.png", // 10 = 쇼핑 카테고리
        "assets/images/show_marker.png", // 11 = 공연 카테고리
        "assets/images/study_marker.png", // 12 = 공부 카테고리
        "assets/images/trip_marker.png", // 13 = 여행 카테고리
        "assets/images/walk_marker.png", // 14 = 산책 카테고리
   */
  /// 나의 위치 아이콘
  static BitmapDescriptor my_position = _userIcon[0]!;

  /// 밥 카테고리 아이콘
  static BitmapDescriptor food = _userIcon[1]!;

  /// 술 카테고리 아이콘
  static BitmapDescriptor drink = _userIcon[2]!;

  /// 취미 카테고리 아이콘
  static BitmapDescriptor hobby = _userIcon[3]!;

  /// 공예 카테고리 아이콘
  static BitmapDescriptor art = _userIcon[4]!;

  /// 기타 카태고리 아이콘
  static BitmapDescriptor etc = _userIcon[5]!;

  /// 게임 카테고리 아이콘
  static BitmapDescriptor game = _userIcon[6]!;

  /// 운동 카테고리 아이콘
  static BitmapDescriptor gym = _userIcon[7]!;

  /// 영화 카테고리 아이콘
  static BitmapDescriptor movie = _userIcon[8]!;

  /// 음악 카테고리 아이콘
  static BitmapDescriptor music = _userIcon[9]!;

  /// 쇼핑 카테고리 아이콘
  static BitmapDescriptor shop = _userIcon[10]!;

  /// 공연 카테고리 아이콘
  static BitmapDescriptor show = _userIcon[11]!;

  /// 공부 카테고리 아이콘
  static BitmapDescriptor study = _userIcon[12]!;

  /// 여행 카테고리 아이콘
  static BitmapDescriptor trip = _userIcon[13]!;

  /// 산책 카테고리 아이콘
  static BitmapDescriptor walk = _userIcon[14]!;

}