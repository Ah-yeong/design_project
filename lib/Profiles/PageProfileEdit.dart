import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../Entity/EntityProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../Resources/LoadingIndicator.dart';
import '../Resources/resources.dart';
import 'PageProfile.dart';
import 'package:http/http.dart' as http;
import 'package:design_project/Profiles/ProfileEarlySetting/inputForm.dart';

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

final List<String> hobby = [
  '영화', '노래', '술', '책',
  '춤', '축구', '여행', '공연',
  '공예', '요리', '게임', '쇼핑',
  '영화2', '노래2', '술2', '책2',
  '춤2', '축구2', '여행2', '공연2',
  '공예2', '요리2', '게임2', '쇼핑2'
];

class _PageProfileEditState extends State<PageProfileEdit> {
  final _picker = ImagePicker();
  File? _image;
  EntityProfiles? myProfile;

  int _mbtiIndex = 0;
  bool selectMbti = false;
  bool _mbtiIsExpanded = false;
  Color _selectedColor = Color(0xFF6ACA9A);
  Color _unSelectedColor = Colors.grey;

  String? selectedCommute = null;
  List<String> sigKorNames = [];
  String? selectedSiDo = null;
  String? selectedSiGunGu = null;
  String? selectedDong = null;
  List<String> siDoList = [];
  Map<String, List<String>> siGunGuMap = {};
  Map<String, List<String>> siGunGuMapSet = {};
  Map<String, List<String>> dongMap = {};
  int currentPage = 1;
  int totalPage = 1;

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        print(_image);
      });
    }
  }

  Future<void> fetchData(int page) async {
    String? url = 'https://api.vworld.kr/req/data?key=BFE41CE4-26A0-3EB2-BE6D-6EAECB1FC4C2&domain=http://localhost:8080&service=data&version=2.0&request=getfeature&format=json&size=1000&geometry=false&attribute=true&crs=EPSG:3857&geomfilter=BOX(13663271.680031825,3894007.9689600193,14817776.555251127,4688953.0631258525)&data=LT_C_ADEMD_INFO&page=';
    String? pageUrl = url + page.toString();
    final response = await http.get(Uri.parse(pageUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final features = data['response']['result']['featureCollection']['features'];

      for (var feature in features) {
        String sigKorName = feature['properties']['full_nm'];
        sigKorNames.add(sigKorName);

        // 시/도와 시/군/구 분리
        List<String> parts = sigKorName.split(' ');
        if (parts.length == 3) {
          String siDo = parts[0];
          String siGunGu = parts[1];
          String dong = parts[2];
          if (!siDoList.contains(siDo)) {
            siDoList.add(siDo);
          }

          if (!siGunGuMap.containsKey(siDo)) {
            siGunGuMap[siDo] = [];
          }
          if (!siGunGuMap[siDo]!.contains(siGunGu)) {
            siGunGuMap[siDo]?.add(siGunGu);
          }

          if (!dongMap.containsKey(siGunGu)) {
            dongMap[siGunGu] = [];
          }
          if (!dongMap[siGunGu]!.contains(dong)) {
            dongMap[siGunGu]?.add(dong);
          }
        }
      }
      final pageData = data['response']['page'];
      currentPage = int.parse(pageData['current']);
      totalPage = int.parse(pageData['total']);

      if (currentPage < totalPage) {
        fetchData(currentPage + 1);
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _showSidoPicker() {
    String? sido = '';
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          child: Column(
            children: <Widget>[
              Expanded(
                  child: CupertinoPicker(
                    backgroundColor: Colors.white,
                    itemExtent: 32,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        sido = siDoList[index];
                      });
                    },
                    children: List<Widget>.generate(siDoList.length, (int index) {
                      return Center(
                        child: Text(
                          siDoList[index],
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }),
                  )
              ),
              CupertinoButton(
                child: Text('저장'),
                onPressed: () {
                  setState(() {
                    if(sido==''){selectedSiDo = siDoList[0];}
                    else{selectedSiDo = sido;}
                    selectedSiGunGu = null;
                    selectedDong = null;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSiGunGuPicker() {
    String? siGunGu = '';
    siGunGuMap.forEach((key, value) {
      value.sort();
    });
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          child: Column(
            children: <Widget>[
              Expanded(
                  child: CupertinoPicker(
                    backgroundColor: Colors.white,
                    itemExtent: 32,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        siGunGu = siGunGuMap[selectedSiDo!]?[index];
                      });
                    },
                    children: List<Widget>.generate(siGunGuMap[selectedSiDo!]!.length, (int index) {
                      return Center(
                        child: Text(
                          siGunGuMap[selectedSiDo!]![index],
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }),
                  )
              ),
              CupertinoButton(
                child: Text('저장'),
                onPressed: () {
                  setState(() {
                    if(siGunGu==''){selectedSiGunGu = siGunGuMap[selectedSiDo!]?[0];}
                    else{selectedSiGunGu = siGunGu;}
                    selectedDong = null;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDongPicker() {
    String? dong = '';
    siGunGuMap.forEach((key, value) {
      value.sort();
    });
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          child: Column(
            children: <Widget>[
              Expanded(
                  child: CupertinoPicker(
                    backgroundColor: Colors.white,
                    itemExtent: 32,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        dong = dongMap[selectedSiGunGu!]?[index];
                      });
                    },
                    children: List<Widget>.generate(dongMap[selectedSiGunGu!]!.length, (int index) {
                      return Center(
                        child: Text(
                          dongMap[selectedSiGunGu!]![index],
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }),
                  )
              ),
              CupertinoButton(
                child: Text('저장'),
                onPressed: () {
                  setState(() {
                    if(dong == ''){selectedDong = dongMap[selectedSiGunGu!]![0];}
                    else{selectedDong = dong;}
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  TextEditingController? _nicknameController;
  TextEditingController? _textInfoController;

  Color ButtonColor1 = Colors.grey;
  Color ButtonColor2 = Colors.grey;
  Color ButtonColor3 = Colors.grey;

  bool _hobbyIsExpanded = false;
  List<bool> _selectedHobby = List.generate(24, (index) => false);

  void _onPressed(int index) {
    setState(() {
      _selectedHobby[index] = !_selectedHobby[index];
    });
  }

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
                                              Navigator.pop(context, ImageSource.camera);
                                            },
                                            child: Text('카메라로 직접 촬영'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, ImageSource.gallery);
                                            },
                                            child: Text('앨범에서 가져오기'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (source != null && source == ImageSource.gallery) {
                                    await _getImage(source);
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundImage: _image != null ? FileImage(_image!) : null,
                                  child: _image == null ? Icon(Icons.person, size: 80) : null,
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
                          ' 한줄소개',
                          style: TextStyle(
                            fontSize: 14,
                          )
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _textInfoController,
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
                        child: ExpansionPanelList(
                          expansionCallback: (int index, bool isExpanded) {
                            setState(() {
                              _mbtiIsExpanded = !isExpanded;
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
                                      selectMbti == false? Text("mbti", style: TextStyle(fontSize: 14)):Text(mbti[_mbtiIndex], style: TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                );
                              },
                              body:
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Container(
                                  height: _mbtiIsExpanded ? 180 : 0,
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
                                              backgroundColor: (_mbtiIndex == index && selectMbti == true)
                                                  ? MaterialStateProperty.all(_selectedColor)
                                                  : MaterialStateProperty.all(_unSelectedColor),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                if (_mbtiIndex != index) {_mbtiIndex = index; selectMbti = true;}
                                                else { selectMbti = false;  _mbtiIndex = -1;}
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
                              isExpanded: _mbtiIsExpanded,
                            ),
                          ],
                        ),
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
                        child: ExpansionPanelList(
                          expansionCallback: (int index, bool isExpanded) {
                            setState(() {
                              _hobbyIsExpanded = !isExpanded;
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
                                  height: _hobbyIsExpanded ? 180 : 0,
                                  child: GridView.count(
                                    crossAxisCount: 4, // 4열
                                    crossAxisSpacing: 5, // 열 사이의 간격 5
                                    mainAxisSpacing: 5, // 행 사이의 간격 5
                                    childAspectRatio: 2.0,
                                    children: List.generate(
                                      24,
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
                              isExpanded: _hobbyIsExpanded,
                            ),
                          ],
                        ),
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
                                  selectedCommute = '통학';
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
                                  selectedCommute = '자취';
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
                                  selectedCommute = '기숙사';
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
                      SizedBox(height: 15),
                      Text(
                          ' 거주지',
                          style: TextStyle(
                            fontSize: 14,
                          )
                      ),
                      ElevatedButton(
                        onPressed: _showSidoPicker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedSiDo == null ? _unSelectedColor : _selectedColor,
                          padding: EdgeInsets.only(left: 6.0),
                          // fixedSize: Size.fromWidth(110),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              selectedSiDo ?? '시/도',
                              // style: TextStyle(fontSize: 12),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5.0),
                              child: Icon(Icons.arrow_drop_down),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if(selectedSiDo == null){ showAlert("시/도 먼저 선택해주세요", context, colorError); }
                          else{_showSiGunGuPicker();};
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedSiGunGu == null ? _unSelectedColor : _selectedColor,
                          padding: EdgeInsets.only(left: 6.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              selectedSiGunGu ?? '시/군/구',
                              // style: TextStyle(fontSize: 12),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5.0),
                              child: Icon(Icons.arrow_drop_down),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if(selectedSiDo == null){ showAlert("시/도 먼저 선택해주세요", context, colorError); }
                          else if(selectedSiGunGu == null){ showAlert("시/군/구 먼저 선택해주세요", context, colorError); }
                          else{ _showDongPicker(); }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedDong == null ? _unSelectedColor : _selectedColor,
                          padding: EdgeInsets.only(left: 6.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              selectedDong ?? '읍/면/동',
                              // style: TextStyle(fontSize: 12),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5.0),
                              child: Icon(Icons.arrow_drop_down),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        child: Text('저장'),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF6ACA9A),
                        ),
                        onPressed: () async {
                          await _updateProfile();
                          Navigator.pop(context);
                        },
                      )
                    )
                ),
              ],
            )

        )
    );
  }

  void initState() {
    super.initState();
    myProfile = EntityProfiles(FirebaseAuth.instance.currentUser!.uid);
    myProfile!.loadProfile().then((n) {
      _nicknameController = TextEditingController(text: '${myProfile!.name}');
      _textInfoController = TextEditingController(text: '${myProfile!.textInfo}');

      if(myProfile!.commute == '통학'){
        ButtonColor1 = _selectedColor;
      }
      if(myProfile!.commute == '자취'){
        ButtonColor2 = _selectedColor;
      }
      if(myProfile!.commute == '기숙사'){
        ButtonColor3 = _selectedColor;
      }
      _mbtiIndex = myProfile!.mbtiIndex;
      if (_mbtiIndex != -1) { selectMbti = true; }

      for (int i = 0; i < myProfile!.hobbyIndex.length; i++) {
        _selectedHobby[myProfile!.hobbyIndex[i]] = true;
      }

      selectedSiDo = myProfile!.addr1;
      selectedSiGunGu = myProfile!.addr2;
      selectedDong = myProfile!.addr3;
      setState(() {});
    });
    fetchData(currentPage);
  }

  _updateProfile() async {
    List<int> hobbyIndex = [];
    List<String> selectedHobby = [];
    for (int i = 0; i < _selectedHobby.length; i++) {
      if (_selectedHobby[i]) {
        hobbyIndex.add(i);
        selectedHobby.add(hobby[i]);
      }
    }
    try {
      await FirebaseFirestore.instance
          .collection('UserProfile')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'nickName' : _nicknameController!.value.text,
        'textInfo' : _textInfoController!.value.text,
        'mbtiIndex': _mbtiIndex,
        'hobbyIndex' : hobbyIndex,
        'hobby': selectedHobby,
        'commute' : selectedCommute,
        'addr1' : selectedSiDo,
        'addr2' : selectedSiGunGu,
        'addr3' : selectedDong
      });
      print('Profile data updated successfully.');
    } catch (e) {
      print('Error updating profile data: $e');
    }
  }
}