import 'package:design_project/Boards/post.dart';
import 'package:design_project/Boards/Search/search_post_list.dart';
import 'package:design_project/Entity/entity_post.dart';
import 'package:design_project/Resources/loading_indicator.dart';
import 'page_hub.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../Resources/resources.dart';

class BoardPostListPage extends StatefulWidget {
  const BoardPostListPage({super.key});

  @override
  State<StatefulWidget> createState() => _BoardGroupListPage();
}

class _BoardGroupListPage extends State<BoardPostListPage> with AutomaticKeepAliveClientMixin {
  var count = 10;

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return postManager.isLoading
        ? buildLoadingProgress()
        : CustomScrollView(
            controller: _scrollController,
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
                              naviToPost(index);
                            },
                            child: Card(
                                elevation: 0.5,
                                child: Padding(
                                    padding: const EdgeInsets.all(7),
                                    child: buildFriendRow(postManager.list[postManager.list.length - index - 1], 0.0))),
                          ),
                      childCount: postManager.loadedCount)),
            ],
          );
  }

  @override
  void initState() {
    super.initState();
    postManager.loadPages("").then((value) => setState(() {}));
    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.offset + 100 < _scrollController.position.minScrollExtent &&
            _scrollController.position.outOfRange &&
            !postManager.isLoading) {
          postManager.reloadPages("").then((value) => setState(() {}));
        }
      });
    });
  }

  naviToPost(int index) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            BoardPostPage(postId: postManager.list[postManager.list.length - index - 1].getPostId())));
  }

  @override
  bool get wantKeepAlive => true;
}

// 모임 카드
Widget buildFriendRow(EntityPost entity, double distance) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const SizedBox(
        width: 15,
        height: 10,
      ),
      Column(
        children: [
          Icon(entity.getPostCurrentPerson() == 1
              ? Icons.person
              : entity.getPostCurrentPerson() == 2
                  ? CupertinoIcons.person_2_fill
                  : CupertinoIcons.person_3_fill),
          Text(getMaxPersonText(entity),
              style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
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
                    '${entity.getPostHead()}', // 글 제목
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Text(
                      '${entity.getWriterNick()}', // 글 작성자 닉네임
                      style: const TextStyle(fontSize: 12, color: colorGrey),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
            ),
            distance != 0.0
                ? Row(
                    children: [
                      const Icon(
                        Icons.gps_fixed_sharp,
                        color: colorSuccess,
                        size: 13,
                      ),
                      Text(
                        " ${getDistanceString(entity.distance)}",
                        style: TextStyle(fontSize: 11, color: colorSuccess, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                : SizedBox(),
            SizedBox(
              height: distance == "" ? 0 : 1,
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: colorGrey,
                  size: 13,
                ),
                Text(
                  " ${entity.getLLName().AddressName}",
                  style: TextStyle(fontSize: 11, color: Color(0xFF858585)),
                ),
              ],
            ),
            SizedBox(
              height: 1,
            ),
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: colorGrey,
                  size: 13,
                ),
                Text(
                  getMeetTimeText(entity.getTime()),
                  style: TextStyle(fontSize: 11, color: Color(0xFF858585)),
                ),
              ],
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 18,
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: entity.getPostCurrentPerson() > 8 ? Colors.orangeAccent :entity.isVoluntary() ? Colors.orangeAccent : Colors.cyan),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: 5, left: 5),
                            child: Text(entity.getPostCurrentPerson() > 8 ? "자율참여" : entity.isVoluntary() ? "자율 참여" : "위치 공유",
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          // 더 추가해야함, 모집 완료
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    SizedBox(
                      height: 18,
                      child: Container(
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.circular(4), color: const Color(0xFFB0B0B0)),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: 5, left: 5),
                            child: Text(entity.getCategory(),
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: getAgeText(entity) != "나이 무관" ? 2 : 0,
                    ),
                    getAgeText(entity) != "나이 무관"
                        ? SizedBox(
                            height: 18,
                            child: Container(
                              decoration:
                                  BoxDecoration(borderRadius: BorderRadius.circular(4), color: const Color(0xFFB0B0B0)),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 5, left: 5),
                                  child: Text(getAgeText(entity),
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                    SizedBox(
                      width: getGenderText(entity) != "성별 무관" ? 2 : 0,
                    ),
                    getGenderText(entity) != "성별 무관"
                        ? SizedBox(
                            height: 18,
                            child: Container(
                              decoration:
                                  BoxDecoration(borderRadius: BorderRadius.circular(4), color: const Color(0xFFB0B0B0)),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 5, left: 5),
                                  child: Text(getGenderText(entity),
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                Padding(padding: EdgeInsets.only(right: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      color: const Color(0xFF858585),
                      size: 11,
                    ),
                    Text(" ${entity.getViewCount()}",
                        style: const TextStyle(color: const Color(0xFF858585), fontSize: 11)),
                  ],
                ),),
              ],
            ),
            SizedBox(
              height: 4,
            ),
          ],
        ),
      ),
    ],
  );
}

String getMaxPersonText(EntityPost post) {
  if (post.getPostMaxPerson() == -1) return "${post.getPostCurrentPerson()}";
  return "${post.getPostCurrentPerson()}/${post.getPostMaxPerson()}";
}

String getGenderText(EntityPost post) {
  if (post.getPostGender() == 0) {
    return "성별 무관";
  } else if (post.getPostGender() == 1) {
    return "남자만";
  } else {
    return "여자만";
  }
}

String getAgeText(EntityPost post) {
  if (post.getMinAge() == -1 && post.getMaxAge() == -1) {
    return "나이 무관";
  } else if (post.getMinAge() == -1) {
    return "${post.getMaxAge()}세 이하";
  } else if (post.getMaxAge() == -1) {
    return "${post.getMinAge()}세 이상";
  } else {
    return "${post.getMinAge()} ~ ${post.getMaxAge()}세";
  }
}

String getMeetTimeText(String time) {
  Duration timeGap = DateTime.now().difference(DateTime.parse(time));
  bool isNegative = timeGap.isNegative;
  timeGap = timeGap.abs();
  String val;
  if (timeGap.inDays > 365) {
    val = "${timeGap.inDays ~/ 365}년";
  } else if (timeGap.inDays >= 30) {
    val = "${timeGap.inDays ~/ 30}개월";
  } else if (timeGap.inDays >= 1) {
    val = "${timeGap.inDays}일";
  } else if (timeGap.inHours >= 1) {
    val = "${timeGap.inHours}시간";
  } else if (timeGap.inMinutes >= 1) {
    val = "${timeGap.inMinutes}분";
  } else {
    val = "잠시";
  }
  return " $val ${isNegative ? "후" : "전"}";
}
