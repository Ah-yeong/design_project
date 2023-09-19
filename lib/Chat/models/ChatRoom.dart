class ChatRoom {
  late bool isGroupChat;
  int? postId;
  List<String>? members;
  String? recvUserNick;
  String? recvUserId;

  ChatRoom({required this.isGroupChat, this.postId, this.members, this.recvUserId, this.recvUserNick});
}
