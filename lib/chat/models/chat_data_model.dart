import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDataModel {
  String text;
  Timestamp ts;
  String nickName;
  int? unreadCount;
  String? uuid;

  ChatDataModel({required this.text, required this.ts, required this.nickName, this.unreadCount, this.uuid});

  ChatDataModel.fromJson(Map<String, dynamic> json)
      : text = json['text'] as String,
        ts = Timestamp.fromDate(DateTime.parse(json['ts'])),
        nickName = json['nick'] as String,
        uuid = json['uuid'] ?? "";

  Map<String, dynamic> toJson() => {
        'text': text,
        'ts': ts.toDate().toString(),
        'nick': nickName,
        'uuid': uuid
      };
}
