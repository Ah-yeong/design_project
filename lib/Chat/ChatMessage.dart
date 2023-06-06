import 'package:flutter/material.dart';
import 'ChatBubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
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
  late CollectionReference _chatCollection;

  @override
  void initState() {
    super.initState();
    _chatRef = FirebaseDatabase.instance.reference().child('chat');
    _chatCollection = FirebaseFirestore.instance.collection('chat');
    _initSharedPreferences();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser!.uid;
    final chatData = _chatController.text.trim();
    final timestamp = Timestamp.now();
    var userName;
    await FirebaseFirestore.instance.collection('UserData').doc(user)
        .get()
        .then((DocumentSnapshot ds) => userName = ds.get('nickName'));

    _chatCollection.add({
      'text': chatData,
      'time': timestamp,
      'userID': user,
      'nickname': userName,

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

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>?>(
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

        List<Widget> chatWidgets = [];
        DateTime? currentDate;

        for (int i = (chatDocs.length - 1); i >= 0; i--) {
          final chat = chatDocs[i].data() as Map<String, dynamic>;
          final isMe = chat['userID'] == user!.uid;
          final timestamp = chat['time'] as Timestamp;
          final dateTime = timestamp.toDate();
          final year = dateTime.year;
          final month = dateTime.month;
          final day = dateTime.day;
          //final weekday = dateTime.weekday;

          // 날짜가 바뀌면 날짜를 표시
          if (currentDate == null || currentDate.year != year ||
              currentDate.month != month || currentDate.day != day) {
            currentDate = DateTime(year, month, day);
            final formattedDate = DateFormat('yyyy-MM-dd E').format(
                currentDate);
            chatWidgets.add(
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          final formattedTime = DateFormat.jm().format(dateTime);
          final userID = chat['userID'];
          final userName = chat['nickname'];

          chatWidgets.add(
            Row(
              mainAxisAlignment: isMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (isMe)
                  Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ChatBubble(chat['text'], isMe, userName ?? 'Unknown'),
                if (!isMe)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView(
                reverse: true,
                children: chatWidgets.reversed.toList(),
              ),
            ),
            Container(
              width: 382,
              height: 40,
              margin: EdgeInsets.only(bottom: 16.0), // 상단 여백 조정
              child: TextField(
                controller: _chatController,
                onSubmitted: (value) {
                  _sendMessage();
                },
                decoration: InputDecoration(
                  hintText: ' Enter your message',
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