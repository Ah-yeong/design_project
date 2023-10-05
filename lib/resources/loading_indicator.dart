import 'package:design_project/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget buildContainerLoading(int alpha) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      color: Colors.black.withAlpha(alpha),
    ),
    child: Center(
        child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("데이터를 처리중이에요", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.none), ),
                SpinKitThreeBounce(size: 25, color: const Color(0xDDFFFFFF), duration: const Duration(milliseconds: 1200))
              ],
            )
    ),
  );
}

Widget buildLoadingProgress() {
  return Center(
    child: SpinKitThreeBounce(size: 25, color: colorGrey, duration: const Duration(milliseconds: 1200)),
  );
}
