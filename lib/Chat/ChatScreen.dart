import 'package:flutter/material.dart';

import 'PageUserPosition.dart';
import 'ChatMessage.dart';

const String _name = "Name";

class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(
        backgroundColor: Color(0xFF6ACA89),
        title: Text('같이타자 채팅'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height:10),
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
                        MaterialPageRoute(builder: (context) => GoogleMapPage()),
                      );},
                    label: Container(
                      width: 60,
                      child: Text( '위치공유',
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
                                    //'배고파',
                                    style : TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '장소: 안서 동보 앞 GS25',
                                    //'배고프다고',
                                    style : TextStyle(fontSize: 18),
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
                      child: Text( '모임일정',
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
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor
            ),
            child: _buildTextComposer(),
          ),
          SizedBox(height:10),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Colors.black),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget>[
              Flexible(
                child: TextField(
                  controller: _textController,
                  onSubmitted: _handleSubmitted,
                  decoration: new InputDecoration.collapsed(
                      hintText: "Send a message"),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => _handleSubmitted(_textController.text)),
              ),
            ],
          )
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    var message = ChatMessage(
      text: text,
    );
    setState(() {
      _messages.insert(0, message);
    });
  }
}