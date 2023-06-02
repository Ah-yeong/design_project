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

  void continuePage() {
    isLoading = true;
    _maxCount += 100;
    loadPages().then((value) => isLoading = false);
  }

  Future<void> reloadPages() async {
    isLoading = true;
    _loadedCount = 0;
    _lastLoaded = 0;
    _scrollCount = 0;
    _maxCount = 100;
    list.clear();
    await loadPages().then((value) => isLoading = false);
  }

  Future<void> loadPages() async {
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

      EntityPost post = EntityPost(int.parse(ds.id));
      await post.loadPost();
      list.add(post);
      _loadedCount++;
      _lastLoaded = int.parse(ds.id);
    }
    isLoading = false;
    return;
  }

  int get maxCount => _maxCount;
  int get loadedCount => _loadedCount;
  int get lastLoaded => _lastLoaded;
  int get scrollCount => _scrollCount;
}