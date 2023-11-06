import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/alert/models/alert_manager.dart';
import 'package:design_project/alert/models/alert_object.dart';
import 'package:design_project/main.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:design_project/resources/resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../boards/post_list/page_hub.dart';

class PageAlert extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageAlert();
}

class _PageAlert extends State<PageAlert> with AutomaticKeepAliveClientMixin {
  AlertManager? _alertManager;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 1,
            title: Text(
              '알림',
              style: TextStyle(fontSize: 19, color: Colors.black),
            ),
            backgroundColor: Colors.white,
            actions: [
              SizedBox(width: 55, height: 55, child: PullDownButton(
                itemBuilder: (context) =>
                [
                  const PullDownMenuTitle(title: Text("알림 옵션")),
                  PullDownMenuItem.selectable(
                    iconWidget: const Icon(CupertinoIcons.trash),
                    title: '알림 비우기',
                    itemTheme: PullDownMenuItemTheme(textStyle: TextStyle(color:Colors.redAccent)),
                    onTap: () {
                      _showRemoveAlertPopup();
                    },
                  ),
                  PullDownMenuItem.selectable(
                    iconWidget: const Icon(CupertinoIcons.checkmark_alt),
                    title: '모두 읽음 처리',
                    onTap: () async {
                      hubLoadingStateSetter!(() {
                        hubLoadingContainerVisible = true;
                      });
                      await _alertManager!.readAll();
                      hubLoadingStateSetter!(() {
                        hubLoadingContainerVisible = false;
                      });
                      setState(() {});
                    },
                  )
                ],
                buttonBuilder: (context, showMenu) =>
                    CupertinoButton(
                      onPressed: showMenu,
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.ellipsis, color: Colors.black,),
                    ),
              )
              )
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>?>(
                  stream: FirebaseFirestore.instance.collection("Alert").doc(myUuid).collection("alert").snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return buildLoadingProgress();
                    }
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        /// 현재 LocalStorage 안에다 데이터베이스에 있는 알림 리스트 불러오고, 불러온 DB 삭제
                        List<QueryDocumentSnapshot> alertDBList = snapshot.data!.docs;
                        if (alertDBList.length != 0) {
                          _alertReadByDatabase(alertDBList);
                        }
                        if (_alertManager!.alertList.length == 0) {
                          return Center(child: Text("표시할 알림이 없어요", style: TextStyle(color: colorGrey, fontSize: 14),),);
                        }
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter listViewRefresh) {
                            return ListView.separated(
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == 0 || index == _alertManager!.alertList.length + 1) {
                                    // 첫번째와 마지막에 공백 추가.
                                    return const SizedBox();
                                  }
                                  AlertObject alert = _alertManager!.alertList[_alertManager!.alertList.length - index];
                                  return GestureDetector(
                                    onTap: () async {
                                      bool isReading = alert.reading();
                                      if (isReading) {
                                        await _alertManager!.readAlertCount(myUuid!);
                                        await _alertManager!.saveAlert(isSync: true).then((successful) { if(successful) listViewRefresh((){});});
                                      }
                                      alert.onClick();
                                    },
                                    child: alert.getBanner(),
                                  );
                                },
                                itemCount: _alertManager!.alertList.length > 0 ? _alertManager!.alertList.length + 2 : 0,
                                separatorBuilder: (BuildContext context, int index) => Divider(thickness: 1.5, height: 1.5));
                          },
                        );
                      } else {
                        return SizedBox();
                      }
                    } else {
                      return buildLoadingProgress();
                    }
                  },
                ),
              )
            ],
          ),
        ),

      ]
    );
  }

  _alertReadByDatabase(List<QueryDocumentSnapshot> snapshotList) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        snapshotList.forEach((qds) async {
          Map<String, dynamic> alertJson = jsonDecode(qds.get("alertJson"));
          await _alertManager!.addAlert(alertObject: AlertObject.fromJson(alertJson));
          await qds.reference.delete();
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showRemoveAlertPopup() async {
    final action = CupertinoActionSheet(
      title: Text(
        "알림을 비울까요?",
        style: TextStyle(fontSize: 15),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("비우기"),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            hubLoadingStateSetter!(() {
              hubLoadingContainerVisible = true;
            });
            await _alertManager!.clearAlert();
            setState(() {});
            hubLoadingStateSetter!(() {
              hubLoadingContainerVisible = false;
            });
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("취소"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    await showCupertinoModalPopup(
        context: context, builder: (context) => action);
  }

  @override
  void initState() {
    super.initState();
    _alertManager = AlertManager(LocalStorage!);
    _alertManager!.loadAlert();
  }

  @override
  bool get wantKeepAlive => true;
}
