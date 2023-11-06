import 'dart:convert';

import 'package:design_project/main.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../boards/post_list/page_hub.dart';
import '../entity/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../resources/resources.dart';
import 'package:http/http.dart' as http;

class PageProfileEdit extends StatefulWidget {
  @override
  _PageProfileEditState createState() => _PageProfileEditState();
}

final List<String> mbtiList = [
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

class _PageProfileEditState extends State<PageProfileEdit> {
  final _picker = ImagePicker();
  XFile? _image;

  int _mbtiIndex = 0;
  bool selectMbti = false;

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

  bool isSaving = false;

  OverlayEntry? _MBTIEntry;
  bool _MBTIEntryIsOpened = false;
  final _MBTILink = LayerLink();

  OverlayEntry? _hobbyEntry;
  bool _hobbyEntryIsOpened = false;
  final _hobbyLink = LayerLink();

  Future<void> _getImage(ImageSource source) async {
    XFile? pickedFile;
    pickedFile = await _picker.pickImage(source: source, imageQuality: 25, maxHeight: 300, maxWidth: 300);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile!.path);
      });
    }
  }

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

  TextEditingController? _nicknameController;
  TextEditingController? _textInfoController;
  List<bool> _selectedHobby = List.generate(12, (index) => false);

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
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              '프로필 수정',
              style: TextStyle(fontSize: 18, color: Colors.black),
            )),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
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
                          Text('내 프로필 사진',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                              )),
                          const SizedBox(
                            height: 15,
                          ),
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
                            child: userTempImage[myUuid] == null
                                ? CircleAvatar(
                                    radius: 70,
                                    backgroundColor: colorLightGrey,
                                    backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
                                    child: _image == null ? Icon(Icons.person, size: 80, color: Colors.white) : null,
                                  )
                                : getAvatar(myProfileEntity!, 70),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text('[위의 아이콘 클릭]',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              )),
                        ],
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
                        controller: _nicknameController,
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
                        controller: _textInfoController,
                        decoration: InputDecoration(
                          counterText: '',
                          labelStyle: TextStyle(fontSize: 14),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                        ),
                        maxLength: 50,
                      ),
                      const SizedBox(height: 15),
                      Text(' MBTI', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 5),
                      CompositedTransformTarget(
                        link: _MBTILink,
                        child: InkWell(
                          onTap: () {
                            if (_MBTIEntry != null && _MBTIEntryIsOpened) {
                              _MBTIEntry!.remove();
                              _MBTIEntryIsOpened = false;
                            } else {
                              if (_hobbyEntry != null && _hobbyEntryIsOpened) {
                                _hobbyEntry!.remove();
                                _hobbyEntryIsOpened = false;
                              }
                              _MBTIEntry = _MBTIDropDown();
                              Overlay.of(context).insert(_MBTIEntry!);
                              _MBTIEntryIsOpened = true;
                            }
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(), color: Colors.white),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 40,
                                ),
                                Text(_mbtiIndex == -1 ? "선택" : mbtiList[_mbtiIndex]),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_sharp,
                                    size: 30,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(' 취미', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 5),
                      CompositedTransformTarget(
                        link: _hobbyLink,
                        child: InkWell(
                          onTap: () {
                            if (_hobbyEntry != null && _hobbyEntryIsOpened) {
                              _hobbyEntry!.remove();
                              _hobbyEntryIsOpened = false;
                            } else {
                              if (_MBTIEntry != null && _MBTIEntryIsOpened) {
                                _MBTIEntry!.remove();
                                _MBTIEntryIsOpened = false;
                              }
                              _hobbyEntry = _hobbyDropDown();
                              Overlay.of(context).insert(_hobbyEntry!);
                              _hobbyEntryIsOpened = true;
                            }
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(), color: Colors.white),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 40,
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width - 130,
                                    child: Text(
                                      _getHobbyString(),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_sharp,
                                    size: 30,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(' 통학 여부',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                      SizedBox(height: 5.0),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedCommute == '통학' ? colorSuccess : colorGrey,
                                  padding: EdgeInsets.all(10),
                                  fixedSize: Size.fromWidth(80)),
                              onPressed: () {
                                setState(() {
                                  selectedCommute = '통학';
                                });
                              },
                              child: Text('통학',
                                  style: TextStyle(
                                    fontSize: 15,
                                  )),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedCommute == '자취' ? colorSuccess : colorGrey,
                                  padding: EdgeInsets.all(10),
                                  fixedSize: Size.fromWidth(80)),
                              onPressed: () {
                                setState(() {
                                  selectedCommute = '자취';
                                });
                              },
                              child: Text('자취',
                                  style: TextStyle(
                                    fontSize: 15,
                                  )),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedCommute == '기숙사' ? colorSuccess : colorGrey,
                                  padding: EdgeInsets.all(10),
                                  fixedSize: Size.fromWidth(80)),
                              onPressed: () {
                                setState(() {
                                  selectedCommute = '기숙사';
                                });
                              },
                              child: Text('기숙사',
                                  style: TextStyle(
                                    fontSize: 15,
                                  )),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(' 거주지',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                      ElevatedButton(
                        onPressed: _showSidoPicker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedSiDo == null ? colorGrey : colorSuccess,
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
                          backgroundColor: selectedSiGunGu == null ? colorGrey : colorSuccess,
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
                          backgroundColor: selectedDong == null ? colorGrey : colorSuccess,
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
                            backgroundColor: colorSuccess,
                          ),
                          onPressed: () async {
                            if (_nicknameController!.text.length < 2) {
                              showAlert("닉네임은 두 글자 이상만 허용돼요!", context, colorError);
                              return;
                            }
                            setState(() {
                              if (_hobbyEntry != null && _hobbyEntry!.mounted) _hobbyEntry!.remove();
                              if (_MBTIEntry != null && _MBTIEntry!.mounted) _MBTIEntry!.remove();
                              isSaving = true;
                            });
                            await _updateProfile();
                            isSaving = false;
                            Navigator.pop(context);
                          },
                        ))),
              ],
            )),
            if (isSaving) buildContainerLoading(135)
          ],
        ));
  }

  String _getHobbyString() {
    List<String> result = [];
    for (int i = 0; i < _selectedHobby.length; i++) {
      if (_selectedHobby[i]) {
        result.add(hobby[i]);
      }
    }
    return result.length == 0 ? "없음 (비공개)" : result.join(", ");
  }

  void initState() {
    super.initState();
    myProfileEntity!.loadProfile().then((n) {
      _nicknameController = TextEditingController(text: '${myProfileEntity!.name}');
      _textInfoController = TextEditingController(text: '${myProfileEntity!.textInfo}');

      if (myProfileEntity!.commute != null) selectedCommute = myProfileEntity!.commute;
      if (myProfileEntity!.mbtiIndex != null) _mbtiIndex = myProfileEntity!.mbtiIndex;

      for (int i = 0; i < myProfileEntity!.hobbyIndex.length; i++) {
        _selectedHobby[myProfileEntity!.hobbyIndex[i]] = true;
      }

      selectedSiDo = myProfileEntity!.addr1;
      selectedSiGunGu = myProfileEntity!.addr2;
      selectedDong = myProfileEntity!.addr3;
      setState(() {});
    });
    fetchData(currentPage);
  }

  @override
  void deactivate() {
    if (_hobbyEntry != null && _hobbyEntry!.mounted) _hobbyEntry!.remove();
    if (_MBTIEntry != null && _MBTIEntry!.mounted) _MBTIEntry!.remove();
    super.deactivate();
  }

  OverlayEntry _MBTIDropDown() {
    return OverlayEntry(
      builder: (BuildContext context) {
        return CompositedTransformFollower(
          targetAnchor: Alignment.bottomLeft,
          link: _MBTILink,
          child: GestureDetector(child: Align(alignment: AlignmentDirectional.topStart, child: _MBTITile())),
        );
      },
    );
  }

  OverlayEntry _hobbyDropDown() {
    return OverlayEntry(
      builder: (BuildContext context) {
        return CompositedTransformFollower(
          targetAnchor: Alignment.bottomLeft,
          link: _hobbyLink,
          child: GestureDetector(child: Align(alignment: AlignmentDirectional.topStart, child: _hobbyTile())),
        );
      },
    );
  }

  Widget _MBTITile() {
    return Padding(
      padding: EdgeInsets.zero,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), border: Border.all()),
        child: GridView.count(
          padding: EdgeInsets.all(10),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: 2.0,
          children: List.generate(
            16,
            (index) => ElevatedButton(
              style: ButtonStyle(
                backgroundColor: (_mbtiIndex == index) ? MaterialStateProperty.all(colorSuccess) : MaterialStateProperty.all(colorGrey),
              ),
              onPressed: () {
                setState(() {
                  if (_mbtiIndex != index) {
                    _mbtiIndex = index;
                    selectMbti = true;
                  } else {
                    selectMbti = false;
                    _mbtiIndex = -1;
                  }
                  _MBTIEntryIsOpened = false;
                  _MBTIEntry!.remove();
                });
              },
              child: Text(
                mbtiList[index],
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hobbyTile() {
    return Padding(
      padding: EdgeInsets.zero,
      child: StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setStates) {
        return Container(
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), border: Border.all()),
          child: GridView.count(
            padding: EdgeInsets.all(10),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 2.0,
            children: List.generate(
              12,
              (index) => ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    _selectedHobby[index] ? colorSuccess : colorGrey,
                  ),
                ),
                onPressed: () {
                  setStates(() {});
                  _onPressed(index);
                },
                child: Text(
                  hobby[index],
                  style: TextStyle(fontSize: 14),
                ), // 취미 텍스트 설정
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _updateProfile() async {
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
      var ds = await FirebaseFirestore.instance.collection("UserProfile").doc(myUuid!).get();
      List<int> myPostList = List<int>.from(ds.get("post") as List);
      print(myPostList);
      var posts = await FirebaseFirestore.instance.collection("Post").get();
      await Future.forEach(posts.docs, (doc) async {
        if (doc.reference.id.isNumericOnly) {
          if (myPostList.contains(int.parse(doc.reference.id))) {
            print("good");
            await doc.reference.update({"writer_nick": _nicknameController!.text});
          }
        }
      });
    } catch (e) {
      print("Post name editing error : $e");
    }

    try {
      await FirebaseFirestore.instance.collection('UserProfile').doc(FirebaseAuth.instance.currentUser!.uid).update({
        'nickName': _nicknameController!.value.text,
        'textInfo': _textInfoController!.value.text,
        'mbtiIndex': _mbtiIndex,
        'hobbyIndex': hobbyIndex,
        'hobby': selectedHobby,
        'commute': selectedCommute,
        'addr1': selectedSiDo,
        'addr2': selectedSiGunGu,
        'addr3': selectedDong
      });
      print('Profile data updated successfully.');
    } catch (e) {
      print('Error updating profile data: $e');
    }
    await myProfileEntity!.loadProfile();
  }
}
