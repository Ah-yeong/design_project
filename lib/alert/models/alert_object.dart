import 'package:design_project/alert/models/alert_manager.dart';
import 'package:design_project/boards/post.dart';
import 'package:design_project/chat/chat_screen.dart';
import 'package:design_project/entity/entity_post.dart';
import 'package:design_project/main.dart';
import 'package:design_project/meeting/models/location_manager.dart';
import 'package:design_project/meeting/share_location.dart';
import 'package:design_project/profiles/profile_view.dart';
import 'package:design_project/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlertObject {
  late String _title;
  late String _body;
  late DateTime _time;
  late AlertType _alertType;
  late bool _isRead;
  Map<String, String> _clickAction = {};

  AlertObject(
      {required String title, required String body, required DateTime time, required AlertType alertType, Map<String, String>? clickAction, required bool isRead}) {
    this._title = title;
    this._body = body;
    this._time = time;
    this._alertType = alertType;
    this._isRead = isRead;
    if (clickAction != null) this._clickAction = clickAction;
  }

  bool reading() {
    bool read = !_isRead;
    _isRead = true;
    return read;
  }

  // 배너 클릭 이벤트
  void onClick() async {
    // 타입이 정의되어있지 않다면 클릭 이벤트는 없음
    if (_alertType == AlertType.NONE) return;

    // 클릭 이벤트에 따른
    switch (_alertType) {
      case AlertType.TO_POST:
        if (_clickAction["post_id"] != null) {
          Get.to(() => BoardPostPage(postId: int.parse(_clickAction["post_id"]!)));
        }
        break;
      case AlertType.TO_CHAT_ROOM:
        if (_clickAction["chat_id"] != null) {
          String id = _clickAction["chat_id"]!;
          if (_clickAction["is_group_chat"] != null && _clickAction["is_group_chat"] == "true") {
            Get.to(() => ChatScreen(postId: int.parse(id)));
          } else {
            Get.to(() => ChatScreen(recvUserId: id,));
          }
        }
        break;
      case AlertType.TO_PROFILE:
        if (_clickAction["profile_id"] != null) {
          Get.to(() => BoardProfilePage(profileId: _clickAction["profile_id"]!),transition: Transition.downToUp);
        }
        break;
      case AlertType.TO_SHARE_LOCATION:
        if (_clickAction["meeting_id"] != null) {
          Get.to(() => ChatScreen(postId: int.parse(_clickAction["meeting_id"]!)));
          try {
            LocationManager existTest = LocationManager();
            await existTest.getLocationGroupData(int.parse(_clickAction["meeting_id"]!));
            Get.to(() => PageShareLocation(), arguments: int.parse(_clickAction["meeting_id"]!));
          } catch (e) {
            showAlert("위치 공유 지원이 종료된 모임이에요!", navigatorKey.currentContext!, colorError);
          }
        }
        break;
      default:
        break;
    }
    return;
  }

  AlertObject.fromJson(Map<String, dynamic> json)
      : _alertType = AlertType.fromJson(json['type']),
        _time = DateTime.fromMillisecondsSinceEpoch(json['time']),
        _title = json['title'],
        _body = json['body'],
        _clickAction = (json['action'] as Map<String, dynamic>).map((key, value) => MapEntry(key, value!.toString())) ,
        _isRead = json['read'];

  Map<String, dynamic> toJson() =>
      {'type': _alertType.toJson(), 'time': _time.millisecondsSinceEpoch, 'title': _title, 'body': _body, 'action': _clickAction, 'read': _isRead};

  /// 알림 객체 위젯
  Widget getBanner() {
    return Container(
      decoration: BoxDecoration(
          color: _isRead ? const Color(0xFFF2F2F2) : Colors.white
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isRead ? Icons.alarm_on : Icons.alarm,
                    size: 30,
                    color: _isRead ? colorGrey: colorSuccess,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(getTimeBefore(_time.toString()), style: TextStyle(color: _isRead ? colorGrey : Colors.black, fontSize: 12),),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20,),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _isRead ? colorGrey : Colors.black), overflow: TextOverflow.fade),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(_body, style: const TextStyle(color: colorGrey, fontSize: 14), overflow: TextOverflow.fade),
                ],
              ),
            ),
          ],
        ),
      ),

      constraints: BoxConstraints(minHeight: 75, maxHeight: 200),
    );
  }
}

/// 알림 인앱 배너를 눌렀을 때 이루어지는 이벤트 종류들
/// [TO_POST] 게시물로 이동
/// [TO_CHAT_ROOM] 1:1 또는 모임 채팅방으로 이동
/// [TO_PROFILE] 프로필 페이지로 이동 (나의 프로필 or 유저의 프로필)
/// [TO_SHARE_LOCATION_PAGE] 위치 공유 페이지로 이동
enum AlertType {
  TO_POST,
  TO_CHAT_ROOM,
  TO_PROFILE,
  TO_SHARE_LOCATION,
  FCM_TEST,
  NONE;

  String toJson() => name;

  static AlertType fromJson(String json) => values.byName(json);
}
