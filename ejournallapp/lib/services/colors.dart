
import 'package:flutter/material.dart';

class MyColors{
  static bool darkTheme = true;
  static Color headerColor = const Color.fromARGB(255, 128, 192, 64);
  static Color backgroundColor = const Color.fromARGB(255, 40, 40, 40);
  static Color cardBackgroundColor = const Color.fromARGB(255, 60, 60, 60);
  static Color buttonColor = const Color.fromARGB(255, 4, 88, 205);
  static Color fontColor = const Color.fromARGB(255, 255, 255, 255);
  static Color progressBarColor = const Color.fromARGB(255, 255, 255, 255);
  static Color errorMessageColor = const Color.fromARGB(255, 255, 0, 0);


  static changeTheme(bool dark){
    if (dark != darkTheme){
      darkTheme = dark;
      if (darkTheme){
        headerColor = const Color.fromARGB(255, 128, 192, 64);
        backgroundColor = const Color.fromARGB(255, 40, 40, 40);
        cardBackgroundColor = const Color.fromARGB(255, 60, 60, 60);
        fontColor = const Color.fromARGB(255, 255, 255, 255);
        progressBarColor = const Color.fromARGB(255, 255, 255, 255);
        errorMessageColor = const Color.fromARGB(255, 255, 0, 0);

      }
      else{
        headerColor = const Color.fromARGB(255, 128, 192, 64);
        backgroundColor = const Color.fromARGB(255, 240, 240, 240);
        cardBackgroundColor = const Color.fromARGB(255, 180, 180, 180);
        fontColor = const Color.fromARGB(255, 0, 0, 0);
        progressBarColor = const Color.fromARGB(255, 0, 0, 0);
        errorMessageColor = const Color.fromARGB(255, 255, 0, 0);


      }
    }
  }
}