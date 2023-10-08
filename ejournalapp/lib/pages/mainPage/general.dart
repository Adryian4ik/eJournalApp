import 'dart:convert';


import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class GeneralInfo{
  String _host = "http://45.8.230.244/";
  List? Students = null;
  Map? Schedule = null;
  Function()? postInit;
  Function()? init;
  String _group = "";
  int _groupId = 0;
  String _token = "";
  int _bossId = 0;
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  SharedPreferences? valueSource;

  GeneralInfo(){
    init = initApiInfo;
    
    prefs.then((value){
      _group = value.getString("Group") ?? "";
      _token = value.getString("Token") ?? "";
      _groupId = value.getInt("GroupId") ?? 0;
      _bossId = value.getInt("BossId") ?? 0;
      init!();
    });
  }

  setCallback(Function() fn){
    postInit = fn;
  }

  initApiInfo(){
    http.get(
      Uri.parse('${_host}groupinfo'),
      headers: {"Authorization":"Bearer ${_token}"}
    ).then((httpResponse){
      var response = jsonDecode(utf8.decode(httpResponse.body.codeUnits));
      if (response["detail"] is List){
        Students = response["detail"];  
      }
      isAllInfoGet();
    });


    http.get(
      Uri.parse('${_host}schedule/$_groupId'),
    ).then((httpResponse){
      var response = jsonDecode(utf8.decode(httpResponse.body.codeUnits));
      if (response["detail"] is Map){
        Schedule = response["detail"];   
      }
      isAllInfoGet();
    });
  }


  isAllInfoGet(){
    
    if ((Students != null) && (Schedule != null)){
      postInit!();
    }
  }
  


}