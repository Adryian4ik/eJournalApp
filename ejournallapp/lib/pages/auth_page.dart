import 'dart:async';

import 'package:ejournallapp/services/api_service.dart';
import 'package:ejournallapp/services/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return AuthPageState();
  }
}

class AuthPageState extends State<AuthPage> {
  TextEditingController id = TextEditingController();
  TextEditingController token = TextEditingController();
  String errorText = "";
  @override
  void initState() {
    super.initState();
    goToHome();
  }

  void goToHome() {
    Auth.isLogin.then((value) {
      if (value) {
        Timer(const Duration(milliseconds: 500), () {
          Navigator.pushReplacementNamed(context, '/Home');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.headerColor,
        title: Text(
          "Авторизация",
          style: TextStyle(color: MyColors.fontColor),
        ),
      ),
      backgroundColor: MyColors.backgroundColor,
      body: Center(
        child: FutureBuilder(
            future: Auth.isLogin,
            builder: ((cont, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  color: MyColors.progressBarColor,
                );
              } else if (snapshot.hasError) {
                return Text(
                  "Произошла ошибка",
                  style: TextStyle(
                      color: MyColors.errorMessageColor, fontSize: 18),
                );
              }
              if (snapshot.data!) {
                goToHome();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "eJournal",
                      style: TextStyle(fontSize: 30, color: MyColors.fontColor),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Icon(
                      Icons.lock_open,
                      size: 50,
                      color: Colors.green,
                    )
                  ],
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      errorText,
                      style: TextStyle(
                          fontSize: 25, color: MyColors.errorMessageColor),
                    ),
                    TextField(
                      controller: id,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Введите номер зачетки',
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
                      controller: token,
                      style: const TextStyle(
                          color:
                              Colors.white), // Устанавливаем белый цвет текста
                      decoration: const InputDecoration(
                        labelText: 'Введите код',
                        labelStyle: TextStyle(
                            color: Colors
                                .white), // Устанавливаем белый цвет надписи
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .white), // Устанавливаем белый цвет границы
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .white), // Устанавливаем белый цвет при фокусе
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton.icon(
                        onPressed: () {
                          Auth.signIn(int.parse(id.text), token.text)
                              .then((value) {
                            if (value) {
                              errorText = "";

                              goToHome();
                            } else {
                              errorText = "Неверные данные";
                            }
                          });
                          setState(() {});
                        },
                        icon: const Icon(Icons.lock),
                        label: Text(
                          "Войти",
                          style: TextStyle(
                              backgroundColor: MyColors.buttonColor,
                              color: MyColors.fontColor,
                              fontSize: 18),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) => MyColors.buttonColor),
                            foregroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.white),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10)))),
                  ],
                );
              }
            })),
      ),
    );
  }
}
