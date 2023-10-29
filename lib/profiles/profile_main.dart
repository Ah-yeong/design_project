import 'package:design_project/profiles/completed_group.dart';
import 'package:design_project/profiles/my_group.dart';
import 'package:design_project/profiles/my_post.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:flutter/material.dart';
import '../entity/profile.dart';
import '../entity/entity_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_edit.dart';

class PageProfile extends StatefulWidget {
  @override
  _PageProfileState createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> with AutomaticKeepAliveClientMixin {
  EntityProfiles? myProfile;
  List<EntityPost> myPostList = List.empty(growable: true);
  MannerTemperatureWidget? mannerWidget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('프로필', style: TextStyle(fontSize: 18, color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: myProfile!.isLoading ? Center(
          child: SizedBox(
              height: 65,
              width: 65,
              child: buildLoadingProgress())) :
      SingleChildScrollView(
        child:Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 10),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          'https://picsum.photos/id/237/200/300'),
                    ),
                    SizedBox(width: 25),
                    Expanded(
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(height: 6),
                          Text(
                            "${myProfile!.name}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "${myProfile!.major}, ${myProfile!.age}세",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "${myProfile!.textInfo}",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => PageProfileEdit()))
                                    .then((value) {
                                  _reloadProfile();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF6ACA89),
                              ),
                              child: Text('프로필 수정')
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Divider(thickness: 1, height: 1),
              Container(
                  padding: EdgeInsets.all(15),
                  child: mannerWidget
              ),
              Divider(thickness: 1, height: 1),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PageMyPost(),
                  ));
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '내가 만든 모임',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 17,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Divider(thickness: 1, height: 1),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PageMyGroup(),
                  ));
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '내가 속한 모임',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 17,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Divider(thickness: 1, height: 1),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PageMyEndGroup(),
                  ));
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '종료된 모임',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 17,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Divider(thickness: 1, height: 1),
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: [
                            Row(
                                children: [
                                  Text(
                                    '취미',
                                    style: TextStyle(
                                      fontSize: 14,
                                      //fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Expanded(
                                    child: myProfile!.hobby.isEmpty ?
                                    Text(
                                      '비공개',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey
                                      ),
                                      maxLines: 2, // 텍스트가 2줄을 초과하면 다음 줄로 내려가도록 설정
                                      overflow: TextOverflow.ellipsis, // 텍스트가 오버플로우되는 경우 ...으로 표시
                                    ) :
                                    Text(
                                      '${myProfile!.hobby?.join(', ')}',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                      maxLines: 2, // 텍스트가 2줄을 초과하면 다음 줄로 내려가도록 설정
                                      overflow: TextOverflow.ellipsis, // 텍스트가 오버플로우되는 경우 ...으로 표시
                                    ),
                                  )
                                ]
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Divider(thickness: 1, height: 1),
                            SizedBox(
                              height: 7,
                            ),
                            Row(
                                children: [
                                  Text(
                                    'MBTI',
                                    style: TextStyle(
                                      fontSize: 14,
                                      //fontWeight:FontWeight.bold
                                    ),
                                  ),
                                  Expanded(
                                      child: myProfile!.mbtiIndex == -1 ?
                                      Text(
                                        textAlign: TextAlign.right,
                                        "비공개",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey
                                        ),
                                      ) :
                                      Text(
                                      textAlign: TextAlign.right,
                                      "${mbti[myProfile!.mbtiIndex]}",
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    )
                                  )
                                ]
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Divider(thickness: 1, height: 1),
                            SizedBox(
                              height: 7,
                            ),
                            Row(
                                children: [
                                  Text(
                                    '통학여부',
                                    style: TextStyle(
                                      fontSize: 14,
                                      // fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Expanded(
                                    child: myProfile!.commute == null ?
                                      Text(
                                        textAlign: TextAlign.right,
                                        "비공개",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey
                                        ),
                                      )
                                      : Text(
                                        textAlign: TextAlign.right,
                                        "${myProfile!.commute}",
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      )
                                  )
                                ]
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Divider(thickness: 1, height: 1),
                            SizedBox(
                              height: 7,
                            ),
                            Row(
                                children: [
                                  Text(
                                    '거주지',
                                    style: TextStyle(
                                      fontSize: 14,
                                      // fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Expanded(
                                      child: myProfile!.addr1 == null ?
                                        Text(
                                          textAlign: TextAlign.right,
                                          "비공개",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey
                                          ),
                                        ) :
                                        Text(
                                        textAlign: TextAlign.right,
                                          "${myProfile!.addr1 != null ? myProfile!.addr1 + ' ' : ''}"
                                          "${myProfile!.addr2 != null ? myProfile!.addr2 + ' ' : ''}"
                                          "${myProfile!.addr3 != null ? myProfile!.addr3 : ''}",
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      )
                                  )
                                ]
                            ),
                          ],
                        ),
                      )
                    ]
                ),
              ),
              // 추가적인 프로필 정보를 이곳에 추가할 수 있습니다.
              Divider(thickness: 1, height: 1)
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    //setState(() {});
    super.initState();
    myProfile = EntityProfiles(FirebaseAuth.instance.currentUser!.uid);
    myProfile!.loadProfile().then((n) {
      mannerWidget = MannerTemperatureWidget(mannerScore: myProfile!.mannerGroup);
      // for( var postId in myProfile!.post){
      //   EntityPost myPost = EntityPost(postId);
      //   myPost.loadPost().then((value) {
      //     myPostList.add(myPost);
          setState(() {});
      //   });
      // }
    });
  }

  Future<void> _reloadProfile() async {
    await myProfile!.loadProfile().then((n){
      setState(() {});
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class MannerTemperatureWidget extends StatelessWidget {
  final double mannerScore;

  const MannerTemperatureWidget({
    Key? key,
    required this.mannerScore,
  }) : super(key: key);

  Color _getColorForScore(double score) {
    if (score < 20) {
      return Colors.red;
    } else if (score < 40) {
      return Colors.orange;
    } else if (score < 60) {
      return Colors.yellow;
    } else if (score < 80) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForScore(mannerScore);
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.favorite,
              color: color,
            ),
            SizedBox(width: 8.0),
            Tooltip(
              message: '매너온도에 대한 설명',
              verticalOffset: 54,
              child: Text(
                '매너지수',
                style: TextStyle(
                  //fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${mannerScore}점',
                style: TextStyle(
                  //fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.0),
        SizedBox(
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: mannerScore / 100,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                backgroundColor: color.withOpacity(0.3),
              ),
            )
        )
      ],
    );
  }
}
