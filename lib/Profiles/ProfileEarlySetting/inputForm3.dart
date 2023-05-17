import 'package:flutter/material.dart';
import 'dart:convert';

class residenceScreen extends StatefulWidget {
  @override
  _ResidenceState createState() => _ResidenceState();
}

class _ResidenceState extends State<residenceScreen> {
  List<String> stateList = ["서울시", "천안시", "수원시"];

  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();

  Color ButtonColor1 = Colors.grey;
  Color ButtonColor2 = Colors.grey;
  Color ButtonColor3 = Colors.grey;

  Color _selectedColor = Color(0xFF6ACA9A);
  Color _unSelectedColor = Colors.grey;

  int _selectedIndex = -1;

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
                              ' 통학 여부',
                              style: TextStyle(
                                fontSize: 16,
                              )
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: ButtonColor1,
                                      padding: EdgeInsets.all(10),
                                      fixedSize: Size.fromWidth(80)
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      ButtonColor1 = _selectedColor;
                                      ButtonColor2 = _unSelectedColor;
                                      ButtonColor3 = _unSelectedColor;
                                      _selectedIndex = 1;
                                    });
                                  },
                                  child: Text(
                                      '통학',
                                      style: TextStyle(
                                        fontSize: 16,
                                      )
                                  ),
                                ),
                              ),
                              SizedBox(width: 5.0),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: ButtonColor2,
                                      padding: EdgeInsets.all(10),
                                      fixedSize: Size.fromWidth(80)
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      ButtonColor1 = _unSelectedColor;
                                      ButtonColor2 = _selectedColor;
                                      ButtonColor3 = _unSelectedColor;
                                      _selectedIndex = 2;
                                    });
                                  },
                                  child: Text(
                                      '자취',
                                      style: TextStyle(
                                        fontSize: 16,
                                      )
                                  ),
                                ),
                              ),
                              SizedBox(width: 5.0),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: ButtonColor3,
                                      padding: EdgeInsets.all(10),
                                      fixedSize: Size.fromWidth(80)
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      ButtonColor1 = _unSelectedColor;
                                      ButtonColor2 = _unSelectedColor;
                                      ButtonColor3 = _selectedColor;
                                      _selectedIndex = 3;
                                    });
                                  },
                                  child: Text(
                                      '기숙사',
                                      style: TextStyle(
                                        fontSize: 16,
                                      )
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          Text(
                              ' 거주지',
                              style: TextStyle(
                                fontSize: 16,
                              )
                          ),
                          SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                  )
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  child: Text('회원 정보 저장'),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF6ACA9A),
                  ),
                  onPressed: () {},
                ),
              )
            ],
          )
      ),
    );
  }
}

class City {
  String name;
  String state;

  City({required this.name, required this.state});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(name: json['name'], state: json['state']);
  }
}

class CityDropdownButton extends StatefulWidget {
  @override
  _CityDropdownButtonState createState() => _CityDropdownButtonState();
}

class _CityDropdownButtonState extends State<CityDropdownButton> {
  List<City>? _cities;
  String _selectedCity = '';

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    final jsonFile =
    await DefaultAssetBundle.of(context).loadString('assets/cities.json');
    final cityList = json.decode(jsonFile) as List;
    _cities = cityList.map((json) => City.fromJson(json)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_cities == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    final countryCode = Localizations.localeOf(context).countryCode;
    final stateList = _cities!
        .where((city) => city.state == countryCode)
        .map((city) => city.name)
        .toList();

    return DropdownButton<String>(
      hint: Text('Select a city'),
      value: _selectedCity,
      onChanged: (value) {
        setState(() {
          _selectedCity = value!;
        });
      },
      items: stateList.map((value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
