import 'dart:convert';

import 'package:ejournallapp/services/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String host = "http://45.8.230.244/";

class Group {
  static int groupId = -1;
  static String groupName = "";
  static String token = "";
  static int bossId = -1;
  static List students = [];

  static Future<bool> isLoaded = initData();

  static update() {
    isLoaded = initData();
  }

  static Future<bool> initData() async {
    if (!(await Auth.isLogin)) {
      // вернуться на экран входа
      return false;
    }
    if (groupId == -1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString("info") == null) {
        throw "0, Ошибка получения данных о группе";
      }
      String jsonString = prefs.getString("info")!;
      dynamic data = jsonDecode(jsonString);
      groupName = data["groupName"];
      groupId = data["groupId"];
      token = data["token"];
      bossId = data["bossId"];
    }
    final response = await http.get(Uri.parse('${host}groupinfo'),
        headers: {"Authorization": "Bearer $token"});
    final responseBody = jsonDecode(utf8.decode(response.body.codeUnits));
    if (response.statusCode != 200) {
      return false;
    }
    groupId = 10; //??? убрать потом
    students = responseBody['detail'];
    return true;
  }

  /*

  Group.addStudent({
    "id": 210500,
    "tgId": null,
    "groupId": 10,
    "lastname": "АБоба",
    "firstname": "Авова",
    "patronymic": "Агога"
  })
  
  */
  static Future<bool> addStudent(Map studentInfo) {
    return Future(() async {
      final response = await http.post(Uri.parse('${host}student'),
          headers: {
            "Authorization": "Bearer $token",
            "Content-type": "application/json"
          },
          body: jsonEncode(studentInfo));

      if (response.statusCode != 201) {
        return false;
      }
      update();
      return true;
    });
  }

  /*

  Group.deleteStudent({
      "id": 210500,
  })

  */
  static Future<bool> deleteStudent(Map studentInfo) {
    return Future(() async {
      if (!studentInfo.containsKey("groupId")) {
        studentInfo["groupId"] = groupId;
      }
      final response = await http.delete(Uri.parse('${host}student'),
          headers: {
            "Authorization": "Bearer $token",
            "Content-type": "application/json"
          },
          body: jsonEncode(studentInfo));
      if (response.statusCode != 200) {
        return false;
      }
      update();
      return true;
    });
  }

  /*
  
  Group.updateStudent({
    "id": 210500,
    "tgId": null,
    "groupId": 10,
    "lastname": "АБоба,,,,,,,,,,,,,,,,,",
    "firstname": "Авова",
    "patronymic": "Агога"
  })

   */
  static Future<bool> updateStudent(Map newStudentInfo) {
    return Future(() async {
      final response = await http.patch(Uri.parse('${host}student'),
          headers: {
            "Authorization": "Bearer $token",
            "Content-type": "application/json"
          },
          body: jsonEncode(newStudentInfo));
      if (response.statusCode != 200) {
        return false;
      }
      update();
      return true;
    });
  }

  static Future<Map> getStudent(int id) async {
    if (!(await isLoaded)) {
      update();
      return getStudent(id);
    }
    return Future(() async {
      await isLoaded;
      for (var student in students) {
        if (student["id"] == id) {
          return student;
        }
      }
      return {};
    });
  }
}

class Schedule {
  static Map schedule = {};

  static Future<bool> isLoaded = initData();
  static Map<int, String> weekTypes = {0: "Верхняя", 1: "Нижняя"};
  static List<String> weekDays = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье'
  ];
  static DateTime date = DateTime.now();

  static update() {
    getAllLessons();
    isLoaded = initData();
  }

  static Future<bool> initData() async {
    if (date.weekday == 7) {
      date = date.add(const Duration(days: -1));
    }
    bool isGroupLoaded = await Group.isLoaded;
    if (!isGroupLoaded) {
      Group.update();
      return initData();
    }
    final response = await http.get(
        Uri.parse('${host}schedule/${Group.groupId}'),
        headers: {"Authorization": "Bearer ${Group.token}"});
    final responseBody = jsonDecode(utf8.decode(response.body.codeUnits));
    if (response.statusCode != 200) {
      return false;
    }
    schedule = responseBody['detail'];

    for (var key1 in schedule.keys) {
      for (var key2 in schedule[key1].keys) {
        for (int i = 0; i < schedule[key1][key2].length; i++) {
          if (schedule[key1][key2][i] is Map) {
            schedule[key1][key2][i] = [schedule[key1][key2][i]];
          }
        }
      }
    }

    return true;
  }

  /*

  {
    "id": 0,
    "groupId": 0,
    "lessonId": 0,
    "dayOfWeek": 0,
    "week": 0,
    "numberOfLesson": 0,
    "type": 0,
    "subgroup": 0,
    "dates": [
      "string"
    ],
    "mask": [
      0
    ],
    "auditorium": "string"
  }

  */

  static Future<bool> addLesson(Map scheduleInfo,
      [Map lessonInfo = const {}]) async {
    if (!mapEquals(lessonInfo, {})) {
      final response = await http.post(Uri.parse('${host}lesson'),
          headers: {
            "Authorization": "Bearer ${Group.token}",
            "Content-type": "application/json"
          },
          body: jsonEncode(lessonInfo));
      final responseBody = jsonDecode(utf8.decode(response.body.codeUnits));
      if (response.statusCode != 201) {
        return false;
      }
      lessonInfo = responseBody['detail'];
    }
    if (scheduleInfo['lessonId'] == null) {
      scheduleInfo['lessonId'] = lessonInfo['id'];
    }
    final response = await http.post(Uri.parse('${host}schedule'),
        headers: {
          "Authorization": "Bearer ${Group.token}",
          "Content-type": "application/json"
        },
        body: jsonEncode(scheduleInfo));
    // final responseBody = jsonDecode(utf8.decode(response.body.codeUnits));
    if (response.statusCode != 200) {
      return false;
    }
    update();
    return true;
  }

  static iterationByTime(int value) {
    date = date.add(Duration(days: value));
    if (date.weekday == 7) {
      date = date.add(Duration(days: value));
    }
    Pass.update();
  }

  static setDate(DateTime newDate) {
    date = newDate;
    if (date.weekday == 7) {
      date = date.add(const Duration(days: -1));
    }
    Pass.update();
  }

  static List getScheduleForDay(int weekType, int weekDay) {
    return schedule[weekTypes[weekType]][weekDays[weekDay]];
  }

  static List getCurrentSchedule() {
    return schedule[weekTypes[0]][weekDays[date.weekday - 1]];
  }

  static List<DropdownMenuItem> lessons = [];

  static updateLessons() {}

  static Future<bool> getAllLessons() {
    return Future(() async {
      final response = await http.get(Uri.parse('${host}lesson'),
          headers: {"Authorization": "Bearer ${Group.token}"});
      final responseBody = jsonDecode(utf8.decode(response.body.codeUnits));
      if (response.statusCode != 200) {
        return false;
      }
      lessons = [];
      List lessonsList = responseBody['detail'];

      for (var lesson in lessonsList) {
        lessons.add(DropdownMenuItem(
          value: lesson['id'],
          child: Text(
            lesson['name'],
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: MyColors.fontColor),
          ),
        ));
      }

      lessons.add(DropdownMenuItem(
        value: -1,
        child: Text(
          "Другой предмет",
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: MyColors.fontColor),
        ),
      ));
      return true;
    });
  }
}

class Pass {
  static List passes = [];

  static Future<bool> isLoaded = initData();

  static update() {
    isLoaded = initData();
  }

  static Future<bool> initData() async {
    bool isScheduleLoaded = await Schedule.isLoaded;
    bool isGroupLoaded = await Schedule.isLoaded;
    if (!isScheduleLoaded) {
      Schedule.update();
      return initData();
    }
    if (!isGroupLoaded) {
      Group.update();
      return initData();
    }
    final response = await http.get(
        Uri.parse(
            '${host}pass?start=${DateFormat("yyyy-MM-dd").format(Schedule.date)}&end=${DateFormat("yyyy-MM-dd").format(Schedule.date)}&groupId=${Group.groupId}'),
        headers: {"Authorization": "Bearer ${Group.token}"});
    final responseBody = jsonDecode(utf8.decode(response.body.codeUnits));
    if (response.statusCode != 200) {
      return false;
    }
    passes = responseBody['detail'];
    return true;
  }

  static Future<List> getPassesByPeriod(DateTime startDate, DateTime endDate) {
    return Future(() async {
      final response = await http.get(
          Uri.parse(
              '${host}pass?start=${DateFormat("yyyy-MM-dd").format(startDate)}&end=${DateFormat("yyyy-MM-dd").format(endDate)}&groupId=${Group.groupId}'),
          headers: {"Authorization": "Bearer ${Group.token}"});
      final responseBody = jsonDecode(utf8.decode(response.body.codeUnits));
      if (response.statusCode != 200) {
        return [];
      }
      return responseBody["detail"];
    });
  }

  static Future<List> getPassesOfStudentByPeriod(
      int id, DateTime startDate, DateTime endDate) {
    return Future(() async {
      final response = await http.get(
          Uri.parse(
              '${host}pass/$id?start=${DateFormat("yyyy-MM-dd").format(startDate)}&end=${DateFormat("yyyy-MM-dd").format(endDate)}&groupId=${Group.groupId}'),
          headers: {"Authorization": "Bearer ${Group.token}"});
      final responseBody = jsonDecode(utf8.decode(response.body.codeUnits));
      if (response.statusCode != 200) {
        return [];
      }
      return responseBody["detail"];
    });
  }

  static Future<bool> addPass(Map passInfo) {
    return Future(() async {
      final response = await http.post(Uri.parse('${host}pass'),
          headers: {
            "Authorization": "Bearer ${Group.token}",
            "Content-type": "application/json"
          },
          body: jsonEncode(passInfo));

      if (response.statusCode != 201) {
        return false;
      }
      update();
      return true;
    });
  }

  static Future<bool> deletePass(int id) {
    return Future(() async {
      final response = await http.delete(
        Uri.parse('${host}pass/$id'),
        headers: {
          "Authorization": "Bearer ${Group.token}",
        },
      );
      if (response.statusCode != 200) {
        return false;
      }
      update();
      return true;
    });
  }

  static Future<bool> updatePass(Map passInfo, int newType) {
    Map newPassInfo = Map.from(passInfo);
    return Future(() async {
      var response = await deletePass(passInfo['id']);
      if (!response) {
        return false;
      }
      newPassInfo['type'] = newType;
      response = await addPass(newPassInfo);
      if (!response) {
        await addPass(passInfo);
        return false;
      }
      return true;
    });
  }
}

class Auth {
  static Future<bool> isLogin = Future(() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.containsKey('info');
  });

  static Future<bool> signIn(int id, String token) {
    isLogin = Future(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      return prefs.containsKey('info');
    });
    return Future(() async {
      final response = await http.post(Uri.parse('${host}auth/login'),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({"token": token, "id": id}));
      final responseBody = jsonDecode(utf8.decode(response.body.codeUnits));
      if (response.statusCode == 401) {
        return false;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('info', jsonEncode(responseBody));
      isLogin = Future(() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        return prefs.containsKey('info');
      });
      return true;
    });
  }
}
