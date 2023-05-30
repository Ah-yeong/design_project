// import 'package:flutter/material.dart';
//
// const String _name = "Name";
//
// class ChatMessage extends StatelessWidget {
//   ChatMessage({this.text, this.icon});
//   final String? text;
//   final Icon? icon;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Container(
//             margin: const EdgeInsets.only(right: 16.0),
//             child: CircleAvatar(child: Text(_name[0])),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               if (icon!=null) icon!,
//               Text(_name, style: Theme.of(context).textTheme.bodyText1),
//               Container(
//                 margin: const EdgeInsets.only(top: 5.0),
//                 child: Text(text!),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'ChatBubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  late SharedPreferences _preferences;
  final _chatController = TextEditingController();

  late DatabaseReference _chatRef;
  //final _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //_userEnterMessage = ''; // 초기화 코드를 initState에서 수행
    _chatRef = FirebaseDatabase.instance.reference().child('chat');
    _initSharedPreferences();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final user = FirebaseAuth.instance.currentUser;
    final chatData = _chatController.text.trim();
    FirebaseFirestore.instance.collection('chat').add({
      'text' : chatData,
      'time' : Timestamp.now(),
      'userID' : user!.uid,
    });
    _chatController.clear();

  }

  Future<void> _initSharedPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {}); // _preferences를 초기화한 후에 다시 build 되도록 setState 호출
  }

  Future<void> _saveChatData(String chatData) async {
    final savedChatData = _preferences.getStringList('chat_data') ?? [];
    savedChatData.add(chatData);
    await _preferences.setStringList('chat_data', savedChatData);
  }

  List<String> _getSavedChatData() {
    return _preferences.getStringList('chat_data') ?? [];
  }

  DatabaseReference chatRef = FirebaseDatabase.instance.reference().child('chat');

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final savedChatData = _getSavedChatData();

    _chatRef.onChildAdded.listen((event) {
      final chatData = event.snapshot.value as Map<dynamic, dynamic>;
      final isMe = chatData['userID'] == user!.uid;

      // 상대방의 화면에 채팅 메시지 표시
      if (!isMe) {
        setState(() {
          savedChatData.add(chatData['text']);
        });
      }
    });


    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs;
        void handleData(QuerySnapshot<Map<String, dynamic>> snapshot) {
          final chatDocs = snapshot.docs;
          // 변경된 데이터 가져오기
          final newData = chatDocs.map((doc) => doc.data()).toList();
          print('New Data: $newData');
        }
        // 초기 데이터 처리
        handleData(snapshot.data!);

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: chatDocs.length,
                itemBuilder: (context, index) {
                  final chat = chatDocs[index].data() as Map<String, dynamic>;
                  final isMe = chat['userID'] == user!.uid;
                  //final userName = chatDocs[index]['userName'];
                  return ChatBubble(
                    chat['text'],
                    isMe,
                    //userName,
                  );
                },
              ),
            ),
            Container(
              width: 382,
              height: 40,
              child: TextField(
                controller: _chatController,
                onSubmitted: (value) {
                  _sendMessage();
                },
                decoration: InputDecoration(
                  hintText: 'Enter your message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _sendMessage();
                    },
                    icon: Icon(Icons.send),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
