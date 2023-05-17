import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//구글맵 + 유저 위치 정보
class GoogleMapPage extends StatelessWidget {
  List<PersonInfoWidget> people = [
    PersonInfoWidget(nickname: "AAA", distance: 50, arrived: true),
    PersonInfoWidget(nickname: "BBB", distance: 250, arrived: true),
    PersonInfoWidget(nickname: "CCC", distance: 150, arrived: true),
    PersonInfoWidget(nickname: "DDD", distance: 200, arrived: false),
    PersonInfoWidget(nickname: "EEE", distance: 100, arrived: false),
    PersonInfoWidget(nickname: "FFF", distance: 80, arrived: false),
    PersonInfoWidget(nickname: "GGG", distance: 300, arrived: false),
    PersonInfoWidget(nickname: "HHH", distance: 120, arrived: false),
  ];
  final Set<Marker> _markers = {}; //지도 위 마크 표시
  //const GoogleMapPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // final screenHeight = MediaQuery.of(context).size.height;
    // final halfScreenHeight = screenHeight / 2.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("현재 모임 상황"),
        backgroundColor: Color(0xFF6ACA89),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            height: 220,
            child: ListView.builder(
              itemCount: people.length,
              itemBuilder: (BuildContext context, int index) {
                return PersonInfoWidget(
                  nickname: people[index].nickname,
                  distance: people[index].distance,
                  arrived: people[index].arrived,
                );
              },
            ),
          ),
          SizedBox(height: 25),
          Container(
            height: 400,
            child: GoogleMap(
              mapType: MapType.normal, // 지도 유형
              initialCameraPosition: CameraPosition(
                target: LatLng(36.8340603, 127.1792514),
                zoom: 17.5, // 지도 초기 줌 레벨
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                // 지도 컨트롤러
              },
            ),

          ),
        ],
      ),
    );
  }
}

//Google Map Page에서 유저들 정보
class PersonInfoWidget extends StatelessWidget {
  final String nickname;
  final int distance;
  final bool arrived;

  const PersonInfoWidget({required this.nickname, required this.distance, required this.arrived});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.person),
          Text(nickname),
          Text('${distance.toStringAsFixed(0)}m'),
          ElevatedButton(
            onPressed: () {},
            child: Text('이동중', style: TextStyle(fontSize: 11)),
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(Size(4, 25)),
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}