import 'package:flutter/material.dart';

class QAPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Q&A'),
        backgroundColor: Color(0xFF6ACA89),
      ),
      body: Center(
        child: Text('Q&A 페이지'),
      ),
    );
  }
}
