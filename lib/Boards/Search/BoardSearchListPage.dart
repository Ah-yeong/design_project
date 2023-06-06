import 'package:design_project/Entity/EntityLatLng.dart';
import 'package:design_project/Entity/EntityPostPageManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as Math;

import '../../Entity/EntityPost.dart';
import '../../resources.dart';
import '../List/BoardLocationPage.dart';
import '../List/BoardPostListPage.dart';
import '../BoardPostPage.dart';

final formKey = GlobalKey<FormState>();

class BoardSearchListPage extends StatefulWidget {
  final String search_value;

  const BoardSearchListPage({super.key, required this.search_value});

  @override
  State<StatefulWidget> createState() => _BoardSearchListPage();
}

class _BoardSearchListPage extends State<BoardSearchListPage> {
  String? _search_value;
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

  int _selectedSortingBy = 0;
  int _selectedSortingByTemp = 0;
  int _selectedTime = 0;
  int _selectedTimeTemp = 0;

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
            ? Center(
                child: SizedBox(
                    height: 65,
                    width: 65,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: colorSuccess,
                    )))
            : Column(
                children: [
                  SizedBox(
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                buildSortingButton(
                                    "정렬 기준 : ${_sortingOptionList[_selectedSortingBy]}", () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          _buildModalSheet(context, 0),
                                      backgroundColor: Colors.transparent);
                                }, true),
                                buildSortingButton(
                                    "모임 시간${_filteringTime ? " : ${_timeOptionList[_selectedTime]}" : ""}", () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          _buildModalSheet(context, 1),
                                      backgroundColor: Colors.transparent);
                                }, _filteringTime),
                                buildSortingButton(
                                    "모임 인원", () => print("asdf"), _filteringPeople),
                                buildSortingButton("거리", () => print("asdf"), _filteringDistance),
                                buildSortingButton("카테고리", () => print("asdf"), _filteringCategory),
                                buildSortingButton("성별", () => print("asdf"), _filteringGender),
                              ],
                            ),
                          ))),
                  Expanded(
                      child: ListView.builder(
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        naviToPost(index);
                      },
                      child: Card(
                          child: Padding(
                              padding: const EdgeInsets.all(7),
                              child: buildFriendRow(_pageManager.list[_pageManager.list.length - index - 1]
                                  , _pageManager.list[_pageManager.list.length - index - 1].distance))),
                    ),
                    itemCount: _pageManager.loadedCount,
                  ))
                ],
              ));
  }

  Widget buildSortingButton(String nameText, void Function() onTap, bool isEnabled) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Container(
            decoration: _buildBoxDecoration(isEnabled ? Color(0xFFC5C5C5) : Color(0xFFEAEAEA)),
            child: Padding(
              padding:
                  const EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
              child: Text(nameText,
                  style: const TextStyle(color: Colors.black, fontSize: 14)),
            )),
      ),
      onTap: onTap,
    );
  }

  @override
  void initState() {
    super.initState();
    _searchHistory = List.empty(growable: true);
    _search_value = widget.search_value;
    _pageManager.loadPages(_search_value!).then((value) => setState(() {}));
    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.offset + 100 <
                _scrollController.position.minScrollExtent &&
            _scrollController.position.outOfRange &&
            _pageManager.isLoading) {
          _pageManager
              .reloadPages(_search_value!)
              .then((value) => setState(() {}));
        }
      });
    });
    loadPos();

    textEditingController.text = _search_value!;
    loadStorage().then((value) => {
          setState(() {
            _searchHistory =
                _storage!.getStringList("search_history") ?? _searchHistory;
            _searchHistoryEnabled =
                _storage!.getBool("search_history_enabled") ??
                    _searchHistoryEnabled;
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
        _storage!.setStringList("search_history", _searchHistory!);
      }
    }
    setState(() {});
    _pageManager.reloadPages(search_value).then((value) {
      if(_selectedSortingBy == 0) _sortingByRecently();
      else if(_selectedSortingBy == 1) _sortingByDistance();
      else if(_selectedSortingBy == 2) _sortingByTime();
      setState(() {});
    });

  }

  Future<void> loadStorage() async {
    _storage = await SharedPreferences.getInstance();
    return;
  }

  naviToPost(int index) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            BoardPostPage(postId: _pageManager.list[_pageManager.list.length - index - 1].getPostId())));
  }

  BoxDecoration _buildBoxDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );
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
        case 1: modalChildWidget = _buildTimeSheet(myState); break; // 1. 모임 시간
        case 2: modalChildWidget = _buildSortingSheet(myState); break; // 2. 모임 인원
        case 3: modalChildWidget = _buildSortingSheet(myState); break; // 3. 거리
        case 4: modalChildWidget = _buildSortingSheet(myState); break; // 4. 카테고리
        case 5: modalChildWidget = _buildSortingSheet(myState); break; // 5. 성별
        default: break;
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
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.left),
            SizedBox(height: 20,),
            SizedBox(
              height: 125,
              width: double.infinity,
              child: ListView.builder(itemBuilder: (context, index) => GestureDetector(
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
                    children: [Text(_sortingOptionList[index],
                      style: _selectedSortingByTemp == index ? TextStyle(color: colorSuccess, fontWeight: FontWeight.bold, fontSize: 16)
                      : TextStyle(color: Colors.black, fontSize: 15),
                    ), _selectedSortingByTemp == index ? Icon(Icons.check_rounded, color: colorSuccess, size: 22,) : SizedBox()],
                  ),
                ),
              ), itemCount: 3, scrollDirection: Axis.vertical, physics: NeverScrollableScrollPhysics(),),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 18),
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSortingBy = _selectedSortingByTemp;
                          switch(_selectedSortingBy) {
                            case 0: _sortingByRecently(); break;
                            case 1: _sortingByDistance(); break;
                            case 2: _sortingByTime(); break;
                            default: _sortingByRecently(); break;
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
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.left),
            SizedBox(height: 20,),
            SizedBox(
              height: 250,
              width: double.infinity,
              child: ListView.builder(itemBuilder: (context, index) => GestureDetector(
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
                    children: [Text(_timeOptionList[index],
                      style: _selectedTimeTemp == index ? TextStyle(color: colorSuccess, fontWeight: FontWeight.bold, fontSize: 16)
                          : TextStyle(color: Colors.black, fontSize: 15),
                    ), _selectedTimeTemp == index ? Icon(Icons.check_rounded, color: colorSuccess, size: 22,) : SizedBox()],
                  ),
                ),
              ), itemCount: 6, scrollDirection: Axis.vertical, physics: NeverScrollableScrollPhysics(),),
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

  double getDistance(double lat, double lng) {
    return Geolocator.distanceBetween(lat, lng, _lat, _lng);
  }

  void _sortingByDistance() {
    for(EntityPost post in _pageManager.list) {
      LLName temp = post.getLLName();
      post.distance = getDistance(temp.latLng.latitude, temp.latLng.longitude);
    }
    Comparator<EntityPost> entityComparator = (a, b) => b.distance.compareTo(a.distance);
    _pageManager.list.sort(entityComparator);
  }

  void _sortingByRecently() {
    for(EntityPost post in _pageManager.list) post.distance = 0.0;
    Comparator<EntityPost> entityComparator = (a, b) => a.getPostId().compareTo(b.getPostId());
    _pageManager.list.sort(entityComparator);
  }

  void _sortingByTime() {
    for(EntityPost post in _pageManager.list) post.distance = 0.0;
    Comparator<EntityPost> entityComparator = (a, b) => a.getTime().compareTo(b.getTime());
    _pageManager.list.sort(entityComparator);
  }

}
String getDistanceString(double dist) {
  if (dist > 1000) {
    dist /= 1000;
    return dist.toStringAsFixed(1) + "KM";
  }
  return dist.toStringAsFixed(0) + "M";
}