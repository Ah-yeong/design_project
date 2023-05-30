import 'package:design_project/Boards/BoardPostPage.dart';
import 'package:design_project/Entity/EntityPost.dart';
import 'BoardMain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../resources.dart';

class BoardGroupListPage extends StatefulWidget {
  const BoardGroupListPage({super.key});

  @override
  State<StatefulWidget> createState() => _BoardGroupListPage();
}

class _BoardGroupListPage extends State<BoardGroupListPage>
with AutomaticKeepAliveClientMixin{
  var count = 10;

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return postManager.isLoading ? Center(
      child: SizedBox(
        height: 65,
        width: 65,
        child: CircularProgressIndicator(
          strokeWidth: 4,
          color: colorSuccess,
        )))
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
                      child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: _buildFriendRow(postManager.list[index]))),
                ),
                childCount: postManager.loadedCount))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    postManager.loadPages().then((value) => setState(() {}));
    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.offset <
            _scrollController.position.minScrollExtent &&
            _scrollController.position.outOfRange && !postManager.isLoading ) {
          postManager.reloadPages().then((value) => setState(() {}));
        }
      });
    });
  }

  naviToPost(int index) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => BoardPostPage(postId: postManager.list[index].getPostId())));
  }

  // 바로 모임 카드
  Widget _buildFriendRow(EntityPost entity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 15,
          height: 10,
        ),
        Icon(entity.getPostCurrentPerson() == 1
            ? Icons.person
            : entity.getPostCurrentPerson() == 2
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
                        '${entity.getPostHead()}', // 글 제목
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text(
                            '${entity.getWriterNick()}', // 글 작성자 닉네임
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF858585)),
                          ))
                    ],
                  )),
              const Padding(
                padding: EdgeInsets.only(bottom: 18),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: colorGrey, size: 13,),
                  Text(
                    " ${entity.getLLName().AddressName}",
                    style: TextStyle(fontSize: 11, color: Color(0xFF858585)),
                  ),
                ],
              ),
              SizedBox(height: 1,),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: colorGrey, size: 13,),
                  Text(
                    getMeetTimeText(entity),
                    style: TextStyle(fontSize: 11, color: Color(0xFF858585)),
                  ),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 18,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: const Color(0xFFBFBFBF)),
                          child: Center(
                            child: const Padding(
                              padding: EdgeInsets.only(
                                  right: 5, left: 5),
                              child: Text("카테고리",
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 1, right: 1),
                      ),
                      SizedBox(
                        height: 18,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: const Color(0xFFBFBFBF)),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: 5, left: 5),
                              child: Text(getAgeText(entity),
                                  style:
                                      TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 1, right: 1),
                      ),
                      SizedBox(
                        height: 18,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: const Color(0xFFBFBFBF)),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: 5, left: 5),
                              child: Text(getGenderText(entity),
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.emoji_people, color: Colors.white, size: 14,),
                                Text(getMaxPersonText(entity),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10)),
                              ],
                            )
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
  
  String getMaxPersonText(EntityPost post) {
    if(post.getPostMaxPerson() == -1) return " ${post.getPostCurrentPerson()}";
    return " ${post.getPostCurrentPerson()}/${post.getPostMaxPerson()}";
  }

  String getGenderText(EntityPost post) {
    if(post.getPostGender() == 0) {
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

  @override
  bool get wantKeepAlive => true;
}

String getMeetTimeText(EntityPost post) {
  Duration timeGap = DateTime.now().difference(DateTime.parse(post.getTime()));
  bool isNegative = timeGap.isNegative;
  timeGap = timeGap.abs();
  String val;
  if(timeGap.inDays > 365) {
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