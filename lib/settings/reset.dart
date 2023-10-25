import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../resources/resources.dart';

class PageReset extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageReset();
}

class _PageReset extends State<PageReset> {

  bool _isProgress = false;

  /** 0 :  [POST]
   *
   * 1 : [POST\_GROUP_CoHAT]
   *
   * 2 : [PROCESSING_POST]
   *
   * 3 : [SHARE_LOCATION]
   *
   * 4 : [MEETINGS]
   *
   * 5 : [CHAT]
   *
   * 6 : [USER\_CHAT_DATA]
   *
   * 7 : [USER_MEETINGS]
   *
   * 8 : [USER_PROFILE -> POST]
   */
  List<bool> _isChecked = List.of([false, false, false, false, false, false, false, false, false]);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              "초기화하기",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox(
                height: 55,
                width: 55,
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.black,
                ),
              ),
            ),
            backgroundColor: Colors.white,
            toolbarHeight: 40,
            elevation: 1,
          ),
          backgroundColor: Colors.white,
          body: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                child: ListView.builder(itemBuilder: (context, index) {
                  return index != 9 ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      child: Row(
                        children: [
                          Transform.scale(
                              scale: 0.9,
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _isChecked[index],
                                  onChanged: (_val) {
                                    setState(() {
                                      _isChecked[index] = _val!;
                                    });
                                  },
                                  activeColor: colorSuccess,
                                ),
                              )),
                          Text(
                            getTextValue(index),
                            style: TextStyle(fontSize: 15),
                          )
                        ],
                      ),
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _isChecked[index] = !_isChecked[index];
                        });
                      },
                    ),
                  ) : ElevatedButton(onPressed: () async {
                    setState(() {
                      _isProgress = true;
                    });
                    var instance = FirebaseFirestore.instance;
                    if (_isChecked[0]) { // POST
                      QuerySnapshot qs = await instance.collection("Post").get();
                      await Future.forEach(qs.docs, (element) async {
                        if(element.id == "postData") {
                          await element.reference.set({"last_id": 0});
                        } else {
                          await element.reference.delete();
                        }
                      });
                    }
                    if (_isChecked[1]) { // POST_GROUP_CHAT
                      QuerySnapshot qs = await instance.collection("PostGroupChat").get();
                      await Future.forEach(qs.docs, (element) async {
                        await element.reference.delete();
                      });
                    }
                    if (_isChecked[2]) { // PROCESSING_POST
                      QuerySnapshot qs = await instance.collection("ProcessingPost").get();
                      await Future.forEach(qs.docs, (element) async {
                        await element.reference.delete();
                      });
                    }
                    if (_isChecked[3]) { // SHARE_LOCATION
                      QuerySnapshot qs = await instance.collection("ShareLocation").get();
                      await Future.forEach(qs.docs, (element) async {
                        await element.reference.delete();
                      });
                    }
                    if (_isChecked[4]) { // MEETINGS
                      QuerySnapshot qs = await instance.collection("Meetings").get();
                      await Future.forEach(qs.docs, (element) async {
                        await element.reference.delete();
                      });
                    }
                    if (_isChecked[5]) { // CHAT
                      QuerySnapshot qs = await instance.collection("Chat").get();
                      await Future.forEach(qs.docs, (element) async {
                        await element.reference.delete();
                      });
                    }
                    if (_isChecked[6]) { // USER_CHAT_DATA
                      QuerySnapshot qs = await instance.collection("UserChatData").get();
                      await Future.forEach(qs.docs, (element) async {
                        await element.reference.delete();
                      });
                    }
                    if (_isChecked[7]) { // USER_MEETINGS
                      QuerySnapshot qs = await instance.collection("UserMeetings").get();
                      await Future.forEach(qs.docs, (element) async {
                        await element.reference.delete();
                      });
                    }
                    if (_isChecked[8]) { // USER_PROFILE -> POST
                      QuerySnapshot qs = await instance.collection("UserProfile").get();
                      await Future.forEach(qs.docs, (element) async {
                        element.reference.update({"post" : null});
                      });
                    }
                    setState(() {
                      _isProgress = false;
                      showAlert("삭제 완료", context, colorError, duration: Duration(milliseconds: 3000));
                    });
                  }, child: Text("진행시켜"));
                }, itemCount: 10,),
              )
          ),
        ),
        _isProgress ? buildContainerLoading(130) : SizedBox()
      ],
    );
  }

  String getTextValue(int index) {
    switch(index) {
      case 0: return "POST (게시글)";
      case 1: return "POST_GROUP_CHAT (모임 채팅 내용)";
      case 2: return "PROCESSING_POST (진행중 게시글)";
      case 3: return "SHARE_LOCATION (위치 공유 정보)";
      case 4: return "MEETINGS (모임 정보)";
      case 5: return "CHAT (1:1 채팅 내용)";
      case 6: return "USER_CHAT_DATA (유저의 채팅 정보)";
      case 7: return "USER_MEETINGS (유저의 모임 정보)";
      case 8: return "USER_PROFILE -> POST (유저가 쓴 글)";
      default: return "오류";
    }
  }
}