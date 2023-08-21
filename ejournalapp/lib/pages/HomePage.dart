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
    noticer = Notice(general);
    settindsObject = Settings(general, this);
  }


  _update(){
    setState(() {
      
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
                                    DateTime? newDate = await showDatePicker(context: context, initialDate: noticer!.date, firstDate: DateTime(2023), lastDate: DateTime(noticer!.date.year.toInt()+1), locale: Locale('ru', 'BY'));
                                    
                                    if (newDate != null){
                                      setState(() {
                                        if (newDate.weekday == 7){noticer!.date = newDate.add(const Duration(days:-1));}//понедельник - 7, вторник - 1
                                        else {noticer!.date = newDate;}
                                        noticer!.viewDay();
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
                                });
                                
                              },
                              icon: const Icon(Icons.navigate_next),
                              color: Colors.white,
                              iconSize: 30,
                            )
                          ]
                        ),
                        if (noticer != null)noticer!.tableForNotice
                        
                      ]
                    ),
                  ),
                Container(           // Пропуски за месяц
                  


                ),
                
                Container(           // Пропуски за месяц
                  //child: table,


                ),
                Container(           //карточки студентов
                  child: Column(
                    children:[
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
                              icon: Icon(Icons.add)
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
                                    Future.delayed(Duration(seconds: 1), () {
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
                              label: Text("Сохранить"),
                              icon: Icon(Icons.save)
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
  Table tableForNotice = Table();
  late generalInfo general;
  List Students = [];
  dynamic Shedule = [];

  Notice(generalInfo obj){
    general = generalInfo.from(obj);
    date = DateTime.now();
    if (date.weekday == 7)date = date.add(const Duration(days:-1));
    //print(obj._token);
    http.get(Uri.parse('${general._host}groupinfo'),headers: {"Authorization":"Bearer ${general._token}"}).then((response){
      var answer = jsonDecode(utf8.decode(response.body.codeUnits));
      if (answer["detail"] == "success"){
        Students = answer["students"];
        http.get(Uri.parse('${general._host}schedule/${general._groupId}')).then((response){
          if (response.statusCode == 200){
            Shedule = jsonDecode(utf8.decode(response.body.codeUnits))["Schedule"];
            viewDay();
          }
        });
        /*tableForNotice = DataTable(
          columns: columns,
          rows: rows
        )*/
      }



    });
  }

  getCell(Widget wdgt){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Center(
        child: wdgt,
      ),
    );
  }

  viewDay(){
    var weekType = "Верхняя";
    print(Shedule[weekType][WeekDays[date.weekday-1]]);
    var response = [];
    double k = 1/3;
    int lessonCount = Shedule[weekType][WeekDays[date.weekday-1]].length;
    Map<int, TableColumnWidth> widths = {0:FlexColumnWidth(k* lessonCount / (1-k))};
    for(int i=0;i<=lessonCount;i++){
      widths[i+1] = FlexColumnWidth(1);
    }

    print(widths);
    tableForNotice = Table(
      columnWidths: widths,
      border: TableBorder.all(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      children: List.generate(Students.length+1, (index) {
        if (index == 0){
          return TableRow(
            children: List.generate(Shedule[weekType][WeekDays[date.weekday-1]].length+1,
            (index){
              if (index == 0){
                return getCell(Text(" ", style: TextStyle(color: Colors.white)));
              }
              return getCell(Text(Shedule[weekType][WeekDays[date.weekday-1]][index-1]["numberOfLesson"].toString(), style: TextStyle(color: Colors.white)));
              
            })
          );
        }
        return TableRow(
          children: List.generate(Shedule[weekType][WeekDays[date.weekday-1]].length+1, (i){
            if (i==0){
              return getCell(Text(Students[index-1]["lastname"], style: TextStyle(color: Colors.white)));   
            }
            return getCell(pass().btn);
            
            
            
            
          })
        );
      })


      
    );
    /*http.get(Uri.parse('${general._host}pass/?start=${}&end=${}')).then((response){

    });*/
  }



}


class pass{
  String text = "    ";
  late TextButton btn;
  int state = 0;
  Function()? fn;

  pass(){
    update();
  }

  setFn(Function() fn){
    this.fn = fn;
  }

  update(){
    btn = TextButton(
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15
        )
      ),
      onPressed: (){
        if (state==0){
          state = 1;
        }
        if (state==1){
          fn!();
        }
        
      },
      onLongPress: (){
        if (state==1){
          state = 0;
        }
      },
    );
  }


}

















/*class passTable extends StatefulWidget {
  List studentInfo = [];
  int month = 0;
  int year = 0;
  
  passTable({super.key, group, month, year}){
    
  }
  
  @override
  // ignore: library_private_types_in_public_api
  _passTableState createState() => _passTableState();
}

class _passTableState extends State<passTable> { 
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DataTable(
      border: TableBorder.all(
        color: Colors.white,
        width: 3,
      ),
      showBottomBorder : true,
      columns: [
        DataColumn(label: Text("Фамилия")),
        DataColumn(label: Text("Уважительные")),
        DataColumn(label: Text("Неуважительные")),
        DataColumn(label: Text("По заявлению")),
      ],
      rows: List<DataRow>.generate(5,
      (index) {
        return DataRow(cells: [
          DataCell(Text("fgh")),
          DataCell(Text("fgh")),
          DataCell(Text("fgh")),
          DataCell(Text("fgh")),
        ]);
      })
    );
  }



} */






































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
    if (answer["detail"]=="success"){
      for (var student in answer["students"]){
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
    }
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
      color: Color.fromARGB(255,  19, 19, 19),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              widget.cardInfo["Card"]["error"],
              style: TextStyle(
                color:Colors.red
              )
            ),
            SizedBox(
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
            SizedBox(
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
            SizedBox(
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
              icon: Icon(Icons.delete, color: Colors.black), // Устанавливаем цвет иконки
              label: Text(
                "Удалить",
                style: TextStyle(color: Colors.black), // Устанавливаем цвет текста
              ),
              style: ElevatedButton.styleFrom(
                //alignment: Alignment.centerLeft, // Выравнивание по левому краю
                minimumSize: Size(double.infinity, 30),
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey
                
              )
            ) 
          ],
        )
      
      
    );
  }
}