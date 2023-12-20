import 'package:ejournallapp/services/api_service.dart';
import 'package:ejournallapp/services/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String getCurrentDate() {
  return DateFormat("yyyy-MM-dd").format(Schedule.date);
}

List<DropdownMenuItem<int>> getDropDownItemsByDay(List schedule) {
  List<DropdownMenuItem<int>> items = [];
  String currentDate = DateFormat("yyyy-MM-dd").format(Schedule.date);

  for (int i = 0; i < schedule.length; i++) {
    var lesson = schedule[i];
    for (int j = 0; j < lesson.length; j++) {
      if (lesson[j]["dates"].contains(currentDate)) {
        items.add(DropdownMenuItem(
          value: lesson[j]["numberOfLesson"] * 10 + j,
          child: Text(
            "${lesson[j]['numberOfLesson']}. ${lesson[j]['LessonName']}",
            style: TextStyle(color: MyColors.fontColor),
          ),
        ));
      }
    }
  }
  return items;
}

List getPassesOfDay(List passes) {
  String currentDate = DateFormat("yyyy-MM-dd").format(Schedule.date);
  List items = [];
  for (var pass in passes) {
    if (pass['date'] == currentDate) {
      items.add(pass);
    }
  }
  return items;
}

Widget cardBoxOfStudent(List studentList, bool leftButton, bool rightButton,
    Function fnLeftButton, Function fnRightButton) {
  String headLabel = "";

  if (!leftButton && rightButton) {
    headLabel = "Присутствуют:";
  } else if (leftButton && rightButton) {
    headLabel = "Неуважительный пропуск:";
  } else if (leftButton && !rightButton) {
    headLabel = "Уважительный пропуск:";
  }

  return Padding(
    padding: const EdgeInsets.all(5),
    child: Card(
      color: const Color.fromARGB(0, 0, 0, 0),
      shape: const RoundedRectangleBorder(
        //<-- SEE HERE
        side: BorderSide(
          color: Colors.white,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(headLabel,
                style: TextStyle(fontSize: 15, color: MyColors.fontColor)),
            const SizedBox(
              height: 5,
            ),
            Wrap(
                children: List.generate(studentList.length, (index) {
              return Card(
                color: MyColors.cardBackgroundColor,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      (leftButton) ? 0 : 10, 0, (rightButton) ? 0 : 10, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ((leftButton)
                          ? (IconButton(
                              iconSize: 15,
                              constraints: const BoxConstraints(maxHeight: 30),
                              icon:
                                  Icon(Icons.north, color: MyColors.fontColor),
                              onPressed: () {
                                fnLeftButton(index);
                              },
                            ))
                          : (const Text(''))),
                      Text(
                        "${studentList[index]['lastname']}",
                        style:
                            TextStyle(fontSize: 15, color: MyColors.fontColor),
                      ),
                      ((rightButton)
                          ? (IconButton(
                              iconSize: 15,
                              constraints: const BoxConstraints(maxHeight: 30),
                              icon: Icon(
                                Icons.south,
                                color: MyColors.fontColor,
                              ),
                              onPressed: () {
                                fnRightButton(index);
                              },
                            ))
                          : (Container())),
                    ],
                  ),
                ),
              );
            }))
          ],
        ),
      ),
    ),
  );
}

List insertIntoStudentList(Map object, List list) {
  List temp = [];
  temp.addAll(list);
  for (int i = 0; i < list.length; i++) {
    if (list[i]['id'] < object['id']) {
      temp.insert(i + 1, object);
    }
  }
  return temp;
}

Future<bool> updateStudentsPass(
    Map student, List passes, int selectedValue, List schedule, int newType) {
  Map pass = {};
  for (int i = 0; i < passes.length; i++) {
    var p = passes[i];
    if (student['id'] == p['studentId'] &&
        (selectedValue ~/ 10) == p['numberOfLesson']) {
      pass = p;
    }
  }
  var scheduleId = -1;
  for (int i = 0; i < schedule.length; i++) {
    for (int j = 0; j < schedule[i].length; j++) {
      if (selectedValue == (schedule[i][j]["numberOfLesson"] * 10 + j)) {
        scheduleId = schedule[i][j]['id'];
        break;
      }
    }
    if (scheduleId != -1) {
      break;
    }
  }

  return Pass.updatePass({
    "id": pass['id'],
    "studentId": pass['studentId'],
    "date": getCurrentDate(),
    "scheduleId": scheduleId,
    "type": pass['typeId'],
    "documentId": 0
  }, newType);
}

TextEditingController lastname = TextEditingController();
TextEditingController firstname = TextEditingController();
TextEditingController patronymic = TextEditingController();
TextEditingController id = TextEditingController();
TextEditingController tgId = TextEditingController();
bool sendFlag = false;

SimpleDialog getAddDialog(BuildContext context, Function fnSetState, bool edit,
    [Map student = const {}]) {
  if (edit) {
    lastname.text = student['lastname'];
    firstname.text = student['firstname'] ?? '';
    patronymic.text = student['patronymic'] ?? '';
    id.text = (student['id'] ?? '').toString();
    tgId.text = (student['tgId'] ?? '').toString();
  } else {
    lastname.text = "";
    firstname.text = "";
    patronymic.text = "";
    id.text = "";
    tgId.text = "";
  }

  return SimpleDialog(
    backgroundColor: MyColors.cardBackgroundColor,
    children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text("Добавление студента",
                style: TextStyle(fontSize: 20, color: MyColors.fontColor)),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: lastname,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Фамилия',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: firstname,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Имя',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: patronymic,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Отчество',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: id,
              readOnly: (edit), //&& Group.bossId == student['id']),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Номер зачетки',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: tgId,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Телеграм id',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    if (edit) {
                      if (student['firstname'] != firstname.text ||
                          student['lastname'] != lastname.text ||
                          student['patronymic'] != patronymic.text ||
                          student['tgId'] != int.parse(tgId.text)) {
                        Group.updateStudent({
                          "id": student['id'],
                          "tgId":
                              (tgId.text != '') ? int.parse(tgId.text) : null,
                          "groupId": Group.groupId,
                          "lastname": lastname.text,
                          "firstname": firstname.text,
                          "patronymic": patronymic.text
                        }).then((value) {
                          if (value) {
                            fnSetState(() {});
                            Navigator.pop(context);
                          }
                        });
                      }
                    } else {
                      if (lastname.text == "" || id.text == "") {
                        return;
                      }
                      Group.addStudent({
                        "id": int.parse(id.text),
                        "tgId": (tgId.text != '') ? int.parse(tgId.text) : null,
                        "groupId": Group.groupId,
                        "lastname": lastname.text,
                        "firstname": firstname.text,
                        "patronymic": patronymic.text
                      }).then((value) {
                        if (value) {
                          fnSetState(() {});
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                  icon: Icon(
                    Icons.save,
                    color: MyColors.fontColor,
                  ),
                  label: Text(
                    "Сохранить",
                    style: TextStyle(fontSize: 20, color: MyColors.fontColor),
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => MyColors.buttonColor),
                      padding: MaterialStateProperty.resolveWith((states) =>
                          const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5))),
                ),
                SizedBox(
                  width: edit ? 5 : 0,
                ),
                ((edit && student['id'] != Group.bossId)
                    ? (TextButton.icon(
                        onPressed: () {
                          Group.deleteStudent(student).then((value) {
                            if (value) {
                              fnSetState(() {});
                              Navigator.pop(context);
                            }
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: MyColors.fontColor,
                        ),
                        label: Text(
                          "Удалить",
                          style: TextStyle(
                              fontSize: 20, color: MyColors.fontColor),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                (states) => Colors.red),
                            padding: MaterialStateProperty.resolveWith(
                                (states) => const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5))),
                      ))
                    : (const Text("")))
              ],
            )
          ],
        ),
      )
    ],
  );
}

List<List<DropdownMenuItem>> getMenuItems() {
  List<DropdownMenuItem> weekTypes = [
    DropdownMenuItem(
        value: 0,
        child: Text("Верхняя",
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: MyColors
                    .fontColor)) /*Flexible(
        child: Text("Верхняя", softWrap: true, overflow: TextOverflow.ellipsis,),
      ),*/
        ),
    DropdownMenuItem(
        value: 1,
        child: Text("Нижняя",
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: MyColors
                    .fontColor)) /*Flexible(
        child: Text("Нижняя", softWrap: true, overflow: TextOverflow.ellipsis,),
      ),*/
        )
  ];
  List<DropdownMenuItem> weekDays = [];

  for (var weekDay in Schedule.weekDays) {
    weekDays.add(DropdownMenuItem(
        value: Schedule.weekDays.indexOf(weekDay),
        child: Text(weekDay.toString(),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: MyColors
                    .fontColor)) /*Flexible(
        child: Text(weekDay.toString(), softWrap: true, overflow: TextOverflow.ellipsis,),
      ),*/
        ));
  }
  return [weekTypes, weekDays];
}

getTableForSchedule(List scheduleForOneDay) {
  Map newLessons = {};
  for (var lessons in scheduleForOneDay) {
    for (var lesson in lessons) {
      if (!newLessons.containsKey(lesson['numberOfLesson'])) {
        newLessons[lesson['numberOfLesson']] = [];
      }
      newLessons[lesson['numberOfLesson']].add(lesson);
    }
  }
  var headOfTable = TableRow(children: [
    TableCell(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Text("№",
          style: TextStyle(
              // fontSize: 20,
              color: MyColors.fontColor)),
    )),
    Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1),
      },
      border: TableBorder.all(color: MyColors.fontColor),
      children: [
        TableRow(children: [
          TableCell(
              child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text("Название",
                style: TextStyle(
                    // fontSize: 20,
                    color: MyColors.fontColor)),
          )),
          TableCell(
              child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text("Тип",
                style: TextStyle(
                    // fontSize: 20,
                    color: MyColors.fontColor)),
          )),
          TableCell(
              child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(" ",
                style: TextStyle(
                    // fontSize: 20,
                    color: MyColors.fontColor)),
          ))
        ])
      ],
    )
  ]);
  var bodyOfTable = [headOfTable];
  List indexes = newLessons.keys.toList();
  indexes.sort((a, b) => (a.compareTo(b)));
  for (var keys in indexes) {
    var oneTimeLesson = newLessons[keys];
    List<TableRow> tempTableRows = [];
    for (var lesson in oneTimeLesson) {
      tempTableRows.add(TableRow(children: [
        TableCell(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(lesson['LessonName'],
              style: TextStyle(
                  // fontSize: 20,
                  color: MyColors.fontColor)),
        )),
        TableCell(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(lesson['LessonType'],
              style: TextStyle(
                  // fontSize: 20,
                  color: MyColors.fontColor)),
        )),
        TableCell(
            child: Padding(
          padding: const EdgeInsets.all(0),
          child: IconButton(
            icon: Icon(Icons.edit, color: MyColors.fontColor),
            onPressed: () {
              // режим редактирования
            },
          ),
        ))
      ]));
    }

    bodyOfTable.add(
      TableRow(children: [
        TableCell(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(oneTimeLesson[0]['numberOfLesson'].toString(),
              style: TextStyle(
                  // fontSize: 20,
                  color: MyColors.fontColor)),
        )),
        Table(
            columnWidths: const {
              0: FlexColumnWidth(4),
              1: FlexColumnWidth(1.5),
            },
            children: tempTableRows,
            border: TableBorder.all(color: MyColors.fontColor))
      ]),
    );
  }
  var width = const {
    0: FlexColumnWidth(1),
    1: FlexColumnWidth(5.5),
  };
  Table scheduleFofDay = Table(
    columnWidths: width,
    border: TableBorder.all(color: MyColors.fontColor),
    children: bodyOfTable,
  );

  return scheduleFofDay;
}
