import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/Entity/entity_post.dart';
import 'package:design_project/Resources/resources.dart';

import 'chat_storage.dart';

class ChatRoom implements Comparable<ChatRoom> {
  late bool isGroupChat;
  int? postId;
  List<String>? members;
  String? recvUserNick;
  String? recvUserId;
  String? lastChat;
  String lastTimeStampString = "<Timestamp zone>";
  Timestamp? lastTimeStamp;
  int? unreadCount = 0;

  ChatRoom(
      {required this.isGroupChat,
      this.postId,
      this.members,
      this.recvUserId,
      this.recvUserNick,
      this.lastChat,
      this.unreadCount});

  Future<String> getLastChatting(Timestamp? timestamp) async {
    ChatStorage? _savedChat;
    _savedChat = ChatStorage(postId == null ? recvUserId! : postId!.toString());
    await _savedChat.init().then((value) => _savedChat!.load());
    // 로컬 저장소에 저장된 내용이 없을 경우
    if (_savedChat.savedChatList.length == 0) {
      if (timestamp != null) {
        lastTimeStamp = timestamp;
        return getTimeBefore(timestamp.toFormattedString());
      } else {
        lastTimeStamp = Timestamp.now();
        return "Error#[오류] 정보를 불러올 수 없음";
      }
    }
    Timestamp? localStamp = _savedChat.savedChatList.last.ts;
    if (timestamp != null) {
      if (timestamp.compareTo(localStamp) == 1) {
        // 파라미터의 timestamp가 더 크다면 (최신이라면)
        lastTimeStamp = timestamp;
        return getTimeBefore(timestamp.toFormattedString());
      } else {
        lastTimeStamp = localStamp;
        return "${getTimeBefore(localStamp.toFormattedString())}#${_savedChat.savedChatList.last.text}";
      }
    } else {
      lastTimeStamp = localStamp;
      return "${getTimeBefore(localStamp.toFormattedString())}#${_savedChat.savedChatList.last.text}";
    }
  }

  @override
  int compareTo(ChatRoom otherTimeStamp) {
    return otherTimeStamp.lastTimeStamp!.compareTo(lastTimeStamp!);
  }
}
