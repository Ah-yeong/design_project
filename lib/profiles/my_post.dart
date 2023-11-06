import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../boards/post.dart';
import '../boards/post_list/page_hub.dart';
import '../entity/entity_post.dart';
import '../entity/profile.dart';

import '../resources/loading_indicator.dart';
import '../resources/resources.dart';
import '../boards/post_list/post_list.dart';

class PageMyPost extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageMyPost();
}

class _PageMyPost extends State<PageMyPost> {
  List<EntityPost> myPostList = List.empty(growable: true);
  Map<String, List<EntityPost>> _groupedPosts = {};
  bool _isLoadingPost = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "작성한 모임 게시글",
          style: TextStyle(color: Colors.black, fontSize: 19),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const SizedBox(
            height: 55,
            width: 55,
            child: Icon(
              Icons.close_rounded,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: _isLoadingPost ? buildLoadingProgress()
          : myPostList.isEmpty ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "내가 만든 모임이 없어요\n",
              style: TextStyle(color: colorGrey, fontSize: 13),
            ),
            Text("지금 바로 새로운 모임을 만들어보세요!")
          ],
        ),
      ): SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _groupedPosts.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final dateKey = _groupedPosts.keys.elementAt(index);
              final posts = _groupedPosts[dateKey];
              return Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 3),
                      Text(
                        dateKey,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: posts!.map((post) {
                      return Column(
                        children: [
                          SizedBox(height: 5,),
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => BoardPostPage(postId: post.getPostId()),
                                ));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(7),
                                child: _buildPostCard(post),
                              ),
                            ),
                          ),
                          Divider(thickness: 1, height: 0, color: colorLightGrey),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          )
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    myProfileEntity!.loadProfile().then((n) async {
      if (myProfileEntity!.post != null) {
        Future.forEach(myProfileEntity!.post, (dynamic postId) async {
          EntityPost myPost = EntityPost(postId);
          await myPost.loadPost().then((value) => myPostList.add(myPost));
          if (myPostList.length == myProfileEntity!.post.length) {
            myPostList.sort((a, b) => a.getTime().compareTo(b.getTime()));
            Map<String, List<EntityPost>> groupedPosts= {};
            for (var post in myPostList) {
              final dateKey = post.getTime().substring(0, post.getTime().indexOf(' '));
              if (!groupedPosts.containsKey(dateKey)) {
                groupedPosts[dateKey] = [];
              }
              groupedPosts[dateKey]!.add(post);
            }
            setState(() { _groupedPosts = groupedPosts; });
          }
        });
      }
    }).then((value) => setState(() => _isLoadingPost = false));
  }

  Widget _buildPostCard(EntityPost entity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Row(children: [
                  SizedBox(width: 35, child: Icon(CupertinoIcons.person_3_fill)),
                  Text(
                    '${entity.getPostHead()}', // 글 제목
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                ]),
              ]),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 5)),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: colorGrey, size: 13),
                Text(" ${entity.getLLName().AddressName}", style: TextStyle(fontSize: 11, color: Color(0xFF858585))),
                SizedBox(height: 1),
              ],
            ),
            SizedBox(height: 5),
          ],
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(getMeetTimeText(entity.getTime())+" 모임", style: const TextStyle(color: colorGrey, fontSize: 13)),
            ),
            Icon(Icons.arrow_forward_ios),
          ],
        )
      ],
    );
  }
}