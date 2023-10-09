import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageShareLocation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageShareLocation();
}

class _PageShareLocation extends State<PageShareLocation> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        toolbarHeight: 40,
        title: const Text("모임원 위치 찾기", style: const TextStyle(fontSize: 16),),
        leading: const BackButton(),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(child: Text("hello")),
      )
    );
  }

  @override
  void initState() {
    super.initState();

  }
}