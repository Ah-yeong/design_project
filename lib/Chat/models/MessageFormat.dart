import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String message;
  final String timestamp;
  final String nickName;
  final String senderUid;

  MessageModel({
    required this.senderUid,
    required this.message,
    required this.timestamp,
    required this.nickName
  });

  Map<String, dynamic> toMap() {
    return {
      "message" : message,
      "timestamp" : timestamp,
      "nickname" : nickName,
      "senderUid" : senderUid
    };
  }

  MessageModel fromMap(Map<String, dynamic> data) {
    return MessageModel(senderUid: data['senderUid'],
        message: data['message'],
        timestamp: data['timestamp'],
        nickName: data['nickname']);
  }
  // //서버로부터 map형태의 자료를 MessageModel형태의 자료로 변환해주는 역할을 수행함.
  // factory MessageModel.fromMap({required String id,required Map<String,dynamic> map}){
  //   return MessageModel(
  //       id: id,
  //       content: map['content']??'',
  //       sendDate: map['sendDate']??Timestamp(0, 0)
  //   );
  // }
  //
  // Map<String,dynamic> toMap(){
  //   Map<String,dynamic> data = {
  //     "message"
  //   };
  //   return data;
  // }

}
