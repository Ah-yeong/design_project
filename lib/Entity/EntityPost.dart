import 'package:ntp/ntp.dart';

class EntityPostGroup {
  var _postId;
  var _writerId;
  var _head;
  var _body;
  var _gender;
  var _maxPerson;
  var _currentPerson;
  var _time;
  var _locationX;
  var _locationY;
  late String _upTime;
  var viewCount;
  bool _isLoaded = false;

  EntityPostGroup(var this._postId) {
    loadPost();
  }

  loadPost() {
    // 포스팅 로드
    Future<String> temp = getTimeBefore();
    _isLoaded = true;
  }

  makeTestingPost() {
    _postId = "00000001";
    _writerId = "jongwon1019";
    _head = "제목 테스트 - 영화 볼 사람?!";
    _body = "내용입니다. \n다른 이유는 없습니다.";
    _gender = "man";
    _maxPerson = "5";
    _currentPerson = "2";
    _time = "2023-04-22 11:10:05";
    _locationX = "36.833068";
    _locationY = "127.178419";
    _upTime = "2023-04-16 13:27:00";
    viewCount = "1342";
    _isLoaded = true;
  }

  // Getter, (ReadOnly)
  String getPostId() => _postId;
  String getWriterId() => _writerId;
  String getPostHead() => _head;
  String getPostBody() => _body;
  String getPostGender() => _gender;
  String getPostMaxPerson() => _maxPerson;
  String getPostCurrentPerson() => _currentPerson;
  String getTime() => _time;
  String getUpTime() => _upTime;
  List<String> getLocation() => List.of([_locationX, _locationY]);

  bool isLoad() => _isLoaded;

  Future<String> getTimeBefore() async {
    DateTime currentTime = await NTP.now();
    currentTime = currentTime.toUtc(); // 한국 시간
    DateTime beforeTime = DateTime.parse(_upTime);
    Duration timeGap = currentTime.difference(beforeTime);

    if(timeGap.inDays > 365) {
      return "${timeGap.inDays ~/ 365}년 전";
    } else if (timeGap.inDays >= 30) {
      return "${timeGap.inDays ~/ 30}개월 전";
    } else if (timeGap.inDays >= 1) {
      return timeGap.inDays == 1 ? "하루 전" : ("${timeGap.inDays}일 전");
    } else if (timeGap.inHours >= 1) {
      return "${timeGap.inHours}시간 전";
    } else if (timeGap.inMinutes >= 1) {
      return "${timeGap.inMinutes}분 전";
    } else {
      return "방금 전";
    }

    // List<String> ymdCurrent = cTime.split(" ")[0].split("-");
    // List<String> ymdBefore = _upTime.split(" ")[0].split("-");
    // List<String> hmsCurrent = cTime.split(" ")[1].split(":");
    // List<String> hmsBefore = _upTime.split(" ")[2].split(":");

    int diff = 0;
    // 년도의 차이가 있을 경우
    // for(int i = 0; i < 3; i++) {
    //   if (ymdCurrent[i] != ymdBefore[i]) {
    //     diff = int.parse(timeCurrent[i]) - int.parse(timeBefore[i]);
    //     return "$diff${i == 0 ? "년" :
    //         i == 1 ? "개월" :
    //         i == 2 ? "일" :
    //         i == 3 ? "시간" :
    //             i == 4 ? "분" :
    //         ""} 전" ;
    //   }
    // }
    // return "방금 전";
  }
}

class EntityPostTaxi {

}