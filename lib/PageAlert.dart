import 'package:flutter/material.dart';

class PageAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          '알림목록',
          style: TextStyle(
              fontSize: 18,
              color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: 10, // 알림 개수
        itemBuilder: (BuildContext context, int index) {
          return Card(
              child: ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.alarm),
                    onPressed: () {},
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

