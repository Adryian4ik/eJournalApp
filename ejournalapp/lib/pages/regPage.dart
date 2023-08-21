import 'dart:convert';
import "dart:io";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RegPage extends StatefulWidget {
  @override
  _RegPageState createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {  
  TextEditingController _controllerCode = TextEditingController();
  TextEditingController _controllerNumber = TextEditingController();
  String errorMessage = "";
  String _host = "http://45.8.230.244/";
  @override
  Widget build(BuildContext context) {
    _controllerCode.text = "gAAAAABk2jqOsvGtD_SijK2Ey1V2zABEwYX9KgCqaNrNyaJft7eBWpsyTG5b9i96-awBt4d4878fMktwWo3mxe9cNxNbXoBMjg==";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Авторизация'),
        backgroundColor: Color.fromARGB(255, 10, 180, 55),
      ),
      body:  Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Text(
                errorMessage,
                style: const TextStyle(
                  fontSize: 15.0,
                  color: Colors.red
                ),
              ),
              
              SizedBox(
                height: 10,
              ),

              TextField(
                controller: _controllerCode,
                style: const TextStyle(color: Colors.white), // Устанавливаем белый цвет текста
                decoration: const InputDecoration(
                  labelText: 'Введите код',
                  labelStyle: TextStyle(color: Colors.white), // Устанавливаем белый цвет надписи
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет границы
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет при фокусе
                  ),
                ),
                ),

                SizedBox(
                  height: 10,
                ),

                TextField(
                controller: _controllerNumber,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white), // Устанавливаем белый цвет текста
                decoration: const InputDecoration(
                  labelText: 'Введите номер зачетки',
                  labelStyle: TextStyle(color: Colors.white), // Устанавливаем белый цвет надписи
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет границы
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Устанавливаем белый цвет при фокусе
                  ),
                ),
                ),

                SizedBox(
                  height: 10,
                ),

                TextButton(
                  onPressed:  ()async{
                    try {
                      //final result = await InternetAddress.lookup('google.com');
                      //final result = await http.get(Uri.parse('www.google.com'));
                      var result = await Connectivity().checkConnectivity();


                      if (result != ConnectivityResult.none /*result.isNotEmpty && result[0].rawAddress.isNotEmpty*/) {
                        setState((){
                          http.post(
                            Uri.parse('${_host}auth/login'/*?id=${_controllerNumber.text}&code=${_controllerCode.text}'*/),
                            headers: {
                              "Content-type":"application/json"
                            },
                            body: jsonEncode({
                              "token": _controllerCode.text,
                              "id": int.parse(_controllerNumber.text)
                            })
                          ).then((response) async {
                            dynamic answer = json.decode(utf8.decode(response.body.codeUnits));
                            print(answer);
                            if (answer["detail"]=="success"){
                              
                                errorMessage = "";
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setString('Group', answer["groupName"]);
                                await prefs.setString('Token', answer["token"]);
                                await prefs.setInt('GroupId', answer["groupId"]);
                                await prefs.setInt('BossId', answer["bossId"]);
                                Navigator.pushReplacementNamed(context, '/homeScreen');
                            }
                            else{
                              setState((){
                                errorMessage = "Проверьте введенные данные или обратитесь к администраторам";
                              });
                            }
                          });
                        });

                      }
                    } on SocketException catch (_) {
                      setState((){
                        errorMessage = "Проверьте интернет-соединение";
                      });
                    }
                   
                  },
                  child: const Text('Войти'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 10, 180, 55)),
                    foregroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> state){return Colors.white;})
                  )
                
                )
            ],
          )
        )
        
      ),
      backgroundColor: Color.fromARGB(255, 19, 19, 19),   
        

    );
  }


}