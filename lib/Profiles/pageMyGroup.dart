import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Boards/BoardPostPage.dart';
import '../Boards/List/BoardPostListPage.dart';
import '../Entity/EntityPost.dart';
import '../Entity/EntityProfile.dart';
import 'package:design_project/Profiles/PageProfile.dart';

import '../resources.dart';

class PageMyGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageMyGroup();
}

class _PageMyGroup extends State<PageMyGroup> {
  EntityProfiles? myProfile;
  List<EntityPost> myGroupList = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "내가 속한 모임",
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
      body:
      // body: profileEntity!.isLoading ? Center(
      //     child: SizedBox(
      //         height: 65,
      //         width: 65,
      //         child: CircularProgressIndicator(
      //           strokeWidth: 4,
      //           color: colorSuccess,
      //         ))) :
      SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: myGroupList.map((group) {
            return Card(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => BoardPostPage(postId: group.getPostId()),
                  ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: _buildFriendRow(group),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    myProfile = EntityProfiles(FirebaseAuth.instance.currentUser!.uid);
    myProfile!.loadProfile().then((n) {
      for (var groupId in myProfile!.group) {
        EntityPost myGroup = EntityPost(groupId);
        myGroup.loadPost().then((value) {
          myGroupList.add(myGroup);
          setState(() {});
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
                        '${entity!.getPostHead()}', // 글 제목
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
                                      Text(getMaxPersonText(entity!),
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
                    " ${entity!.getLLName().AddressName}",
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
                    getMeetTimeText(entity!),
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