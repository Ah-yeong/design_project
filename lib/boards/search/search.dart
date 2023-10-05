import 'package:design_project/Resources/resources.dart';
import 'package:get/get.dart';
import 'package:design_project/Boards/Search/search_post_list.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../post_list/page_hub.dart';

final formKey = GlobalKey<FormState>();

class BoardSearchPage extends StatefulWidget {
  const BoardSearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _BoardSearchPage();
}

class _BoardSearchPage extends State<BoardSearchPage> {
  TabController? controller;
  TextEditingController? textEditingController;
  var itemCnt;
  List<String>? tempCategory;
  List<String>? _searchHistory;
  bool _searchHistoryEnabled = true;

  SharedPreferences? _storage;

  @override
  void initState() {
    _searchHistory = List.empty(growable: true);
    tempCategory = CategoryList;
    itemCnt = tempCategory!.length;
    loadStorage().then((value) => {
          setState(() {
            _searchHistory = _storage!.getStringList("${myUuid}_search_history") ?? _searchHistory;
            _searchHistoryEnabled = _storage!.getBool("${myUuid}_search_history_enabled") ?? _searchHistoryEnabled;
          })
        });
  }

  Future<void> loadStorage() async {
    _storage = await SharedPreferences.getInstance();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
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
                      _searchPost(search_value, null);
                    },
                  ),
                )),
            leading: const BackButton(
              color: Colors.black,
            ),
            backgroundColor: Colors.white,
          ),
          body: SafeArea(
              child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text("지금 시간대 추천 카테고리", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ), // 지금 시간대 추천 카테고리
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Wrap(
                      direction: Axis.horizontal,
                      // 나열 방향
                      alignment: WrapAlignment.start,
                      // 정렬 방식
                      spacing: 7,
                      // 좌우 간격
                      runSpacing: 7,
                      // 상하 간격
                      children: CategoryList.map((e) => GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              _searchPost("", e);
                            },
                            child: Container(
                              padding: const EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                              decoration: BoxDecoration(
                                color: Color(0xFFEAEAEA),
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              child: Text(
                                '$e',
                                style: TextStyle(color: Colors.black, fontSize: 14),
                              ),
                            ),
                          )).toList())), // 카테고리 스크롤뷰
              const Padding(
                padding: EdgeInsets.fromLTRB(13, 0, 13, 0),
                child: Divider(
                  thickness: 1.2,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("최근 검색어", style: TextStyle(fontWeight: FontWeight.bold)),
                            const Text(
                              "검색어는 최대 20개까지 저장됩니다",
                              style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchHistory!.clear();
                                  _storage!.setStringList("${myUuid}_search_history", _searchHistory!);
                                });
                              },
                              child: const Text(
                                "모두 지우기",
                                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                              ),
                            ),
                            const VerticalDivider(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchHistoryEnabled = !_searchHistoryEnabled;
                                  _storage!.setStringList("${myUuid}_search_history", List.empty());
                                  _searchHistory!.clear();
                                  _storage!.setBool("${myUuid}_search_history_enabled", _searchHistoryEnabled);
                                });
                              },
                              child: Text(
                                "저장 기능 ${_searchHistoryEnabled ? "끄기" : "켜기"}",
                                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
              ), // 최근 검색어
              _buildHistory(),
            ],
          ))),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }

  Widget _buildHistory() {
    return _searchHistoryEnabled
        ? _searchHistory!.length == 0
            ? SizedBox(
                height: 100,
                width: double.infinity,
                child: Center(
                    child: Text(
                  "저장된 검색어가 없습니다",
                  style: TextStyle(color: colorGrey, fontSize: 15),
                )),
              )
            : Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 4, mainAxisSpacing: 10, crossAxisSpacing: 10),
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: SizedBox(
                              height: 70,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            _searchPost(_searchHistory![_searchHistory!.length - index - 1], null),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.search_sharp),
                                            Padding(
                                              padding: EdgeInsets.only(left: 10),
                                              child: Text("${_searchHistory![_searchHistory!.length - index - 1]}"),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _searchHistory!.removeAt(_searchHistory!.length - index - 1);
                                            _storage!.setStringList("${myUuid}_search_history", _searchHistory!);
                                          });
                                        },
                                        child: const Icon(Icons.close),
                                      )
                                    ],
                                  ),
                                  const Divider(
                                    thickness: 1.5,
                                  ),
                                ],
                              )));
                    },
                    itemCount: _searchHistory!.length,
                  ),
                ),
              )
        : SizedBox(
            height: 100,
            width: double.infinity,
            child: Center(
                child: Text(
              "검색어 자동 저장 기능이 꺼져있습니다",
              style: TextStyle(color: colorGrey, fontSize: 15),
            )),
          );
  }

  _searchPost(String search_value, String? category) {
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
    Get.off(() => BoardSearchListPage(
          search_value: search_value,
          category: category,
        ));
  }

  OutlineInputBorder _buildOutlineInputBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFCCCCCC)),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );
  }
}
