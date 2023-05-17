import 'package:flutter/material.dart';
import 'inputForm3.dart';

class preferenceScreen extends StatefulWidget {
  @override
  _PreferenceState createState() => _PreferenceState();
}

class _PreferenceState extends State<preferenceScreen> {
  int _selectedGenderIndex = 0;
  int _selectedAgeIndex = 0;
  List<String> stateList = ["서울시", "천안시", "수원시"];

  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();

  final List<String> mbti = [
    'ENFP', 'ENFJ', 'ENTP', 'ENTJ',
    'ESFP', 'ESFJ', 'ESTP', 'ESTJ',
    'INFP', 'INFJ', 'INTP', 'INTJ',
    'ISFP', 'ISFJ', 'ISTP', 'ISTJ',
  ];
  final List<String> hobby = [
    '영화', '노래', '술', '책',
  ];

  int _selectedMBTIIndex = -1;
  List<bool> _selectedHobby = List.generate(16, (index) => false);

  void _onPressed(int index) {
    setState(() {
      _selectedHobby[index] = !_selectedHobby[index];
    });
  }
  Color _selectedColor = Color(0xFF6ACA9A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          '가입',
          style: TextStyle(
              fontSize: 18,
              color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
          padding: EdgeInsets.all(20.0),
          height: double.maxFinite,
          child: Column(
            children: [
              Form(
                  key: _formKey,
                  child: Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 6),
                          Text(
                              '나만의 프로필을 작성해주세요 !',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )
                          ),
                          SizedBox(height: 6),
                          Text(
                              '자세하게 입력할수록 본인의 개성을 드러내는 프로필 생성이 가능합니다.',
                              style: TextStyle(
                                fontSize: 14,
                              )
                          ),
                          SizedBox(height: 20),
                          Text(
                              ' MBTI',
                              style: TextStyle(
                                fontSize: 16,
                              )
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            height: 180,
                            child: GridView.count(
                              crossAxisCount: 4, // 4열
                              crossAxisSpacing: 5, // 열 사이의 간격 5
                              mainAxisSpacing: 5, // 행 사이의 간격 5
                              childAspectRatio: 2.0,
                              children: List.generate(
                                16, // 4행 4열 = 총 16개의 버튼
                                    (index) => ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: _selectedMBTIIndex == index ? MaterialStateProperty.all(_selectedColor) : MaterialStateProperty.all(Colors.grey),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_selectedMBTIIndex == index) {
                                        // 이미 선택된 버튼을 다시 클릭한 경우
                                        _selectedMBTIIndex = -1;
                                      } else {
                                        // 새로운 버튼을 클릭한 경우
                                        _selectedMBTIIndex = index;
                                      }
                                    });
                                  },
                                  child: Text(mbti[index],
                                    style: TextStyle(fontSize: 14),
                                  ), // 엠비티아이 텍스트 설정
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                              ' 취미',
                              style: TextStyle(
                                fontSize: 16,
                              )
                          ),
                          SizedBox(height: 10.0),
                          SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Container(
                              height: 180,
                              child: GridView.count(
                                crossAxisCount: 4, // 4열
                                crossAxisSpacing: 5, // 열 사이의 간격 5
                                mainAxisSpacing: 5, // 행 사이의 간격 5
                                childAspectRatio: 2.0,
                                children: List.generate(
                                  4, // 4행 4열 = 총 16개의 버튼
                                      (index) => ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                        _selectedHobby[index] ? Color(0xFF6ACA9A) : Colors.grey,
                                      ),
                                    ),
                                    onPressed: () {
                                      _onPressed(index);
                                    },
                                    child: Text(hobby[index],
                                      style: TextStyle(fontSize: 14),
                                    ), // 취미 텍스트 설정
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  child: Text('다음'),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF6ACA9A),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => residenceScreen()),
                    );
                  },
                ),
              )
            ],
          )
      ),
    );
  }
}
