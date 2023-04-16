import 'package:design_project/Board/BoardLocationPage.dart';
import 'package:design_project/Board/BoardPageDesign.dart';
import 'package:design_project/WritingPageDesign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'resources.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Design Demo',
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: CupertinoPageScaffold(
            backgroundColor: Colors.white,
            navigationBar: CupertinoNavigationBar(
                middle: const Text(
                  'APP NAME',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: SizedBox(
                  height: 45,
                  width: 45,
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {},
                    minSize: 0,
                    color: Strings.styleColor,
                    child: const Icon(Icons.settings),
                  ),
                ),
                backgroundColor: Strings.styleColor),
            child: Scaffold(
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endDocked,
              floatingActionButton: SizedBox(
                height: 34,
                width: 85,
                child: FittedBox(
                  child: FloatingActionButton.extended(
                    backgroundColor: Strings.styleColor,
                    icon: const Icon(CupertinoIcons.list_bullet),
                    onPressed: () {},
                    label: const Text(
                      "INFO",
                      style: TextStyle(fontSize: 20),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        height: 200,
                        child: Card(
                            child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              const Padding(padding: EdgeInsets.only(top: 20)),
                              Row(
                                children: [
                                  Expanded(
                                      child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: CupertinoButton(
                                      child: Text('게시판 디자인'),
                                      color: Strings.styleColor,
                                      padding: EdgeInsets.all(10),
                                      minSize: 0,
                                      onPressed: () {Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => const BoardPageDesign()));
                                      },
                                    ),
                                  )),
                                  Expanded(
                                      child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: CupertinoButton(
                                      child: Text('글쓰기 디자인'),
                                      color: Strings.styleColor,
                                      minSize: 0,
                                      padding: EdgeInsets.all(10),
                                      onPressed: () {Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => const WritingPageDesign()));
                                      },
                                    ),
                                  )),
                                  Expanded(
                                      child: Padding(
                                        padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                        child: CupertinoButton(
                                          child: Text('예시'),
                                          color: Strings.styleColor,
                                          minSize: 0,
                                          padding: EdgeInsets.all(10),
                                          onPressed: () {Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => const BoardLocationPage()));
                                          },
                                        ),
                                      )),
                                ],
                              ),
                              const Padding(padding: EdgeInsets.only(top: 20)),
                              Row(
                                children: [
                                ],
                              )
                            ],
                          ),
                        )),
                      ),
                    )
                  ],
                ),
              ),
            )),
      );
  }
}
