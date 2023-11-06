import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project/alert/models/alert_object.dart';
import 'package:design_project/auth/email_verified.dart';
import 'package:design_project/auth/reset_password.dart';
import 'package:design_project/resources/fcm.dart';
import 'package:design_project/resources/icon_set.dart';
import 'package:design_project/resources/loading_indicator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/signup.dart';
import 'entity/post_page_manager.dart';
import 'resources/resources.dart';
import 'package:get/get.dart';

import 'boards/post_list/page_hub.dart';

final navigatorKey = GlobalKey<NavigatorState>();

SharedPreferences? LocalStorage;
PostPageManager postManager = PostPageManager();
NotificationSettings? notificationSettings;
StateSetter? bAppbarStateSetter;
bool newChat = false;
bool newAlert = false;
Map<String, NetworkImage> userTempImage = {};

String? myToken;
String? accessToken;
PackageInfo? appInfo;

bool isInChat = false;
bool nestedChatOpenSignal = false;

// 백그라운드 푸시알림 핸들러
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    if (message.data.containsKey("type")) {
      String type = message.data["type"];
      _bottomAppbarRefresh(type);
      // else if ...
    }
  }
  // To do..
}

// 서버 토큰 받아오기
Future<void> getServerToken() async {
  DocumentReference ref = FirebaseFirestore.instance.collection("Token").doc("accessToken");
  DocumentSnapshot snapshot = await ref.get();
  accessToken = snapshot.get("tokenValue");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  appInfo = await PackageInfo.fromPlatform();

  // 알림 설정 상태
  notificationSettings = await FirebaseMessaging.instance.requestPermission(badge: true, alert: true, sound: true);

  // 로컬 알림 세팅
  // FCMController.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // iOS가 다크모드일 때도 상단 글자 검은색으로 고정
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return GetMaterialApp(
      title: 'Capstone design',
      navigatorKey: navigatorKey,
      localizationsDelegates: [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: [
        const Locale('ko', 'KR'),
      ],
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? controllerId;
  TextEditingController? controllerPw;
  bool _isRememberId = false;
  bool _isLoading = false;
  bool _splashScreenAnimated = false;
  bool _splashScreenShow = false;
  bool _fadeOutLogo = false;

  // About save options
  SharedPreferences? _localdb;
  bool? _saveIdEnabled;
  String? _savedId;

  bool _isManager = false;

  final PREFIX_COOL = "[PCD]";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          bottom: false,
          top: false,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: _fadeOutLogo ? 0 : 1,
                        duration: Duration(milliseconds: 500),
                        child: Center(
                            child: GestureDetector(
                          onDoubleTap: () {
                            setState(() {
                              _isManager = !_isManager;
                            });
                          },
                          child: Text(
                            "마음 맞는, 사람끼리",
                            style: TextStyle(
                              fontSize: 35,
                              color: Colors.black87,
                              fontFamily: "logo",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                      ),
                      AnimatedOpacity(
                        opacity: _splashScreenShow ? 1 : 0,
                        duration: Duration(milliseconds: 450),
                        child: AnimatedCrossFade(
                          firstChild: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 50,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE8E8E8),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 20),
                                          child: TextFormField(
                                              controller: controllerId,
                                              style: TextStyle(fontSize: 15),
                                              maxLength: _isManager ? 100 : 9,
                                              textInputAction: TextInputAction.next,
                                              decoration: InputDecoration(
                                                  hintText: "아이디 (학번)", hintStyle: TextStyle(fontSize: 15), border: InputBorder.none, counterText: '')),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                          height: 50,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFE8E8E8),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 20),
                                            child: TextFormField(
                                                controller: controllerPw,
                                                obscureText: true,
                                                style: TextStyle(fontSize: 15),
                                                decoration: InputDecoration(
                                                  hintText: "비밀번호",
                                                  hintStyle: TextStyle(fontSize: 15),
                                                  border: InputBorder.none,
                                                  counterText: "",
                                                )),
                                          )),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            child: Row(
                                              children: [
                                                Transform.scale(
                                                    scale: 0.9,
                                                    child: SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child: Checkbox(
                                                        value: _isRememberId,
                                                        onChanged: (_val) {
                                                          setState(() {
                                                            _isRememberId = _val!;
                                                            saveOption(_isRememberId);
                                                          });
                                                        },
                                                        activeColor: colorSuccess,
                                                      ),
                                                    )),
                                                Text(
                                                  " 아이디 저장",
                                                  style: TextStyle(fontSize: 15),
                                                )
                                              ],
                                            ),
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              setState(() {
                                                _isRememberId = !_isRememberId;
                                                saveOption(_isRememberId);
                                              });
                                            },
                                          ),
                                          GestureDetector(
                                            child: Container(
                                              height: 18,
                                              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colorGrey))),
                                              child: Text(
                                                "비밀번호 재설정",
                                                style: TextStyle(fontSize: 14, color: colorGrey),
                                              ),
                                            ),
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => PageResetPassword()));
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      SizedBox(
                                        height: 50,
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            _login();
                                          },
                                          child: const Text(
                                            '로그인',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: colorSuccess),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 35,
                                        width: 100,
                                        child: GestureDetector(
                                          child: Center(
                                            child: Text(
                                              "회원가입",
                                              style: TextStyle(fontSize: 15, color: colorGrey),
                                            ),
                                          ),
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            Navigator.of(context).push(MaterialPageRoute(builder: (cont) => const SignUpPage()));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          secondChild: SizedBox(width: double.infinity),
                          crossFadeState: !_splashScreenAnimated ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          duration: Duration(milliseconds: 800),
                          sizeCurve: Curves.easeOutCubic,
                        ),
                        curve: Curves.linear,
                      ),
                      // 관리자 로그인버튼
                      AnimatedCrossFade(
                        firstChild: SizedBox(
                          width: double.infinity,
                        ),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(left: 40, right: 40),
                          child: SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                                _login(manager: true);
                              },
                              child: const Text(
                                '관리자 로그인',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.deepPurpleAccent),
                            ),
                          ),
                        ),
                        crossFadeState: _isManager ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: Duration(milliseconds: 500),
                        sizeCurve: Curves.easeOutQuart,
                      )
                    ],
                  ),
                ),
                _isLoading ? buildContainerLoading(135) : SizedBox(),
              ],
            ),
          )),
    );
  }

  _auth() async {
    Future.delayed(const Duration(milliseconds: 100), () async {
      await versionCheck(context);
      if (FirebaseAuth.instance.currentUser != null) {
        // postManager 로딩
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          await getServerToken();
          postManager.loadPages("");
          await _initializeFCM();
        }
      }
    });
    Timer(const Duration(milliseconds: 2000), () {
      if (FirebaseAuth.instance.currentUser != null) {
        // 로고 페이드 아웃 및 메인으로 넘어가기
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          Timer.periodic(const Duration(milliseconds: 200), (timer) {
            if (!postManager.isLoading && myToken != null) {
              timer.cancel();
              setState(() {
                _fadeOutLogo = true;
              });
              Timer(Duration(milliseconds: 500), () {
                Get.off(() => BoardPageMainHub(), transition: Transition.fadeIn);
              });
            }
          });
        } else {
          setState(() {
            _fadeOutLogo = true;
          });
          Timer(Duration(milliseconds: 550), () {
            Get.off(() => PageEmailVerified());
          });
        }
      } else {
        // 로고 상단으로 올리고 가입화면 표시하기
        setState(() {
          _splashScreenAnimated = true;
          Timer(Duration(milliseconds: 800), () {
            setState(() {
              _splashScreenShow = true;
            });
          });
        });
      }
    });
  }

  _login({bool? manager}) async {
    manager = manager ?? false;
    if (!manager && (controllerId!.text.length != 9 || !controllerId!.text.isNumericOnly)) {
      showAlert("학번을 제대로 입력해주세요!", context, colorError);
      _loadingCompleted();
      return;
    }
    if (controllerId!.text.isEmpty) {
      showAlert("학번을 입력해주세요!", context, colorWarning);
    } else if (controllerPw!.text.isEmpty) {
      showAlert("비밀번호를 입력해주세요!", context, colorWarning);
    } else if (_formKey.currentState!.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());

      // Firebase 사용자 인증, 등록
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: manager ? controllerId!.text : "${controllerId!.text}@sangmyung.kr", password: controllerPw!.text);
        await _initializeFCM();
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          Get.off(() => const BoardPageMainHub());
          saveId(controllerId!.text);
        } else {
          Get.off(() => const PageEmailVerified());
          saveId(controllerId!.text);
          _loadingCompleted();
          return;
        }
      } on FirebaseAuthException catch (e) {
        String message = '';

        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          message = '학번 또는 비밀번호를 확인하세요';
        } else if (e.code == 'invalid-email') {
          message = '학번이 잘못되었습니다';
        } else {
          message = e.code;
        }
        showAlert(message, context, colorError);
      }
    }
    _loadingCompleted();
  }

  _loadingCompleted() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  dispose() async {
    super.dispose();
  }

  void saveOption(bool option) {
    _localdb!.setBool("login_option_save_enabled", option);
    if (option == false) {
      _localdb!.remove("login_option_saved_id");
    }
  }

  void saveId(String id) {
    _localdb!.setString("login_option_saved_id", id);
  }

  Future<void> _loadStorage() async {
    _localdb = await SharedPreferences.getInstance();
    return;
  }



  @override
  void initState() {
    super.initState();
    controllerId = TextEditingController();
    controllerPw = TextEditingController();

    MyIcon.loadUserIcon();
    _loadStorage().then((value) {
      _handleViewCountCoolDown();
      SharedPreferences.getInstance().then((value) => LocalStorage = value);
      setState(() {
        _saveIdEnabled = _localdb!.getBool("login_option_save_enabled");
        _savedId = _localdb!.getString("login_option_saved_id");
        if (_saveIdEnabled != null) {
          _isRememberId = _saveIdEnabled!;
          if (_saveIdEnabled == true && _savedId != null) {
            controllerId!.text = _savedId!;
          }
        }
      });
    });
    _auth();
  }

  // 조회수 쿨타임 지난 것들 로컬에서 제거
  _handleViewCountCoolDown() {
    for (String key in _localdb!.getKeys()) {
      if (key.contains(PREFIX_COOL)) {
        int now = DateTime.now().millisecondsSinceEpoch;
        int dbTime = _localdb!.getInt(key)!;
        if (now - dbTime > 1000 * 60 * 30) {
          // 1000 (1초) * 60 (1분) * 30 (30분)
          _localdb!.remove(key);
        }
      }
    }
  }

  _initializeFCM() async {
    // FCM 토큰 받아오기
    myUuid = FirebaseAuth.instance.currentUser!.uid;

    myToken = await FirebaseMessaging.instance.getToken();

    try {
      DocumentReference reference = FirebaseFirestore.instance.collection("UserProfile").doc(myUuid!);
      await reference.update({"fcmToken": myToken});
    } catch (e) {
      if (e.toString().contains("document was not found")) {
        FirebaseFirestore.instance.collection("UserProfile").doc(myUuid!).set({"fcmToken": myToken});
      }
    }

    // 토큰 만료 확인
    FCMController fcm = FCMController();
    await fcm.sendMessage(userToken: myToken!, title: "TestMessaging", body: "TestMessage", type: AlertType.FCM_TEST).then((value) {
      if (value == "전송 실패") {
        FirebaseMessaging.instance.deleteToken().then((value) async {
          myToken = await FirebaseMessaging.instance.getToken();
          try {
            DocumentReference reference = FirebaseFirestore.instance.collection("UserProfile").doc(myUuid!);
            await reference.update({"fcmToken": myToken});
          } catch (e) {
            if (e.toString().contains("document was not found")) {
              FirebaseFirestore.instance.collection("UserProfile").doc(myUuid!).set({"fcmToken": myToken});
            }
          }
        });
      }
    });

    // 토큰 리프레시
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      myToken = fcmToken;
      myProfileEntity!.fcmToken = fcmToken;
      DocumentReference reference = FirebaseFirestore.instance.collection("UserProfile").doc(myUuid!);
      await reference.update({"fcmToken": fcmToken});
      print("fcmToken 새로고침");
    }).onError((err) {
      // Error getting token
    });
    // 백그라운드 푸시알림
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 포어그라운드 푸시알림
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message != null) {
        if (message.notification != null) {
          if (message.data.containsKey("type")) {
            var fcm = FCMController();
            fcm.showNotificationSnackBar(title: message.notification!.title!, body: message.notification!.body!, clickActionValue: message.data);
            //_bottomAppbarRefresh(type);
            // else if ...
          }
        }
      }
    });
  }
}

// 바텀 앱바의 뱃지를 새로고침하기 위한 기능
_bottomAppbarRefresh(String type) {
  if (bAppbarStateSetter != null) {
    if (type == "chat") {
      newChat = true;
    } else if (type == "alert") {
      newAlert = true;
    }
    bAppbarStateSetter!(() {});
  }
}

Future<void> versionCheck(BuildContext context) async {
  try {
    var snapshot = await FirebaseFirestore.instance.collection("AppInfo").doc("version").get();
    if (snapshot.exists) {
      if (int.parse(snapshot.get("version").toString().replaceAll(".", "")) > int.parse(appInfo!.version.replaceAll(".", ""))) {
        await showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text("최신 버전이 있습니다"),
              content: Column(
                children: [
                  Text("\n현재 버전 : ${appInfo!.version}", style: TextStyle(fontSize: 14)),
                  Text("최신 버전 : ${snapshot.get("version")}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              actions: [CupertinoDialogAction(child: Text("확인"), onPressed: () => Navigator.pop(context))],
            ));
        exit(0);
      }
    } else {
      await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text("버전 확인 불가"),
            content: Column(
              children: [Text("네트워크 상태를 확인하세요.")],
            ),
            actions: [CupertinoDialogAction(child: Text("확인"), onPressed: () => Navigator.pop(context))],
          ));
      exit(0);
    }
  } catch (e) {
    await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("네트워크 연결이 끊겼습니다"),
          content: Column(
            children: [Text("네트워크 상태를 확인하세요.")],
          ),
          actions: [CupertinoDialogAction(child: Text("확인"), onPressed: () => Navigator.pop(context))],
        ));
    exit(0);
  }
}