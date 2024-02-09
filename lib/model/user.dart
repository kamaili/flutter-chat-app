import 'dart:io';
import 'package:chat/services/database_IO.dart';
import 'package:chat/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  late String _username,_ref;
  late String _logo;

  User({required username}){
    _username = username;
  }
  get logo => _logo;
  get username => _username;
  get userID => _ref;
  User.empty() {
    _username = '';
    //lastReceivedMessages = [];
  }
  set logoImage(String url){_logo = url;}
  set userId(String r){_ref=r;}
  //void addMessage(Message msg){lastReceivedMessages.add(msg);}
  static User snapShotToUser(DocumentSnapshot snapshot){

      User user = User(username: (snapshot.data()! as Map)['username']);
      user.userId = snapshot.id;
      return user;
  }
}