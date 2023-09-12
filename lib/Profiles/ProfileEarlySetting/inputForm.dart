import 'dart:io';
import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:design_project/Resources/resources.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NameSignUpScreen extends StatefulWidget {
  @override
  _NicknameFormState createState() => _NicknameFormState();
}

class _NicknameFormState extends State<NameSignUpScreen> {
  int pageIndex = 1;
  ScrollController scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  TextEditingController? controllerNickName;
  TextEditingController? controllerText;

  Color _selectedColor = Color(0xFF6ACA9A);
  Color _unSelectedColor = Colors.grey;

  Color maleButtonColor = Colors.grey;
  Color femaleButtonColor = Colors.grey;
  String gender = '';

  int year = 2000;
  int month = 1;
  int day = 1;

  List<String> sigKorNames = [];
  String? selectedSiDo = null;
  String? selectedSiGunGu = null;
  List<String> siDoList = [];
  Map<String, List<String>> siGunGuMap = {};
  int currentPage = 1;
  int totalPage = 1;

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
    '영화', '노래', '술', '책',
    '춤', '축구', '여행', '공연',
    '공예', '요리', '게임', '쇼핑'
  ];

  final List<String> commute = [
    '통학', '자취', '기숙사'
  ];

  int _selectedMBTIIndex = -1;
  List<bool> _selectedHobby = List.generate(32, (index) => false);

  Color ButtonColor1 = Colors.grey;
  Color ButtonColor2 = Colors.grey;
  Color ButtonColor3 = Colors.grey;

  int _commuteIndex = -1;

  Future<void> fetchData(int page) async {
    String? url = 'https://api.vworld.kr/req/data?key=BFE41CE4-26A0-3EB2-BE6D-6EAECB1FC4C2&domain=http://localhost:8080&service=data&version=2.0&request=getfeature&format=json&size=1000&geometry=false&attribute=true&crs=EPSG:3857&geomfilter=BOX(13663271.680031825,3894007.9689600193,14817776.555251127,4688953.0631258525)&data=LT_C_ADSIGG_INFO&page=';
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
        if (parts.length == 2) {
          String siDo = parts[0];
          String siGunGu = parts[1];
          if (!siDoList.contains(siDo)) {
            siDoList.add(siDo);
          }

          if (!siGunGuMap.containsKey(siDo)) {
            siGunGuMap[siDo] = [];
          }
          siGunGuMap[siDo]?.add(siGunGu);
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

  @override
  void initState() {
    super.initState();
    controllerNickName = TextEditingController();
    controllerText = TextEditingController();
    fetchData(currentPage);
  }

  final _picker = ImagePicker();
  File? _image;

//   // 앨범 접근 권한 요청
//   Future<bool> requestAlbumPermission() async {
//     final PermissionStatus status = await Permission.photos.request();
//     return status.isGranted;
//   }
//
// // 앨범 접근 권한 확인
//   Future<bool> checkAlbumPermission() async {
//     final PermissionStatus status = await Permission.photos.status;
//     return status.isGranted;
//   }
//
  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _onPressed(int index) {
    setState(() {
      _selectedHobby[index] = !_selectedHobby[index];
    });
  }

  void dispose() {
    scrollController.dispose(); // ScrollController 해제
    super.dispose();
  }

  void resetScrollPosition() {
    scrollController.jumpTo(0); // 스크롤 위치를 초기화
  }

  void _showYearPicker() {
    int selectedYear = DateTime.now().year;
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
                    selectedYear = DateTime.now().year - 30 + index;
                  },
                  children: List<Widget>.generate(21, (int index) {
                    final year = DateTime.now().year - 30 + index;
                    return Center(
                      child: Text(
                        '$year년',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }),
                ),
              ),
              CupertinoButton(
                child: Text('저장'),
                onPressed: () {
                  setState(() {
                    year = selectedYear;
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

  void _showMonthPicker() async {
    int selectedMonth = DateTime.now().month;
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
                    selectedMonth = index + 1;
                  },
                  children: List<Widget>.generate(12, (int index) {
                    return Center(
                      child: Text(
                        '${index + 1}월',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }),
                ),
              ),
              CupertinoButton(
                child: Text('저장'),
                onPressed: () {
                  setState(() {
                    month = selectedMonth;
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

  void _showDayPicker() async {
    int selectedDay = DateTime.now().day;
    final daysInMonth = DateTime(year, month + 1, 0).day;
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
                    selectedDay = index + 1;
                  },
                  children: List<Widget>.generate(daysInMonth, (int index) {
                    return Center(
                      child: Text(
                        '${index + 1}일',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }),
                ),
              ),
              CupertinoButton(
                child: Text('저장'),
                onPressed: () {
                  setState(() {
                    day = selectedDay;
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

  void _showSidoPicker() {
    String sido ='';
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
                    selectedSiDo = sido;
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
    String? siGunGu ='';
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
                    selectedSiGunGu = siGunGu;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            if (pageIndex > 1) {
              setState(() {
                pageIndex--; // 이전 페이지로 이동
              });
            }
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
                        child: _buildInputForm(pageIndex)
                    ),
                  )
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  child: Text(pageIndex == 4 ? '저장' : '다음'),
                  style: ElevatedButton.styleFrom(
                    primary: _selectedColor,
                  ),
                  onPressed: () {
                    if(pageIndex == 2){
                      var errMsg = _checkIsInputEmpty();
                      if (errMsg != "Success") {
                        showAlert(errMsg, context, colorError);
                        return;
                      }
                    }
                    if (pageIndex == 4) {
                      _createProfile();
                      Get.off(() => const BoardPageMainHub());
                      // pageIndex가 3일 때 _createProfile 메소드 호출
                    } else {
                      setState(() {
                        pageIndex++;
                      });
                    }
                  },
                ),
              )
            ],
          )
      ),
    );
  }

  Widget _imageInput(){
    return Column(
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
              '프로필 사진은 꼭 본인의 모습을 나타낼 필요는 없습니다.     ',
              style: TextStyle(
                fontSize: 14,
              )
          ),
          SizedBox(height: 100),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
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
                    if (source != null) {
                      await _getImage(source);
                    }
                  },
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(
                      Icons.person,
                      size: 80,
                    )
                        : null,
                  ),
                ),
                SizedBox(
                  height: 26,
                ),
                Text(
                    '[위의 아이콘을 클릭]',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    )
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                    '사진은 필수가 아닌 선택사항입니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    )
                ),
              ],
            ),
          )
        ]
    );
  }

  Widget _inputForm1(){
    return Column(
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
            ' 닉네임',
            style: TextStyle(
              fontSize: 16,
            )
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: controllerNickName,
          decoration: InputDecoration(
            labelText: '닉네임',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20),
        Text(
            ' 한줄소개',
            style: TextStyle(
              fontSize: 16,
            )
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: controllerText,
          decoration: InputDecoration(
            labelText: '한줄소개',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16.0),
        Text(
            ' 성별',
            style: TextStyle(
              fontSize: 16,
            )
        ),
        SizedBox(height: 8.0),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: femaleButtonColor,
                  padding: EdgeInsets.all(10),
                  fixedSize: Size.fromWidth(80)
              ),
              onPressed: () {
                setState(() {
                  femaleButtonColor = _selectedColor; // 클릭 시 버튼 색 변경
                  maleButtonColor = _unSelectedColor;
                  gender = 'female';
                });
              },
              child: Text(
                  '여자',
                  style: TextStyle(
                    fontSize: 16,
                  )
              ),
            ),
            SizedBox(width: 5.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: maleButtonColor,
                  padding: EdgeInsets.all(10),
                  fixedSize: Size.fromWidth(80)
              ),
              onPressed: () {
                setState(() {
                  femaleButtonColor = _unSelectedColor;
                  maleButtonColor = _selectedColor;
                  gender = 'male';
                });
              },
              child: Text(
                  '남자',
                  style: TextStyle(
                    fontSize: 16,
                  )
              ),
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Text(
            ' 생년월일',
            style: TextStyle(
              fontSize: 16,
            )
        ),
        SizedBox(height: 8.0),
        Row(
          children: [
            ElevatedButton(
              onPressed: _showYearPicker,
              style: ElevatedButton.styleFrom(
                backgroundColor: _unSelectedColor,
                padding: EdgeInsets.only(left: 6.0),
                fixedSize: Size.fromWidth(110),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$year년'),
                  Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Icon(Icons.arrow_drop_down),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5),
            ElevatedButton(
              onPressed: _showMonthPicker,
              style: ElevatedButton.styleFrom(
                backgroundColor: _unSelectedColor,
                fixedSize: Size.fromWidth(80),
                padding: EdgeInsets.only(left: 6.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$month월'),
                  Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Icon(Icons.arrow_drop_down),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5),
            ElevatedButton(
              onPressed: _showDayPicker,
              style: ElevatedButton.styleFrom(
                backgroundColor: _unSelectedColor,
                fixedSize: Size.fromWidth(80),
                padding: EdgeInsets.only(left: 6.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$day일'),
                  Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Icon(Icons.arrow_drop_down),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _inputForm2(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 6),
        Text(
          '나만의 프로필을 작성해주세요 !',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '지금부터의 항목은 모두 선택사항입니다. \n자세하게 입력할수록 본인의 개성을 드러내는 프로필 생성이 가능합니다.',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        SizedBox(height: 20),
        Text(
          ' MBTI',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          child: GridView.count(
            crossAxisCount: 4, // 4열
            crossAxisSpacing: 5, // 열 사이의 간격 5
            mainAxisSpacing: 5, // 행 사이의 간격 5
            childAspectRatio: 2.0,
            shrinkWrap: true, // 내부 컨텐츠에 맞게 크기 조정
            physics: NeverScrollableScrollPhysics(),
            children: List.generate(
              16, // 4행 4열 = 총 16개의 버튼
                  (index) => ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: _selectedMBTIIndex == index
                      ? MaterialStateProperty.all(_selectedColor)
                      : MaterialStateProperty.all(_unSelectedColor),
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
                child: Text(
                  mbti[index],
                  style: TextStyle(fontSize: 14),
                ), // 엠비티아이 텍스트 설정
              ),
            ),
          ),
        ),
        Text(
          ' 취미',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10.0),
        Container(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4열
                crossAxisSpacing: 5, // 열 사이의 간격 5
                mainAxisSpacing: 5, // 행 사이의 간격 5
                childAspectRatio: 2.0,
              ),
              itemCount: hobby.length, // hobby 배열의 길이만큼 아이템을 생성
              shrinkWrap: true, // 내부 컨텐츠에 맞게 크기 조정
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      _selectedHobby[index] ? _selectedColor : _unSelectedColor,
                    ),
                  ),
                  onPressed: () {
                    _onPressed(index);
                  },
                  child: Text(
                    hobby[index],
                    style: TextStyle(fontSize: 14),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _inputForm3(){
    return Column(
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
            ' 통학 여부',
            style: TextStyle(
              fontSize: 16,
            )
        ),
        SizedBox(height: 10.0),
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
                    _commuteIndex = 0;
                  });
                },
                child: Text(
                    '통학',
                    style: TextStyle(
                      fontSize: 16,
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
                    _commuteIndex = 1;
                  });
                },
                child: Text(
                    '자취',
                    style: TextStyle(
                      fontSize: 16,
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
                    _commuteIndex = 2;
                  });
                },
                child: Text(
                    '기숙사',
                    style: TextStyle(
                      fontSize: 16,
                    )
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Text(
            ' 거주지',
            style: TextStyle(
              fontSize: 16,
            )
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _showSidoPicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _unSelectedColor,
                  padding: EdgeInsets.only(left: 6.0),
                  // fixedSize: Size.fromWidth(110),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(selectedSiDo ?? '시/도 선택'),
                    Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Icon(Icons.arrow_drop_down),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _showSiGunGuPicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _unSelectedColor,
                  fixedSize: Size.fromWidth(80),
                  padding: EdgeInsets.only(left: 6.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(selectedSiGunGu ?? '시/군/구 선택'),
                    Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Icon(Icons.arrow_drop_down),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
          ],
        );
  }

  Widget _buildInputForm(int index) {
    switch (index) {
      case 1:
        return _imageInput();
      case 2:
        return _inputForm1();
      case 3:
        return _inputForm2();
      case 4:
        return _inputForm3();
      default:
        return Container(); // 기본적으로 빈 컨테이너를 반환하거나 예외 처리를 추가할 수 있습니다.
    }
  }

  String _checkIsInputEmpty() {
    String msg = "Success";
    if (controllerNickName!.value.text.isEmpty) {
      msg = "닉네임을 입력해주세요!";
    } else if (gender == '') {
      msg = "성별을 선택해주세요!";
    }
    return msg;
  }

  _createProfile() async {
    List<int> hobbyIndex = [];
    List<String> selectedHobby = [];
    print(FirebaseAuth.instance.currentUser!.uid);
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
          .set({
        'nickName' : controllerNickName!.value.text,
        'textInfo' : controllerText!.value.text,
        'gender' : gender,
        'birth' : '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
        'mbtiIndex': _selectedMBTIIndex,
        'mbti': mbti[_selectedMBTIIndex],
        // 'hobbyIndex' hobbyIndex,
        'hobby': selectedHobby,
        'commuteIndex' : _commuteIndex,
        'commute' : commute[_commuteIndex],
        'mannerGroup': 50,
        'post': null,
        'group': null,
        'profileImagePath': _image,
        'addr1': selectedSiDo,
        'addr2': selectedSiGunGu,
      });
      print('Profile data updated successfully.');
    } catch (e) {
      print('Error updating profile data: $e');
    }
  }
}