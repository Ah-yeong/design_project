import 'package:design_project/Profiles/ProfileEarlySetting/inputForm1.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'PageProfileEdit.dart';

class PageProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final int mannerScore = 70;
    final int taxiScore = 10;

    final mannerWidget = MannerTemperatureWidget(mannerScore: mannerScore);
    final taxiWidget = TaxiTemperatureWidget(taxiScore: taxiScore);

    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: Text(
            '프로필',
            style: TextStyle(
                fontSize: 16,
                color: Colors.black
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
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
                              '조아영',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '소프트웨어학과',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '한줄소개가 들어갈 부분',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    //MaterialPageRoute(builder: (context) => PageProfileEdit()),
                                    MaterialPageRoute(builder: (context) => NameSignUpScreen()),
                                  );
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
                    child: Column(
                        children: <Widget>[
                          mannerWidget,
                          SizedBox(height: 15),
                          taxiWidget,
                        ]
                    )
                ),
                Divider(thickness: 1, height: 1),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            '내가 속한 모임',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )
                        ),
                        SizedBox(height: 10),
                        Card(
                          child: Padding(
                              padding: const EdgeInsets.all(7),
                              child: _buildFriendRow(2)
                          ),
                        ),
                        Card(
                          child: Padding(
                              padding: const EdgeInsets.all(7),
                              child: _buildTaxiRow(2)
                          ),
                        )
                      ]
                  ),
                ),
                Divider(thickness: 1, height: 1),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            '내 정보',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )
                        ),
                        SizedBox(height: 10),
                        Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 2,
                                color: Color(0xFF6ACA89),
                              ),
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            '취미',
                                            style: TextStyle(
                                              fontSize: 14,
                                            )
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                            'MBTI',
                                            style: TextStyle(
                                              fontSize: 14,
                                            )
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                            '통학여부',
                                            style: TextStyle(
                                              fontSize: 14,
                                            )
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                            '거주지',
                                            style: TextStyle(
                                              fontSize: 14,
                                            )
                                        )
                                      ]
                                  ),
                                  SizedBox(width:20),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            '단대호수 산책',
                                            style: TextStyle(
                                              fontSize: 14,
                                            )
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                            'ESTP',
                                            style: TextStyle(
                                              fontSize: 14,
                                            )
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                            '안서동 자취',
                                            style: TextStyle(
                                              fontSize: 14,
                                            )
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                            '경기도 오산시',
                                            style: TextStyle(
                                              fontSize: 14,
                                            )
                                        )
                                      ]
                                  ),
                                ]
                            )
                        )
                      ]
                  ),
                )
                // 추가적인 프로필 정보를 이곳에 추가할 수 있습니다.
              ],
            ),
          ),
        ),
    );
  }

  // 바로모임 카드
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
                            '현재 인원 : 3명',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF858585)),
                          )
                      )
                    ],
                  )
              ),
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: const Color(0xFF6ACA9A),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Center(
                            child: Text("채팅방",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10)),
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
                padding: EdgeInsets.only(bottom: 18),
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
                  padding: const EdgeInsets.only(right: 5),
                  child: Text(
                    '현재 인원 : 3명',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF858585)),
                  )
              ),
              SizedBox(height: 7,),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFF999999),
                    ),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text("${index * 100000}원",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10)),
                        ),
                      ),
                    )),
              ),
              Padding(padding: EdgeInsets.only(bottom: 2)),
              Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFF6ACA9A),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Center(
                        child: Text("채팅방",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  )
              )
            ],
          ),
        )
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${mannerScore}점',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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

class TaxiTemperatureWidget extends StatelessWidget {
  final int taxiScore;

  const TaxiTemperatureWidget({
    Key? key,
    required this.taxiScore,
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
    final color = _getColorForScore(taxiScore);
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.directions_car,
              color: color,
            ),
            SizedBox(width: 8.0),
            Text(
              '탑승완료율',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                '${taxiScore}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
                value: taxiScore / 100,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                backgroundColor: color.withOpacity(0.3),
              ),
            )
        )
      ],
    );
  }
}
