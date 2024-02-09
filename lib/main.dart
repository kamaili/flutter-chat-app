/**import 'package:chat/View/Home.dart';
import 'package:chat/View/startPage.dart';
import 'package:chat/services/local_storage.dart';
import 'package:chat/services/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'View/dimensions.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAiWsXauh0ahMl_QH2FPMbX8pjIaUuRyPw",
      appId: "1:1006894065167:android:8f86e27a34f98cc68f257a",
      projectId: "chat-ae387",
      messagingSenderId: '1006894065167',
    ),
  );
  runApp(ChangeNotifierProvider(
    create: (context) => MyProvider(),
    child: const MyApp(),
  ));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    //Dimensions.setDimensions(context);
    return MaterialApp(
        title: "aymen",home:
      FutureBuilder<String>(
      future: LocalStorage.getUserId(), // Assuming getUserId returns a Future<String>
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while data is being fetched
          return Scaffold(body: Center(child: Image.asset("assets/gifs/loading.gif")));
        } else if (snapshot.hasError) {
          // Handle error if any
          return Text('Error: ${snapshot.error}');
        } else {
          // Data fetched successfully, now build the UI
          String userID = snapshot.data ?? "";
          return userID.isEmpty ? const StartPage() : Home();
        }
      },
    ));
  }
}
*/
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message Pagination Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MessageScreen(),
    );
  }
}

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ScrollController _scrollController = ScrollController();
  List<String> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadInitialMessages();
    _scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void loadInitialMessages() {
    setState(() {
      isLoading = true;
    });
    // Simulating loading initial messages
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        messages = List.generate(20, (index) => 'Message ${20 - index + 1}');
        isLoading = false;
      });
    });
  }

  void loadMoreMessages() {
    setState(() {
      isLoading = true;
    });
    // Simulating loading more messages
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        List<String> j = (List.generate(20, (index) => 'Message ${messages.length - index + 1}'));
        j.addAll(messages);
        messages = j;
        isLoading = false;
      });
    });
  }

  void scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.minScrollExtent) {
      loadMoreMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Pagination Demo'),
      ),
      body: Column(
        children: [
          if (isLoading) CircularProgressIndicator(), // Show the indicator at the top if loading
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + 1,
              itemBuilder: (context, index) {
                if (index < messages.length) {
                  return ListTile(title: Text(messages[index]));
                } else {
                  return Center();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
