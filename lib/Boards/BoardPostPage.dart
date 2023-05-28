import 'dart:async';

import 'package:flutter/material.dart';
import '../Entity/EntityPost.dart';
import '../Entity/EntityProfile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:design_project/resources.dart';

class BoardPostPage extends StatefulWidget {
  final int postId;

  const BoardPostPage({super.key, required this.postId});

  @override
  State<StatefulWidget> createState() => _BoardPostPage();
}

class _BoardPostPage extends State<BoardPostPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final List<Marker> _markers = [];

  static const CameraPosition _kSeoul = CameraPosition(
    target: LatLng(36.833068, 127.178419),
    zoom: 17.4746,
  );

  var postId;
  EntityPost? postEntity;
  EntityProfiles? profileEntity;
  bool isLoaded = false;
  bool postTimeIsLoaded = false;
  var postTime;
  Size? mediaSize;

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    return !isLoaded
        ? const Center(
            child: CircularProgressIndicator(
              strokeWidth: 5,
              color: Colors.black,
              backgroundColor: Colors.white,
            ),
          )
        : Scaffold(
            bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFF6F6F6),
        elevation: 1,
        notchMargin: 4,
        child: SizedBox(
            height: 55,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(padding: EdgeInsets.only(left: 40)),
                    SizedBox(
                        width: mediaSize!.width / 3 - 20,
                        child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("현재 인원 ${postEntity!.getPostCurrentPerson()}/${postEntity!.getPostMaxPerson()} 명",
                                    style: const TextStyle(color: Colors.black54, fontSize: 14)),
                                const Text("마감 하루 남음",
                                    style: TextStyle(color: Colors.black54, fontSize: 14)),
                              ],
                            )
                        )
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                        width: mediaSize!.width / 2 - 20,
                        height: mediaSize!.height / 22,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: colorSuccess),
                        child: const Center(
                          child: Text("신청하기",
                              style: TextStyle(color: Colors.white, fontSize: 15)),
                        )
                    ),
                    const Padding(padding: EdgeInsets.only(left: 20)),
                  ],
                )
              ],
            ),
          ),
      ),
      appBar: AppBar(
        title: const Text(
          "게시글",
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 3 / 8,
                          child: GoogleMap(
                            markers: Set.from(_markers),
                            mapType: MapType.normal,
                            initialCameraPosition: CameraPosition(
                              target: postEntity!.getLLName().latLng,
                              zoom: 17.4746,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                          ),
                        ),
                        // 지도 표시 구간
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
                        ),

                        // 제목 및 카테고리
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(postEntity!.getPostHead(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: const Color(0xFFBFBFBF)),
                                  child: const Padding(
                                    padding: EdgeInsets.only(
                                        right: 5, left: 5, top: 3, bottom: 3),
                                    child: Text("20~24세",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 1, right: 1),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: const Color(0xFFBFBFBF)),
                                  child: const Padding(
                                    padding: EdgeInsets.only(
                                        right: 5, left: 5, top: 3, bottom: 3),
                                    child: Text("남자만",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 1, right: 1),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: const Color(0xFFBFBFBF)),
                                  child: const Padding(
                                    padding: EdgeInsets.only(
                                        right: 5, left: 5, top: 3, bottom: 3),
                                    child: Text("영화",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 1, right: 1),
                                ),
                              ],
                            )
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                          child: Divider(
                            thickness: 1,
                          ),
                        ),
                        drawProfile(),
                        // 프로필
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 4, 0, 12),
                          child: Divider(
                            thickness: 1,
                          ),
                        ),
                        Text(postEntity!.getPostBody(),
                            style: const TextStyle(fontSize: 15)),
                        // 내용
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        ),
                        Text("조회수 ${postEntity!.viewCount}, $postTime",
                            style: const TextStyle(
                                fontSize: 12.5, color: Color(0xFF888888))),
                        // 조회수 및 게시글 시간
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                          child: Divider(
                            thickness: 1,
                          ),
                        ),
                        // const Text("모임 장소 및 시간",
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.bold, fontSize: 16)),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                        ),
                        Text("시간 : ${postEntity!.getTime()}"),
                        const Text("장소 : 예시 텍스트"),

                        // Text("Max Person : ${postEntity!.getPostMaxPerson()}"),
                        // Text("Gender Limit : ${postEntity!.getPostGender()}"),
                      ]),
                )),
      ),
    );
  }

  void _updatePosition(CameraPosition _position) {
    var m = _markers.firstWhere((p) => p.markerId == const MarkerId('1'));
    _markers.remove(m);
    _markers.add(
      Marker(
        markerId: const MarkerId('1'),
        position: LatLng(_position.target.latitude, _position.target.longitude),
        draggable: true,
      ),
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    postId = widget.postId;
    postEntity = EntityPost(postId);
    postEntity!.loadPost().then((value) {
      profileEntity = EntityProfiles(postEntity!.getWriterId());
      profileEntity!.makeTestingProfile();
      _markers.add(Marker(
          markerId: const MarkerId('1'),
          draggable: true,
          onTap: () => print("marker tap"),
          position: postEntity!.getLLName().latLng));
      loadPostTime();
    });
    //postEntity!.makeTestingPost();
  }

  Color _getColorForScore(int score) {
    if (score < 20) {
      return Colors.red;
    } else if (score < 40) {
      return Colors.orange;
    } else if (score < 60) {
      return Colors.lime;
    } else if (score < 80) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  loadPostTime() {
    String ptime = getTimeBefore(postEntity!.getUpTime());
    postTime = ptime;
    setState(() {
      postTimeIsLoaded = true;
      isLoaded = true;
    });
  }

  Widget drawProfile() {
    final color = _getColorForScore(profileEntity!.mannerGroup);
    return GestureDetector(
      onTap: () {
        // 프로필 터치 이벤트
        print(profileEntity!.profileId);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                profileEntity!.profileImagePath,
                width: 45,
                height: 45,
              ),
              const Padding(padding: EdgeInsets.only(left: 10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${profileEntity!.name}",
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 4)),
                  Text(
                    "${profileEntity!.major}, ${profileEntity!.age}세",
                    style:
                        const TextStyle(color: Color(0xFF777777), fontSize: 13),
                  )
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 7, top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("매너 지수 ${profileEntity!.mannerGroup}점", style: const TextStyle(color: Color(0xFF777777), fontSize: 12),),
                const Padding(padding: EdgeInsets.only(top:2),),
                SizedBox(
                  height: 6,
                  width: 105,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: profileEntity!.mannerGroup / 100,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      backgroundColor: color.withOpacity(0.3),
                    ),
                  )
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
