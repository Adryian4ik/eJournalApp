import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {  
  Notice? noticer;
  Settings? settindsObject;
  Schedule? schedule;
  SharedPreferences? prefs; 
  int _currentIndex = 0;
  PageController control = PageController();
  ScrollController menuControl = ScrollController();
  int menuPage = 0; // 0 - меню, остальное вкладки


  generalInfo general = generalInfo();





  @override
  void initState()  {

    super.initState();
    general.setCallback((){initOthers();});
    
  }
  
  initOthers(){
    noticer = Notice(general, this);
    settindsObject = Settings(general, this);
    schedule = Schedule(general);
  }


  _update({Function? fn = null}){
    setState(() {
      if (fn != null){
        fn();
      }
    });
  }

  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        appBar: AppBar(
          title: Text(general._group),
          backgroundColor: const Color.fromARGB(255, 10, 180, 55),
          centerTitle: true,
        ),
        body:  Center(
            child:PageView(
              controller: control,
              children: [
                Container(           //отметить
                    child:Column(
                      children:[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:[
                            IconButton(
                              onPressed: (){
                                setState((){
                                  noticer!.date = noticer!.date.add(const Duration(days:-1));
                                  if (noticer!.date.weekday == 7)noticer!.date = noticer!.date.add(const Duration(days:-1));
                                  noticer!.updateDate();

                                  /*http.get(
                                    Uri.parse('${general._host}pass?start=${DateFormat("yyyy-MM-dd").format(noticer!.date)}&end=${DateFormat("yyyy-MM-dd").format(noticer!.date)}&groupId=${general._groupId}'),
                                    headers: {"Authorization":"Bearer ${general._token}"}
                                  
                                  ).then((response){

                                    var answer = jsonDecode(utf8.decode(response.body.codeUnits));
                                    noticer!.Passes = answer["detail"];
                                    print(noticer!.Passes);
                                    noticer!.viewDay();
                                  });*/
                                });
                              },
                              icon: const Icon(Icons.chevron_left),
                              color: Colors.white,
                              iconSize: 30,
                            ),
                            Column(
                              children: [
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 169, 10, 222)),
                                    foregroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> state){return Colors.white;})
                                  ),
                                  onPressed: () async{
                                    DateTime? newDate = await showDatePicker(context: context, initialDate: noticer!.date, firstDate: DateTime(2023), lastDate: DateTime(noticer!.date.year.toInt()+1), locale: const Locale('ru', 'BY'));
                                    
                                    if (newDate != null){
                                      setState(() {
                                        if (newDate.weekday == 7){noticer!.date = newDate.add(const Duration(days:-1));}//понедельник - 7, вторник - 1
                                        else {noticer!.date = newDate;}
                                        noticer!.updateDate();
                                        /*http.get(
                                          Uri.parse('${general._host}pass?start=${DateFormat("yyyy-MM-dd").format(noticer!.date)}&end=${DateFormat("yyyy-MM-dd").format(noticer!.date)}&groupId=${general._groupId}'),
                                          headers: {"Authorization":"Bearer ${general._token}"}
                                        
                                        ).then((response){

                                          var answer = jsonDecode(utf8.decode(response.body.codeUnits));
                                          noticer!.Passes = answer["detail"];

                                          noticer!.viewDay();
                                        });*/
                                      });
                                      setState(() {});
                                      
                                    }
                                  },
                                  child: Text(
                                    DateFormat("dd.MM.yy").format(noticer!.date),
                                    style: const TextStyle(fontSize: 18),
                                    ),
                                ),
                                Text(
                                  noticer!.WeekDays[noticer!.date.weekday.toInt()-1],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15
                                  ),
                                )
                              ],
                            ),          
                            IconButton(
                              onPressed: (){
                                setState((){
                                  
                                  noticer!.date = noticer!.date.add(const Duration(days:1));
                                  if (noticer!.date.weekday == 7)noticer!.date = noticer!.date.add(const Duration(days:1));
                                  noticer!.updateDate();
                                  /*http.get(
                                    Uri.parse('${general._host}pass?start=${DateFormat("yyyy-MM-dd").format(noticer!.date)}&end=${DateFormat("yyyy-MM-dd").format(noticer!.date)}&groupId=${general._groupId}'),
                                    headers: {"Authorization":"Bearer ${general._token}"}
                                  
                                  ).then((response){

                                    var answer = jsonDecode(utf8.decode(response.body.codeUnits));
                                    noticer!.Passes = answer["detail"];

                                    noticer!.viewDay();
                                  });*/
                                });
                                
                              },
                              icon: const Icon(Icons.navigate_next),
                              color: Colors.white,
                              iconSize: 30,
                            )
                          ]
                        ),
                        if (noticer != null && noticer!.mainActiv  != null)noticer!.mainActiv!
                        
                      ]
                    ),
                  ),
                Container(           // отметить период
                  


                ),
                
                Container(           // Пропуски за месяц
                  //child: table,


                ),

                Container(           // расписание
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:[
                            IconButton(
                              onPressed: (){
                                setState(() {
                                  schedule?.dayMinus(); 
                                });
                                
                                
                              },
                              icon: const Icon(Icons.chevron_left),
                              color: Colors.white,
                              iconSize: 30,
                            ),
                            Column(
                              children: [
                                Text(
                                  schedule?.currentDay ?? "",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20
                                  ),
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 169, 10, 222)),
                                    foregroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> state){return Colors.white;})
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      schedule?.weekChange();
                                    });
                                  },
                                  child: Text(
                                    schedule?.currentWeek ?? "",
                                    style: TextStyle(

                                      fontSize: 20
                                    )
                                  )
                                )
                              ],
                            ),          
                            IconButton(
                              onPressed: (){
                                setState(() {
                                  schedule?.dayPlus(); 
                                });
                                       
                              },
                              icon: const Icon(Icons.navigate_next),
                              color: Colors.white,
                              iconSize: 30,
                            )
                          ]
                        ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: schedule?.scheduleForDay ?? Column(),
                      )
                      










                    ],
                  ),
                  

                ),
                Container(           //карточки студентов
                  child: Column(
                    children:[
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 500,
                            mainAxisExtent: 300,
                            mainAxisSpacing: 0
                          ),
                          itemCount: settindsObject!.Cards.length,
                          itemBuilder: (context, index){
                            return settindsObject!.Cards[index];
                          },
                        )
                      ), 
                      Row(
                        children:[
                          Expanded(
                            child:ElevatedButton.icon(
                              onPressed: (){
                                
                                setState((){
                                  settindsObject!.addStudent();
                                });
                              },
                              label: const Text("Добавить"),
                              icon: const Icon(Icons.add)
                            )
                          ),
                          const SizedBox(
                            width: 10
                          ),
                          Expanded(
                            child:ElevatedButton.icon(
                              onPressed: (){
                                settindsObject!.checkAll();
                                if (settindsObject!.hasErrors){
                                  showDialog(
                                  context: context,
                                  builder: (context) {
                                    Future.delayed(const Duration(seconds: 1), () {
                                      Navigator.of(context).pop(true);
                                    });
                                    return const AlertDialog(
                                      title: Text('Проверьте введенные данные', textAlign: TextAlign.center,),
                                    );
                                  });
                                }
                                else{
                                  settindsObject!.SaveInfo();
                                }

                              },
                              label: const Text("Сохранить"),
                              icon: const Icon(Icons.save)
                            )
                          )
                        ]
                      )
                    ]
                  )
                )

              ],
              onPageChanged: (int index){
                setState(() {
                  _currentIndex = index;
                });
              },
            )
          )
        ,
        backgroundColor: const Color.fromARGB(255, 19, 19, 19),   
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Отметить"),
            BottomNavigationBarItem(icon: Icon(Icons.edit_calendar), label: "Множественная выборка"),
            BottomNavigationBarItem(icon: Icon(Icons.table_view), label: "Пропуски за месяц"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Расписание"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Настройки"),
            
          ],
          backgroundColor: const Color.fromARGB(255, 41, 41, 41),
          currentIndex: _currentIndex,
          onTap: (int index){
            setState(() {
              _currentIndex = index;
            });
            control.animateToPage(index, duration: const Duration(milliseconds: 1), curve: Curves.linear);
          },
          selectedItemColor:const Color.fromARGB(255, 6, 240, 217),
          unselectedItemColor: Colors.white,
          selectedIconTheme: const IconThemeData(
            color: Color.fromARGB(255, 6, 240, 217)
          ),
          showUnselectedLabels: false,
          selectedFontSize: 16,
        ), 
    );
  }
}




class Schedule{
  int gDay = 0;
  int week = 0;
  int day = 0;
  late generalInfo general;
  StatefulBuilder scheduleForDay=StatefulBuilder(builder: (context, setstate){
    return Column();
  });
  
  List<String> WeekDays = ['Понедельник', 'Вторник','Среда','Четверг','Пятница','Суббота','Воскресенье'];
  List<String> WeekTypes= ['Верхняя', 'Нижняя'];

  List<List<List<Map>>> Days = [[
    [{
    "numberOfLesson": 1,
    "Lesson": "Криптография"

    },
    {
      "numberOfLesson": 1,
      "Lesson": "Аппаратка"

    }],
    [{
      "numberOfLesson": 2,
      "Lesson": "Вышмат"

    }]
  ]];
  String currentDay = "";
  String currentWeek = "";
  Schedule(generalInfo obj){
    general = generalInfo.from(obj);
    updateDayFields();


  }

  updateDayFields(){
    week = (gDay / 7).truncate();
    day = (gDay % 7);
    print('$gDay $week $day');
    currentDay = WeekDays[day];
    currentWeek = WeekTypes[week];

    scheduleForDay=StatefulBuilder(builder: (context, setstate){
      return Column(
        children: List.generate(Days[gDay].length, (index){
          
          List<Widget> tempChildren = [];
          for(var i=0; i<Days[gDay][index].length;i++){
            var item = Days[gDay][index][i];
            tempChildren.add(
              TextButton(
                onPressed: (){

                },
                child: Text(
                  item["Lesson"],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18
                  ),
                )
              )
            );

            if (i != Days[gDay][index].length-1){
              tempChildren.add(
                Divider(
                  color: Colors.white,
                  thickness: 2,
                )
              );
            }
          }

          return Card(
            color: const Color.fromARGB(255, 50, 50, 50),
            child: Row(
              
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 15, 10),
                  child: Text(
                    '${Days[gDay][index][0]["numberOfLesson"]}.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18
                    ),
                  )
                ),
                SizedBox(
                  width: 2,
                  
                  child: Expanded(
                    child: VerticalDivider(
                    color: Colors.white,
                    thickness: 2,
                  ),
                  ),
                ),

                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: tempChildren
                  )
                )
              ],
            ),
          );
        }),
      );
    });

  }

  dayPlus(){
    if (gDay < 12) gDay++;
    if (gDay % 7 == 6) gDay++;
    updateDayFields();
  }

  dayMinus(){
    if (gDay > 0 ) gDay--;
    if (gDay % 7 == 1 && (gDay / 7).truncate() == 1) gDay--;
    updateDayFields();
  }

  weekChange(){
    gDay =(gDay + 7) % 14;
    updateDayFields();
  }

  
}
























class generalInfo{
  String _host = "http://45.8.230.244/";
  String _group = "";
  int _groupId = 0;
  String _token = "";
  int _bossId = 0;
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  SharedPreferences? valueSource;
  Function()? fn;

  generalInfo(){
    prefs.then((value){
      _group = value.getString("Group") ?? "";
      _groupId = value.getInt("GroupId") ?? 0;
      _token = value.getString("Token") ?? "";
      _bossId = value.getInt("BossId") ?? 0;
      fn!();
    });
  }

  

  setCallback(Function() fn){
    this.fn = fn;
  }

  generalInfo.from(generalInfo obj){
    _host = obj._host;
    _group = obj._group;
    _groupId = obj._groupId;
    _token = obj._token;
    _bossId = obj._bossId;
  }

  


}



















class Notice{
  List<String> WeekDays = ['Понедельник', 'Вторник','Среда','Четверг','Пятница','Суббота','Воскресенье'];
  late DateTime date;
  StatefulBuilder? mainActiv;
  late generalInfo general;
  List Students = [];
  Map Schedule = {};
  dynamic Passes = [];
  late _HomePageState hmPgstrt;

  Notice(generalInfo obj, _HomePageState main){
    hmPgstrt = main;
    general = generalInfo.from(obj);
    date = DateTime.now();
    if (date.weekday == 7)date = date.add(const Duration(days:-1));

    http.get(
      Uri.parse('${general._host}schedule/${general._groupId}')
    ).then((response){
      var answer = jsonDecode(utf8.decode(response.body.codeUnits));
      //print(answer);
      Schedule = answer["detail"];
      updateDate();

    });

    http.get(
      Uri.parse('${general._host}groupinfo'),
      headers: {"Authorization":"Bearer ${general._token}"}
    )
    .then((response){
      var answer = jsonDecode(utf8.decode(response.body.codeUnits));
      //print(answer);
      Students = answer["detail"];
      updateDate();
    });

    

    /*http.get(Uri.parse('${general._host}groupinfo'),headers: {"Authorization":"Bearer ${general._token}"}).then((response){
      var answer = jsonDecode(utf8.decode(response.body.codeUnits));      
      Students = answer["detail"];
      http.get(Uri.parse('${general._host}schedule/${general._groupId}')).then((response){
        if (response.statusCode == 200){
          Shedule = jsonDecode(utf8.decode(response.body.codeUnits))["detail"];
          print(Shedule["Верхняя"]["Среда"]);
          http.get(
            Uri.parse('${general._host}pass?start=${DateFormat("yyyy-MM-dd").format(date)}&end=${DateFormat("yyyy-MM-dd").format(date)}&groupId=${general._groupId}'),
            headers: {"Authorization":"Bearer ${general._token}"}
          
          ).then((response){

            var answer = jsonDecode(utf8.decode(response.body.codeUnits));
            Passes = answer["detail"];
            
            viewDay();
          });
          
        }
      });
    });*/
  }

  updateDate(){
    http.get(
      Uri.parse('${general._host}pass?start=${DateFormat("yyyy-MM-dd").format(date)}&end=${DateFormat("yyyy-MM-dd").format(date)}&groupId=${general._groupId}'),
      headers: {"Authorization":"Bearer ${general._token}"}
    )
    .then((response){
      var answer = jsonDecode(utf8.decode(response.body.codeUnits));
      print(answer);
      Passes = answer["detail"];
      updateMainActiv();
    });
  }

  updateMainActiv(){
    print(Students);
    print(Schedule);
    if(!(Students == []) && mapEquals({}, Schedule)){
      mainActiv = StatefulBuilder(
        builder: (context, setState){
        return const Expanded(
          child: Center(
            child: Text(
              "Данные загружаются",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18
              )
              ),
          )
        );
      });
    }
    else if(Students == [] && !mapEquals({}, Schedule)){
      mainActiv = StatefulBuilder(
        builder: (context, setState){
        return const Expanded(
          child: Center(
            child: Text(
              "Похоже расписания на этот день нет",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18
              )
              ),
          )
        );
      });
    }
    else if (Students == [] && mapEquals({}, Schedule)){
      mainActiv = StatefulBuilder(
        builder: (context, setState){
        return const Expanded(
          child: Center(
            child: Text(
              "Похоже некоторые данные отстуствуют\nПроверьте их наличие",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18
              )
              ),
          )
        );
      });
    }
    else{
      var weektype = "Верхняя";
      var weekdayT = WeekDays[date.weekday-1];
      var scheduleForDay = Schedule[weektype][weekdayT];

      getCell(Widget wdgt){
        return Padding(
          padding: const EdgeInsets.all(3),
          child: Center(
            child:wdgt
          )
        );
      }

      TableRow headOfTable = TableRow(
        children: List.generate(scheduleForDay.length+1, (index){
          if (index == 0) {
            return getCell(const Text(
              " ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15
              ),
            ));
          }


          var lessons = scheduleForDay[index-1];
          
          var button;
          if (lessons is Map){
            
            var dates;

            if (lessons["dates"] != null){
              
              dates = [
                Text(
                  "Даты прохождения пар: ${lessons["dates"]} ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                  ),
                ),
                SizedBox(
                  height: 10,
                )
              ];
            }
            var dialogWnd = [
              Text(
                "Информация о паре",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
                ),
              ),
              SizedBox(
                height: 10,
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Пара: ${lessons["LessonName"]}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  Text(
                    "Тип: ${lessons["LessonType"]}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
              if (dates != null) Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: dates),
                
              

            ];



      

            button = TextButton(
              onPressed: (){
                showDialog(
                  context: hmPgstrt.context,
                  builder: (context){
                    return SimpleDialog(
                      backgroundColor: Color.fromARGB(255, 24, 24, 24),
                      children: [Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: dialogWnd
                        ),
                      )]
                    );
                  }
                );
              },
               child: Text(lessons["numberOfLesson"].toString())
            );
          }
          else if (lessons is List){


            var dialogWnd = [
              Text(
                "Информация о паре",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ];


            for (int i=0;i<lessons.length;i++){
              var lesson = lessons[i];
              var dates;

              if (lesson["dates"] != null){
                var datesString = "";
                
                for (var oneDate in lesson["dates"]){
                  var dateForm = DateFormat("yyyy-MM-dd").parse(oneDate);
                  
                  datesString += "${DateFormat("dd.MM.yy").format(dateForm)}, ";
                }

                dates = [
                  Text(
                    "Даты прохождения пар: ${datesString} ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ];
              }

              var temp = [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Пара: ${lesson["LessonName"]}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    Text(
                      "Тип: ${lesson["LessonType"]}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
                if (dates != null) Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: dates),
                if(i!=lessons.length-1)Divider(
                  color: Colors.white,
                  thickness: 3,
                )
                

              ];

              dialogWnd.addAll(temp);

            }








            button = TextButton(
              onPressed: (){
                showDialog(
                  context: hmPgstrt.context,
                  builder: (context){
                    return SimpleDialog(
                      backgroundColor: Color.fromARGB(255, 24, 24, 24),
                      children: [Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: dialogWnd
                        ),
                      )]
                    );
                  }
                );
              },
               child: Text(lessons[0]["numberOfLesson"].toString())
            );
          }


          return getCell(button);
        })
      );

      print(scheduleForDay);
      

      var bodyOfTable = List.generate(Students.length, (i){
          return TableRow(
            children: List.generate(scheduleForDay.length+1, (index){

              var student = Students[i];

              if (index == 0) {
                return getCell(
                Text(
                  student["lastname"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15
                  ),
                  ));
              }


              Widget cell = Text("124");

              var lesson = scheduleForDay[index-1];
              if (lesson is Map){

                if(lesson["subgroup"]==1 && lesson["subgroupStudents"].indexOf(student["id"]) == -1 ){
                  cell = Container(
                      color: Color.fromARGB(255, 50, 50, 50),
                      child: Text("   "),
                  );
                }
                else if (lesson["subgroup"]==0 || (lesson["subgroup"]==1 && lesson["subgroupStudents"].indexOf(student["id"])!= -1  )){
                  //12345
                  print("-----------${DateFormat("yyyy-MM-dd").format(date)}");
                  var passInfo;
                  for (var item in Passes){
                    if (item["studentId"] == student["id"] && item["numberOfLesson"]==lesson["numberOfLesson"]){
                      passInfo = item;
                      break;
                    }
                  }

                  if (passInfo==null){
                    cell = Pass(general, student, lesson, DateFormat("yyyy-MM-dd").format(date),hmPgstrt);
                  }
                  else{
                    cell = Pass(general, student, lesson, DateFormat("yyyy-MM-dd").format(date),hmPgstrt, infoFromDB: passInfo);
                  }

                  
                }
              }
              else if(lesson is List){
                var temp;
                for(var oneLesson in lesson){
                  if (oneLesson["subgroup"]==1 && oneLesson["subgroupStudents"].indexOf(student["id"]) != -1){
                    //12345

                    var passInfo;
                    print(Passes);
                    for (var item in Passes){
                      print("${item["studentId"]}--${student["id"]}--${item["numberOfLesson"]}--${oneLesson["numberOfLesson"]}");
                      if (item["studentId"] == student["id"] && item["numberOfLesson"]==oneLesson["numberOfLesson"]){
                        passInfo = item;
                        break;
                      }
                    }
                    print("------------${passInfo}");

                    if (passInfo==null){
                      temp = Pass(general, student, oneLesson, DateFormat("yyyy-MM-dd").format(date),hmPgstrt);
                    }
                    else{
                      temp = Pass(general, student, oneLesson, DateFormat("yyyy-MM-dd").format(date), hmPgstrt, infoFromDB: passInfo);
                    }




                    break;
                  }
                }
                if (temp == null){
                  temp = Container(
                      color: Color.fromARGB(255, 50, 50, 50),
                      child: Text("   "),
                  );
                }
                
                cell = temp;
              }


              return (cell);




            })
          );

      });

      bodyOfTable.insert(0, headOfTable);

      double k = 1/3;
      int lessonCount = scheduleForDay.length;
      Map<int, TableColumnWidth> widths = {0:FlexColumnWidth(k* lessonCount / (1-k))};
      for(int i=0;i<lessonCount;i++){
        widths[i+1] = FlexColumnWidth(1);
      }

      mainActiv = StatefulBuilder(
        builder: (context, setState){
        return Expanded(
          child: Center(
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: (lessonCount != 0) ? widths: null,
              border: TableBorder.all(
                color: Colors.white,
                width: 2,
              ),
              children: bodyOfTable
              )
          )
        );
      });
    }

    hmPgstrt._update();
  } 

}







class Pass extends StatefulWidget{
  late generalInfo general;
  late Map student;
  late Map schedule;
  late String date;
  String text = "     ";
  bool state = false;
  Map passInfo = {};
  TextEditingController docId = TextEditingController();
  int passType = 1;
  String wndPassInfo = "";
  late _HomePageState hmpg;
  Pass(generalInfo obj, this.student, this.schedule, this.date, this.hmpg,  {infoFromDB}){
    general = generalInfo.from(obj);
    print(date);
    if (infoFromDB != null){
      passInfo = infoFromDB;
      state = true;
      text = (passInfo["typeId"] == 1 ) ? "2" : ((passInfo["typeId"] == 2 ) ? "②" : ((passInfo["typeId"] == 3 ) ? "з" : " ")); 
      if (passInfo["documentId"] != null) docId.text = passInfo["documentId"].toString();
      passType = passInfo["typeId"] - 1;

      wndPassInfo = (passType == 0 ) ? "Неуважительный" : ((passType == 1 ) ? "Уважительный" : ((passType == 2 ) ? "По заявлению" : " "));
    }
  }

  @override
  _PassState createState() => _PassState();

  onPress(BuildContext context){
    
  }
  
}

class _PassState extends State<Pass>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextButton(
      onPressed: (){
        if (!widget.state){
          http.post(
            Uri.parse('${widget.general._host}pass'),
            headers: {"Authorization":"Bearer ${widget.general._token}", "Content-type":"application/json"},
            body: jsonEncode({
              "studentId": widget.student["id"],
              "date": widget.date,
              "scheduleId": widget.schedule["id"],
              "type": 1
            })
          )
          .then((response){
            var answer = jsonDecode(utf8.decode(response.body.codeUnits));
            print(answer);
            if (answer["status"]=="Success"){
              setState((){
                widget.state = true;
                widget.text = "2";
              });
              widget.passInfo = answer["detail"];
            }
            
          });
        }
        else{
          showDialog(
            context: context,
            builder: (context) => StatefulBuilder(builder: (context, ss)=>
              SimpleDialog(
                backgroundColor: Color.fromARGB(255, 66, 66, 66),
                children: [
                  Padding(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      children: [
                        const Text(
                          "Редактирование пропуска",
                          style:  TextStyle(
                            color: Colors.white,
                            fontSize: 20
                          )
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Студент: ${widget.student["lastname"]} ${widget.student["firstname"]}',
                          style:  const TextStyle(
                            color: Colors.white
                          )
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Пара: ${widget.schedule["LessonName"]}',
                          style:  const TextStyle(
                            color: Colors.white
                          )
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Тип пропуска",
                              style:  TextStyle(
                                color: Colors.white
                              )
                            ),
                            TextButton(
                              onPressed: (){
                                
                                ss(() {
                                  widget.passType = (++widget.passType) % 3;
                                  widget.wndPassInfo = (widget.passType == 0 ) ? "Неуважительный" : ((widget.passType == 1 ) ? "Уважительный" : ((widget.passType == 2 ) ? "По заявлению" : " "));
                                });
                              },
                              child: Text(
                                widget.wndPassInfo
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 7, 2, 105)),
                                foregroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> state){return Colors.white;})
                              )
                            )
                          
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: widget.docId,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                          decoration: const InputDecoration(
                          labelText: 'ID документа',
                          labelStyle: TextStyle(color: Colors.white), 
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), 
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), 
                          ),
                        )
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          onPressed: (){

                            var body =   {
                              "start" : widget.date,
                              "end" : widget.date,
                              "passId" :  widget.passInfo["id"],
                              "type": widget.passType+1
                            };
                            if (widget.docId.text != "")body["docId"] = int.parse(widget.docId.text);

                            http.patch(
                              Uri.parse('${widget.general._host}pass/${widget.student["id"]}'),
                              headers: {"Authorization":"Bearer ${widget.general._token}", "Content-type":"application/json"}, 
                              body : jsonEncode(body)

                            ).then((response){
                              var answer = jsonDecode(utf8.decode(response.body.codeUnits));
                              print(answer);
                              if (answer["status"] == "Success"){
                                http.get(
                                  Uri.parse('${widget.general._host}pass/${widget.student["id"]}?start="${widget.date}"&end="${widget.date}"&id=${widget.passInfo["id"]}')
                                )
                                .then((response){
                                  var answer = jsonDecode(utf8.decode(response.body.codeUnits));
                                  print(answer);
                                  widget.passInfo = answer["detail"][0];

                                  widget.state = true;
                                  if (widget.passInfo["documentId"] != null) widget.docId.text = widget.passInfo["documentId"].toString();
                                  widget.passType = widget.passInfo["typeId"] - 1;

                                  widget.wndPassInfo = (widget.passType == 0 ) ? "Неуважительный" : ((widget.passType == 1 ) ? "Уважительный" : ((widget.passType == 2 ) ? "По заявлению" : " "));
                                  setState(() {
                                    widget.text = (widget.passInfo["typeId"] == 1 ) ? "2" : ((widget.passInfo["typeId"] == 2 ) ? "②" : ((widget.passInfo["typeId"] == 3 ) ? "З" : " ")); 
                                  
                                  });
                                  /*widget.hmpg._update(
                                    fn: (){
                                      
                                    }
                                  );*/
                                });
                              }
                            });
                          },
                          child: Text(
                            "Изменить"
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 56, 3, 171)),
                            foregroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> state){return Colors.white;})
                          )
                        )




                      ],
                    ),
                  )
                ],
              )

            )
          );
        }

        
      },
      onLongPress: (){
        http.delete(
            Uri.parse('${widget.general._host}pass/${widget.passInfo["id"]}'),
            headers: {"Authorization":"Bearer ${widget.general._token}", "Content-type":"application/json"},
          )
          .then((response){
            var answer = jsonDecode(utf8.decode(response.body.codeUnits));
            print(answer);
            if (answer["status"]=="Success"){
              setState((){
                widget.state = false;
                widget.text = " ";
              });
              widget.passInfo = {};
              widget.docId.text = "";
              widget.passType = 0;
              
              widget.wndPassInfo = (widget.passType == 0 ) ? "Неуважительный" : ((widget.passType == 1 ) ? "Уважительный" : ((widget.passType == 2 ) ? "По заявлению" : " "));
            }
            
          });
      },
      child: Text(widget.text),
      style: ButtonStyle(
        //backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 169, 10, 222)),
        foregroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> state){return Colors.white;})
      )
      );
  }
}




class Settings{
  List<CardElement> DeletedCards = [];
  List<CardElement> Cards = [];
  List UniquesId = [];
  late _HomePageState Widget;
  bool hasErrors = false;

  late generalInfo general;
  
 
  Settings(generalInfo General,_HomePageState main){
    general = generalInfo.from(General);
    Widget = main;
    updateInfo();
  }
  
  addStudent(){
    int uId = 0;
    int minId = 1000000000000;
    List<int> Unsoported = [];
    for(var item in Cards){
      if (item.cardInfo["Card"]["id"].text != "" && (minId > int.parse(item.cardInfo["Card"]["id"].text)))minId = int.parse(item.cardInfo["Card"]["id"].text);
      if (item.cardInfo["Card"]["id"].text != "")Unsoported.add(int.parse(item.cardInfo["Card"]["id"].text));
    }
    uId = Random().nextInt(1000);
    while(UniquesId.indexOf(uId)!=-1){
      uId = Random().nextInt(1000);
    }
    UniquesId.add(uId);
    
    while(Unsoported.indexOf(minId)!=-1){
      minId++;
    }
    var CardInfo = {
      "fromDB" : false,
      "uId":uId,
      "Student":{
        "id": ((minId==1000000000000)? null : minId),
        "tgId": null,
        "groupId": general._groupId,
        "lastname": "",
        "firstname": "",
        "patronymic": ""
      },
      "Card":{
        "lastname": TextEditingController(),
        "firstname": TextEditingController(),
        "patronymic": TextEditingController(),
        "id": TextEditingController(),
        "tgId": TextEditingController(),
        "error": ""
      }
    };

    Cards.add(CardElement(info: CardInfo, parent: this));
    for(var item in Cards){
      errorCheck(item.cardInfo["uId"]);
    }
    checkAll();

  }

  deleteStudent(int uId){
    for(int i = 0; i < Cards.length; i++){
      if (Cards[i].cardInfo["uId"] == uId){
        if (Cards[i].cardInfo["fromDB"]){DeletedCards.add(Cards.removeAt(i));}
        else Cards.removeAt(i);
        UniquesId.remove(uId);
        
        
        //break;
      }
    }
    checkAll();
    Widget._update();
  }

  SaveInfo() async{
    checkAll();
    Widget._update();
    if (!hasErrors){
      List Updated = [];
      List Deleted = [];
      List Added = [];
      for(var item in Cards){
        if (item.cardInfo["Student"]["id"].toString()!=item.cardInfo["Card"]["id"].text){
          dynamic addedtemp = {
            "lastname": item.cardInfo["Card"]["lastname"].text,
            "firstname": item.cardInfo["Card"]["firstname"].text,
            "patronymic": item.cardInfo["Card"]["patronymic"].text,
            "id": int.parse(item.cardInfo["Card"]["id"].text),
            "groupId": general._groupId
          };
          if (item.cardInfo["Card"]["tgId"].text !="")addedtemp["tgId"] = int.parse(item.cardInfo["Card"]["tgId"].text);
          Added.add(addedtemp);
          if (item.cardInfo["fromDB"]) Deleted.add(item.cardInfo["Student"]);
        }
        else{
          dynamic temp = {
            "lastname": item.cardInfo["Card"]["lastname"].text,
            "firstname": item.cardInfo["Card"]["firstname"].text,
            "patronymic": item.cardInfo["Card"]["patronymic"].text,
            "id": int.parse(item.cardInfo["Card"]["id"].text),
            "groupId": general._groupId
          };
          if (item.cardInfo["Card"]["tgId"].text !="")temp["tgId"] = int.parse(item.cardInfo["Card"]["tgId"].text);

          dynamic temp2 = {};
          for (var key in item.cardInfo["Student"].keys)
          {
            if (item.cardInfo["Student"][key] != null)temp2[key] = item.cardInfo["Student"][key];
          }


          if (!mapEquals(temp, temp2) && item.cardInfo["fromDB"] ){
            Updated.add(temp);
          }
          else if(!mapEquals(temp, temp2)){
            Added.add(temp);
          }
          
        }
      }

      for(var item in DeletedCards){
        Deleted.add(item.cardInfo["Student"]);
      }

      if (Deleted.length != 0){
        await http.delete(
          Uri.parse('${general._host}students'),
          headers: {"Authorization":"Bearer ${general._token}", "Content-type":"application/json"}, 
          body : jsonEncode({"array":Deleted})
        ).then((value){
            print(utf8.decode(value.body.codeUnits));
          });
      }
      if (Added.length != 0){
        await http.post(
          Uri.parse('${general._host}students'),
          headers: {"Authorization":"Bearer ${general._token}", "Content-type":"application/json"}, 
          body : jsonEncode({"array":Added})
        ).then((value){
            print(utf8.decode(value.body.codeUnits));
          });
      }
      if (Updated.length != 0){
        await http.patch(
          Uri.parse('${general._host}students/'),
          headers: {"Authorization":"Bearer ${general._token}", "Content-type":"application/json"}, 
          body : jsonEncode({"array":Updated})
        ).then((value){
            print(utf8.decode(value.body.codeUnits));
          });
      }

      if (Updated.length != 0 || Added.length != 0 || Deleted.length != 0){
        showDialog(
        context: Widget.context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pop(true);  
          });
          return const AlertDialog(
            title: Text('Данные сохранены', textAlign: TextAlign.center,),
          );
        });
        updateInfo();

      }

      
    
    }
  }

  checkAll(){
    bool state = false;
    for(var item in Cards){
      errorCheck(item.cardInfo["uId"]);
      if (hasErrors && !state) state = true;
    }
    hasErrors = state;
  }

  errorCheck(int uId){

    hasErrors = false;
    for (var item in Cards){
      if (item.cardInfo["uId"]== uId){
        if (item.cardInfo["Card"]["lastname"].text == "" && item.cardInfo["Card"]["id"].text == ""){
          item.cardInfo["Card"]["error"] = "Фамилия и номер зачетки обязательные параметры";
          hasErrors = true;
        }
        else if (item.cardInfo["Card"]["lastname"].text == "" && item.cardInfo["Card"]["id"].text != ""){
          item.cardInfo["Card"]["error"] = "Фамилия - обязательный параметр";
          hasErrors = true;
        }
        else if (item.cardInfo["Card"]["lastname"].text != "" && item.cardInfo["Card"]["id"].text == ""){
          item.cardInfo["Card"]["error"] = "Номер зачетки - обязательный параметр";
          hasErrors = true;
        }
        else{
          item.cardInfo["Card"]["error"] = "";
        }
        for (var item2 in Cards){
          if ((item2.cardInfo["uId"] != uId) && (item.cardInfo["Card"]["id"].text != "") && (item.cardInfo["Card"]["id"].text == item2.cardInfo["Card"]["id"].text)){
            item.cardInfo["Card"]["error"] = "Номер зачетки должен быть уникальным";
            item2.cardInfo["Card"]["error"] = "Номер зачетки должен быть уникальным";
            item2.child.update();
            hasErrors = true;

          }
        }
      }

    }

  }

updateInfo(){
  DeletedCards = [];
  Cards = [];
  UniquesId = [];
  hasErrors = false;
  http.get(Uri.parse('${general._host}groupinfo'),headers: {"Authorization":"Bearer ${general._token}"}).then((response){
    
    dynamic answer = json.decode(utf8.decode(response.body.codeUnits));
    print(answer);
    
    for (var student in answer["detail"]){
      int uId = Random().nextInt(1000);
      while(UniquesId.indexOf(uId)!=-1){
        uId = Random().nextInt(1000);
      }
      var CardInfo = {
        "fromDB" : true,
        "uId":uId,
        "Student":{
          "id": student["id"],
          "tgId": student["tgId"],
          "groupId": student["groupId"],
          "lastname":student["lastname"],
          "firstname":student["firstname"],
          "patronymic":student["patronymic"]
        },
        "Card":{
          "lastname": TextEditingController(),
          "firstname": TextEditingController(),
          "patronymic": TextEditingController(),
          "id": TextEditingController(),
          "tgId": TextEditingController(),
          "error": ""
        }
      };
      Cards.add(CardElement(info: CardInfo, parent: this)); 
    }
    Widget._update();
    
  });
  Widget._update();
  }
  
}

// ignore: must_be_immutable
class CardElement extends StatefulWidget {
  //final String serverIP;
  late Map cardInfo;
  late Settings Parent;
  late _CardWidget child;
  CardElement({super.key, info, parent}){
    cardInfo = info;
    Parent = parent;
    cardInfo["Card"]["lastname"].text = cardInfo["Student"]["lastname"]==null ? "" :cardInfo["Student"]["lastname"].toString();
    cardInfo["Card"]["firstname"].text = cardInfo["Student"]["firstname"]==null ? "" :cardInfo["Student"]["firstname"].toString();
    cardInfo["Card"]["patronymic"].text = cardInfo["Student"]["patronymic"]==null ? "" :cardInfo["Student"]["patronymic"].toString();
    cardInfo["Card"]["tgId"].text = cardInfo["Student"]["tgId"]==null ? "" : cardInfo["Student"]["tgId"].toString();
    cardInfo["Card"]["id"].text = cardInfo["Student"]["id"]==null ? "" : cardInfo["Student"]["id"].toString();

  }
  

  @override
  _CardWidget createState() {
    child = _CardWidget(); 
    return child;
  }
}

class _CardWidget extends State<CardElement> { 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    widget.cardInfo;
  }
  
  update(){
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      color: const Color.fromARGB(255,  19, 19, 19),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.cardInfo["Card"]["error"],
              style: const TextStyle(
                color:Colors.red
              )
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children:[
                Expanded(
                  child: TextField(
                    onChanged: (String text){
                      setState((){
                        widget.Parent.errorCheck(widget.cardInfo["uId"]);
                      });
                    },
                    controller: widget.cardInfo["Card"]["lastname"],
                    style: const TextStyle(color: Colors.white), // Устанавливаем белый цвет текста
                    decoration: const InputDecoration(
                      labelText: 'Фамилия',
                      labelStyle: TextStyle(color: Colors.white), // Устанавливаем белый цвет надписи
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет границы
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет при фокусе
                      ),
                    )
                  ),
                )
              ]
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children:[
                Expanded(
                  child: TextField(
                    onChanged: (String text){
                          setState((){
                          widget.Parent.errorCheck(widget.cardInfo["uId"]);
                          });
                        },
                    controller:widget.cardInfo["Card"]["firstname"],
                    style: const TextStyle(color: Colors.white), // Устанавливаем белый цвет текста
                    decoration: const InputDecoration(
                      labelText: 'Имя',
                      labelStyle: TextStyle(color: Colors.white), // Устанавливаем белый цвет надписи
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет границы
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет при фокусе
                      ),
                    )
                  ),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (String text){
                          setState((){
                          widget.Parent.errorCheck(widget.cardInfo["uId"]);
                          });
                        },
                    controller:widget.cardInfo["Card"]["patronymic"],
                    style: const TextStyle(color: Colors.white), // Устанавливаем белый цвет текста
                    decoration: const InputDecoration(
                      labelText: 'Отчество',
                      labelStyle: TextStyle(color: Colors.white), // Устанавливаем белый цвет надписи
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет границы
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет при фокусе
                      ),
                    )
                  ),
                )
              ]
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children:[
                Expanded(
                  child: TextField(
                    onChanged: (String text){
                      setState(() {
                        widget.Parent.errorCheck(widget.cardInfo["uId"]);
                      });
                    },
                    readOnly: (widget.cardInfo["Student"]["id"]==widget.Parent.general._bossId),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller:widget.cardInfo["Card"]["id"],
                    style: const TextStyle(color: Colors.white), // Устанавливаем белый цвет текста
                    decoration: const InputDecoration(
                      labelText: 'Номер зачетки',
                      labelStyle: TextStyle(color: Colors.white), // Устанавливаем белый цвет надписи
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет границы
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет при фокусе
                      ),
                    )
                  ),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (String text){
                      setState((){
                      widget.Parent.errorCheck(widget.cardInfo["uId"]);
                      });
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller:widget.cardInfo["Card"]["tgId"],
                    style: const TextStyle(color: Colors.white), // Устанавливаем белый цвет текста
                    decoration: const InputDecoration(                          
                      labelText: 'Telegram id',
                      labelStyle: TextStyle(color: Colors.white), // Устанавливаем белый цвет надписи
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет границы
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет при фокусе
                      ),
                    )
                  ),
                )
              ]
            ),
            ElevatedButton.icon(
              onPressed: 
              (
              (widget.Parent.general._bossId.toString() == widget.cardInfo["Student"]["id"].toString()) ?
              null :
              (
                () { 
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Удалить пользователя'),
                      content: const Text('Данное действие нельзя отменить, вся информация о пользователе будет утеряна'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () {

                            widget.Parent.deleteStudent(widget.cardInfo["uId"]);
                            return Navigator.pop(context, 'OK');
                          },
                          child: const Text('Удалить'),
                        ),
                      ],
                    ),
                  );
                }
                )
              ),
              icon: const Icon(Icons.delete, color: Colors.black), // Устанавливаем цвет иконки
              label: const Text(
                "Удалить",
                style: TextStyle(color: Colors.black), // Устанавливаем цвет текста
              ),
              style: ElevatedButton.styleFrom(
                //alignment: Alignment.centerLeft, // Выравнивание по левому краю
                minimumSize: const Size(double.infinity, 30),
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey
                
              )
            ) 
          ],
        )
      
      
    );
  }
}