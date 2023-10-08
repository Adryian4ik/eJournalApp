import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {  
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 100), () { 
      checkIfRecordExists();
    });
     // Проверяем, сохранена ли запись
  }
  
  Future<void> checkIfRecordExists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool recordExists = prefs.containsKey('Group'); // Проверяем наличие записи
    if (recordExists) {
      Navigator.pushReplacementNamed(context, '/newHomeScreen'); // Переход на экран 2
    }
    else{
      Navigator.pushReplacementNamed(context, '/regScreen');
    }
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 19, 19, 19), // Устанавливаем цвет фона для тела
        child: const Center(
          child: Text(
            'eJournal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 50.0
            ),
          ),
        ),
      ),
      
    );
  }
}