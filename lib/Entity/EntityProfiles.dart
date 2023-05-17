class EntityProfiles {
  var profileId;
  var name;
  var age;
  var major; // 학과
  late String profileImagePath;
  var mannerGroup; // 소모임 매너지수
  var mannerTaxi; // 택시 온도

  var nickname;
  List<String>? hobby;
  var mbti;
  var commute;
  var birth;

  bool _isLoaded = false;

  EntityProfiles(var this.profileId) {
    loadProfile();
    _isLoaded = true;
  }

  loadProfile() {
    // profileID 로 프로필 불러오기
  }

  makeTestingProfile() {
    name = "홍길동";
    age = 23;
    major = "소프트웨어학과";
    profileImagePath = "assets/images/userImage.png";
    mannerGroup = 80;
    mannerTaxi = 64;

    nickname = "테스트";
    hobby = ["술", "영화"];
    birth = "1999-10-19";
    commute = "통학";

    _isLoaded = true;
  }
}