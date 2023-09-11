import 'dart:async';

import 'package:design_project/main.dart';
import 'package:flutter/material.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreenPage();
}

class _SplashScreenPage extends State<SplashScreenPage> {
  @override
  Widget build(BuildContext context) {
    final String imageLogoName = 'assets/images/public/PurpleLogo.svg';

    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor:1.0),
        child: Scaffold(
          backgroundColor: const Color(0xFF6F22D2),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: screenHeight * 0.384375),
              Image.asset(
                imageLogoName,
                width: screenWidth * 0.616666,
                height: screenHeight * 0.0859375,
              ),
              const Expanded(child: SizedBox()),
              Align(
                child: Text("쉽게 만나자, 사람 끼리",
                    style: TextStyle(
                      fontSize: screenWidth*( 14/360), color: Color.fromRGBO(255, 255, 255, 0.6),)
                ),
              ),
              SizedBox( height: MediaQuery.of(context).size.height*0.0625,),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    Timer(Duration(milliseconds: 1500), () {
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => const MyHomePage()
      )
      );
    });
  }
}