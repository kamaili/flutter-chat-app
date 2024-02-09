
import 'dart:math';
import 'dart:ui';

import 'package:chat/services/database_IO.dart';
import 'package:chat/services/messages_streams.dart';
import 'package:chat/services/provider.dart';
import 'package:chat/model/message.dart';
import 'package:chat/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MessageBubble extends StatefulWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  State<StatefulWidget> createState() => MessageBubbleState();
}
  class MessageBubbleState extends State<MessageBubble>{
  bool feeling = false;
  late String feelingStr;
  void refresh(String str)async{
    String update = (feelingStr == str)?"":str;
    setState((){
      feelingStr = update;
      feeling = false;
    });
    await DatabaseIO.changeFeeling(widget.message, update);
  }
  @override
  void initState() {
    feelingStr = widget.message.feeling;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    
    return  StreamBuilder<Message>(
      stream: MessagesStream.streams[widget.message.messageID],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }else{
        Message message = snapshot.data!;
        feelingStr = message.feeling;
        final double width = MediaQuery.of(context).size.width;
        final double height = MediaQuery.of(context).size.height;
        final InkWell baseContainer = InkWell(child: Container(
          margin: EdgeInsets.symmetric(horizontal: width*0.03),
          constraints: BoxConstraints(maxWidth: width*0.7),
          padding: EdgeInsets.all(width / 40),
          decoration: BoxDecoration(
              color: feeling? Colors.yellowAccent:message.sended ? Colors.deepOrange : Colors.grey[200],
              borderRadius: BorderRadius.circular(7.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[400]!, // You can set the shadow color
                  offset: const Offset(0, 2), // Specify the offset of the shadow
                  blurRadius: 4.0, // Set the blur radius of the shadow
                  spreadRadius: 1.0, // Set the spread radius of the shadow
                ),
              ]),
          child: Text(
            message.message,
            style: GoogleFonts.montserrat(
              fontSize: width / 30,
              fontWeight: FontWeight.bold,
              color: feeling? Colors.deepOrange : message.sended ? Colors.white : Colors.black,
            ),
          ),
        ),
            onLongPress: () {
              setState(() {
                feeling = !feeling;
              });
            });

        // I don't know how it works hhhh

        Padding time = Padding(
            padding: EdgeInsets.only(left: width*0.04,right: width*0.04,bottom: height*0.02),
          child:Text('${message.timestamp.hour}:${message.timestamp.minute}',style: TextStyle(fontSize: width*0.02),));
        Widget feelWidget = feeling?Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              feelIconWidget("love", width, message),
              feelIconWidget("happy", width, message),
              feelIconWidget("surprised", width, message),
              feelIconWidget("sad", width, message),
              feelIconWidget("angry", width, message)
            ],
          ):const SizedBox.shrink();
        final Widget feelingIcon = feelingStr!=""?ClipOval(
            child: SvgPicture.asset(
              "assets/icons/$feelingStr.svg",
              width: width / 18,
              height: width / 18,
            )):const SizedBox.shrink();

        return Column(crossAxisAlignment: message.sended?CrossAxisAlignment.end:CrossAxisAlignment.start,
            children: <Widget>[
                Row(mainAxisAlignment: message.sended?MainAxisAlignment.end:MainAxisAlignment.start,
                  children: <Widget>[
                  message.sended?feelingIcon:baseContainer,
                  message.sended?baseContainer:feelingIcon,
                ],),
                feeling?feelWidget:time
              ]);
        }
      },
    );

  }
  Widget feelIconWidget(String feel, width, Message message){
    return InkWell(child: Container(margin: EdgeInsets.all(width*0.01),padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: feelingStr==feel?Colors.yellow:null,borderRadius: BorderRadius.circular(50),
          border: const Border.fromBorderSide(BorderSide(color: Colors.deepOrange))),
    child: SvgPicture.asset(
    "assets/icons/$feel.svg",
    width: width / 10,
    height: width / 10,
    )),onTap: ()async{refresh(feel);
    });
  }
}
