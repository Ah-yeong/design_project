import 'package:flutter/material.dart';

const String _name = "Name";

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.icon});
  final String? text;
  final Icon? icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(child: Text(_name[0])),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (icon!=null) icon!,
              Text(_name, style: Theme.of(context).textTheme.bodyText1),
              Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: Text(text!),
              ),
            ],
          ),
        ],
      ),
    );
  }
}