import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../resources.dart';

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
  final TextEditingController _searchController = TextEditingController();

  // LatLng _initialPosition = LatLng(37.5665, 126.9780);
  // GoogleMapController? _mapController;
  // Set<Marker> _markers = {};
  //
  // void _onMapCreated(GoogleMapController controller) {
  //   _mapController = controller;
  // }
  //
  // void _onTapMap(LatLng position) {
  //   setState(() {
  //     _markers.clear();
  //     _markers.add(
  //       Marker(
  //         markerId: MarkerId(position.toString()),
  //         position: position,
  //       ),
  //     );
  //   });
  // }
  //
  // void _onSearchSubmitted(String query) async {
  //   List<Location> locations = await locationFromAddress(query);
  //   if (locations.isNotEmpty) {
  //     final LatLng position =
  //     LatLng(locations.first.latitude, locations.first.longitude);
  //     _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  //     _onTapMap(position);
  //   }
  // }

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
                primary: styleColor,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(primary: styleColor))),
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
              primary: styleColor,
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
  Color _selectedColor = Color(0xFF6ACA9A);
  String? _selectedPerson = "2";

  final _formKey = GlobalKey<FormState>();
  int _minAge = 18;
  int _maxAge = 99;

  TextEditingController? head;
  TextEditingController? body;
  int? _selectedSex = 0;

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
                            Text(' 모임 날짜',
                                style:
                                    TextStyle(fontSize: 16, color: fontGrey)),
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
                            Text(' 모임 시간',
                                style:
                                    TextStyle(fontSize: 16, color: fontGrey)),
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
                            Text(' 모임 장소',
                                style:
                                    TextStyle(fontSize: 16, color: fontGrey)),
                            // GoogleMap(
                            //   onMapCreated: _onMapCreated,
                            //   onTap: _onTapMap,
                            //   markers: _markers,
                            //   initialCameraPosition: CameraPosition(
                            //     target: _initialPosition,
                            //     zoom: 10,
                            //   ),
                            // ),
                            SizedBox(height: 10),
                            const Divider(
                              thickness: 1,
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
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
                                      Text(' 인원 수',
                                          style: TextStyle(
                                              fontSize: 16, color: fontGrey)),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Text('${_selectedPerson}',
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Text('${_selectedPerson == "무제한" ? "                  " : "명                   "}',
                                          style: TextStyle(
                                              fontSize: 16, color: fontGrey)),
                                    ],
                                  ),
                                  Icon(Icons.keyboard_arrow_right)
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
                                Text(' 희망 연령대',
                                    style: TextStyle(
                                        fontSize: 16, color: fontGrey)),
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
                                            fontSize: 16, color: fontGrey)),
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
                                            fontSize: 16, color: fontGrey)),
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
                                        color: fontGrey, fontSize: 16),
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
                                        selectedColor: styleColor,
                                        elevation: 1,
                                        selectedBorderColor: fontGrey,
                                        unSelectedBorderColor: fontGrey,
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
                            // ElevatedButton(
                            //   onPressed: () => _selectTime(context),
                            //   child: Text(_selectedTime == null
                            //       ? 'Select time'
                            //       : 'Selected time: ${timeFormatter.format(DateTime(2000, 1, 1, _selectedTime.hour, _selectedTime.minute))}'),
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                            //   children: [
                            //     DropdownButton<int>(
                            //       value: _selectedMinAge,
                            //       hint: Text('최소 연령 선택'),
                            //       onChanged: (int? selectedMinAge) {
                            //         setState(() {
                            //           _selectedMinAge = selectedMinAge ?? _selectedMinAge;
                            //         });
                            //       },
                            //       items: _ages.where((age) => _selectedMaxAge == null || age < _selectedMaxAge!).map((age) {
                            //         return DropdownMenuItem<int>(
                            //           value: age,
                            //           child: Text('$age 세'),
                            //         );
                            //       }).toList(),
                            //     ),
                            //     DropdownButton<int>(
                            //       value: _selectedMaxAge,
                            //       hint: Text('최대 연령 선택'),
                            //       onChanged: (int? selectedMaxAge) {
                            //         setState(() {
                            //           _selectedMaxAge = selectedMaxAge ?? _selectedMaxAge;
                            //         });
                            //       },
                            //       items: _ages.where((age) => _selectedMinAge == null || age > _selectedMinAge!).map((age) {
                            //         return DropdownMenuItem<int>(
                            //           value: age,
                            //           child: Text('$age 세'),
                            //         );
                            //       }).toList(),
                            //     ),
                            //   ],
                            // )
                          ]),
                    ),
                  )),
              // SizedBox(
              //   width: double.infinity,
              //   height: 50,
              //   child: ElevatedButton(
              //     child: Text('등록'),
              //     style: ElevatedButton.styleFrom(
              //       primary: Color(0xFF6ACA9A),
              //     ),
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(builder: (context) => preferenceScreen()),
              //       );
              //     },
              //   ),
              // )
            ],
          )),
    );
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
