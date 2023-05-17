import 'package:design_project/Boards/BoardPostPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../resources.dart';

class BoardGroupListPage extends StatefulWidget {
  const BoardGroupListPage({super.key});

  @override
  State<StatefulWidget> createState() => _BoardGroupListPage();
}

class _BoardGroupListPage extends State<BoardGroupListPage> {
  var count = 10;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        /*SliverToBoxAdapter(
          child: Container(
            height: 400,
            color: Colors.grey,
          ),
        ),*/
        SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) => GestureDetector(
                  onTap: () {
                    naviToPost("$index");
                  },
                  child: Card(
                      child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: _buildFriendRow(index))),
                ),
                childCount: 40))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  naviToPost(String index) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => BoardPostPage(postId: index)));
  }

  // 바로 모임 카드
  Widget _buildFriendRow(var index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 15,
          height: 10,
        ),
        Icon(index == 0
            ? Icons.person
            : index == 1
                ? CupertinoIcons.person_2_fill
                : CupertinoIcons.person_3_fill),
        const SizedBox(
          width: 25,
          height: 10,
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1} 번째 게시글 제목',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text(
                            '작성자 닉네임 ${index + 1}',
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF858585)),
                          ))
                    ],
                  )),
              const Padding(
                padding: EdgeInsets.only(bottom: 18),
              ),
              const Text(
                '모임 시간 : 7일 뒤 / 35분 남음 / NN:NN',
                style: TextStyle(fontSize: 11, color: Color(0xFF858585)),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color(0xFFBFBFBF)),
                        child: const Padding(
                          padding: EdgeInsets.only(
                              right: 5, left: 5, top: 3, bottom: 3),
                          child: Text("카테고리",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 1, right: 1),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color(0xFFBFBFBF)),
                        child: const Padding(
                          padding: EdgeInsets.only(
                              right: 5, left: 5, top: 3, bottom: 3),
                          child: Text("20~24세",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 1, right: 1),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color(0xFFBFBFBF)),
                        child: const Padding(
                          padding: EdgeInsets.only(
                              right: 5, left: 5, top: 3, bottom: 3),
                          child: Text("남자만",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 4),
                      child: Container(
                        width: 60,
                        height: 25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: const Color(0xFF6ACA9A),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Center(
                            child: Text("모집중 $index/4",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 9.5)),
                          ),
                        ),
                      ))
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
