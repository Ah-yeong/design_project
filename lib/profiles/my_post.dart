import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../boards/post.dart';
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
  EntityProfiles? myProfile;
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
    myProfile = EntityProfiles(FirebaseAuth.instance.currentUser!.uid);
    myProfile!.loadProfile().then((n) async {
      if (myProfile!.post != null) {
        Future.forEach(myProfile!.post, (dynamic postId) async {
          EntityPost myPost = EntityPost(postId);
          await myPost.loadPost().then((value) => myPostList.add(myPost));
          if (myPostList.length == myProfile!.post.length) {
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
        }).then((value) => setState(() => _isLoadingPost = false));
      }
    });
  }

  Widget _buildPostCard(EntityPost entity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 5,
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entity.getPostHead()}', // 글 제목
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Container(
                            width: 60,
                            height: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: const Color(0xFF6ACA9A),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.emoji_people, color: Colors.white, size: 14,),
                                      Text(getMaxPersonText(entity),
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 10)),
                                    ],
                                  )
                              ),
                            ),
                          )
                      )
                    ],
                  )
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: colorGrey, size: 13,),
                  Text(
                    " ${entity.getLLName().AddressName}",
                    style: TextStyle(fontSize: 11, color: Color(0xFF858585)),
                  ),
                  SizedBox(height: 1,),
                ],
              ),
              SizedBox(height: 1,),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: colorGrey, size: 13,),
                  Text(
                    getMeetTimeText(entity.getTime()),
                    style: TextStyle(fontSize: 11, color: Color(0xFF858585)),
                  ),
                ],
              ),
              SizedBox(height: 5,),
            ],
          ),
        ),
        SizedBox(width: 12,),
        Container(
          child: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18,),
        )
      ],
    );
  }
}