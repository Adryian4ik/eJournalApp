import 'package:ejournallapp/services/api_service.dart';
import 'package:ejournallapp/services/colors.dart';
import 'package:ejournallapp/services/widget_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int selectedValue = 0;
  int indexOfPage = 0;
  PageController pageViewController = PageController();
  int lessonIndex = -1;
  int weekTypeIndex = 0;
  int weekDayIndex = 0;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 30));
  int counter = 0;
  TextEditingController numberOfLesson = TextEditingController();
  TextEditingController newLessonName = TextEditingController();

  bool isLection = true;

  bool isEditAddMode = false;

  @override
  void initState() {
    super.initState();
    Pass.update();
    Group.isLoaded.then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.headerColor,
          toolbarHeight: 0,
        ),
        backgroundColor: MyColors.backgroundColor,
        body: PageView(
          onPageChanged: (value) {
            setState(() {
              indexOfPage = value;
            });
          },
          controller: pageViewController,
          children: [
            // page 1
            Column(
              children: [
                // headbar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        selectedValue = 0;
                        setState(() {
                          Schedule.iterationByTime(-1);
                        });
                      },
                      icon: const Icon(Icons.navigate_before),
                      color: MyColors.fontColor,
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        DateTime? newDate = await showDatePicker(
                            context: context,
                            initialDate: Schedule.date,
                            firstDate: DateTime(Schedule.date.year - 1),
                            lastDate: DateTime(Schedule.date.year + 1),
                            locale: const Locale('ru', 'BY'));
                        if (newDate != null) {
                          setState(() {
                            Schedule.setDate(newDate);
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(DateFormat("dd.MM.yy").format(Schedule.date)),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) =>
                                  const Color.fromARGB(255, 205, 148, 4)),
                          iconColor: MaterialStateColor.resolveWith(
                              (states) => MyColors.fontColor),
                          foregroundColor: MaterialStateColor.resolveWith(
                              (states) => MyColors.fontColor),
                          textStyle: MaterialStateTextStyle.resolveWith(
                              (states) => const TextStyle(fontSize: 20))),
                    ),
                    IconButton(
                      onPressed: () {
                        selectedValue = 0;

                        setState(() {
                          Schedule.iterationByTime(1);
                        });
                      },
                      icon: const Icon(Icons.navigate_next),
                      color: MyColors.fontColor,
                    ),
                  ],
                ),

                //KO
                Flexible(
                    child: FutureBuilder(
                        future: Pass.isLoaded,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator(
                              color: MyColors.fontColor,
                            ));
                          }
                          if (snapshot.hasError || !snapshot.data!) {
                            return Container(
                                child: Column(
                                  children: [
                                    Text(
                                      "Произошла ошибка",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: MyColors.errorMessageColor),
                                    ),
                                    TextButton.icon(
                                        onPressed: () {
                                          Pass.update();
                                          setState(() {});
                                        },
                                        label: Text(
                                          "Обновить",
                                          style: TextStyle(
                                              color: MyColors.fontColor),
                                        ),
                                        icon: Icon(
                                          Icons.update,
                                          color: MyColors.fontColor,
                                        ),
                                        style: ButtonStyle(
                                            padding: MaterialStateProperty
                                                .resolveWith((states) =>
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5)),
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith((states) =>
                                                        MyColors.buttonColor)))
                                  ],
                                ));
                          }

                          List schedule = Schedule.getCurrentSchedule();

                          List<DropdownMenuItem<int>> items =
                              getDropDownItemsByDay(schedule);
                          if (schedule.isNotEmpty && selectedValue == 0) {
                            selectedValue =
                                schedule[0][0]["numberOfLesson"] * 10;
                          }

                          return ((items.isNotEmpty)
                              ? (Column(children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: DropdownButton(
                                      isExpanded: true,
                                      items: items,
                                      onChanged: (newValue) {
                                        if (newValue != null &&
                                            selectedValue != newValue) {
                                          Pass.update();
                                        }
                                        setState(() {
                                          selectedValue =
                                              newValue ?? selectedValue;
                                        });
                                      },
                                      value: selectedValue,
                                      dropdownColor:
                                          MyColors.cardBackgroundColor,
                                    ),
                                  ),
                                  FutureBuilder(
                                      future: Pass.isLoaded,
                                      builder: ((context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child: CircularProgressIndicator(
                                            color: MyColors.fontColor,
                                          ));
                                        }

                                        if (snapshot.hasError ||
                                            !snapshot.data!) {
                                          return Container(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Произошла ошибка",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: MyColors
                                                            .errorMessageColor),
                                                  ),
                                                  TextButton.icon(
                                                      onPressed: () {
                                                        Pass.update();
                                                        setState(() {});
                                                      },
                                                      label: Text(
                                                        "Обновить",
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .fontColor),
                                                      ),
                                                      icon: Icon(
                                                        Icons.update,
                                                        color:
                                                            MyColors.fontColor,
                                                      ),
                                                      style: ButtonStyle(
                                                          padding: MaterialStateProperty
                                                              .resolveWith((states) =>
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          5)),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .resolveWith(
                                                                      (states) =>
                                                                          MyColors
                                                                              .buttonColor)))
                                                ],
                                              ));
                                        }

                                        List passes = Pass.passes;
                                        List allStudent = Group.students;

                                        List uStudents = []; // уважительный
                                        List nStudents = []; // неуважительный
                                        List oStudents = []; // остальные

                                        oStudents.addAll(allStudent);

                                        List passOneDay =
                                            getPassesOfDay(passes);
                                        for (int i = 0;
                                            i < passOneDay.length;
                                            i++) {
                                          var pass = passOneDay[i];
                                          if (pass['numberOfLesson'] !=
                                              selectedValue ~/ 10) {
                                            continue;
                                          }
                                          for (int j = 0;
                                              j < allStudent.length;
                                              j++) {
                                            var student = allStudent[j];
                                            if (pass['studentId'] ==
                                                student['id']) {
                                              if (pass['typeId'] == 1) {
                                                nStudents.add(student);
                                              } else if (pass['typeId'] == 2) {
                                                uStudents.add(student);
                                              }
                                              oStudents.remove(student);
                                              break;
                                            }
                                          }
                                        }

                                        return Expanded(
                                            child: ListView(
                                          children: [
                                            cardBoxOfStudent(oStudents, false,
                                                true, (index) {}, (index) {
                                              var student = oStudents[index];
                                              var scheduleId = -1;
                                              for (int i = 0;
                                                  i < schedule.length;
                                                  i++) {
                                                for (int j = 0;
                                                    j < schedule[i].length;
                                                    j++) {
                                                  if (selectedValue ==
                                                      (schedule[i][j][
                                                                  "numberOfLesson"] *
                                                              10 +
                                                          j)) {
                                                    scheduleId =
                                                        schedule[i][j]['id'];
                                                    break;
                                                  }
                                                }
                                                if (scheduleId != -1) {
                                                  break;
                                                }
                                              }

                                              Pass.addPass({
                                                "id": 0,
                                                "studentId": student['id'],
                                                "date": getCurrentDate(),
                                                "scheduleId": scheduleId,
                                                "type": 1,
                                                "documentId": 0
                                              }).then((value) {
                                                if (value) {
                                                  setState(() {});
                                                }
                                              });
                                            }),
                                            cardBoxOfStudent(
                                                nStudents, true, true, (index) {
                                              var student = nStudents[index];
                                              int passId = -1;
                                              for (int i = 0;
                                                  i < passOneDay.length;
                                                  i++) {
                                                var pass = passOneDay[i];
                                                if (student['id'] ==
                                                        pass['studentId'] &&
                                                    (selectedValue ~/ 10) ==
                                                        pass[
                                                            'numberOfLesson']) {
                                                  passId = pass['id'];
                                                  break;
                                                }
                                              }
                                              Pass.deletePass(passId)
                                                  .then((value) {
                                                if (value) {
                                                  setState(() {});
                                                }
                                              });
                                            }, (index) {
                                              updateStudentsPass(
                                                      nStudents[index],
                                                      passOneDay,
                                                      selectedValue,
                                                      schedule,
                                                      2)
                                                  .then((value) {
                                                if (value) {
                                                  setState(() {});
                                                }
                                              });
                                            }),
                                            cardBoxOfStudent(
                                                uStudents, true, false,
                                                (index) {
                                              updateStudentsPass(
                                                      uStudents[index],
                                                      passOneDay,
                                                      selectedValue,
                                                      schedule,
                                                      1)
                                                  .then((value) {
                                                if (value) {
                                                  setState(() {});
                                                }
                                              });
                                            }, (index) {}),
                                          ],
                                        ));
                                      }))
                                ]))
                              : (Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: Text(
                                    "Пары на данный день отсутствуют.",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: MyColors.fontColor),
                                  ))));
                        }))
              ],
            ),
            //page 2
            Column(
              // direction: Axis.vertical,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: Schedule.date,
                            firstDate: DateTime(Schedule.date.year - 1),
                            lastDate: DateTime(Schedule.date.year + 1),
                            locale: const Locale('ru', 'BY'));

                        if (date == null) {
                          return;
                        }

                        startDate = date;
                        if (endDate.compareTo(startDate) < 0) {
                          endDate = startDate;
                        }
                        setState(() {});
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(DateFormat("dd.MM.yy").format(startDate)),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) =>
                                  const Color.fromARGB(255, 205, 148, 4)),
                          iconColor: MaterialStateColor.resolveWith(
                              (states) => MyColors.fontColor),
                          foregroundColor: MaterialStateColor.resolveWith(
                              (states) => MyColors.fontColor),
                          textStyle: MaterialStateTextStyle.resolveWith(
                              (states) => const TextStyle(fontSize: 20))),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: Schedule.date,
                            firstDate: DateTime(Schedule.date.year - 1),
                            lastDate: DateTime(Schedule.date.year + 1),
                            locale: const Locale('ru', 'BY'));
                        if (date == null) {
                          return;
                        }

                        endDate = date;
                        if (endDate.compareTo(startDate) < 0) {
                          endDate = startDate;
                        }
                        setState(() {});
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(DateFormat("dd.MM.yy").format(endDate)),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) =>
                                  const Color.fromARGB(255, 205, 148, 4)),
                          iconColor: MaterialStateColor.resolveWith(
                              (states) => MyColors.fontColor),
                          foregroundColor: MaterialStateColor.resolveWith(
                              (states) => MyColors.fontColor),
                          textStyle: MaterialStateTextStyle.resolveWith(
                              (states) => const TextStyle(fontSize: 20))),
                    )
                  ],
                ),
                Expanded(
                    child: ListView(
                  children: [
                    FutureBuilder(
                        future: Pass.getPassesByPeriod(startDate, endDate),
                        builder: ((context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: MyColors.fontColor,
                                )
                              ],
                            );
                          }

                          if (snapshot.hasError) {
                            return Expanded(
                              child: Container(
                                  child: Column(
                                    children: [
                                      Text(
                                        "Произошла ошибка",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: MyColors.errorMessageColor),
                                      ),
                                      TextButton.icon(
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          label: Text(
                                            "Обновить",
                                            style: TextStyle(
                                                color: MyColors.fontColor),
                                          ),
                                          icon: Icon(
                                            Icons.update,
                                            color: MyColors.fontColor,
                                          ),
                                          style: ButtonStyle(
                                              padding: MaterialStateProperty
                                                  .resolveWith((states) =>
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5)),
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .resolveWith((states) =>
                                                          MyColors
                                                              .buttonColor)))
                                    ],
                                  )),
                            );
                          }

                          // подготовка данных для таблички

                          var students = Group.students;

                          var passes = snapshot.data!;

                          for (int i = 0; i < students.length; i++) {
                            var student = students[i];
                            student['uPass'] = 0;
                            student['nPass'] = 0;
                            List deletedPasses = [];
                            for (var pass in passes) {
                              if (pass['studentId'] == student['id']) {
                                String tag = '';
                                if (pass['typeId'] == 1) {
                                  tag = 'nPass';
                                } else if (pass['typeId'] == 2) {
                                  tag = 'uPass';
                                }
                                students[i][tag] += 2;
                                deletedPasses.add(pass);
                              }
                            }
                            for (var pass in deletedPasses) {
                              passes.remove(pass);
                            }
                          }

                          var headOfTable = TableRow(children: [
                            TableCell(
                                child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text("Фамилия",
                                  style: TextStyle(
                                      // fontSize: 20,
                                      color: MyColors.fontColor)),
                            )),
                            TableCell(
                                child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text("У",
                                  style: TextStyle(
                                      // fontSize: 20,
                                      color: MyColors.fontColor)),
                            )),
                            TableCell(
                                child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text("Н",
                                  style: TextStyle(
                                      // fontSize: 20,
                                      color: MyColors.fontColor)),
                            )),
                            TableCell(
                                child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text("В",
                                  style: TextStyle(
                                      // fontSize: 20,
                                      color: MyColors.fontColor)),
                            )),
                          ]);

                          List<TableRow> tableBody = [headOfTable];

                          for (int i = 0; i < students.length; i++) {
                            var student = students[i];
                            tableBody.add(TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(student['lastname'],
                                    style: TextStyle(
                                        // fontSize: 20,
                                        color: MyColors.fontColor)),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(student['uPass'].toString(),
                                    style: TextStyle(
                                        // fontSize: 20,
                                        color: MyColors.fontColor)),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(student['nPass'].toString(),
                                    style: TextStyle(
                                        // fontSize: 20,
                                        color: MyColors.fontColor)),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                    (student['uPass'] + student['nPass'])
                                        .toString(),
                                    style: TextStyle(
                                        // fontSize: 20,
                                        color: MyColors.fontColor)),
                              )),
                            ]));
                          }

                          var width = const {
                            0: FlexColumnWidth(3),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1)
                          };

                          return Table(
                            columnWidths: width,
                            border: TableBorder.all(color: MyColors.fontColor),
                            children: tableBody,
                          );
                        }))
                  ],
                ))
              ],
            ),
            //page 3
            Column(
              // direction: Axis.vertical,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        // direction: Axis.vertical,
                        children: [
                          DropdownButton(
                            isExpanded: true,
                            value: weekTypeIndex,
                            items: getMenuItems()[0],
                            dropdownColor: MyColors.cardBackgroundColor,
                            onChanged: (value) {
                              weekTypeIndex = value;
                              setState(() {});
                            },
                          ),
                          DropdownButton(
                            isExpanded: true,
                            value: weekDayIndex,
                            items: getMenuItems()[1],
                            dropdownColor: MyColors.cardBackgroundColor,
                            onChanged: (value) {
                              weekDayIndex = value;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      FutureBuilder(
                          future: Schedule.getAllLessons(),
                          builder: ((context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: MyColors.fontColor,
                                    )
                                  ]);
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "Произошла ошибка",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: MyColors.errorMessageColor),
                                    ),
                                    TextButton.icon(
                                        onPressed: () {
                                          Group.update();
                                          setState(() {});
                                        },
                                        label: Text(
                                          "Обновить",
                                          style: TextStyle(
                                              color: MyColors.fontColor),
                                        ),
                                        icon: Icon(
                                          Icons.update,
                                          color: MyColors.fontColor,
                                        ),
                                        style: ButtonStyle(
                                            padding: MaterialStateProperty
                                                .resolveWith((states) =>
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5)),
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith((states) =>
                                                        MyColors.buttonColor)))
                                  ],
                                ),
                              );
                            }
                            List scheduleForOneDay = Schedule.getScheduleForDay(
                                weekTypeIndex, weekDayIndex);
                            return Align(
                              child: getTableForSchedule(scheduleForOneDay),
                              alignment: Alignment.bottomCenter,
                            );
                          })),
                      ((isEditAddMode)
                          ? (Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Лекция",
                                        style: TextStyle(
                                            color: MyColors.fontColor)),
                                    Switch(
                                        activeColor: MyColors.buttonColor,
                                        inactiveThumbColor: MyColors.fontColor,
                                        value: isLection,
                                        onChanged: (value) {
                                          setState(() {
                                            isLection = value;
                                          });
                                        }),
                                    Text('Практика',
                                        style: TextStyle(
                                            color: MyColors.fontColor))
                                  ],
                                ),
                                TextField(
                                  controller: numberOfLesson,
                                  style: TextStyle(color: MyColors.fontColor),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Номер пары',
                                    labelStyle: TextStyle(color:  MyColors.fontColor),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color:  MyColors.fontColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color:  MyColors.fontColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                FutureBuilder(
                                    future: Schedule.getAllLessons(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text("");
                                      }
                                      return DropdownButton(
                                          isExpanded: true,
                                          items: Schedule.lessons,
                                          value: lessonIndex,
                                          dropdownColor:
                                              MyColors.cardBackgroundColor,
                                          onChanged: (value) {
                                            setState(() {
                                              lessonIndex = value;
                                            });
                                          });
                                    }),
                                ((lessonIndex == -1)
                                    ? (TextField(
                                        controller: newLessonName,
                                        style: TextStyle(
                                            color:  MyColors.fontColor),
                                        decoration:  InputDecoration(
                                          labelText: 'Название пары',
                                          labelStyle:
                                              TextStyle(color:  MyColors.fontColor),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color:  MyColors.fontColor),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color:  MyColors.fontColor),
                                          ),
                                        ),
                                      ))
                                    : (const Text('')))
                              ],
                            ))
                          : (const Text("")))
                    ],
                  ),
                )
              ],
            ),
            //page 4
            Column(
              // direction: Axis.vertical,
              children: [
                FutureBuilder(
                    future: Group.isLoaded,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Expanded(
                            child: CircularProgressIndicator(
                          color: MyColors.fontColor,
                        ));
                      }

                      if (snapshot.hasError || !snapshot.data!) {
                        return Expanded(
                          child: Container(
                              color:  MyColors.fontColor,
                              child: Column(
                                children: [
                                  Text(
                                    "Произошла ошибка",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: MyColors.errorMessageColor),
                                  ),
                                  TextButton.icon(
                                      onPressed: () {
                                        Group.update();
                                        setState(() {});
                                      },
                                      label: Text(
                                        "Обновить",
                                        style: TextStyle(
                                            color: MyColors.fontColor),
                                      ),
                                      icon: Icon(
                                        Icons.update,
                                        color: MyColors.fontColor,
                                      ),
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty
                                              .resolveWith((states) =>
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5)),
                                          backgroundColor:
                                              MaterialStateProperty.resolveWith(
                                                  (states) =>
                                                      MyColors.buttonColor)))
                                ],
                              )),
                        );
                      }

                      List<Widget> studentCards =
                          List.generate(Group.students.length, (index) {
                        var student = Group.students[index];
                        return Card(
                            color: MyColors.cardBackgroundColor,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${student['lastname']} ${student['firstname'] ?? ''} \n${student['patronymic'] ?? ''}",
                                        style: TextStyle(
                                            color: MyColors.fontColor,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        "Номер зачетки: ${student['id']}",
                                        style: TextStyle(
                                            color: MyColors.fontColor,
                                            fontSize: 15),
                                      ),
                                      Text(
                                        "Телеграм: ${(student['tgId'] == null) ? "нет" : "есть"}",
                                        style: TextStyle(
                                            color: MyColors.fontColor,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return getAddDialog(context,
                                                  setState, true, student);
                                            });
                                      },
                                      icon: Icon(Icons.edit,
                                          color: MyColors.fontColor))
                                ],
                              ),
                            ));
                      });
                      studentCards.add(Column(
                        children: [
                          const SizedBox(
                            height: 2,
                          ),
                          Divider(
                            color: MyColors.fontColor.withAlpha(150),
                            thickness: 2,
                          ),
                          Text("Количество студентов: ${studentCards.length}",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: MyColors.fontColor.withAlpha(150)))
                        ],
                      ));
                      return Expanded(
                        child: ListView(
                          children: studentCards,
                        ),
                      );
                    }),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return getAddDialog(context, setState, false);
                        });
                  },
                  icon: Icon(
                    Icons.add,
                    color: MyColors.fontColor,
                  ),
                  label: Text(
                    "Добавить",
                    style: TextStyle(fontSize: 20, color: MyColors.fontColor),
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => MyColors.buttonColor),
                      padding: MaterialStateProperty.resolveWith((states) =>
                          const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5))),
                )
              ],
            )
          ],
        ),
        floatingActionButton: ((indexOfPage == 2)
            ? (FloatingActionButton(
                onPressed: () {
                  if (!isEditAddMode) {
                    isEditAddMode = true;
                    setState(() {});
                  } else {
                    Map lesson = {};
                    // условие что другой предмет
                    if (lessonIndex == -1) {
                      lesson['name'] = newLessonName.text;
                    }
                    Schedule.addLesson({
                      "id": 0,
                      "lessonId": (lessonIndex == -1) ? null : lessonIndex,
                      "groupId": Group.groupId,
                      "dayOfWeek": weekDayIndex + 1,
                      "week": weekTypeIndex == 0 ? 1 : 0,
                      "numberOfLesson": /* из текстового поля */
                          numberOfLesson.text != ''
                              ? int.parse(numberOfLesson.text)
                              : 0,
                      "type": /* слайдер */ (isLection) ? 2 : 1,
                      "subgroup": 1,
                      "dates": List.generate(16, (index) {
                        DateTime first = DateTime(2023, 9, 1);
                        DateTime newDate = first;

                        while (newDate.weekday != weekDayIndex + 1) {
                          newDate = newDate.add(const Duration(days: 1));
                        }
                        newDate = newDate.add(Duration(days: 7 * index));
                        return DateFormat("yyyy-MM-dd").format(newDate);
                      }),
                      "mask": [0],
                      "auditorium": ""
                    }, lesson)
                        .then((value) {
                      if (value) {
                        setState(() {
                          isEditAddMode = false;
                        });
                      }
                    });
                  }
                },
                backgroundColor: MyColors.buttonColor,
                child: Icon(
                  ((isEditAddMode) ? Icons.save : Icons.add),
                  color: MyColors.fontColor,
                ),
              ))
            : (null)),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: indexOfPage,
          type: BottomNavigationBarType.fixed,
          backgroundColor: MyColors.cardBackgroundColor,
          onTap: (index) {
            setState(() {
              if (index == indexOfPage){
                counter++;
                
              }
              else{
                counter = 0;
              }
              if (counter >= 10){
                MyColors.changeTheme(!MyColors.darkTheme);
                counter = 0;
              }
              indexOfPage = index;
            });
            pageViewController.animateToPage(index,
                duration: const Duration(milliseconds: 50),
                curve: Curves.linear);
          },
          unselectedItemColor: MyColors.fontColor,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Отметить"),
            BottomNavigationBarItem(
                icon: Icon(Icons.functions), label: "Сводник"),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt), label: "Расписание"),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: "Группа")
          ],
          selectedItemColor: MyColors.buttonColor,
        ));
  }
}
