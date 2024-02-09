
import 'package:chat/services/database_IO.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage{
  static Future<String> getUserId()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? id = prefs.getString('userID');
    if(id != null && id !=""){
      await DatabaseIO.loadUser(id!);
    }
    return id ?? "";
  }
  static Future<void> setUserId(String id)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('userID', id);
  }


}