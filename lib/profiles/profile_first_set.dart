import 'dart:io';
import 'package:design_project/main.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:design_project/resources/resources.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../boards/post_list/page_hub.dart';

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

  Color _selectedColor = colorSuccess;
  Color _unSelectedColor = colorGrey;

  Color maleButtonColor = colorGrey;
  Color femaleButtonColor = colorGrey;
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
    'ENFP',
    'ENFJ',
    'ENTP',
    'ENTJ',
    'ESFP',
    'ESFJ',
    'ESTP',
    'ESTJ',
    'INFP',
    'INFJ',
    'INTP',
    'INTJ',
    'ISFP',
    'ISFJ',
    'ISTP',
    'ISTJ',
  ];

  final List<String> hobby = [
    '영화',
    '노래',
    '술',
    '책',
    '춤',
    '축구',
    '여행',
    '공연',
    '공예',
    '요리',
    '게임',
    '쇼핑',
  ];

  final List<String> commute = ['통학', '자취', '기숙사'];

  int _selectedMBTIIndex = -1;
  List<bool> _selectedHobby = List.generate(32, (index) => false);

  Color ButtonColor1 = colorGrey;
  Color ButtonColor2 = colorGrey;
  Color ButtonColor3 = colorGrey;

  String? selectedCommute = null;

  Future<void> fetchData(int page) async {
    String? url =
        'https://api.vworld.kr/req/data?key=BFE41CE4-26A0-3EB2-BE6D-6EAECB1FC4C2&domain=http://localhost:8080&service=data&version=2.0&request=getfeature&format=json&size=1000&geometry=false&attribute=true&crs=EPSG:3857&geomfilter=BOX(13663271.680031825,3894007.9689600193,14817776.555251127,4688953.0631258525)&data=LT_C_ADEMD_INFO&page=';
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
    pickedFile = await picker.pickImage(source: imageSource, imageQuality: 25, maxHeight: 300, maxWidth: 300);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile!.path);
      });
    }
  }

  void _onPressed(int index) {
    setState(() {
      _selectedHobby[index] = !_selectedHobby[index];
    });
  }

  @override
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
    String sido = '';
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
              )),
              CupertinoButton(
                child: Text('저장'),
                onPressed: () {
                  setState(() {
                    if (sido == '') {
                      selectedSiDo = siDoList[0];
                    } else {
                      selectedSiDo = sido;
                    }
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
              )),
              CupertinoButton(
                child: Text('저장'),
                onPressed: () {
                  setState(() {
                    if (siGunGu == '') {
                      selectedSiGunGu = siGunGuMap[selectedSiDo!]?[0];
                    } else {
                      selectedSiGunGu = siGunGu;
                    }
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
              )),
              CupertinoButton(
                child: Text('저장'),
                onPressed: () {
                  setState(() {
                    if (dong == '') {
                      selectedDong = dongMap[selectedSiGunGu!]![0];
                    } else {
                      selectedDong = dong;
                    }
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
    return CircleAvatar(
      radius: 120,
      backgroundColor: colorLightGrey,
      backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
      child: _image == null ? Icon(Icons.person, size: 150, color: Colors.white) : null,
    );
  }

  PageController _pageController = PageController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: pageIndex != 1
            ? IconButton(
                onPressed: () {
                  if (pageIndex > 1) {
                    setState(() {
                      pageIndex--;
                      _pageController.animateToPage(pageIndex - 1, duration: Duration(milliseconds: 400), curve: Curves.decelerate);
                    });
                  }
                },
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.black))
            : const SizedBox(),
        title: Text(
          '시작하기',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [Container(
            height: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Text('나만의 프로필을 작성해주세요 !',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      PageView(
                        controller: _pageController,
                        physics: NeverScrollableScrollPhysics(),
                        children: [_imageInput(), _inputForm1(), _inputForm2(), _inputForm3()],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildBottomDotProgress(),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                child: Text(pageIndex == 4 ? '저장' : '다음'),
                                style: ElevatedButton.styleFrom(
                                  primary: _selectedColor,
                                ),
                                onPressed: () async {
                                  if (pageIndex == 2) {
                                    var errMsg = _checkIsInputEmpty();
                                    if (errMsg != "Success") {
                                      showAlert(errMsg, context, colorError);
                                      return;
                                    }
                                  }
                                  if (pageIndex == 4) {
                                    setState(() {
                                      _isSaving = true;
                                    });
                                    await _createProfile();
                                    Get.off(() => const BoardPageMainHub());
                                  } else {
                                    setState(() {
                                      pageIndex++;
                                      _pageController.animateToPage(pageIndex - 1, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
          if(_isSaving) buildContainerLoading(135)
        ],
      ),
    );
  }

  Widget _imageInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 6),
        Text('프로필 사진은 꼭 본인의 모습을 나타낼 필요는 없어요',
            style: TextStyle(
              fontSize: 14,
            )),
        Text('사진 설정은 필수가 아닌 선택사항이에요!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            )),
        SizedBox(height: 50),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              _buildPhotoArea(),
              SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.indigoAccent, borderRadius: BorderRadius.circular(10)),
                    width: 130,
                    height: 35,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        overlayColor: MaterialStateProperty.all(Colors.white38),
                        onTap: () => _getImage(ImageSource.camera),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("카메라로 촬영 ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(color: Colors.indigoAccent, borderRadius: BorderRadius.circular(10)),
                    width: 130,
                    height: 35,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        overlayColor: MaterialStateProperty.all(Colors.white38),
                        onTap: () => _getImage(ImageSource.gallery),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("기존 사진 사용 ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ]),
    );
  }

  Widget _inputForm1() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6),
          Text('자세히 입력해서 본인의 개성을 잘 나타내보아요!',
              style: TextStyle(
                fontSize: 14,
              )),
          const SizedBox(height: 25),
          Row(
            children: [
              Text(' 닉네임 (최대 8자)',
                  style: TextStyle(
                    fontSize: 14,
                  )),
              Text('  한글, 숫자, 영문만 입력 가능',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorGrey,
                  )),
            ],
          ),
          const SizedBox(height: 2),
          TextFormField(
            controller: controllerNickName,
            decoration: InputDecoration(
              counterText: '',
              labelStyle: TextStyle(fontSize: 14),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
            ),
            maxLength: 8,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Zㄱ-ㅎ가-힣]'))],
          ),
          const SizedBox(height: 15),
          Text(' 한줄소개 (최대 50자)',
              style: TextStyle(
                fontSize: 14,
              )),
          const SizedBox(height: 4),
          TextFormField(
            controller: controllerText,
            decoration: InputDecoration(
              counterText: '',
              labelStyle: TextStyle(fontSize: 14),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
            ),
            maxLength: 50,
          ),
          SizedBox(height: 16.0),
          Text(' 성별',
              style: TextStyle(
                fontSize: 16,
              )),
          SizedBox(height: 8.0),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: femaleButtonColor, padding: EdgeInsets.all(10), fixedSize: Size.fromWidth(80)),
                onPressed: () {
                  setState(() {
                    femaleButtonColor = _selectedColor; // 클릭 시 버튼 색 변경
                    maleButtonColor = _unSelectedColor;
                    gender = 'female';
                  });
                },
                child: Text('여자',
                    style: TextStyle(
                      fontSize: 16,
                    )),
              ),
              SizedBox(width: 5.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: maleButtonColor, padding: EdgeInsets.all(10), fixedSize: Size.fromWidth(80)),
                onPressed: () {
                  setState(() {
                    femaleButtonColor = _unSelectedColor;
                    maleButtonColor = _selectedColor;
                    gender = 'male';
                  });
                },
                child: Text('남자',
                    style: TextStyle(
                      fontSize: 16,
                    )),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Text(' 생년월일',
              style: TextStyle(
                fontSize: 16,
              )),
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
      ),
    );
  }

  Widget _inputForm2() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6),
          Text(
            '이후 모든 사항은 선택 사항이에요! \n선택하지 않으면 모두 비공개로 처리해요',
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
              crossAxisCount: 4,
              // 4열
              crossAxisSpacing: 5,
              // 열 사이의 간격 5
              mainAxisSpacing: 5,
              // 행 사이의 간격 5
              childAspectRatio: 2.0,
              shrinkWrap: true,
              // 내부 컨텐츠에 맞게 크기 조정
              physics: NeverScrollableScrollPhysics(),
              children: List.generate(
                16, // 4행 4열 = 총 16개의 버튼
                (index) => ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: _selectedMBTIIndex == index ? MaterialStateProperty.all(_selectedColor) : MaterialStateProperty.all(_unSelectedColor),
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
              itemCount: hobby.length,
              // hobby 배열의 길이만큼 아이템을 생성
              shrinkWrap: true,
              // 내부 컨텐츠에 맞게 크기 조정
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
      ),
    );
  }

  Widget _inputForm3() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6),
          Text('이후 모든 사항은 선택 사항이에요! \n선택하지 않으면 모두 비공개로 처리해요',
              style: TextStyle(
                fontSize: 14,
              )),
          SizedBox(height: 20),
          Text(' 통학 여부',
              style: TextStyle(
                fontSize: 16,
              )),
          SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: ButtonColor1, padding: EdgeInsets.all(10), fixedSize: Size.fromWidth(80)),
                  onPressed: () {
                    setState(() {
                      ButtonColor1 = _selectedColor;
                      ButtonColor2 = _unSelectedColor;
                      ButtonColor3 = _unSelectedColor;
                      selectedCommute = '통학';
                    });
                  },
                  child: Text('통학',
                      style: TextStyle(
                        fontSize: 16,
                      )),
                ),
              ),
              SizedBox(width: 5.0),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: ButtonColor2, padding: EdgeInsets.all(10), fixedSize: Size.fromWidth(80)),
                  onPressed: () {
                    setState(() {
                      ButtonColor1 = _unSelectedColor;
                      ButtonColor2 = _selectedColor;
                      ButtonColor3 = _unSelectedColor;
                      selectedCommute = '자취';
                    });
                  },
                  child: Text('자취',
                      style: TextStyle(
                        fontSize: 16,
                      )),
                ),
              ),
              SizedBox(width: 5.0),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: ButtonColor3, padding: EdgeInsets.all(10), fixedSize: Size.fromWidth(80)),
                  onPressed: () {
                    setState(() {
                      ButtonColor1 = _unSelectedColor;
                      ButtonColor2 = _unSelectedColor;
                      ButtonColor3 = _selectedColor;
                      selectedCommute = '기숙사';
                    });
                  },
                  child: Text('기숙사',
                      style: TextStyle(
                        fontSize: 16,
                      )),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Text(' 거주지',
              style: TextStyle(
                fontSize: 16,
              )),
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
              if (selectedSiDo == null) {
                showAlert("시/도 먼저 선택해주세요", context, colorError);
              } else {
                _showSiGunGuPicker();
              }
              ;
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
              if (selectedSiDo == null) {
                showAlert("시/도 먼저 선택해주세요", context, colorError);
              } else if (selectedSiGunGu == null) {
                showAlert("시/군/구 먼저 선택해주세요", context, colorError);
              } else {
                _showDongPicker();
              }
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
    );
  }

  Widget _buildBottomDotProgress() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, color: pageIndex == 1 ? colorSuccess : colorLightGrey, size: 10),
          const SizedBox(width: 5,),
          Icon(Icons.circle, color: pageIndex == 2 ? colorSuccess : colorLightGrey, size: 10),
          const SizedBox(width: 5,),
          Icon(Icons.circle, color: pageIndex == 3 ? colorSuccess : colorLightGrey, size: 10),
          const SizedBox(width: 5,),
          Icon(Icons.circle, color: pageIndex == 4 ? colorSuccess : colorLightGrey, size: 10),
        ],
      ),
    );
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

  Future<void> _createProfile() async {
    List<int> hobbyIndex = [];
    List<String> selectedHobby = [];
    for (int i = 0; i < _selectedHobby.length; i++) {
      if (_selectedHobby[i]) {
        hobbyIndex.add(i);
        selectedHobby.add(hobby[i]);
      }
    }
    if (_image != null) {
      final storageInstance = FirebaseStorage.instance;
      Reference storageRef = storageInstance.ref("profile_image/${myUuid}");
      await storageRef.putFile(File(_image!.path));
    }
    try {
      await FirebaseFirestore.instance.collection('UserProfile').doc(FirebaseAuth.instance.currentUser!.uid).set({
        'nickName': controllerNickName!.value.text,
        'textInfo': controllerText!.value.text,
        'gender': gender,
        'birth': '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
        'age': DateTime.now().year - year + 1,
        'mbtiIndex': _selectedMBTIIndex,
        'hobbyIndex': hobbyIndex,
        'hobby': selectedHobby,
        'commute': selectedCommute,
        'mannerGroup': 50,
        'post': FieldValue.arrayUnion([]),
        'group': FieldValue.arrayUnion([]),
        'endGroup': FieldValue.arrayUnion([]),
        'addr1': selectedSiDo,
        'addr2': selectedSiGunGu,
        'addr3': selectedDong,
        'fcmToken': myToken,
      });
      // print('Profile data updated successfully.');
    } catch (e) {
      print('Error updating profile data: $e');
    }
  }
}
