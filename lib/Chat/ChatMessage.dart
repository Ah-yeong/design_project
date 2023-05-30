import 'package:flutter/material.dart';
import 'ChatBubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:intl/intl.dart';



class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  late SharedPreferences _preferences;
  final _chatController = TextEditingController();
  late DatabaseReference _chatRef;

  @override
  void initState() {
    super.initState();
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
                  final timestamp = chat['time'] as Timestamp;
                  final dateTime = timestamp.toDate();
                  final formattedTime = DateFormat.jm().format(dateTime);
                  //return ChatBubble(chat['text'], isMe,);
                  return Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        ChatBubble(chat['text'], isMe),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ),
            Container(
              width: 382,
              height: 40,
              child: TextField(
                controller: _chatController,
                onSubmitted: (value) {_sendMessage();},
                decoration: InputDecoration(
                  hintText: 'Enter your message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                  suffixIcon: IconButton(
                    onPressed: () {_sendMessage();},
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

//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// class Messages extends StatefulWidget {
//   const Messages({Key? key}) : super(key: key);
//
//   @override
//   _MessagesState createState() => _MessagesState();
// }
//
// class _MessagesState extends State<Messages> {
//   late SharedPreferences _preferences;
//   final _chatController = TextEditingController();
//   late DatabaseReference _chatRef;
//
//   @override
//   void initState() {
//     super.initState();
//     _chatRef = FirebaseDatabase.instance.reference().child('chat');
//     _initSharedPreferences();
//   }
//
//   @override
//   void dispose() {
//     _chatController.dispose();
//     super.dispose();
//   }
//
//   void _sendMessage() {
//     final user = FirebaseAuth.instance.currentUser;
//     final chatData = _chatController.text.trim();
//     FirebaseFirestore.instance.collection('chat').add({
//       'text': chatData,
//       'time': Timestamp.now(),
//       'userID': user!.uid,
//     });
//     _chatController.clear();
//   }
//
//   Future<void> _initSharedPreferences() async {
//     _preferences = await SharedPreferences.getInstance();
//     setState(() {}); // _preferences를 초기화한 후에 다시 build 되도록 setState 호출
//   }
//
//   List<String> _getSavedChatData() {
//     return _preferences.getStringList('chat_data') ?? [];
//   }
//
//   DatabaseReference chatRef = FirebaseDatabase.instance.reference().child('chat');
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     final savedChatData = _getSavedChatData();
//
//     _chatRef.onChildAdded.listen((event) {
//       final chatData = event.snapshot.value as Map<dynamic, dynamic>;
//       final isMe = chatData['userID'] == user!.uid;
//
//       // 상대방의 화면에 채팅 메시지 표시
//       if (!isMe) {
//         setState(() {
//           savedChatData.add(chatData['text']);
//         });
//       }
//     });
//
//     return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: FirebaseFirestore.instance
//         .collection('chat')
//         .orderBy('time', descending: true)
//         .snapshots(),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return Center(
//           child: CircularProgressIndicator(),
//         );
//       }
//       final chatDocs = snapshot.data!.docs;
//       void handleData(QuerySnapshot<Map<String, dynamic>> snapshot) {
//       final chatDocs = snapshot.docs;
//       // 변경된 데이터 가져오기
//       final newData = chatDocs.map((doc) => doc.data()).toList();
//       print('New Data: $newData');
//       }
//       // 초기 데이터 처리
//       handleData(snapshot.data!);
//       return Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               reverse: true,
//               itemCount: chatDocs.length,
//               itemBuilder: (context, index) {
//               final chat = chatDocs[index].data() as Map<String, dynamic>;
//               final isMe = chat['userID'] == user!.uid;
//               final timestamp = chat['time'] as Timestamp;
//               final dateTime = timestamp.toDate();
//               final formattedTime = DateFormat.jm().format(dateTime);
//
//             return Row(
//               mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//               children: [
//                 ChatBubble(chat['text'], isMe),
//                 Text(
//                   formattedTime,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             );
//               },
//             ),
//           ),
//           Container(
//             width: 382,
//             height: 40,
//             child: TextField(
//               controller: _chatController,
//               onSubmitted: (value) {
//                 _sendMessage();
//               },
//               decoration: InputDecoration(
//                 hintText: 'Enter your message',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(9.0),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(vertical: 12.0),
//                 suffixIcon: IconButton(
//                   onPressed: () {
//                     _sendMessage();
//                   },
//                   icon: Icon(Icons.send),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     },
//     );
//   }
// }
//
// class ChatBubble extends StatelessWidget {
//   final String text;
//   final bool isMe;
//
//   ChatBubble(this.text, this.isMe);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       decoration: BoxDecoration(
//         color: isMe ? Colors.blueAccent : Colors.grey[200],
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 16,
//           color: isMe ? Colors.white : Colors.black,
//         ),
//       ),
//     );
//   }
// }
//
//}