import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _commentsSwitchValue = true; //댓글
  bool _popularSwitchValue = true; //인기글
  bool _chatSwitchValue = false; //채팅
  bool _scheduleBriefingSwitchValue = true;   //일정 브리핑

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림설정'),
        backgroundColor: Color(0xFF6ACA89),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('댓글'),
            trailing: Switch(
              value: _commentsSwitchValue,
              onChanged: (value) {
                setState(() {
                  _commentsSwitchValue = value;
                });
              },
            ),
          ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
            title: Text('인기글'),
            trailing: Switch(
              value: _popularSwitchValue,
              onChanged: (value) {
                setState(() {
                  _popularSwitchValue = value;
                });
              },
            ),
          ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
            title: Text('채팅'),
            trailing: Switch(
              value: _chatSwitchValue,
              onChanged: (value) {
                setState(() {
                  _chatSwitchValue = value;
                });
              },
            ),
          ),
          Divider(
            color: Colors.grey[400],
            thickness: 2,
            indent: 10,
            endIndent: 10,
          ),

          ListTile(
            title: Text('일정 브리핑'),
            trailing: Switch(
              value: _scheduleBriefingSwitchValue,
              onChanged: (value) {
                setState(() {
                  _scheduleBriefingSwitchValue = value;
                });
              },
            ),
          ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
        ],
      ),
    );
  }
}
