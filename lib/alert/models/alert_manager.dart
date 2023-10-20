import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/boards/post_list/page_hub.dart';
import 'package:design_project/entity/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../resources/fcm.dart';
import 'alert_object.dart';

class AlertManager {
  final ALERT_FIELD = "alert_$myUuid";
  SharedPreferences _preferences;
  List<AlertObject> _alertList = [];
  List<String> _alertStringList = [];

  AlertManager(this._preferences);

  get alertList => _alertList;

  loadAlert() {
    if (_preferences.getStringList(ALERT_FIELD) != null) {
      _alertList.clear();
      _alertStringList = _preferences.getStringList(ALERT_FIELD)!;

      _alertStringList.forEach((alert) {
        _alertList.add(AlertObject.fromJson(jsonDecode(alert)));
      });
    }
  }

  /// isSync : alertList만 수정했을 때, StringList도 수정하여 저장하는지 여부
  Future<bool> saveAlert({bool? isSync}) async {
    if (isSync != null && isSync) {
      _alertStringList.clear();
      _alertList.forEach((alert) {
        _alertStringList.add(jsonEncode(alert));
      });
    }
    return await _preferences.setStringList(ALERT_FIELD, _alertStringList);
  }

  Future<bool> addAlert({required AlertObject alertObject}) async {
    _alertList.add(alertObject);
    _alertStringList.add(jsonEncode(alertObject));
    return saveAlert();
  }

  /// 주의 : clickAction을 쓸 때 AlertType이 제대로 작성되지 않으면 동작하지 않을 수 있음
  Future<bool> sendAlert({required String title, required String body, required AlertType alertType, required String userUUID, Map<String, String>? clickAction, required bool withPushNotifications}) async {
    bool successful = false;
    try {
      DateTime time = DateTime.now();
      AlertObject tempObj = AlertObject(title: title, body: body, time: time, alertType: alertType, isRead: false, clickAction: clickAction);
      DocumentReference ref = FirebaseFirestore.instance.collection("Alert").doc(userUUID);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var documentSnapshots = await transaction.get(ref);
        if ( documentSnapshots.exists ) {
          await transaction.update(ref, {"unread_alert" : FieldValue.increment(1)});
        } else {
          await transaction.set(ref, {"unread_alert" : 1});
        }
      });
      await ref.collection("alert").doc(time.millisecondsSinceEpoch.toString()).set({"alertJson" : jsonEncode(tempObj.toJson())});
      if ( withPushNotifications ) {
        EntityProfiles profile = EntityProfiles(userUUID);
        await profile.loadProfile();
        FCMController controller = FCMController();
        String? pushSuccessful = await controller.sendMessage(userToken: profile.fcmToken, title: title, body: body, type: alertType, clickAction: clickAction);
        successful = pushSuccessful == null;
      } else {
        successful = true;
      }
    } catch (e) {
      print(e);
      successful = false;
    }
    return successful;
  }

  Future<void> readAlertCount(String userUUID) async {
    DocumentReference ref = FirebaseFirestore.instance.collection("Alert").doc(userUUID);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      var documentSnapshots = await transaction.get(ref);
      if ( documentSnapshots.exists ) {
        if (documentSnapshots.get("unread_alert") > 0 )
        await transaction.update(ref, {"unread_alert" : FieldValue.increment(-1)});
      } else {
        await transaction.set(ref, {"unread_alert" : 0});
      }
    });
    return;
  }

}