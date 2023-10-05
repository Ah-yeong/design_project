import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'input_form.dart';

class ImageSignUpScreen extends StatefulWidget {
  @override
  _ImageSignUpScreenState createState() => _ImageSignUpScreenState();
}

class _ImageSignUpScreenState extends State<ImageSignUpScreen> {
  final _picker = ImagePicker();
  File? _image;

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            '가입',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(height: 6),
                      Text('나만의 프로필을 작성해주세요 !',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                      SizedBox(height: 6),
                      Text('프로필 사진은 꼭 본인의 모습을 나타낼 필요는 없습니다.     ',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                      SizedBox(height: 30),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            InkWell(
                              onTap: () async {
                                final source = await showDialog<ImageSource>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('사진 업로드'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, ImageSource.camera);
                                          },
                                          child: Text('카메라로 직접 촬영'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, ImageSource.gallery);
                                          },
                                          child: Text('앨범에서 가져오기'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (source != null) {
                                  await _getImage(source);
                                }
                              },
                              child: CircleAvatar(
                                radius: 100,
                                backgroundImage: _image != null ? FileImage(_image!) : null,
                                child: _image == null
                                    ? Icon(
                                        Icons.person,
                                        size: 80,
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(
                              height: 26,
                            ),
                            Text('[위의 아이콘을 클릭]',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            Text('사진은 필수가 아닌 선택사항입니다.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                )),
                          ],
                        ),
                      )
                    ]),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    child: Text('다음'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF6ACA9A),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NameSignUpScreen()),
                      );
                    },
                  ),
                ))
          ],
        ));
  }
}
