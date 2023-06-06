import 'package:design_project/Profiles/pageMyGroup.dart';
import 'package:design_project/Profiles/pageMyPost.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Boards/BoardPostPage.dart';
import '../Entity/EntityProfile.dart';
import '../Entity/EntityPost.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:design_project/resources.dart';
import 'PageProfileEdit.dart';
import 'package:design_project/Boards/List/BoardPostListPage.dart';

class PageProfile extends StatefulWidget {
  @override
  _PageProfileState createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  EntityProfiles? myProfile;
  List<EntityPost> myPostList = List.empty(growable: true);
  MannerTemperatureWidget? mannerWidget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          '프로필',
          style: TextStyle(
              fontSize: 18,
              color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: myProfile!.isLoading ? Center(
          child: SizedBox(
              height: 65,
              width: 65,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: colorSuccess,
              ))) :
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
                                  setState(() {

                                  });
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF6ACA89),
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
                              '내가 작성한 글',
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
                                    child: Text(
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
                                      child: Text(
                                        textAlign: TextAlign.right,
                                        "${myProfile!.mbti}",
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
                                      child: Text(
                                        textAlign: TextAlign.right,
                                        "${myProfile!.commute}",
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      )
                                  )
                                ]
                            ),
                            // Divider(thickness: 1, height: 1),
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
      for( var postId in myProfile!.post){
        EntityPost myPost = EntityPost(postId);
        myPost.loadPost().then((value) {
          myPostList.add(myPost);
          setState(() {});
        });
      }
    });
  }

  // 바로모임 카드
  Widget _buildFriendRow(EntityPost entity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 15,
          height: 10,
        ),
        Icon(entity!.getPostCurrentPerson() == 1
            ? Icons.person
            : entity!.getPostCurrentPerson() == 2
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
                        '${entity!.getPostHead()}', // 글 제목
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text(
                            '${entity!.getWriterNick()}', // 글 작성자 닉네임
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
                    " ${entity!.getLLName().AddressName}",
                    style: TextStyle(fontSize: 11, color: Color(0xFF858585)),
                  ),
                ],
              ),
              SizedBox(height: 1,),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: colorGrey, size: 13,),
                  Text(
                    getMeetTimeText(entity!),
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
                              child: Text(getAgeText(entity!),
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
                              child: Text(getGenderText(entity!),
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
                                  Text(getMaxPersonText(entity!),
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
}

class MannerTemperatureWidget extends StatelessWidget {
  final int mannerScore;

  const MannerTemperatureWidget({
    Key? key,
    required this.mannerScore,
  }) : super(key: key);

  Color _getColorForScore(int score) {
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
