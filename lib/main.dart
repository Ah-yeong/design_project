import 'dart:async';

import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:design_project/Resources/LoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Auth/SignUpPage.dart';
import 'Resources/resources.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // iOS가 다크모드일 때도 상단 글자 검은색으로 고정
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return GetMaterialApp(
      title: 'Capstone design',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          bottom: false,
          top: false,
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedOpacity(opacity: _fadeOutLogo ? 0 : 1, duration: Duration(milliseconds: 500), child:
                    Center(
                      child: Text(
                        "마음 맞는, 사람끼리",
                        style: TextStyle(
                          fontSize: 35,
                          color: Colors.black87,
                          fontFamily: "logo",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),),
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
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: TextFormField(
                                            controller: controllerId,
                                            style: TextStyle(fontSize: 15),
                                            decoration: InputDecoration(
                                                hintText: "사용자 아이디",
                                                hintStyle:
                                                    TextStyle(fontSize: 15),
                                                border: InputBorder.none)),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                        height: 50,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE8E8E8),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20),
                                          child: TextFormField(
                                              controller: controllerPw,
                                              obscureText: true,
                                              style: TextStyle(fontSize: 15),
                                              decoration: InputDecoration(
                                                hintText: "사용자 비밀번호",
                                                hintStyle:
                                                    TextStyle(fontSize: 15),
                                                border: InputBorder.none,
                                                counterText: "",
                                              )),
                                        )),
                                    SizedBox(height: 8),
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
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: colorSuccess),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 35,
                                      width: 100,
                                      child: GestureDetector(
                                        child: Center(
                                          child: Text(
                                            "회원가입",
                                            style: TextStyle(
                                                fontSize: 15, color: colorGrey),
                                          ),
                                        ),
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (cont) =>
                                                      const SignUpPage()));
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
                        crossFadeState: !_splashScreenAnimated
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: Duration(milliseconds: 800),
                        sizeCurve: Curves.easeOutCubic,
                      ),
                      curve: Curves.linear,
                    )
                  ],
                ),
              ),
              _isLoading ? buildContainerLoading() : SizedBox(),
            ],
          )),
    );
  }
  //test

  _auth() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (FirebaseAuth.instance.currentUser != null) {
        setState(() {
          _fadeOutLogo = true;
        });
        Timer(Duration(milliseconds: 550), () {
          Get.off(() => BoardPageMainHub());
        });
      } else {
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

  _login() async {
    if (controllerId!.text.isEmpty) {
      showAlert("이메일을 입력해주세요!", context, colorWarning);
    } else if (controllerPw!.text.isEmpty) {
      showAlert("비밀번호를 입력해주세요!", context, colorWarning);
    } else if (_formKey.currentState!.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());

      // Firebase 사용자 인증, 등록
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: controllerId!.text, password: controllerPw!.text);
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          Get.off(() => const BoardPageMainHub());
          saveId(controllerId!.text);
        } else {
          showAlert(
              "이메일로 인증 주소를 보냈습니다!\n인증 주소를 클릭해주세요.", context, colorSuccess);
          _loadingCompleted();
          return;
        }
      } on FirebaseAuthException catch (e) {
        String message = '';

        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          message = '사용자 이름 및 암호를 확인하세요';
        } else if (e.code == 'invalid-email') {
          message = '이메일 형식이 잘못되었습니다';
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

  _logout() async {
    await FirebaseAuth.instance.signOut();
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
    _loadStorage().then((value) => {
      setState(() {
        _saveIdEnabled = _localdb!.getBool("login_option_save_enabled");
        _savedId = _localdb!.getString("login_option_saved_id");
        if (_saveIdEnabled != null) {
          _isRememberId = _saveIdEnabled!;
          if (_saveIdEnabled == true && _savedId != null) {
            controllerId!.text = _savedId!;
          }
        }
      })
    });

    Timer(Duration(milliseconds: 2500), () {
      _auth();
    });

  }
}
