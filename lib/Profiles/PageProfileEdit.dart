import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'PageProfile.dart';

class PageProfileEdit extends StatefulWidget {
  @override
  _PageProfileEditState createState() => _PageProfileEditState();
}

final List<String> mbti = [
  'ENFP', 'ENFJ', 'ENTP', 'ENTJ',
  'ESFP', 'ESFJ', 'ESTP', 'ESTJ',
  'INFP', 'INFJ', 'INTP', 'INTJ',
  'ISFP', 'ISFJ', 'ISTP', 'ISTJ',
];

class _PageProfileEditState extends State<PageProfileEdit> {
  final _picker = ImagePicker();
  File? _image;

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  final _nicknameController = TextEditingController();

  int _selectedIndex = -1;

  Color ButtonColor1 = Colors.grey;
  Color ButtonColor2 = Colors.grey;
  Color ButtonColor3 = Colors.grey;

  Color _selectedColor = Color(0xFF6ACA9A);
  Color _unSelectedColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black,),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              '프로필 수정', style: TextStyle(fontSize: 18, color: Colors.black),)
        ),
        body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20.0),
                  // height: double.maxFinite,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  final source = await showDialog<ImageSource>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('사진 업로드'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context, ImageSource.camera);
                                            },
                                            child: Text('카메라로 직접 촬영'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context, ImageSource.gallery);
                                            },
                                            child: Text('앨범에서 가져오기'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (source != null) {
                                    await _getImage(source);
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundImage: _image != null
                                      ? FileImage(_image!)
                                      : null,
                                  child: _image == null
                                      ? Icon(Icons.person, size: 80,) : null,
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                  '[위의 아이콘 클릭]',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  )
                              ),
                            ],
                          )
                      ),
                      SizedBox(height: 10),
                      Text(
                          ' 닉네임',
                          style: TextStyle(
                            fontSize: 14,
                          )
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _nicknameController,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(fontSize: 14),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.only(left:10 ,top: 10, bottom: 10),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                          ' MBTI',
                          style: TextStyle(
                            fontSize: 14,
                          )
                      ),
                      SizedBox(height: 7.0),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey, // 테두리 색상을 변경하고자 하는 색상으로 변경하세요.
                            width: 1.0, // 테두리 두께를 지정할 수 있습니다.
                          ),
                        ),
                        child: MbtiWidget(),
                      ),
                      SizedBox(height: 15),
                      Text(
                          ' 취미',
                          style: TextStyle(
                            fontSize: 14,
                          )
                      ),
                      SizedBox(height: 7.0),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey, // 테두리 색상을 변경하고자 하는 색상으로 변경하세요.
                            width: 1.0, // 테두리 두께를 지정할 수 있습니다.
                          ),
                        ),
                        child: HobbyWidget(),
                      ),
                      SizedBox(height: 15),
                      Text(
                          ' 통학 여부',
                          style: TextStyle(
                            fontSize: 14,
                          )
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: ButtonColor1,
                                  padding: EdgeInsets.all(10),
                                  fixedSize: Size.fromWidth(80)
                              ),
                              onPressed: () {
                                setState(() {
                                  ButtonColor1 = _selectedColor;
                                  ButtonColor2 = _unSelectedColor;
                                  ButtonColor3 = _unSelectedColor;
                                  _selectedIndex = 1;
                                });
                              },
                              child: Text(
                                  '통학',
                                  style: TextStyle(
                                    fontSize: 14,
                                  )
                              ),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: ButtonColor2,
                                  padding: EdgeInsets.all(10),
                                  fixedSize: Size.fromWidth(80)
                              ),
                              onPressed: () {
                                setState(() {
                                  ButtonColor1 = _unSelectedColor;
                                  ButtonColor2 = _selectedColor;
                                  ButtonColor3 = _unSelectedColor;
                                  _selectedIndex = 2;
                                });
                              },
                              child: Text(
                                  '자취',
                                  style: TextStyle(
                                    fontSize: 14,
                                  )
                              ),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: ButtonColor3,
                                  padding: EdgeInsets.all(10),
                                  fixedSize: Size.fromWidth(80)
                              ),
                              onPressed: () {
                                setState(() {
                                  ButtonColor1 = _unSelectedColor;
                                  ButtonColor2 = _unSelectedColor;
                                  ButtonColor3 = _selectedColor;
                                  _selectedIndex = 3;
                                });
                              },
                              child: Text(
                                  '기숙사',
                                  style: TextStyle(
                                    fontSize: 14,
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        child: Text('저장'),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF6ACA9A),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    )
                ),
              ],
            )

        )
    );
  }
}

class MbtiWidget extends StatefulWidget {
  @override
  _MbtiWidgetState createState() => _MbtiWidgetState();
}

class _MbtiWidgetState extends State<MbtiWidget> {
  int _selectedIndex = -1;
  bool _isExpanded = false;
  Color _selectedColor = Color(0xFF6ACA9A);

  final List<String> mbti = [
    'ENFP', 'ENFJ', 'ENTP', 'ENTJ',
    'ESFP', 'ESFJ', 'ESTP', 'ESTJ',
    'INFP', 'INFJ', 'INTP', 'INTJ',
    'ISFP', 'ISFJ', 'ISTP', 'ISTJ',
  ];

  @override
  Widget build(BuildContext context) {
    String selectedMBTI = _selectedIndex == -1 ? '' : mbti[_selectedIndex];

    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isExpanded = !isExpanded;
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Row(
                children: [
                  Icon(Icons.mood),
                  SizedBox(width: 12),
                  Text(selectedMBTI, style: TextStyle(fontSize: 14)),
                ],
              ),
            );
          },
          body:
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: _isExpanded ? 180 : 0,
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 2.0,
                children: List.generate(
                  16,
                      (index) =>
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: _selectedIndex == index
                              ? MaterialStateProperty.all(_selectedColor)
                              : MaterialStateProperty.all(Colors.grey),
                        ),
                        onPressed: () {
                          setState(() {
                            if (_selectedIndex == index) {
                              _selectedIndex = -1;
                            } else {
                              _selectedIndex = index;
                            }
                          });
                        },
                        child: Text(
                          mbti[index],
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                ),
              ),
            ),
          ),
          isExpanded: _isExpanded,
        ),
      ],
    );
  }
}

class HobbyWidget extends StatefulWidget {
  @override
  _HobbyWidgetState createState() => _HobbyWidgetState();
}

// 취미 (mbti 복붙해옴 수정 필요)
class _HobbyWidgetState extends State<HobbyWidget> {
  bool _isExpanded = false;
  Color _selectedColor = Color(0xFF6ACA9A);

  final List<String> hobby = [
    '영화', '노래', '술', '책',
  ];
  List<bool> _selectedHobby = List.generate(16, (index) => false);

  void _onPressed(int index) {
    setState(() {
      _selectedHobby[index] = !_selectedHobby[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isExpanded = !isExpanded;
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Row(
                children: [
                  Icon(Icons.mood),
                  SizedBox(width: 12),
                  Text('취미', style: TextStyle(fontSize: 14)),
                ],
              ),
            );
          },
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: _isExpanded ? 180 : 0,
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
                        _selectedHobby[index] ? _selectedColor : Colors.grey,
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
          isExpanded: _isExpanded,
        ),
      ],
    );
  }
}
