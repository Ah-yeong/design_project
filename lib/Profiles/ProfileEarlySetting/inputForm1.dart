import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'inputForm2.dart';

class NameSignUpScreen extends StatefulWidget {
  @override
  _NicknameFormState createState() => _NicknameFormState();
}

class _NicknameFormState extends State<NameSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();

  Color maleButtonColor = Colors.grey;
  Color femaleButtonColor = Colors.grey;

  int _selectedGenderIndex = 0;

  int year = 2000;
  int month = 1;
  int day = 1;

  void _showYearPicker() {
    int selectedYear = year;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          child: Column(
            children: <Widget>[
              Expanded(
                child: CupertinoPicker(
                  backgroundColor: Colors.white,
                  itemExtent: 32,
                  onSelectedItemChanged: (int index) {
                    selectedYear = DateTime.now().year - 30 + index;
                  },
                  children: List<Widget>.generate(21, (int index) {
                    final year = DateTime.now().year - 30 + index;
                    return Center(
                      child: Text(
                        '$year년',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }),
                ),
              ),
              CupertinoButton(
                child: Text('저장'),
                onPressed: () {
                  setState(() {
                    year = selectedYear;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMonthPicker() async {
    int selectedMonth = month;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          child: Column(
            children: <Widget>[
              Expanded(
                child: CupertinoPicker(
                  backgroundColor: Colors.white,
                  itemExtent: 32,
                  onSelectedItemChanged: (int index) {
                    selectedMonth = index + 1;
                  },
                  children: List<Widget>.generate(12, (int index) {
                    return Center(
                      child: Text(
                        '${index + 1}월',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }),
                ),
              ),
              CupertinoButton(
                child: Text('저장'),
                onPressed: () {
                  setState(() {
                    month = selectedMonth;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDayPicker() async {
    int selectedDay = day;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          child: Column(
            children: <Widget>[
              Expanded(
                child: CupertinoPicker(
                  backgroundColor: Colors.white,
                  itemExtent: 32,
                  onSelectedItemChanged: (int index) {
                    selectedDay = index + 1;
                  },
                  children: List<Widget>.generate(daysInMonth, (int index) {
                    return Center(
                      child: Text(
                        '${index + 1}일',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }),
                ),
              ),
              CupertinoButton(
                child: Text('저장'),
                onPressed: () {
                  setState(() {
                    day = selectedDay;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          '가입',
          style: TextStyle(
              fontSize: 18,
              color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
          padding: EdgeInsets.all(20.0),
          height: double.maxFinite,
          child: Column(
            children: [
              Form(
                  key: _formKey,
                  child: Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 6),
                          Text(
                              '나만의 프로필을 작성해주세요 !',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )
                          ),
                          SizedBox(height: 6),
                          Text(
                              '자세하게 입력할수록 본인의 개성을 드러내는 프로필 생성이 가능합니다.',
                              style: TextStyle(
                                fontSize: 14,
                              )
                          ),
                          SizedBox(height: 20),
                          Text(
                              ' 닉네임',
                              style: TextStyle(
                                fontSize: 16,
                              )
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _nicknameController,
                            decoration: InputDecoration(
                              labelText: '닉네임',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                              ' 한줄소개',
                              style: TextStyle(
                                fontSize: 16,
                              )
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _nicknameController,
                            decoration: InputDecoration(
                              labelText: '한줄소개',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                              ' 성별',
                              style: TextStyle(
                                fontSize: 16,
                              )
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: femaleButtonColor,
                                    padding: EdgeInsets.all(10),
                                    fixedSize: Size.fromWidth(80)
                                ),
                                onPressed: () {
                                  setState(() {
                                    femaleButtonColor = Color(0xFF6ACA9A); // 클릭 시 버튼 색 변경
                                    maleButtonColor = Colors.grey;
                                  });
                                },
                                child: Text(
                                    '여자',
                                    style: TextStyle(
                                      fontSize: 16,
                                    )
                                ),
                              ),
                              SizedBox(width: 5.0),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: maleButtonColor,
                                    padding: EdgeInsets.all(10),
                                    fixedSize: Size.fromWidth(80)
                                ),
                                onPressed: () {
                                  setState(() {
                                    femaleButtonColor = Colors.grey;
                                    maleButtonColor = Color(0xFF6ACA9A);
                                  });
                                },
                                child: Text(
                                    '남자',
                                    style: TextStyle(
                                      fontSize: 16,
                                    )
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          Text(
                              ' 생년월일',
                              style: TextStyle(
                                fontSize: 16,
                              )
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: _showYearPicker,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  padding: EdgeInsets.only(left: 6.0),
                                  fixedSize: Size.fromWidth(110),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('$year년'),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Icon(Icons.arrow_drop_down),
                                    ),
                                  ],
                                ),
                              )
                              ,
                              SizedBox(width: 5),
                              ElevatedButton(
                                onPressed: _showMonthPicker,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  fixedSize: Size.fromWidth(80),
                                  padding: EdgeInsets.only(left: 6.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('$month월'),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Icon(Icons.arrow_drop_down),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              ElevatedButton(
                                onPressed: _showDayPicker,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  fixedSize: Size.fromWidth(80),
                                  padding: EdgeInsets.only(left: 6.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('$day일'),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Icon(Icons.arrow_drop_down),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
              ),
              SizedBox(
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
                      MaterialPageRoute(builder: (context) => preferenceScreen()),
                    );
                  },
                ),
              )
            ],
          )
      ),
    );
  }
}
