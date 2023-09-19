import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDataModel {
  String text;
  Timestamp ts;
  String nickName;
  ChatDataModel({required this.text, required this.ts, required this.nickName});

  ChatDataModel.fromJson(Map<String, dynamic> json) :
        text = json['text'] as String,
        ts = Timestamp.fromDate(DateTime.parse(json['ts'])),
        nickName = json['nick'] as String;

  Map<String, dynamic> toJson() =>
      {
        'text' : text,
        'ts' : ts.toDate().toString(),
        'nick' : nickName,
      };
}