class EntityProfiles {
  var profileId;
  var name;
  var age;
  var major; // 학과
  late String profileImagePath;
  var mannerGroup; // 소모임 매너지수
  var mannerTaxi; // 택시 온도
  bool _isLoaded = false;

  EntityProfiles(var this.profileId) {
    loadProfile();
    _isLoaded = true;
  }

  loadProfile() {

  }

  makeTestingProfile() {
    name = "홍길동";
    age = 23;
    major = "소프트웨어학과";
    profileImagePath = "assets/images/userImage.png";
    mannerGroup = 80;
    mannerTaxi = 64;
    _isLoaded = true;
  }
}