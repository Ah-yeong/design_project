import 'package:flutter/material.dart';

//설정 -> 커뮤니티 이용규칙
class CommunityRulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('커뮤니티 이용규칙'),
        backgroundColor: Color(0xFF6ACA89),
      ),
      body: Center(
        child: Text('커뮤니티 이용규칙 페이지'),
      ),
    );
  }
}