
import 'dart:async';

import 'package:chat/View/dimensions.dart';
import 'package:chat/View/messagebubble.dart';
import 'package:chat/services/database_IO.dart';
import 'package:chat/services/messages_streams.dart';
import 'package:chat/model/message.dart';
import 'package:chat/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Conversation extends StatefulWidget {
  final User receiver;


  const Conversation({Key? key, required this.receiver})
      :
        super(key: key);

  @override
  State<StatefulWidget> createState() => _ConversationState();
}
class _ConversationState extends State<Conversation>{
  late final Stream<Message> stream;
  late TextEditingController controller;
  late final User receiver;
  late final double height,width;
  final Set<Message> _messages = <Message>{};
  bool error = false;
  late ScrollController _scrollController;
  late StreamController<bool> _scrollToBottomController;
  bool firstScroll = true;

  @override
  void initState() {
    height = 1000;//Dimensions.height;
    width = 500;//Dimensions.width;
    controller = TextEditingController();
    stream = DatabaseIO.getMessages();
    receiver = widget.receiver;
    //_scrollController = ScrollController();
    //_scrollToBottomController = StreamController<bool>.broadcast();
    /*_scrollToBottomController.stream.listen((scrollToBottom) {
      if (scrollToBottom) {
        scrollToEnd();
      }
    });*/
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    //_scrollController.dispose();
    _scrollToBottomController.close(); // Close the stream controller
    super.dispose();
  }

  void scrollToEnd() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if(firstScroll){
          firstScroll = false;
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        else{
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent+height/40,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    try{DatabaseIO.listenForMessagesUpdates(receiver.userID);}catch(_){error = true;}
    MessagesStream.clearStreams();
    return WillPopScope(child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.grey[200],
          leading: Padding(padding: const EdgeInsets.all(5),child: ClipOval(
            child: Image.network(
              receiver.logo,
              width: (width + height) / 55, // Adjust the width as needed
              height: (width + height) / 55, // Adjust the height as needed
              fit: BoxFit.cover,
            ),
          ),),
          title: Text(
            receiver.username,
            style: GoogleFonts.montserrat(
              fontSize: height / 50,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.videocam_outlined,
                color: Colors.grey,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call_outlined, color: Colors.grey),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu, color: Colors.grey),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                flex: 9,
                child: FutureBuilder<List<Message>>(
                  future: DatabaseIO.fetchLast10Messages(receiver.userID),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Show loading indicator while waiting for the future to complete
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      // Show error message if an error occurred
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    else if(snapshot.data!.isEmpty){
                      return const Center(
                        child: Text('No messages found'),
                      );
                    }
                    else {
                        _messages.addAll(snapshot.data!);
                        //_scrollToBottomController.add(true);
                    return StreamBuilder<Message>(
                      stream: stream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData) {
                          return const Center(child: Text('shit.'));
                        } else {
                          Message msg = snapshot.data!;
                          _messages.add(msg);
                          //_scrollToBottomController.add(true);

                          return ListView.builder(
                           // controller: _scrollController,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              Message msg =_messages.toList()[index];
                              // You can now use userData to display information about the user

                              return MessageBubble(message: msg);

                            },
                          );
                        }
                      },
                    );
                      }
                  },
                )
            ),

            Padding(padding: EdgeInsets.all(width/50),child: Row(
              children: [
                Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0),bottomLeft: Radius.circular(10.0)),
                      color: Colors.grey[
                      200], // You can set the background color as needed
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset("assets/icons/emoji.svg"),
                    )),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: InputBorder.none
                    ),
                    controller: controller
                  ),
                ),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(10.0),bottomRight: Radius.circular(10.0)),
                      color: Colors.grey[
                      200], // You can set the background color as needed
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.image_outlined,color: Colors.grey,),
                    )),
                SizedBox(width: width / 50),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.deepOrange[100], // You can set the background color as needed
                    ),
                    child: IconButton(
                      onPressed: () async{
                        if(controller.text != ""){
                          await DatabaseIO.insertMessage(receiver,controller.text,"text");
                          if(error){
                            DatabaseIO.listenForMessagesUpdates(receiver.userID);
                            error = false;
                          }
                          if(_messages.isEmpty){
                            setState(() {

                            });
                          }
                          controller.clear();
                        }
                      },
                      icon: const Icon(Icons.send,color: Colors.deepOrange,),
                    ))
              ],
            ),)
          ],
        )
    ), onWillPop: ()async{MessagesStream.clearStreams();return true;});
  }

}
