

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';

import 'general.dart';

class Passes{
  late GeneralInfo general;
  late DateTime currentDay = DateTime.now();
  StatefulBuilder? mainView;
  List<String> weekDays = ['Понедельник', 'Вторник','Среда','Четверг','Пятница','Суббота','Воскресенье'];

  Passes(GeneralInfo obj){
    general = obj;
    updateWidget();
  }

  updateWidget(){
    mainView = StatefulBuilder(builder: (context, setStaten){
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: (){
                  setStaten((){
                    minusDay();
                  });
                  
                },
                icon: Icon(Icons.arrow_left),
                iconSize: 30,
              ),
              Column(
                children: [
                  TextButton(
                    onPressed: (){
                      
                    },
                    child: Text(
                      DateFormat("dd.MM.yyyy").format(currentDay),
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red
                      ),
                    )
                  ),
                  Text(
                    weekDays[currentDay.weekday-1]
                  )
                ],
              ),
              IconButton(
                onPressed: (){
                  setStaten((){
                    plusDay();
                  });
                  
                },
                icon: Icon(Icons.arrow_right),
                iconSize: 30,
              )
            ],
          )




        ],




      );
    });
  }

  updateDay(){
    if (currentDay.weekday == 7) currentDay = currentDay.add(Duration(days: -1));
  }

  plusDay(){
    currentDay = currentDay.add(Duration(days: 1));
    if (currentDay.weekday == 7) currentDay = currentDay.add(Duration(days: 1));
  }

  minusDay(){
    currentDay = currentDay.add(Duration(days: -1));
    if (currentDay.weekday == 7) currentDay = currentDay.add(Duration(days: -1));
  }

}