import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message{
  String senderRef,type,message;
  DateTime timestamp;
  String? mediaPath,messageID;
  String feeling = "";
  bool sended = true;
  Message(this.senderRef,this.message,this.type,this.timestamp);
  void setMessageId(String id){messageID = id;}
  void setFeeling(String f){feeling = f;}
  static List<Message> toMessages(List<Map<String, dynamic>> data) {
    List<Message> list = [];
    for (var element in data) { list.add(Message(element["sender_ref"],
      element["content"],
        element["type"],DateTime.now()
        //_toDateTime(element["timestamp"]),
    )); }
    return list;
  }
  static DateTime _toDateTime(dynamic ts) {
      return ts.toDate();
  }
  @override
  String toString() {
    return 'Message { senderRef: $senderRef, type: $type, message: $message, '
        'feeling: $feeling, mediaPath: $mediaPath }';
  }
  factory Message.fromJson(Map<String, dynamic> json,String ID, String msgId) {
    Message msg = Message(
      json['sender_ref'] ?? '',
      json['content'] ?? '',
      json['type'] ?? '',
      (json['timestamp'] as Timestamp).toDate(),
    );
    msg.sended = json['sender_ref'] == ID;
    msg.feeling = json['feeling'];
    msg.setMessageId(msgId);
    return msg;
  }

  @override
  bool operator ==(other) => other is Message && messageID == other.messageID;

  @override
  int get hashCode => messageID.hashCode;

}