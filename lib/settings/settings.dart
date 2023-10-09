import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/meeting/share_location.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../boards/post_list/page_hub.dart';

class PageSettings extends StatelessWidget {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6ACA89),
        title: Text('설정'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('콜렉션 생성'),
            onTap: () {
              // _database
              //     .collection("TestCollection")
              //     .doc(DateTime.now().millisecondsSinceEpoch.toString())
              //     .set({"a": true});
              // _database.collection("TestCollection").get().then((d) {
              //   for (DocumentSnapshot ds in d.docs) {
              //     print(ds.id);
              //   }
              // });
            },
          ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
            title: Text('콜렉션 삭제'),
            onTap: () {
              // CollectionReference _collection = _database.collection("TestCollection");
              // _collection.get().then((qs) {
              //   List<QueryDocumentSnapshot> list = qs.docs;
              //   for (int i = 0; i < list.length; i++) {
              //     _collection.doc(list[i].id).delete();
              //     print("${list[i].id} is deleted!");
              //   }
              //   for (DocumentSnapshot ds in qs.docs) {
              //     _collection.doc(ds.id).delete();
              //     print("${ds.id} is deleted!");
              //   }
              // });
            },
          ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
            title: Text('위치 공유 화면'),
            onTap: () {
              Get.to(() => PageShareLocation(), arguments: 43);
            },
          ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          ListTile(
            title: Text('채팅 데이터 지우기'),
            onTap: () async {
              // SharedPreferences _shared = await SharedPreferences.getInstance();
              // int count = 0;
              // for (String key in _shared.getKeys()) {
              //   if (key.contains("ChatData") && key.contains(myUuid!)) {
              //     print("remove $key");
              //     await _shared.remove(key);
              //     count++;
              //   }
              // }
              // print("$count개 데이터 삭제 완료");
            },
          ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
            title: Text('기기 채팅 데이터 전체삭제'),
            onTap: () async {
              // SharedPreferences _shared = await SharedPreferences.getInstance();
              // int count = 0;
              // for (String key in _shared.getKeys()) {
              //   if (key.contains("ChatData")) {
              //     print("remove $key");
              //     await _shared.remove(key);
              //     count++;
              //   }
              // }
              // print("$count개 데이터 삭제 완료");
            },
          ),
        ],
      ),
    );
  }
}
