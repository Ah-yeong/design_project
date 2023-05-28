import 'package:cloud_firestore/cloud_firestore.dart';

import 'EntityPost.dart';

class PostPageManager {
  bool isLoaded = false;
  int _loadedCount = 0;
  int _maxCount = 100;
  int _lastLoaded = 0;
  int _scrollCount = 0;
  List<EntityPost> list = List.empty(growable: true);

  PostPageManager() {}

  void reloadPage() {
    isLoaded = true;
    _maxCount += 100;
    loadPages().then((value) => isLoaded = false);
  }

  Future<void> loadPages() async {
    int post_count = 0;
    DocumentReference<Map<String, dynamic>> ref =
        await FirebaseFirestore.instance.collection("Post").doc("postData");
    await ref.get().then((DocumentSnapshot ds) {
      post_count = ds.get("post_count");
    });
    var qs = await FirebaseFirestore.instance.collection("Post").get();
    for(DocumentSnapshot ds in qs.docs) {
      if(post_count <= _loadedCount || _maxCount <= _loadedCount) {
        isLoaded = true;
        return;
      }
      if (ds.id == "postData") continue;
      if(int.parse(ds.id) <= _lastLoaded) continue;
      EntityPost pg = EntityPost(int.parse(ds.id));
      await pg.loadPost();
      list.add(pg);
      _loadedCount++;
      _lastLoaded = int.parse(ds.id);
    }
    isLoaded = true;
    return;
    // forEach((doc) async {
    //   if(doc.id != "postData" && _maxCount > _loadedCount && int.parse(doc.id) > _lastLoaded) {
    //     if(int.parse(doc.id) > _lastLoaded) {
    //       EntityPostGroup pg = EntityPostGroup(doc.id);
    //       await pg.loadPost();
    //       list.add(pg);
    //       _loadedCount++;
    //       _lastLoaded = int.parse(doc.id);
    //       print("로드완료, $_loadedCount");
    //     }
    //   }
    // });
  }

  int get maxCount => _maxCount;
  int get loadedCount => _loadedCount;
  int get lastLoaded => _lastLoaded;
  int get scrollCount => _scrollCount;
}