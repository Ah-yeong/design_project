import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:design_project/resources/resources.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../boards/post_list/page_hub.dart';

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
  String? selectedDong = null;
  List<String> siDoList = [];
  Map<String, List<String>> siGunGuMap = {};
  Map<String, List<String>> siGunGuMapSet = {};
  Map<String, List<String>> dongMap = {};
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
    '영화2', '노래2', '술2', '책2',
    '춤2', '축구2', '여행2', '공연2',
    '공예2', '요리2', '게임2', '쇼핑2'
  ];

  final List<String> commute = [
    '통학', '자취', '기숙사'
  ];

  int _selectedMBTIIndex = -1;
  List<bool> _selectedHobby = List.generate(32, (index) => false);

  Color ButtonColor1 = Colors.grey;
  Color ButtonColor2 = Colors.grey;
  Color ButtonColor3 = Colors.grey;

  String? selectedCommute = null;

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

  @override
  void initState() {
    super.initState();
    controllerNickName = TextEditingController();
    controllerText = TextEditingController();
    fetchData(currentPage);
  }

  final ImagePicker picker = ImagePicker();
  XFile? _image;

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
  Future<void> _getImage(ImageSource imageSource) async {
    XFile? pickedFile;
    await picker.pickImage(source: imageSource).then((value) => pickedFile = value);
    print(pickedFile);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile!.path);
        print(pickedFile?.path);
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
    int selectedYear = DateTime.now().year - 30;
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
    int selectedMonth = 1;
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
    int selectedDay = 1;
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
    String? siGunGu ='';
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
    String? dong ='';
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

  Widget _buildPhotoArea() {
    return _image != null ? Container(
        width: 300,
        height: 300,
        child: Image.file(File(_image!.path)), //가져온 이미지를 화면에 띄워주는 코드
      ) : Container(
        width: 300,
        height: 300,
        color: Colors.grey,
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
                _buildPhotoArea(),
                SizedBox(
                  height: 26,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _getImage(ImageSource.camera); //getImage 함수를 호출해서 카메라로 찍은 사진 가져오기
                      },
                      child: Text("카메라"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _getImage(ImageSource.gallery); //getImage 함수를 호출해서 카메라로 찍은 사진 가져오기
                      },
                      child: Text("갤러리"),
                    ),
                  ],
                )
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
            '지금부터의 항목은 모두 선택사항입니다. \n자세하게 입력할수록 본인의 개성을 드러내는 프로필 생성이 가능합니다.',
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
                    selectedCommute = '통학';
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
                    selectedCommute = '자취';
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
                    selectedCommute = '기숙사';
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
        'age' : DateTime.now().year - year + 1,
        'mbtiIndex': _selectedMBTIIndex,
        'hobbyIndex' : hobbyIndex,
        'hobby': selectedHobby,
        'commute' : selectedCommute,
        'mannerGroup': 50,
        'post': FieldValue.arrayUnion([]),
        'group': FieldValue.arrayUnion([]),
        'endGroup': FieldValue.arrayUnion([]),
        'profileImagePath': _image,
        'addr1': selectedSiDo,
        'addr2': selectedSiGunGu,
        'addr3': selectedDong,
      });
      // print('Profile data updated successfully.');
    } catch (e) {
      print('Error updating profile data: $e');
    }
  }
}