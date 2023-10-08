import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'general.dart';
import 'notePasses.dart';

class newHomePage extends StatefulWidget {

  Passes? passes = null;
  Widget Empty = Center(
    child: CircularProgressIndicator(
      color: Colors.white
    ),
  );

  GeneralInfo general = GeneralInfo();


  
  newHomePage(){
    general.setCallback((){
      passes = Passes(general);


      wgtm?.setState(() {
        changeView(0);
      });
    });
    
  }

  Color headColor = Color.fromARGB(255, 10, 180, 55);
  Color backgroundColor = Colors.white;//Color.fromARGB(255, 19, 19, 19);
  Widget currentView = Center();
  int currIndex = 0;
  void changeView(int index){
    currIndex = index;
    switch (currIndex){
      case 0:{
        currentView = passes?.mainView ?? Empty;
        passes?.updateWidget();
        break;
      }
      case 1:{
        currentView = Text("23456789234567890-098765445");
        break;
      }

    }
  }


  _HomePageState? wgtm;
  @override
  _HomePageState createState(){
    var wgt = _HomePageState(); 
    wgtm = wgt;
    return wgt;
  }
}

class _HomePageState extends State<newHomePage> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Приложение"),
        backgroundColor: widget.headColor,
      ),
      backgroundColor: widget.backgroundColor,
      
      body: widget.currentView,

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: " "
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: " "
          )
        ],
        currentIndex: widget.currIndex,
        backgroundColor: const Color.fromARGB(255, 40, 40, 40),
        onTap: (int index){
          setState(() {
            widget.changeView(index);
          });
        },
      ),
      
    );
  }  

}