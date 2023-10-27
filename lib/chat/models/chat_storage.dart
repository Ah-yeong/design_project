import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../boards/post_list/page_hub.dart';
import 'chat_data_model.dart';

class ChatStorage {
  String id;
  SharedPreferences? _storage;
  List<ChatDataModel> savedChatList = List.empty(growable: true);

  ChatStorage(this.id);

  Future<void> init() async {
    _storage = await SharedPreferences.getInstance();
    return;
  }

  SharedPreferences getStorage() {
    return _storage!;
  }

  save() {
    _storage!.setString("${myUuid}_ChatData_$id", jsonEncode(savedChatList));
  }

  load() {
    if (_storage!.getString("${myUuid}_ChatData_$id") == null) {
      return;
    }
    savedChatList = listDataFromJson(_storage!.getString("${myUuid}_ChatData_$id")!);
  }

  remove() {
    if (_storage!.getString("${myUuid}_ChatData_$id") == null) {
      return;
    }
    _storage!.remove("${myUuid}_ChatData_$id");
  }

  List<ChatDataModel> listDataFromJson(String json) {
    List<dynamic> parsedJson = jsonDecode(json);
    List<ChatDataModel> listdatas = [];
    for (int i = 0; i < parsedJson.length; i++) {
      listdatas.add(ChatDataModel.fromJson(parsedJson[i]));
    }
    return listdatas;
  }
}
