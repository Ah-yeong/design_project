import 'package:design_project/Board/BoardPostPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../resources.dart';

class BoardTaxiListPage extends StatefulWidget {
  const BoardTaxiListPage({super.key});

  @override
  State<StatefulWidget> createState() => _BoardTaxiListPage();
}

class _BoardTaxiListPage extends State<BoardTaxiListPage> {
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
                          child: _buildTaxiRow(index))),
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

  // 택시 카드
  Widget _buildTaxiRow(var index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 15,
          height: 10,
        ),
        const Icon(CupertinoIcons.car_detailed),
        const SizedBox(
          width: 25,
          height: 10,
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  '${index + 1} 번째 게시글 제목',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
              ),
              const Text(
                '탑승 시간 : NN:NN',
                style: TextStyle(fontSize: 12, color: Color(0xFF858585)),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  '상명대학교 정문 -> 두정역 1호선',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF858585)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4, bottom: 2),
                child: Container(
                    width: 60,
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFF999999),
                    ),
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text("${(index+1) * 100000}원",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10)),
                        ),
                      ),
                    )),
              ),
              Padding(padding: EdgeInsets.only(bottom: 2)),
              Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 4),
                  child: Container(
                      width: 60,
                      height: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFF6ACA9A),
                      ),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text("모집중 $index/4",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      )))
            ],
          ),
        )
      ],
    );
  }
}
