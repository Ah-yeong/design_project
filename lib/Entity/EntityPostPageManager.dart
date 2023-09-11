import 'package:cloud_firestore/cloud_firestore.dart';
import 'EntityPost.dart';

class PostPageManager {
  bool isLoading = true;
  int _loadedCount = 0;
  int _maxCount = 100;
  int _lastLoaded = 0;
  int _scrollCount = 0;
  List<EntityPost> list = List.empty(growable: true);

  PostPageManager() {}

  Future<void> continuePage() async {
    isLoading = true;
    _maxCount += 100;
    await loadPages("").then((value) => isLoading = false);
  }

  Future<void> reloadPages(String search_value) async {
    isLoading = true;
    _loadedCount = 0;
    _lastLoaded = 0;
    _scrollCount = 0;
    _maxCount = 100;
    list.clear();
    await loadPages(search_value).then((value) => isLoading = false);
  }

  Future<void> loadPages(String search_value) async {
    var qs = await FirebaseFirestore.instance.collection("Post").get();
    // FirebaseFirestore.instance.collection("Post").orderBy("post_id", descending: false).get(); => 정렬로 가져오기
    // descending : false 시 post_id에 대하여 내림차순 정렬 로드

    for(DocumentSnapshot ds in qs.docs) {
      // 한 번에 로드될 게시물의 개수 넘어가면 로드 정지
      if(_maxCount <= _loadedCount) {
        isLoading = false;
        return;
      }

      // postData값 건너 뜀
      if (ds.id == "postData") continue;

      // FirebaseQuery에서 where문 wildcard를 지원하지 않기 때문에 모든 게시물을 불러와서 직접 걸러줘야 함.
      // 검색어에 대한 제목 + 내용 검색.
      if (search_value != "") {
        bool isContainValue = ds.get("head").toString().contains(search_value) || ds.get("body").toString().contains(search_value);
        if (!isContainValue) continue;
      }

      EntityPost post = EntityPost(int.parse(ds.id));
      await post.loadPost();
      list.add(post);
      _loadedCount++;
      _lastLoaded = int.parse(ds.id);
    }
    Comparator<EntityPost> entityComparator = (a, b) => a.getPostId().compareTo(b.getPostId());
    list.sort(entityComparator);
    isLoading = false;
    return;
  }

  void removePost(EntityPost post) {
    list.remove(post);
    _loadedCount -= 1;
  }

  int get maxCount => _maxCount;
  int get loadedCount => _loadedCount;
  int get lastLoaded => _lastLoaded;
  int get scrollCount => _scrollCount;
}