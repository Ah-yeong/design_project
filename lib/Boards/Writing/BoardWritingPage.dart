import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:design_project/Boards/Writing/BoardSelectPositionPage.dart';
import 'package:design_project/Entity/EntityPost.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import '../../Entity/EntityLatLng.dart';
import '../../Entity/EntityProfile.dart';
import '../../resources.dart';

// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';

final key = GlobalKey<CustomRadioButtonState>();

const List<String> _peopleCounts = <String>[
  '선택',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '무제한'
];

class BoardWritingPage extends StatefulWidget {
  @override
  _BoardWritingPage createState() => _BoardWritingPage();
}

class _BoardWritingPage extends State<BoardWritingPage> {
  DateTime _selectedDate = DateTime.now(); // 초기값 할당

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      cancelText: "취소",
      confirmText: "적용",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: colorSuccess,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(primary: colorSuccess))),
          child: child!,
        );
      },
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  TimeOfDay _selectedTime = TimeOfDay.now().hour < 23
      ? TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1)
      : TimeOfDay(hour: 23, minute: 59);

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? newSelectedTime = await showTimePicker(
        cancelText: "취소",
        confirmText: "적용",
        minuteLabelText: "분",
        hourLabelText: "시",
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: colorSuccess,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
        initialEntryMode: TimePickerEntryMode.inputOnly,
        context: context,
        initialTime: _selectedTime);
    if (newSelectedTime != null) {
      setState(() {
        _selectedTime = newSelectedTime;
      });
    }
  }

  Color maleButtonColor = Colors.grey;
  Color femaleButtonColor = Colors.grey;
  String _selectedPerson = "선택";
  int _selectedPersonIndex = 0;

  ScrollController? _scrollController;
  bool _btnVisible = false;

  final _formKey = GlobalKey<FormState>();
  int _minAge = -1, _minAgeIdx = 0;
  int _maxAge = -1, _maxAgeIdx = 0;
  List<String>? _minAgeItems;
  List<String>? _maxAgeItems;
  bool _isDropDownAge = false;

  TextEditingController? _head;
  TextEditingController? _body;

  int? _selectedGender = 0;

  LLName? _llName;
  bool _isUploading = false;
  bool _isIgnoreAge = false;

  EntityProfiles? profileEntity;

  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              if (!_isUploading) Navigator.of(context).pop(); // 홈화면으로 이동
            },
          ),
          title: Text(
            '게시물 작성',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          backgroundColor: _isUploading ? Colors.grey : Colors.white,
          toolbarHeight: 40,
        ),
        body: Container(
          height: double.maxFinite,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Form(
                        key: _formKey,
                        child: Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('게시물 작성 자세하게 할 수록 좋다는 문구 추가',
                                      style: TextStyle(
                                        fontSize: 14,
                                      )),
                                  SizedBox(height: 20),
                                  TextField(
                                    maxLines: 1,
                                    maxLength: 20,
                                    controller: _head,
                                    cursorColor: Colors.black,
                                    decoration: const InputDecoration(
                                        hintText: "글 제목 (최대 20자)",
                                        counterText: "",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black12),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black54))),
                                  ),
                                  TextField(
                                    maxLines: 5,
                                    maxLength: 500,
                                    maxLengthEnforcement:
                                        MaxLengthEnforcement.none,
                                    controller: _body,
                                    cursorColor: Colors.black,
                                    decoration: const InputDecoration(
                                        hintText: "내용 작성 (최대 500자)",
                                        counterText: "",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black12),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black54))),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text('모임 날짜',
                                      style: TextStyle(
                                          fontSize: 16, color: colorGrey)),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => _selectDate(context),
                                    style: ElevatedButton.styleFrom(
                                      primary: Color(0xFF6ACA9A),
                                    ),
                                    child: Text(
                                        '${dateFormatter.format(_selectedDate)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                        )),
                                  ),
                                  const Divider(
                                    thickness: 1,
                                  ),
                                  SizedBox(height: 10),
                                  Text('모임 시간',
                                      style: TextStyle(
                                          fontSize: 16, color: colorGrey)),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => _selectTime(context),
                                    style: ElevatedButton.styleFrom(
                                      primary: Color(0xFF6ACA9A),
                                    ),
                                    child:
                                        Text('${_selectedTime.format(context)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                            )),
                                  ),
                                  const Divider(
                                    thickness: 1,
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      var modify = await Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  BoardSelectPositionPage()));
                                      setState(() {
                                        _llName = modify ?? _llName;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('모임 장소',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: colorGrey)),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                _llName == null
                                                    ? '해당 영역을 눌러 모임 장소를 지정해주세요'
                                                    : _llName!.AddressName,
                                                style: TextStyle(fontSize: 15)),
                                          ],
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 20,
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  SizedBox(height: 10),
                                  const Divider(
                                    thickness: 1,
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      showCupertinoModalPopup<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return _buildBottomPicker(
                                                _buildPersonNumberPicker());
                                          });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text('인원 수',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: colorGrey)),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Text('${_selectedPerson}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Text(
                                                '${_selectedPerson == "무제한" ? "" : "명"}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: colorGrey)),
                                          ],
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 20,
                                        )
                                        // DropdownButton(
                                        //   value: _selectedPerson,
                                        //   items: List.generate(
                                        //     9,
                                        //         (index) => DropdownMenuItem(
                                        //       value: index + 2,
                                        //       child: Text("${index + 2}"),
                                        //     ),
                                        //   ),
                                        //   onChanged: (value) {
                                        //     setState(() {
                                        //       _selectedPerson = value;
                                        //     });
                                        //   },
                                        // ), // DropdownButton
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  const Divider(
                                    thickness: 1,
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      showCupertinoModalPopup<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return _buildBottomDoublePicker(
                                                _buildRangeOfAgePicker(true),
                                                _buildRangeOfAgePicker(false));
                                          });
                                    },
                                    behavior: HitTestBehavior.translucent,
                                    child: _buildAgeSelect(),
                                  ),
                                  SizedBox(height: 10),
                                  // Row(
                                  //   children: [
                                  //     DropdownButton(
                                  //       value: _minAge,
                                  //       onChanged: (value) {
                                  //         setState(() {
                                  //           _minAge = value as int;
                                  //         });
                                  //       },
                                  //       items: _buildDropdownItems(18, 99),
                                  //     ),
                                  //     Text('  ~  ',
                                  //         style: TextStyle(
                                  //             fontSize: 16, color: colorGrey)),
                                  //     DropdownButton(
                                  //       value: _maxAge,
                                  //       onChanged: (value) {
                                  //         setState(() {
                                  //           _maxAge = value as int;
                                  //         });
                                  //       },
                                  //       items: _buildDropdownItems(_minAge, 99),
                                  //     ),
                                  //     Text('세',
                                  //         style: TextStyle(
                                  //             fontSize: 16, color: colorGrey)),
                                  //   ],
                                  // )
                                  const Divider(
                                    thickness: 1,
                                  ),
                                  AnimatedPadding(
                                    padding: _selectedGender == 0
                                        ? EdgeInsets.only(top: 15, bottom: 0)
                                        : EdgeInsets.only(top: 15, bottom: 10),
                                    duration: Duration(milliseconds: 200),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "성별 ",
                                          style: TextStyle(
                                              color: colorGrey, fontSize: 16),
                                        ),
                                        Expanded(
                                            child: CustomRadioButton(
                                          buttonLables: const [
                                            "무관",
                                            "남자만",
                                            "여자만",
                                          ],
                                          buttonValues: const [
                                            "any",
                                            "man",
                                            "woman",
                                          ],
                                          radioButtonValue: (value) {
                                            selectGender(value);
                                          },
                                          unSelectedColor: Colors.white,
                                          selectedColor: colorSuccess,
                                          elevation: 1,
                                          selectedBorderColor: colorGrey,
                                          unSelectedBorderColor: colorGrey,
                                          defaultSelected: "any",
                                        ))
                                      ],
                                    ),
                                  ),
                                  (_selectedGender! != 0
                                      ? Center(
                                          child: Text(
                                              "해당 성별(${_selectedGender! == 1 ? "남성" : "여성"})에게만 게시글이 나타나게 됩니다!",
                                              style: TextStyle(
                                                  color: Color(0xAAAA0000))))
                                      : const Text('')),
                                  const Divider(
                                    thickness: 1,
                                  ),
                                  SizedBox(height: 55),
                                ]),
                          ),
                        )),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: AnimatedOpacity(
                  opacity: _btnVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: !_btnVisible ? SizedBox() : Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 18),
                      child: InkWell(
                          onTap: () {
                            if(!_btnVisible) return;
                            // 게시물 양식 확인
                            var errMsg = _checkIsInputEmpty();
                            if (errMsg != "Success") {
                              showAlert(errMsg, context, colorError);
                              return;
                            }
                            bool success = false;
                            _tryUploadPost().then((value) {
                              success = value;
                              setState(() => _isUploading = false);
                              showAlert(success ? "글 작성 완료!" : "글 작성에 실패했습니다!", context, success ? colorSuccess : colorError);
                              postManager.reloadPages("");
                              if(success) Navigator.pop(context);
                            });
                          },
                          child: SizedBox(
                            height: 50,
                            width: MediaQuery.of(context).size.width - 40,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: colorSuccess,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(1, 1),
                                        blurRadius: 4.5)
                                  ]),
                              child: Center(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "글쓰기 ",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ],
                              )),
                            ),
                          )),
                    ),
                  ),
                ),
              ),
              _isUploading
                  ? GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.only(bottom: 50),
                        color: Color(0x66000000),
                        child: Center(
                            child: SizedBox(
                                height: 50,
                                width: 50,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  color: Colors.white,
                                ))),
                      ),
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
      onWillPop: () async => false, // 스와이프하여 뒤로가기 방지
    );
  }

  Column _buildAgeSelect() {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Text('희망 연령대', style: TextStyle(fontSize: 16, color: colorGrey)),
            SizedBox(
              width: 10,
            ),
            Text(
              (_maxAge == _minAge && _maxAge == -1) ? "상관 없음" :
              '${_minAge == -1 ? "" : _minAge} ~ ${_maxAge == -1 ? "" : _maxAge}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(
              width: 3,
            ),
            Text(
              (_maxAge == _minAge && _maxAge == -1) ? "" : "세",
              style: TextStyle(fontSize: 16),
            ),
          ]),
          Transform.rotate(angle: (_isDropDownAge ? 90 : 0) * math.pi / 180,
            child: Icon(Icons.arrow_forward_ios, size: 20,),),
        ]),

      ],
    );
  }

  Widget _buildPersonNumberPicker() {
    return CupertinoPicker(
      magnification: 1.22,
      squeeze: 1.2,
      useMagnifier: true,
      itemExtent: 32,
      // This sets the initial item.
      scrollController: FixedExtentScrollController(
        initialItem: _selectedPersonIndex,
      ),
      // This is called when selected item is changed.
      onSelectedItemChanged: (int selectedItem) {
        setState(() {
          _selectedPersonIndex = selectedItem;
          _selectedPerson = _peopleCounts[selectedItem];
        });
      },
      children: List<Widget>.generate(_peopleCounts.length, (int index) {
        return Center(child: Text(_peopleCounts[index]));
      }),
    );
  }

  Widget _buildRangeOfAgePicker(bool isLeft) {
    return CupertinoPicker(
      magnification: 1.22,
      squeeze: 1.2,
      useMagnifier: true,
      itemExtent: 32,
      // This sets the initial item.
      scrollController: FixedExtentScrollController(
        initialItem: isLeft ? _minAgeIdx : _maxAgeIdx,
      ),
      // This is called when selected item is changed.
      onSelectedItemChanged: (int selectedItem) {
        setState(() {
          if (isLeft) {
            _minAgeIdx = selectedItem;
            _minAge = (_minAgeItems![selectedItem] == "상관 없음" ? -1 : int.parse(_minAgeItems![selectedItem]));
          } else {
            _maxAgeIdx = selectedItem;
            _maxAge = (_maxAgeItems![selectedItem] == "상관 없음" ? -1 : int.parse(_maxAgeItems![selectedItem]));
          }
        });
      },
      children: List<Widget>.generate(_minAgeItems!.length, (int index) {
        return Center(child: Text("${_minAgeItems![index]}"));
      }),
    );
  }

  Widget _buildBottomDoublePicker(Widget picker1, Widget picker2) {
    return Container(
      height: 238,
      padding: const EdgeInsets.only(top: 6.0),
      color: Colors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 21.0,
        ),
        child: GestureDetector(
            // Blocks taps from propagating to the modal sheet and popping.
            onTap: () {},
            child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(child: picker1),
                    Center(
                        child: SizedBox(
                      width: 10,
                      child: Text("~"),
                    )),
                    Expanded(child: picker2),
                  ],
                ))),
      ),
    );
  }

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: 216,
      padding: const EdgeInsets.only(top: 6.0),
      color: Colors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  List<String> _buildDropdownItems(int start, int end) {
    List<String> items = [];
    items.add("상관 없음");
    for (int i = start; i <= end; i++) {
      items.add("$i");
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    _head = TextEditingController();
    _body = TextEditingController();
    _minAgeItems = _buildDropdownItems(19, 45);
    _maxAgeItems = _buildDropdownItems(19, 45);
    _scrollController = ScrollController();
    _scrollController!.addListener(() {
      setState(() {
        if (_scrollController!.offset >
            _scrollController!.position.maxScrollExtent / 2) {
          _btnVisible = true;
        } else {
          _btnVisible = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController!.dispose();
    _head!.dispose();
    _body!.dispose();
    super.dispose();
  }

  selectGender(var value) {
    setState(() {
      if (value == "any") {
        _selectedGender = 0;
      } else if (value == "man") {
        _selectedGender = 1;
      } else {
        _selectedGender = 2;
      }
    });
  }

  // 게시물 업로드 시도
  Future<bool> _tryUploadPost() async {
    bool successUpload = false;

    // 게시물 양식 조건이 모두 맞으면 업로드 시도
    setState(() => _isUploading = true); // 업로드 시작
    DateTime dt = DateTime.now();
    successUpload = await addPost(_head!.text, _body!.text, _selectedGender!, _selectedPerson == "무제한" ? -1 : int.parse(_selectedPerson),
        "${dateFormatter.format(_selectedDate)} ${_selectedTime.to24hours()}:00",
        _llName!, "${dateFormatter.format(DateTime.now())} ${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}:${dt.second.toString().padLeft(2, "0")}", _minAge, _maxAge, "Example");
    profileEntity = EntityProfiles(FirebaseAuth.instance.currentUser!.uid);
    successUpload = await profileEntity!.addPostId();
    print('게시물 업로드 완료 !!');
    return successUpload;
  }

  String _checkIsInputEmpty() {
    String msg = "Success";
    int selectTime = _selectedTime.hour * 60 + _selectedTime.minute;
    int nowTime = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
    if (_head!.text.isEmpty) {
      msg = "제목을 입력해주세요!";
    } else if (_head!.text.trim().length < 2) {
      msg = "제목은 두 글자 이상이어야 합니다!";
    } else if (_body!.text.isEmpty) {
      msg = "내용을 입력해주세요!";
    } else if (_body!.text.trim().length < 10) {
      msg = "내용은 열 글자 이상이어야 합니다!";
    } else if (_llName == null) {
      msg = "모임 장소를 선택해주세요!";
    } else if (_selectedPerson == "선택") {
      msg = "모임 인원을 선택해주세요!";
    } else if (_minAge != -1 && _maxAge != -1 && _maxAge - _minAge < 0) {
      msg = "연령대 범위가 잘못되었습니다!";
    } else if (selectTime - nowTime < 30 &&
        _selectedDate.day - DateTime.now().day == 0) {
      msg = "모임 시간은 최소 30분 이후입니다!";
    }
    return msg;
  }

}

extension TimeOfDayConverter on TimeOfDay {
  String to24hours() {
    final hour = this.hour.toString().padLeft(2, "0");
    final min = this.minute.toString().padLeft(2, "0");
    return "$hour:$min";
  }
}

// class UploadException {
//   String code;
//   bool uploaded;
//   UploadException(this.code, this.uploaded);
// }
