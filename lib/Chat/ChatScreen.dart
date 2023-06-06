import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChatMessage.dart';
import 'PageUserPosition.dart';

class ChatScreen extends StatefulWidget {
  final int postId;

  const ChatScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState(postId);
}

class _ChatScreenState extends State<ChatScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  final int postId;
  _ChatScreenState(this.postId);

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }



  @override
    Widget build(BuildContext context) {
    print(postId);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF6ACA89),
          title: Text('Chat Room $postId'),
          actions: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GoogleMapPage()),
                          );
                        },
                        label: Container(
                          width: 60,
                          child: Text('위치공유',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        backgroundColor: Color(0xFF6ACA89),
                        heroTag: null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('모임'),
                                content: Container(
                                  width: double.maxFinite,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '시간: 18:30 PM',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '장소: 안서 동보 앞 GS25',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('닫기'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        label: Container(
                          width: 60,
                          child: Text('모임일정',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        backgroundColor: Color(0xFF6ACA89),
                        heroTag: null,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Messages(),
              ),
              //NewMessage(),
            ],
          ),
        ),
      );
    }
}
