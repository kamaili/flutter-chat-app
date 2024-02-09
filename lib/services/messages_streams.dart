import 'package:chat/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class MessagesStream{

  //static Map<String,BehaviorSubject<Message>> streamsMap = {};
  static Map<String,Stream<Message>> streams = {};

  static void addStream(Message msg,String currentID){
    DocumentReference messageRef =
    FirebaseFirestore.instance.collection('messages').doc(msg.messageID);
    // Return the snapshots stream of the document
    streams[msg.messageID!] = messageRef.snapshots().map((snapshot) {
      // Convert the document snapshot to a Message object
      return Message.fromJson(snapshot.data() as Map<String,dynamic>,currentID,messageRef.id);
    });
  }
  static void clearStreams(){
    streams.clear();
  }
}