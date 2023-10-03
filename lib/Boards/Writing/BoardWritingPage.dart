import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:design_project/Boards/Writing/BoardSelectPositionPage.dart';
import 'package:design_project/Entity/EntityPost.dart';
import 'package:design_project/Resources/LoadingIndicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../Entity/EntityLatLng.dart';
import '../../Entity/EntityProfile.dart';
import '../../Resources/resources.dart';

// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';

final key = GlobalKey<CustomRadioButtonState>();

const List<String> _peopleCounts = <String>['선택', '2', '3', '4', '5', '6', '7', '8', '무제한'];

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
              textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(primary: colorSuccess))),
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

  TimeOfDay _selectedTime = (TimeOfDay.now().hour + ((TimeOfDay.now().minute / 5).round() * 5 == 60 ? 1 : 0)) < 23
      ? TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1 + ((TimeOfDay.now().minute / 5).round() * 5 == 60 ? 1 : 0), minute: (TimeOfDay.now().minute / 5).round() * 5 == 60 ? 0 : (TimeOfDay.now().minute / 5).round() * 5)
      : TimeOfDay(hour: 23, minute: 59);

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? newSelectedTime = await showTimePicker(
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
      if (newSelectedTime.minute % 5 != 0) {
        newSelectedTime = newSelectedTime.replacing(minute: (newSelectedTime.minute / 5).round() * 5);
      }
      setState(() {
        _selectedTime = newSelectedTime!;
      });
    }
  }

  Color maleButtonColor = Colors.grey;
  Color femaleButtonColor = Colors.grey;
  int _selectedPersonIndex = 0;
  String _selectedPerson = "선택";
  String _selectedCategory = "없음";
  bool _tappedCategory = false;
  int? _selectedGender = 0;
  bool _isVoluntary = false;
  List<String> _categories = CategoryList;

  ScrollController? _scrollController;
  bool _btnVisible = false;

  final _formKey = GlobalKey<FormState>();
  int _minAge = -1, _minAgeIdx = 0;
  int _maxAge = -1, _maxAgeIdx = 0;
  List<String>? _minAgeItems;
  List<String>? _maxAgeItems;
  TextEditingController? _head;
  TextEditingController? _body;

  LLName? _llName;
  bool _isUploading = false;

  EntityProfiles? profileEntity;
  SuperTooltipController _tooltipController = SuperTooltipController();

  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          backgroundColor: Colors.white,
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
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Container(
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
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  // 글 제목
                                  TextField(
                                    maxLines: 1,
                                    maxLength: 20,
                                    controller: _head,
                                    cursorColor: Colors.black,
                                    decoration: const InputDecoration(
                                        hintText: "글 제목 (최대 20자)",
                                        hintStyle: TextStyle(fontSize: 15, color: colorLightGrey),
                                        counterText: "",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black12),
                                        ),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54))),
                                  ),
                                  // 글 내용
                                  TextField(
                                    maxLines: 5,
                                    maxLength: 500,
                                    maxLengthEnforcement: MaxLengthEnforcement.none,
                                    controller: _body,
                                    cursorColor: Colors.black,
                                    decoration: const InputDecoration(
                                        hintText: "내용 작성 (최대 500자)",
                                        hintStyle: TextStyle(fontSize: 15, color: colorLightGrey),
                                        counterText: "",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black12),
                                        ),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54))),
                                  ),
                                  const SizedBox(height: 35.0),
                                  // 모임 날짜 및 시간
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('모임 날짜 및 시간', style: TextStyle(fontSize: 16, color: colorGrey)),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => _selectDate(context),
                                            style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(side: BorderSide(), borderRadius: BorderRadius.circular(5))),
                                            child: Row(
                                              children: [
                                                Text('${dateFormatter.format(_selectedDate)}  ', style: TextStyle(fontSize: 15, color: Colors.black)),
                                                SizedBox(
                                                  width: 15,
                                                  child: Icon(
                                                    Icons.keyboard_arrow_down_outlined,
                                                    color: Colors.black,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          ElevatedButton(
                                            onPressed: () => _selectTime(context),
                                            style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(side: BorderSide(), borderRadius: BorderRadius.circular(5))),
                                            child: Row(
                                              children: [
                                                Text('${_selectedTime.format(context)}  ', style: TextStyle(fontSize: 15, color: Colors.black)),
                                                SizedBox(
                                                  width: 15,
                                                  child: Icon(
                                                    Icons.keyboard_arrow_down_outlined,
                                                    color: Colors.black,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3.0),
                                        child: Text("모임 시간은 5분 단위로 자동 재설정돼요!", style: TextStyle(color: colorGrey, fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                  // 구분선
                                  const Padding(
                                    padding: const EdgeInsets.only(top: 25, bottom: 25),
                                    child: Divider(thickness: 1),
                                  ),
                                  // 카테고리 선택
                                  GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        setState(() {
                                          _tappedCategory = !_tappedCategory;
                                        });
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '카테고리',
                                                style: TextStyle(color: colorGrey, fontSize: 16),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    _selectedCategory,
                                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  AnimatedRotation(
                                                    turns: _tappedCategory ? 1 / 4 : 0,
                                                    duration: Duration(milliseconds: 500),
                                                    curve: Curves.decelerate,
                                                    child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 20,
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      )),
                                  AnimatedCrossFade(
                                    firstChild: SizedBox(
                                      width: double.infinity,
                                    ),
                                    secondChild: SizedBox(
                                      width: double.infinity,
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: Wrap(
                                            direction: Axis.horizontal,
                                            // 나열 방향
                                            alignment: WrapAlignment.start,
                                            // 정렬 방식
                                            spacing: 7,
                                            // 좌우 간격
                                            runSpacing: 7,
                                            // 상하 간격
                                            children: _categories
                                                .map((e) => GestureDetector(
                                                      behavior: HitTestBehavior.translucent,
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedCategory = e;
                                                          _tappedCategory = false;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                                                        decoration: BoxDecoration(
                                                          color: _selectedCategory == e ? colorGrey : Color(0xFFEAEAEA),
                                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                                        ),
                                                        child: Text(
                                                          '$e',
                                                          style: TextStyle(color: _selectedCategory == e ? Colors.white : Colors.black, fontSize: 14),
                                                        ),
                                                      ),
                                                    ))
                                                .toList()),
                                      ),
                                    ),
                                    crossFadeState: _tappedCategory ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                    duration: Duration(milliseconds: 500),
                                    sizeCurve: Curves.decelerate,
                                  ),
                                  const SizedBox(height: 35),
                                  // 모임 장소 선택
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      var modify =
                                          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => BoardSelectPositionPage()));
                                      setState(() {
                                        _llName = modify ?? _llName;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('모임 장소 ', style: TextStyle(fontSize: 16, color: colorGrey)),
                                        Row(
                                          children: [
                                            Text(_llName == null ? '미지정' : _llName!.AddressName,
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            SizedBox(width: 10),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 20,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 35),
                                  // 인원수 선택
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      showCupertinoModalPopup<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return _buildBottomPicker(_buildPersonNumberPicker());
                                          });
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('인원 수', style: TextStyle(fontSize: 16, color: colorGrey)),
                                        Row(
                                          children: [
                                            Text('${_selectedPerson}',
                                                style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 20,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 35),
                                  // 희망 연령대 선택
                                  GestureDetector(
                                    onTap: () {
                                      showCupertinoModalPopup<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return _buildBottomDoublePicker(_buildRangeOfAgePicker(true), _buildRangeOfAgePicker(false));
                                          });
                                    },
                                    behavior: HitTestBehavior.translucent,
                                    child: _buildAgeSelect(),
                                  ),
                                  // 구분선
                                  const Padding(
                                    padding: const EdgeInsets.only(top: 25, bottom: 25),
                                    child: Divider(thickness: 1),
                                  ),
                                  // 성별 선택 버튼 및 메시지
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "성별 ",
                                        style: TextStyle(color: colorGrey, fontSize: 16),
                                      ),
                                      CustomRadioButton(
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
                                          _selectGender(value);
                                        },
                                        unSelectedColor: Colors.white,
                                        selectedColor: Colors.white,
                                        buttonTextStyle: ButtonTextStyle(
                                          selectedColor: Colors.black,
                                          unSelectedColor: colorGrey,
                                        ),
                                        elevation: 0,
                                        width: 73.33,
                                        height: 30,
                                        enableShape: true,
                                        radius: 5,
                                        selectedBorderColor: Colors.green,
                                        unSelectedBorderColor: colorLightGrey,
                                        defaultSelected: "any",
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: AnimatedCrossFade(
                                      firstChild: SizedBox(
                                        width: double.infinity,
                                        height: 25,
                                        child: Center(
                                            child: Text(
                                          "${_selectedGender! == 1 ? "️🙋🏻️남성" : "🙋🏻‍♀여성"}만 이 모임에 참여할 수 있게 돼요!",
                                          style: TextStyle(color: Color(0xAAAA0000), fontSize: 14),
                                        )),
                                      ),
                                      secondChild: const SizedBox(),
                                      sizeCurve: Curves.decelerate,
                                      duration: Duration(milliseconds: 500),
                                      crossFadeState: _selectedGender == 0 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // 자율 참여 선택 버튼 및 메시지
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            "모임 방식 ",
                                            style: TextStyle(color: colorGrey, fontSize: 16),
                                          ),
                                          GestureDetector(
                                            onTap: () async => await _tooltipController.showTooltip(),
                                            child: SuperTooltip(
                                              popupDirection: TooltipDirection.up,
                                              arrowTipDistance: 7,
                                              shadowSpreadRadius: 3,
                                              shadowColor: Colors.black.withAlpha(150),
                                              showDropBoxFilter: true,
                                              showBarrier: true,
                                              sigmaX: 2.5,
                                              sigmaY: 2.5,
                                              controller: _tooltipController,
                                              content: Container(
                                                width: MediaQuery.of(context).size.width * 9 / 10,
                                                height: 200,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 10.0),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Icon(
                                                            Icons.info,
                                                            size: 16,
                                                            color: colorGrey,
                                                          ),
                                                          Text(
                                                            " 위치공유 모임 : \n - 모임이 성사되면 채팅방이 개설돼요.\n - 모임 15분 전 위치 공유 서비스가 활성화돼요.\n - 참여 및 불참이 GPS로 자동 확인돼요.",
                                                            style: TextStyle(color: Colors.black, fontSize: 13),
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Icon(
                                                            Icons.info,
                                                            size: 16,
                                                            color: colorGrey,
                                                          ),
                                                          Text(
                                                            " 자율적인 모임 : \n - 모임이 성사되면 채팅방이 개설돼요. \n - 이후에는 모임 시간에 맞추어 자율적으로 참여해요.",
                                                            style: TextStyle(color: Colors.black, fontSize: 13),
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Icon(
                                                            Icons.info,
                                                            size: 16,
                                                            color: colorGrey,
                                                          ),
                                                          Text(
                                                            " 인원 무제한시 : \n - 8명 이하면 [위치공유 모임]으로 설정돼요.\n - 9명 이상이면 [자율적인 모임]으로 설정돼요.",
                                                            style: TextStyle(color: Colors.black, fontSize: 13),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                String.fromCharCode(Icons.info_outline.codePoint),
                                                style: TextStyle(
                                                  inherit: false,
                                                  color: Colors.deepOrangeAccent,
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: Icons.info_outline.fontFamily,
                                                  package: Icons.info_outline.fontPackage,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      _selectedPerson != "무제한" ? CustomRadioButton(
                                        buttonLables: const [
                                          "위치공유 모임",
                                          "자율적인 모임",
                                        ],
                                        buttonValues: const [
                                          "withGPS",
                                          "voluntary",
                                        ],
                                        radioButtonValue: (value) {
                                          _selectVoluntary(value);
                                        },
                                        unSelectedColor: Colors.white,
                                        selectedColor: Colors.white,
                                        buttonTextStyle: ButtonTextStyle(
                                          selectedColor: Colors.black,
                                          unSelectedColor: colorGrey,
                                        ),
                                        elevation: 0,
                                        width: 114,
                                        height: 30,
                                        enableShape: true,
                                        radius: 5,
                                        selectedBorderColor: Colors.green,
                                        unSelectedBorderColor: colorLightGrey,
                                        defaultSelected: "withGPS",
                                      ) : Text("참여 인원수에 따른 자동 설정 ", style: TextStyle(color: colorGrey, fontSize: 16),)
                                    ],
                                  ),

                                  const SizedBox(height: 15),
                                  //SuperTooltip(content: content),

                                  const SizedBox(height: 80),
                                ]),
                              ),
                            )),
                      ],
                    ),
                  ),
                  // 글 작성 버튼
                  Align(
                    child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: AnimatedCrossFade(
                          firstChild: Padding(
                            padding: EdgeInsets.only(bottom: 18),
                            child: InkWell(
                              onTap: () {
                                if (!_btnVisible) return;
                                // 게시물 양식 확인
                                var errMsg = _checkIsInputEmpty();
                                if (errMsg != "Success") {
                                  showAlert(errMsg, context, colorError);
                                  return;
                                }
                                bool success = false;
                                _tryUploadPost().then((value) {
                                  success = value;
                                  if (success) {
                                    postManager.reloadPages("").then((value) {
                                      setState(() => _isUploading = false);
                                      showAlert(success ? "글 작성 완료!" : "글 작성에 실패했습니다!", context, success ? colorSuccess : colorError);
                                      Navigator.pop(context);
                                    });
                                  }
                                });
                              },
                              child: SizedBox(
                                height: 50,
                                width: MediaQuery.of(context).size.width - 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: colorSuccess,
                                      boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 4.5)]),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 15.0, right: 2),
                                          child: Text(
                                            "글 작성 완료하기",
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Icon(Icons.edit, color: Colors.white, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          secondChild: Padding(
                              padding: const EdgeInsets.only(left: 0, right: 0, bottom: 15),
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _scrollController!.position.moveTo(_scrollController!.position.maxScrollExtent,
                                      duration: Duration(milliseconds: 500), curve: Curves.easeOutQuart);
                                },
                                child: Container(
                                    decoration: BoxDecoration(color: colorGrey.withAlpha(200), borderRadius: BorderRadius.circular(5)),
                                    height: 20,
                                    width: MediaQuery.of(context).size.width,
                                    child: RotatedBox(
                                      quarterTurns: 1,
                                      child: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.white),
                                    )),
                              )),
                          duration: Duration(milliseconds: 250),
                          sizeCurve: Curves.decelerate,
                          crossFadeState: _btnVisible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        )),
                    alignment: Alignment.bottomCenter,
                  ),
                  _isUploading
                      ? GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.only(bottom: 50),
                            color: Color(0x66000000),
                            child: buildLoadingProgress(),
                          ),
                        )
                      : SizedBox()
                ],
              ),
            ),
          )),
      onWillPop: () async => false, // 스와이프하여 뒤로가기 방지
    );
  }

  Column _buildAgeSelect() {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('희망 연령대', style: TextStyle(fontSize: 16, color: colorGrey)),
          Row(
            children: [
              Text(
                (_maxAge == _minAge && _maxAge == -1) ? "상관 없음" : '${_minAge == -1 ? "" : _minAge} ~ ${_maxAge == -1 ? "" : _maxAge}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
              )
            ],
          )
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
        if (_scrollController!.offset > _scrollController!.position.maxScrollExtent * 3 / 4) {
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

  _selectGender(var value) {
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

  _selectVoluntary(var value) {
    _isVoluntary = value == "voluntary";
    setState(() {});
  }

  // 게시물 업로드 시도
  Future<bool> _tryUploadPost() async {
    bool successUpload = false;
    bool successUploadProfiles = false;

    // 게시물 양식 조건이 모두 맞으면 업로드 시도
    setState(() => _isUploading = true); // 업로드 시작
    DateTime dt = DateTime.now();
    successUpload = await addPost(
        head: _head!.text,
        body: _body!.text,
        gender: _selectedGender!,
        maxPerson: _selectedPerson == "무제한" ? -1 : int.parse(_selectedPerson),
        time: "${dateFormatter.format(_selectedDate)} ${_selectedTime.to24hours()}:00",
        llName: _llName!,
        upTime:
            "${dateFormatter.format(dt)} ${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}:${dt.second.toString().padLeft(2, "0")}",
        category: _selectedCategory,
        minAge: _minAge,
        maxAge: _maxAge,
        writerNick: myProfileEntity!.name,
        isVoluntary: _isVoluntary);
    profileEntity = EntityProfiles(FirebaseAuth.instance.currentUser!.uid);
    successUploadProfiles = await profileEntity!.addPostId();

    return successUpload && successUploadProfiles;
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
    } else if (_selectedCategory == "없음") {
      msg = "카테고리를 지정해주세요! ";
    } else if (_llName == null) {
      msg = "모임 장소를 선택해주세요!";
    } else if (_selectedPerson == "선택") {
      msg = "모임 인원을 선택해주세요!";
    } else if (_minAge != -1 && _maxAge != -1 && _maxAge - _minAge < 0) {
      msg = "연령대 범위가 잘못되었습니다!";
    } else if (selectTime - nowTime < 30 && _selectedDate.day - DateTime.now().day == 0) {
      msg = "모임 시간은 최소 30분 이후입니다!";
    }
    return msg;
  }
}

// 올린 시간 정규화
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
