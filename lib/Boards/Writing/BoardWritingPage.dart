import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:design_project/Boards/Writing/BoardSelectPositionPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../resources.dart';

// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';

final key = GlobalKey<CustomRadioButtonState>();


const List<String> _peopleCounts = <String>[
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
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  TimeOfDay _selectedTime = TimeOfDay.now();

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
      initialTime: _selectedTime,
    );
    if (newSelectedTime != null) {
      setState(() {
        _selectedTime = newSelectedTime;
      });
    }
  }

  Color maleButtonColor = Colors.grey;
  Color femaleButtonColor = Colors.grey;
  String? _selectedPerson = "2";

  ScrollController? _scrollController;
  bool _btnVisible = false;

  final _formKey = GlobalKey<FormState>();
  int _minAge = 18;
  int _maxAge = 99;

  TextEditingController? head;
  TextEditingController? body;
  int? _selectedSex = 0;

  LatLng? _position;
  String? _positionName;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormatter = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // 홈화면으로 이동
          },
        ),
        title: Text(
          '게시물 작성',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 40,
      ),
      body: Container(
          padding: EdgeInsets.all(20.0),
          height: double.maxFinite,
          child: Stack(
            children: [
              Column(
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
                                  controller: head,
                                  cursorColor: Colors.black,
                                  decoration: const InputDecoration(
                                      hintText: "글 제목 (최대 20자)",
                                      counterText: "",
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.black12),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.black54))),
                                ),
                                TextField(
                                  maxLines: 5,
                                  maxLength: 500,
                                  maxLengthEnforcement: MaxLengthEnforcement.none,
                                  controller: head,
                                  cursorColor: Colors.black,
                                  decoration: const InputDecoration(
                                      hintText: "내용 작성 (최대 500자)",
                                      counterText: "",
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.black12),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.black54))),
                                ),
                                SizedBox(height: 10.0),
                                Text('모임 날짜',
                                    style:
                                    TextStyle(fontSize: 16, color: colorGrey)),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => _selectDate(context),
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xFF6ACA9A),
                                  ),
                                  child: Text(
                                      _selectedDate == null
                                          ? 'Select date'
                                          : '${dateFormatter.format(_selectedDate)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                      )),
                                ),
                                const Divider(
                                  thickness: 1,
                                ),
                                SizedBox(height: 10),
                                Text('모임 시간',
                                    style:
                                    TextStyle(fontSize: 16, color: colorGrey)),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => _selectTime(context),
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xFF6ACA9A),
                                  ),
                                  child: Text(
                                      _selectedTime == null
                                          ? 'Select date'
                                          : '${_selectedTime.format(context)}',
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
                                    var modify = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => BoardSelectPositionPage()));
                                    setState(() {
                                      _positionName = modify ?? _positionName;
                                    });
                                  },
                                  child:
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('모임 장소',
                                              style:
                                              TextStyle(fontSize: 16, color: colorGrey)),
                                          SizedBox(height: 5,),
                                          Text(_positionName ?? '해당 영역을 눌러 모임 장소를 지정해주세요',
                                              style:
                                              TextStyle(fontSize: 15)),
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios,size: 20,)
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
                                  onTap: (){
                                    showCupertinoModalPopup<void>(
                                        context: context, builder: (BuildContext context){
                                      return _buildBottomPicker(
                                          _buildCupertinoPicker()
                                      );
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text('인원 수',
                                              style: TextStyle(
                                                  fontSize: 16, color: colorGrey)),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Text('${_selectedPerson}',
                                              style: TextStyle(
                                                  fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Text('${_selectedPerson == "무제한" ? "" : "명"}',
                                              style: TextStyle(
                                                  fontSize: 16, color: colorGrey)),
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios,size: 20,)
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
                                Row(
                                  children: [
                                    Text('희망 연령대',
                                        style: TextStyle(
                                            fontSize: 16, color: colorGrey)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Row(
                                      children: [
                                        DropdownButton(
                                          value: _minAge,
                                          onChanged: (value) {
                                            setState(() {
                                              _minAge = value as int;
                                            });
                                          },
                                          items: _buildDropdownItems(18, 99),
                                        ),
                                        Text('  ~  ',
                                            style: TextStyle(
                                                fontSize: 16, color: colorGrey)),
                                        DropdownButton(
                                          value: _maxAge,
                                          onChanged: (value) {
                                            setState(() {
                                              _maxAge = value as int;
                                            });
                                          },
                                          items: _buildDropdownItems(_minAge, 99),
                                        ),
                                        Text('세',
                                            style: TextStyle(
                                                fontSize: 16, color: colorGrey)),
                                      ],
                                    )
                                  ],
                                ),

                                const Divider(
                                  thickness: 1,
                                ),
                                AnimatedPadding(
                                  padding: _selectedSex == 0
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
                                      Expanded(child:
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
                                          selectSex(value);
                                        },
                                        unSelectedColor: Colors.white,
                                        selectedColor: colorSuccess,
                                        elevation: 1,
                                        selectedBorderColor: colorGrey,
                                        unSelectedBorderColor: colorGrey,
                                        defaultSelected: "any",
                                      )
                                      )

                                    ],
                                  ),
                                ),
                                (_selectedSex! != 0
                                    ? Center(
                                    child: Text(
                                        "해당 성별(${_selectedSex! == 1 ? "남성" : "여성"})에게만 게시글이 나타나게 됩니다!",
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
              AnimatedOpacity(opacity: _btnVisible ? 1.0 : 0.0, duration: const Duration(milliseconds: 200), child:
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 18),
                  child: InkWell(
                      onTap: () => showAlert("작성 불가능!", context, colorError),
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
                                  Icon(Icons.edit, color: Colors.white,),
                                ],
                              )
                          ),
                        ),
                      )),
                ),

              ),),
            ],
          ),
      ),
    );
  }

  void tryUploadPost() {

  }

  Widget _buildCupertinoPicker() {
    return CupertinoPicker(
      magnification: 1.22,
      squeeze: 1.2,
      useMagnifier: true,
      itemExtent: 32,
      // This sets the initial item.
      scrollController: FixedExtentScrollController(
        initialItem: 0,
      ),
      // This is called when selected item is changed.
      onSelectedItemChanged: (int selectedItem) {
        setState(() {
          _selectedPerson = _peopleCounts[selectedItem];
        });
      },
      children:
      List<Widget>.generate(_peopleCounts.length, (int index) {
        return Center(child: Text(_peopleCounts[index]));
      }),
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

  List<DropdownMenuItem<int>> _buildDropdownItems(int start, int end) {
    List<DropdownMenuItem<int>> items = [];
    for (int i = start; i <= end; i++) {
      items.add(
        DropdownMenuItem(
          value: i,
          child: Text('$i'),
        ),
      );
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    head = TextEditingController();
    body = TextEditingController();
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
    super.dispose();
  }

  selectSex(var value) {
    setState(() {
      if (value == "any") {
        _selectedSex = 0;
      } else if (value == "man") {
        _selectedSex = 1;
      } else {
        _selectedSex = 2;
      }
    });
  }

  // 사람 만나기 작성 폼
  Widget friendsForm() {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [],
        ));
  }
}
