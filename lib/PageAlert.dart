import 'package:flutter/material.dart';

class PageAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text('알림 목록')
      ),
      body: ListView.builder(
        itemCount: 10, // 알림 개수
        itemBuilder: (BuildContext context, int index) {
          return Card(
              child: ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.alarm),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  title: Text('알림 제목 $index'),
                  subtitle: Text('알림 내용 $index'),
                  trailing: Text('10시간 전')// 알림 발생 시각
              )
          );
        },
      ),
    );
  }
}

