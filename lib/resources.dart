import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color colorSuccess = const Color(0xFF6ACA89);
const Color colorGrey = const Color(0xFF777777);
const Color colorWarning = const Color(0xFFFFae69);
const Color colorError = const Color(0xFFEE7070);

void showAlert(String message, BuildContext cont, Color color) {
  final snackBar = SnackBar(
    elevation: 2,
    content: Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: 15),
      textAlign: TextAlign.center,
    ),
    duration: Duration(milliseconds: 1300),
    backgroundColor: color,
  );

  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  ScaffoldMessenger.of(cont).showSnackBar(snackBar);
} // 메시지 박스 띄우기
