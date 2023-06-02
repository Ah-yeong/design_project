import 'package:design_project/Entity/EntityPostPageManager.dart';
import 'package:flutter/material.dart';

import '../../resources.dart';
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
                    setState(() {});
                    _pageManager.reloadPages(search_value).then((value) {setState(() {});});
                  },
                ),
              )),
          leading: const BackButton(
            color: Colors.black,
          ),
          backgroundColor: Colors.white,
        ),
      body: _pageManager.isLoading ? Center(
          child: SizedBox(
              height: 65,
              width: 65,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: colorSuccess,
              )))
          : CustomScrollView(
        controller: _scrollController,
        slivers: [
          /*SliverToBoxAdapter(
          child: Container(
            height: 400,
            color: Colors.grey,
          ),
        ),*/
          SliverList(
              delegate: SliverChildBuilderDelegate(
                      (context, index) => GestureDetector(
                    onTap: () {
                      naviToPost(index);
                    },
                    child: Card(
                        child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: buildFriendRow(_pageManager.list[index]))),
                  ),
                  childCount: _pageManager.loadedCount))
        ],
      )
    );
  }

  @override
  void initState() {
    super.initState();
    _search_value = widget.search_value;
    _pageManager.loadPages(_search_value!).then((value) => setState(() {}));
    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.offset + 100<
            _scrollController.position.minScrollExtent &&
            _scrollController.position.outOfRange && _pageManager.isLoading ) {
          _pageManager.reloadPages(_search_value!).then((value) => setState(() {}));
        }
      });
    });
    textEditingController.text = _search_value!;
  }

  naviToPost(int index) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => BoardPostPage(postId: _pageManager.list[index].getPostId())));
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