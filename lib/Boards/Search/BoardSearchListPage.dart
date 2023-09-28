import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:design_project/Entity/EntityLatLng.dart';
import 'package:design_project/Entity/EntityPostPageManager.dart';
import 'package:design_project/Resources/LoadingIndicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import '../../Entity/EntityPost.dart';
import '../../Resources/resources.dart';
import '../List/BoardPostListPage.dart';
import '../BoardPostPage.dart';

final formKey = GlobalKey<FormState>();

class BoardSearchListPage extends StatefulWidget {
  final String search_value;
  final String? category;

  const BoardSearchListPage({super.key, required this.search_value, this.category});

  @override
  State<StatefulWidget> createState() => _BoardSearchListPage();
}

class _BoardSearchListPage extends State<BoardSearchListPage> {
  String? _search_value;
  String? _paramCategory;
  var count = 10;

  ScrollController _scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  PostPageManager _pageManager = PostPageManager();

  List<String>? _searchHistory;
  bool _searchHistoryEnabled = true;
  SharedPreferences? _storage;

  Position? position;
  double _lat = 36.833068;
  double _lng = 127.178419;

  List<String> _sortingOptionList = List.of(["최신순", "거리 가까운 순", "모임 시간 빠른 순"]);
  List<String> _timeOptionList = List.of(["제한 없음", "1시간 이내", "6시간 이내", "1일 이내", "7일 이내", "직접 입력"]);
  List<String> _genderOptionList = List.of(["제한 없음", "남자만", "여자만"]);
  List<String> _categoryList = CategoryList;
  int _minPeople = 2;
  int _maxPeople = 9;
  String _peopleText = " 모임 인원에 상관없이 게시글을 검색합니다.";
  String _peopleFilterText = "";
  int _distanceValue = 50;

  int _selectedSortingBy = 0;
  int _selectedSortingByTemp = 0;
  int _selectedTime = 0;
  int _selectedTimeTemp = 0;
  int _selectedGender = 0;
  int _selectedGenderTemp = 0;
  List<String> _selectedCategory = List.empty(growable: true);

  bool _filteringTime = false;
  bool _filteringPeople = false;
  bool _filteringDistance = false;
  bool _filteringCategory = false;
  bool _filteringGender = false;

  Future<void> loadPos() async {
    // 애뮬레이터 비활성화시 아래 주석 제거
    /*
    await determinePosition().then((value) {
      _lat = value.latitude;
      _lng = value.longitude;
      print(_lat);
      print(_lng);
    });
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 1,
          title: Form(
              key: formKey,
              child: SizedBox(
                height: 40,
                width: 400,
                child: TextFormField(
                  textInputAction: TextInputAction.search,
                  textAlignVertical: TextAlignVertical.bottom,
                  controller: textEditingController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: "검색어를 입력하세요",
                      enabledBorder: _buildOutlineInputBorder(),
                      disabledBorder: _buildOutlineInputBorder(),
                      focusedBorder: _buildOutlineInputBorder()),
                  onFieldSubmitted: (search_value) {
                    _search_value = search_value;
                    _searchPost(search_value);
                  },
                ),
              )),
          leading: const BackButton(
            color: Colors.black,
          ),
          backgroundColor: Colors.white,
        ),
        body: _pageManager.isLoading
            ? buildLoadingProgress()
            : GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
                child: Column(
                  children: [
                    SizedBox(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  buildSortingButton("${_sortingOptionList[_selectedSortingBy]}", () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) => _buildModalSheet(context, 0),
                                        backgroundColor: Colors.transparent);
                                  }, true),
                                  Row(
                                    children: _buildFilteringContents(),
                                  )
                                ],
                              ),
                            ))),
                    _pageManager.list.length != 0
                        ? Expanded(
                            child: ListView.builder(
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () {
                                naviToPost(index);
                              },
                              child: Card(
                                  child: Padding(
                                      padding: const EdgeInsets.all(7),
                                      child: buildFriendRow(_pageManager.list[_pageManager.list.length - index - 1],
                                          _pageManager.list[_pageManager.list.length - index - 1].distance))),
                            ),
                            itemCount: _pageManager.loadedCount,
                          ))
                        : Expanded(
                            child: Center(
                                child: Text(
                              "검색된 모임이 없습니다",
                              style: TextStyle(color: colorGrey, fontWeight: FontWeight.bold, fontSize: 15),
                            )),
                          ),
                    _pageManager.list.length == 0
                        ? SizedBox(
                            width: double.infinity,
                            height: 65,
                          )
                        : SizedBox()
                  ],
                ),
              ));
  }

  Widget buildSortingButton(String nameText, void Function() onTap, bool isEnabled) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Container(
            decoration: _buildBoxDecoration(
                isEnabled ? Color(0xFFFFFFFF) : Color(0xFFFFFFFF), isEnabled ? colorGrey : Color(0xFFEAEAEA)),
            child: Padding(
                padding: const EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                child: Row(
                  children: [
                    Text("$nameText ",
                        style: TextStyle(
                            color: isEnabled ? Colors.black : colorGrey, fontSize: 14, fontWeight: FontWeight.normal)),
                    RotatedBox(
                      quarterTurns: 1,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: isEnabled ? 11 : 10,
                        color: isEnabled ? Color(0xFF000000) : colorGrey,
                      ),
                    )
                  ],
                ))),
      ),
      onTap: onTap,
    );
  }

  @override
  void initState() {
    super.initState();
    _searchHistory = List.empty(growable: true);
    _search_value = widget.search_value;
    if (widget.category != null) {
      _paramCategory = widget.category;
      _filteringCategory = true;
      _selectedCategory.add(_paramCategory!);
    }
    _applyFiltering();
    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.offset + 100 < _scrollController.position.minScrollExtent &&
            _scrollController.position.outOfRange &&
            _pageManager.isLoading) {
          _pageManager.reloadPages(_search_value!).then((value) => setState(() {}));
        }
      });
    });
    loadPos();

    textEditingController.text = _search_value!;
    loadStorage().then((value) => {
          setState(() {
            _searchHistory = _storage!.getStringList("${myUuid}_search_history") ?? _searchHistory;
            _searchHistoryEnabled = _storage!.getBool("${myUuid}_search_history_enabled") ?? _searchHistoryEnabled;
          })
        });
  }

  _searchPost(String search_value) {
    if (search_value != "" && search_value.length < 2) {
      showAlert("검색어를 두 글자 이상 입력해주세요", context, colorSuccess);
      return;
    }
    if (search_value != "") {
      if (_searchHistoryEnabled) {
        if (_searchHistory!.length == 20) {
          // 최대 20개 까지 저장할 수 있음
          _searchHistory!.removeAt(0);
        }
        if (_searchHistory!.contains(search_value)) {
          _searchHistory!.remove(search_value);
        }
        _searchHistory!.add(search_value);
        _storage!.setStringList("${myUuid}_search_history", _searchHistory!);
      }
    }
    setState(() {});
    _pageManager.reloadPages(search_value).then((value) {
      if (_selectedSortingBy == 0)
        _sortingByRecently();
      else if (_selectedSortingBy == 1)
        _sortingByDistance();
      else if (_selectedSortingBy == 2) _sortingByTime();
      setState(() {});
    });
  }

  Future<void> loadStorage() async {
    _storage = await SharedPreferences.getInstance();
    return;
  }

  naviToPost(int index) {
    final int postId = _pageManager.list[_pageManager.list.length - index - 1].getPostId();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            BoardPostPage(postId: postId)));
  }

  OutlineInputBorder _buildOutlineInputBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFCCCCCC)),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );
  }

  Widget _buildModalSheet(BuildContext context, int pageIdx) {
    return StatefulBuilder(builder: (BuildContext context, StateSetter myState) {
      Widget modalChildWidget = _buildSortingSheet(myState);
      switch (pageIdx) {
        // 0. 정렬 기준
        case 1:
          modalChildWidget = _buildTimeSheet(myState);
          break; // 1. 모임 시간
        case 2:
          modalChildWidget = _buildPeopleSheet(myState);
          break; // 2. 최대 인원
        case 3:
          modalChildWidget = _buildDistanceSheet(myState);
          break; // 3. 거리
        case 4:
          modalChildWidget = _buildCategorySheet(myState);
          break; // 4. 카테고리
        case 5:
          modalChildWidget = _buildGenderSheet(myState);
          break; // 5. 성별
        default:
          break;
      }
      return SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(padding: EdgeInsets.all(13), child: modalChildWidget),
      ));
    });
  }

  Widget _buildSortingSheet(StateSetter stateSetter) {
    return Padding(
        padding: EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("정렬 기준",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.left),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 125,
              width: double.infinity,
              child: ListView.builder(
                itemBuilder: (context, index) => GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    stateSetter(() {
                      setState(() {
                        _selectedSortingByTemp = index;
                      });
                    });
                  },
                  child: SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _sortingOptionList[index],
                          style: _selectedSortingByTemp == index
                              ? TextStyle(color: colorSuccess, fontWeight: FontWeight.bold, fontSize: 16)
                              : TextStyle(color: Colors.black, fontSize: 15),
                        ),
                        _selectedSortingByTemp == index
                            ? Icon(
                                Icons.check_rounded,
                                color: colorSuccess,
                                size: 22,
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
                ),
                itemCount: 3,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
              child: Padding(
                padding: EdgeInsets.only(bottom: 18),
                child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSortingBy = _selectedSortingByTemp;
                        switch (_selectedSortingBy) {
                          case 0:
                            _sortingByRecently();
                            break;
                          case 1:
                            _sortingByDistance();
                            break;
                          case 2:
                            _sortingByTime();
                            break;
                          default:
                            _sortingByRecently();
                            break;
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: colorSuccess,
                            boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 4.5)]),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "적용하기",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ],
                        )),
                      ),
                    )),
              ),
            ),
          ],
        ));
  }

  Widget _buildTimeSheet(StateSetter stateSetter) {
    return Padding(
        padding: EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("모임 시간",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.left),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 250,
              width: double.infinity,
              child: ListView.builder(
                itemBuilder: (context, index) => GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    stateSetter(() {
                      setState(() {
                        _selectedTimeTemp = index;
                      });
                    });
                  },
                  child: SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _timeOptionList[index],
                          style: _selectedTimeTemp == index
                              ? TextStyle(color: colorSuccess, fontWeight: FontWeight.bold, fontSize: 16)
                              : TextStyle(color: Colors.black, fontSize: 15),
                        ),
                        _selectedTimeTemp == index
                            ? Icon(
                                Icons.check_rounded,
                                color: colorSuccess,
                                size: 22,
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
                ),
                itemCount: 6,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
              child: Padding(
                padding: EdgeInsets.only(bottom: 18),
                child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTime = _selectedTimeTemp;
                        _filteringTime = _selectedTime == 0 ? false : true;
                        // filtering of Time
                        _applyFiltering();
                      });
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: colorSuccess,
                            boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 4.5)]),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "적용하기",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ],
                        )),
                      ),
                    )),
              ),
            ),
          ],
        ));
  }

  Widget _buildPeopleSheet(StateSetter stateSetter) {
    return Padding(
        padding: EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("최대 인원",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.left),
            SizedBox(
              height: 20,
            ),
            SizedBox(
                height: 100,
                width: double.infinity,
                child: Column(
                  children: [
                    SliderTheme(
                        data: SliderThemeData(
                            thumbColor: colorGrey,
                            rangeThumbShape: RoundRangeSliderThumbShape(
                              enabledThumbRadius: 9,
                              pressedElevation: 1,
                            ),
                            trackHeight: 4,
                            activeTrackColor: colorGrey,
                            activeTickMarkColor: colorGrey,
                            overlayColor: const Color(0x00000000),
                            rangeValueIndicatorShape: PaddleRangeSliderValueIndicatorShape(),
                            valueIndicatorColor: Colors.black),
                        child: RangeSlider(
                          min: 2,
                          max: 9,
                          divisions: 7,
                          values: RangeValues(_minPeople.toDouble(), _maxPeople.toDouble()),
                          labels: RangeLabels(_minPeople == 9 ? "무제한" : _minPeople.toString(),
                              _maxPeople == 9 ? "무제한" : _maxPeople.toString()),
                          onChanged: (changeValue) {
                            _minPeople = changeValue.start.round().toInt();
                            _maxPeople = changeValue.end.round().toInt();
                            stateSetter(() {
                              setState(() {
                                if (_minPeople == 2 && _maxPeople == 9) {
                                  _peopleText = " 모임 인원에 상관없이 게시글을 검색합니다.";
                                  return;
                                } else if (_minPeople == _maxPeople) {
                                  if (_maxPeople == 9) {
                                    _peopleText = " 모임 인원이 무제한인 게시글을 검색합니다.";
                                    _peopleFilterText = "인원 무제한";
                                  } else {
                                    _peopleText = " 모임 인원이 $_maxPeople명인 게시글을 검색합니다.";
                                    _peopleFilterText = "$_maxPeople명";
                                  }
                                } else {
                                  _peopleText =
                                      " 모임 인원이 $_minPeople ~ ${_maxPeople == 9 ? "" : "$_maxPeople"}명인 게시글을 검색합니다.";
                                  _peopleFilterText = "$_minPeople~${_maxPeople == 9 ? "" : "$_maxPeople"}명";
                                }
                              });
                            });
                          },
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.black,
                          size: 15,
                        ),
                        Text(_peopleText),
                      ],
                    ),
                  ],
                )),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
              child: Padding(
                padding: EdgeInsets.only(bottom: 18),
                child: InkWell(
                    onTap: () {
                      setState(() {
                        _filteringPeople = !(_minPeople == 2 && _maxPeople == 9);
                        _applyFiltering();
                      });
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: colorSuccess,
                            boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 4.5)]),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "적용하기",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ],
                        )),
                      ),
                    )),
              ),
            ),
          ],
        ));
  }

  Widget _buildDistanceSheet(StateSetter stateSetter) {
    return Padding(
        padding: EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("거리",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.left),
            SizedBox(
              height: 20,
            ),
            SizedBox(
                height: 100,
                width: double.infinity,
                child: Column(
                  children: [
                    SliderTheme(
                        data: SliderThemeData(
                            thumbColor: colorGrey,
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 9,
                              pressedElevation: 1,
                            ),
                            trackHeight: 4,
                            activeTrackColor: colorGrey,
                            activeTickMarkColor: colorGrey,
                            overlayColor: const Color(0x00000000),
                            valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                            valueIndicatorColor: Colors.black),
                        child: Slider(
                          min: 0,
                          max: 50,
                          divisions: 50,
                          value: _distanceValue.toDouble(),
                          label: "${_distanceValue == 50 ? "무제한" : "${(_distanceValue + 1) * 100}m"}",
                          onChanged: (changeValue) {
                            stateSetter(() {
                              setState(() {
                                _distanceValue = changeValue.round().toInt();
                              });
                            });
                          },
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.black,
                          size: 15,
                        ),
                        Text(
                            " 모임 장소${_distanceValue == 50 ? "에 상관없이 " : "가 ${(_distanceValue + 1) * 100}m 이내인 "}게시글을 검색합니다."),
                      ],
                    ),
                  ],
                )),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
              child: Padding(
                padding: EdgeInsets.only(bottom: 18),
                child: InkWell(
                    onTap: () {
                      setState(() {
                        _filteringDistance = _distanceValue != 50;
                        _applyFiltering();
                      });
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: colorSuccess,
                            boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 4.5)]),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "적용하기",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ],
                        )),
                      ),
                    )),
              ),
            ),
          ],
        ));
  }

  Widget _buildCategorySheet(StateSetter stateSetter) {
    return Padding(
        padding: EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("카테고리 선택",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.left),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Column(children: [
                Wrap(
                    direction: Axis.horizontal,
                    // 나열 방향
                    alignment: WrapAlignment.start,
                    // 정렬 방식
                    spacing: 7,
                    // 좌우 간격
                    runSpacing: 7,
                    // 상하 간격
                    children: _categoryList
                        .map((e) => GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                stateSetter(() {
                                  setState(() {
                                    if (_selectedCategory.contains(e))
                                      _selectedCategory.remove(e);
                                    else
                                      _selectedCategory.add(e);
                                  });
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                                decoration: BoxDecoration(
                                  color: _selectedCategory.contains(e) ? colorGrey : Color(0xFFEAEAEA),
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                                child: Text(
                                  '$e',
                                  style: TextStyle(
                                      color: _selectedCategory.contains(e) ? Colors.white : Colors.black, fontSize: 14),
                                ),
                              ),
                            ))
                        .toList()),
              ]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
              child: Padding(
                padding: EdgeInsets.only(bottom: 18),
                child: InkWell(
                    onTap: () {
                      setState(() {
                        _filteringCategory = !_selectedCategory.isEmpty;
                        _applyFiltering();
                      });
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: colorSuccess,
                            boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 4.5)]),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "적용하기",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ],
                        )),
                      ),
                    )),
              ),
            ),
          ],
        ));
  }

  Widget _buildGenderSheet(StateSetter stateSetter) {
    return Padding(
      padding: EdgeInsets.all(7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("성별 제한",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.left),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: ListView.builder(
              itemBuilder: (context, index) => GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  stateSetter(() {
                    setState(() {
                      _selectedGenderTemp = index;
                    });
                  });
                },
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _genderOptionList[index],
                        style: _selectedGenderTemp == index
                            ? TextStyle(color: colorSuccess, fontWeight: FontWeight.bold, fontSize: 16)
                            : TextStyle(color: Colors.black, fontSize: 15),
                      ),
                      _selectedGenderTemp == index
                          ? Icon(
                              Icons.check_rounded,
                              color: colorSuccess,
                              size: 22,
                            )
                          : SizedBox()
                    ],
                  ),
                ),
              ),
              itemCount: 3,
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
            child: Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedGender = _selectedGenderTemp;
                    _filteringGender = _selectedGender == 0 ? false : true;
                    _applyFiltering();
                  });
                  Navigator.pop(context);
                },
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: colorSuccess,
                        boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 4.5)]),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "적용하기",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double getDistance(double lat, double lng) {
    return Geolocator.distanceBetween(lat, lng, _lat, _lng);
  }

  BoxDecoration _buildBoxDecoration(Color contentColor, Color outlineColor) {
    return BoxDecoration(
      color: contentColor,
      border: Border.all(color: outlineColor),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );
  }

  void _sortingByDistance() {
    for (EntityPost post in _pageManager.list) {
      LLName temp = post.getLLName();
      post.distance = getDistance(temp.latLng.latitude, temp.latLng.longitude);
    }
    Comparator<EntityPost> entityComparator = (a, b) => b.distance.compareTo(a.distance);
    _pageManager.list.sort(entityComparator);
  }

  void _sortingByRecently() {
    for (EntityPost post in _pageManager.list) post.distance = 0.0;
    Comparator<EntityPost> entityComparator = (a, b) => a.getPostId().compareTo(b.getPostId());
    _pageManager.list.sort(entityComparator);
  }

  void _sortingByTime() {
    for (EntityPost post in _pageManager.list) post.distance = 0.0;
    Comparator<EntityPost> entityComparator = (a, b) => a.getTime().compareTo(b.getTime());
    _pageManager.list.sort(entityComparator);
  }

  void _applyFiltering() {
    _pageManager.reloadPages(_search_value!).then((value) {
      if (_selectedSortingBy == 0)
        _sortingByRecently();
      else if (_selectedSortingBy == 1)
        _sortingByDistance();
      else if (_selectedSortingBy == 2) _sortingByTime();

      List<EntityPost> removeList = List.empty(growable: true);
      for (EntityPost post in _pageManager.list) {
        bool removeFlag = false;

        // 모임 인원 필터
        if (_filteringPeople) {
          // maxPerson이 무제한인 경우 -1
          if (post.getPostMaxPerson() == -1) {
            if (_maxPeople != 9) {
              // RangeSlider의 우측 범위가 맨 오른쪽이 아니면 삭제
              removeFlag = true;
            }
          } else if (_minPeople > post.getPostMaxPerson() || _maxPeople < post.getPostMaxPerson()) {
            removeFlag = true;
          }
        }

        // 거리 필터
        if (_filteringDistance) {
          LLName temp = post.getLLName();
          double dist = getDistance(temp.latLng.latitude, temp.latLng.longitude);
          post.distance = dist;
          if (dist > (_distanceValue + 1) * 100) removeFlag = true;
        }

        // 성별 필터
        if (_filteringGender) {
          if (post.getPostGender() != _selectedGender) removeFlag = true;
        }

        // 모임 시간 필터
        if (_filteringTime) {
          DateTime currentTime = DateTime.now();
          currentTime = currentTime.toUtc(); // 한국 시간
          DateTime beforeTime = DateTime.parse(post.getTime());
          Duration timeGap = currentTime.difference(beforeTime);

          int _sTime;
          switch (_selectedTime) {
            case 1:
              _sTime = 1;
              break;
            case 2:
              _sTime = 6;
              break;
            case 3:
              _sTime = 24;
              break;
            case 4:
              _sTime = 24 * 7;
              break;
            case 5:
              _sTime = 24 * 7 * 4;
              break;
            default:
              _sTime = 0;
              break;
          }
          if (timeGap.inHours > 0) {
            removeFlag = true;
          } else if (-1 * timeGap.inHours > _sTime) {
            removeFlag = true;
          }
        }

        // 카테고리 필터
        if (_filteringCategory) {
          if (!_selectedCategory.contains(post.getCategory())) {
            removeFlag = true;
          }
        }

        // flag = true인 포스트 삭제
        if (removeFlag) {
          removeList.add(post);
        }
      }

      for (EntityPost target in removeList) {
        _pageManager.removePost(target);
      }

      setState(() {});
    });
  }

  List<Widget> _buildFilteringContents() {
    return <Widget>[
      _filteringTime
          ? buildSortingButton(_filteringTime ? _timeOptionList[_selectedTime] : "모임 시간", () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => _buildModalSheet(context, 1),
                  backgroundColor: Colors.transparent);
            }, _filteringTime)
          : SizedBox(),

      _filteringPeople
          ? buildSortingButton(_filteringPeople ? _peopleFilterText : "최대 인원", () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => _buildModalSheet(context, 2),
                  backgroundColor: Colors.transparent);
            }, _filteringPeople)
          : SizedBox(),

      _filteringDistance
          ? buildSortingButton(_filteringDistance ? "${(_distanceValue + 1) * 100}m 이내" : "거리", () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => _buildModalSheet(context, 3),
                  backgroundColor: Colors.transparent);
            }, _filteringDistance)
          : SizedBox(),

      _filteringCategory
          ? buildSortingButton(
              _selectedCategory.length != 0 && _filteringCategory
                  ? _selectedCategory.length == 1
                      ? _selectedCategory.first
                      : "${_selectedCategory.first} 외 ${_selectedCategory.length - 1}개"
                  : "카테고리", () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => _buildModalSheet(context, 4),
                  backgroundColor: Colors.transparent);
            }, _filteringCategory)
          : SizedBox(),

      _filteringGender
          ? buildSortingButton(_filteringGender ? getGenderTextForInteger(_selectedGender) : "성별", () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => _buildModalSheet(context, 5),
                  backgroundColor: Colors.transparent);
            }, _filteringGender)
          : SizedBox(),

      // --------------------- 후순위 --------------------- //
      !_filteringTime
          ? buildSortingButton(_filteringTime ? _timeOptionList[_selectedTime] : "모임 시간", () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => _buildModalSheet(context, 1),
                  backgroundColor: Colors.transparent);
            }, _filteringTime)
          : SizedBox(),

      !_filteringPeople
          ? buildSortingButton(_filteringPeople ? _peopleFilterText : "최대 인원", () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => _buildModalSheet(context, 2),
                  backgroundColor: Colors.transparent);
            }, _filteringPeople)
          : SizedBox(),

      !_filteringDistance
          ? buildSortingButton(_filteringDistance ? "${(_distanceValue + 1) * 100}m 이내" : "거리", () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => _buildModalSheet(context, 3),
                  backgroundColor: Colors.transparent);
            }, _filteringDistance)
          : SizedBox(),

      !_filteringCategory
          ? buildSortingButton(
              _selectedCategory.length != 0 && _filteringCategory
                  ? _selectedCategory.length == 1
                      ? _selectedCategory.first
                      : "${_selectedCategory.first} 외 ${_selectedCategory.length - 1}개"
                  : "카테고리", () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => _buildModalSheet(context, 4),
                  backgroundColor: Colors.transparent);
            }, _filteringCategory)
          : SizedBox(),

      !_filteringGender
          ? buildSortingButton(_filteringGender ? getGenderTextForInteger(_selectedGender) : "성별", () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => _buildModalSheet(context, 5),
                  backgroundColor: Colors.transparent);
            }, _filteringGender)
          : SizedBox(),
    ];
  }

  String getGenderTextForInteger(int gender) {
    if (gender == 0)
      return "성별";
    else if (gender == 1)
      return "남자만";
    else
      return "여자만";
  }
}

String getDistanceString(double dist) {
  if (dist > 1000) {
    dist /= 1000;
    return dist.toStringAsFixed(1) + "KM";
  }
  return dist.toStringAsFixed(0) + "M";
}
