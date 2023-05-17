import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color styleColor = const Color(0xFF6ACA89);
const Color fontGrey = const Color(0xFF777777);

void showAlert(String message, BuildContext cont) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: Duration(milliseconds: 1250),
    backgroundColor: Color(0xFFFF5555),
  );

  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  ScaffoldMessenger.of(cont).showSnackBar(snackBar);
} // 메시지 박스 띄우기
