import 'package:flutter/material.dart';

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

  @override
  void initState() {
    tempCategory =
        List.of(["술", "밥", "영화", "산책", "공부", "취미", "운동", "기타", "음악", "게임"]);
    itemCnt = tempCategory!.length;
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
                      child: Text("지금 시간대 추천 카테고리",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ), // 지금 시간대 추천 카테고리
                  Padding(
                      padding: const EdgeInsets.fromLTRB(15, 16, 16, 16),
                      child: SizedBox(
                        height: 31,
                        width: double.maxFinite,
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Container(
                                decoration: _buildBoxDecoration(),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10, left: 10, top: 7, bottom: 7),
                                  child: Text(tempCategory![index],
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14)),
                                ),
                              ),
                            );
                          },
                          scrollDirection: Axis.horizontal,
                          itemCount: itemCnt,
                        ),
                      )), // 카테고리 스크롤뷰
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
                          children: [
                            const Text("최근 검색어",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text("모두 지우기", style: TextStyle(fontSize: 12, color: Color(0xFF888888)),),
                                ),
                                const VerticalDivider(),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text("저장 기능 끄기", style: TextStyle(fontSize: 12, color: Color(0xFF888888)),),
                                ),
                              ],
                            )
                          ],
                        )
                    ),
                  ), // 최근 검색어
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 4,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10),
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: SizedBox(
                                  height: 70,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              print("tapped $index");
                                            },
                                            child: Row(
                                              children: [
                                                const Icon(Icons.search_sharp),
                                                Padding(padding: EdgeInsets.only(left:10), child: Text("예시 $index"),),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              print("closed $index");
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
                        itemCount: 20,
                      ),
                    ),
                  ),
                ],
              ))),
      onTap: () {FocusManager.instance.primaryFocus?.unfocus();},
    );

  }

  BoxDecoration _buildBoxDecoration() {
    return const BoxDecoration(
      color: Color(0xFFEAEAEA),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );
  }

  OutlineInputBorder _buildOutlineInputBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFCCCCCC)),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );
  }
}