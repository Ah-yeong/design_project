import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Boards/BoardPostPage.dart';
import '../Boards/List/BoardPostListPage.dart';
import '../Entity/EntityPost.dart';
import '../Entity/EntityProfile.dart';
import 'package:design_project/Profiles/PageProfile.dart';

import '../Resources/LoadingIndicator.dart';
import '../Resources/resources.dart';

class PageMyPost extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageMyPost();
}

class _PageMyPost extends State<PageMyPost> {
  EntityProfiles? myProfile;
  List<EntityPost> myPostList = List.empty(growable: true);
  Map<String, List<EntityPost>> groupedPosts = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "내가 만든 모임",
          style: TextStyle(color: Colors.black, fontSize: 16),
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
        toolbarHeight: 40,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: myProfile!.isLoading ? buildLoadingProgress()
      : SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: myPostList.isEmpty ?
          Column(
            children: [
              SizedBox(height: 20),
              Center(
                child: Text("내가 만든 모임이 아직 없습니다.",
                    style: TextStyle(color: Colors.grey, fontSize: 15)
                )
              )
            ],
          ) :
          Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: myPostList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Card(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => BoardPostPage(postId: myPostList[index].getPostId()),
                          ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: _buildFriendRow(myPostList[index]),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    myProfile = EntityProfiles(FirebaseAuth.instance.currentUser!.uid);
    myProfile!.loadProfile().then((n) {
      for (var postId in myProfile!.post) {
        EntityPost myPost = EntityPost(postId);
        myPost.loadPost().then((value) {
          myPostList.add(myPost);
          if (myPostList.length == myProfile!.post.length) {
            myPostList.sort((a, b) => a.getTime().compareTo(b.getTime()));

            for (var post in myPostList) {
              final dateKey = post.getTime().substring(0, post.getTime().indexOf(' '));
              if (!groupedPosts.containsKey(dateKey)) {
                groupedPosts[dateKey] = [];
              }
              groupedPosts[dateKey]!.add(post);
            }
            setState(() {
            });
          }
        });
      }
    });
  }

  Widget _buildFriendRow(EntityPost entity) {
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
                          padding: const EdgeInsets.only(right: 5, bottom: 5),
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
      ],
    );
  }
}