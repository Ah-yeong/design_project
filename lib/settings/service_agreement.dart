import 'package:flutter/material.dart';

//설정 -> 서비스 이용약관
class ServiceAgreementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('서비스 이용약관'),
        backgroundColor: Color(0xFF6ACA89),
      ),
      body: Center(
        child: Text('서비스 이용약관 페이지'),
      ),
    );
  }
}
