import 'package:design_project/Boards/List/BoardLocationPage.dart';
import 'package:design_project/Boards/List/BoardMain.dart';
import 'package:design_project/Boards/Writing/BoardWritingPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Auth/SignUpPage.dart';
import 'resources.dart';
import 'package:get/get.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          '로그인',
          style: TextStyle(
              fontSize: 16,
              color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        bottom: true,
          child: Form(
        key: _formKey,
        child: Column(
          children: [
            Center(
              child: ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Hero(tag: 'detail', child: Icon(Icons.arrow_right_alt)),
                    Text('- 페이지 강제이동 - 커밋 풀')
                  ],
                ),
                onPressed: () {
                  Get.off(() => BoardPageMainHub());
                },
              ),
            ),
            SizedBox(
              height: 100,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: controllerId,
                          decoration: const InputDecoration(
                          hintText: "글 제목 (최대 20자)",
                          border: OutlineInputBorder(),
                          counterText: "",
                          )
                        ),
                        TextField(
                          controller: controllerPw,
                          obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "글 제목 (최대 20자)",
                              border: OutlineInputBorder(),
                              counterText: "",
                            )
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: ElevatedButton(
                      onPressed: () => _login(),
                      child: const Text('로그인'),
                    ),
                  )
                ],
              ),
            ),
            ElevatedButton(
                child: Text('회원가입'),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (cont) => const SignUpPage()));
                }),
          ],
        ),
      )),
    );
  }

  _auth() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (FirebaseAuth.instance.currentUser != null) {
        Get.off(() => const BoardPageMainHub());
      }
    });
  }

  _login() async {
    if (controllerId!.text.isEmpty) {
      showAlert("이메일을 입력해주세요!", context, colorWarning);
      return;
    }
    if (controllerPw!.text.isEmpty) {
      showAlert("비밀번호를 입력해주세요!", context, colorWarning);
      return;
    }
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());

      // Firebase 사용자 인증, 등록
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: controllerId!.text, password: controllerPw!.text);
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          Get.off(() => const BoardPageMainHub());
        } else {
          showAlert("이메일로 인증 주소를 보냈습니다!\n인증 주소를 클릭해주세요.", context, colorSuccess);
          return;
        }
      } on FirebaseAuthException catch (e) {
        String message = '';

        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          message = '사용자 이름 및 암호를 확인하세요';
        } else if (e.code == 'invalid-email') {
          message = '이메일을 확인하세요';
        } else {
          message = e.code;
        }
        showAlert(message, context, colorError);
      }
    }
  }

  _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  dispose() async {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controllerId = TextEditingController();
    controllerPw = TextEditingController();

    _auth();
  }
}
