import 'package:chat/View/Conversation.dart';
import 'package:chat/View/ListTile.dart';
import 'package:chat/services/database_IO.dart';
import 'package:chat/model/user.dart';
import 'package:flutter/material.dart';

class Invite extends StatefulWidget {
  const Invite({super.key});

  @override
  State<StatefulWidget> createState() => _InviteState();
}
class _InviteState extends State<Invite>{
  late final TextEditingController controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  // Function to refresh the FutureBuilder
  Future<void> _refresh() async {
    // Use setState to trigger a rebuild of the FutureBuilder
    setState(() {});
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: EdgeInsets.all(width / 50),
          child: Column(
            children: <Widget>[
              TextFormField(onChanged: (_){
                _refresh();
              },
                decoration: InputDecoration(
                    hintText: 'Type username',
                    hintStyle: TextStyle(color: Colors.grey[700]),
                    border:
                        const UnderlineInputBorder(borderSide: BorderSide())),
                controller: controller,
              ),
              Expanded(child: FutureBuilder<List<User>>(
                future: DatabaseIO.getUsersByUsername(controller.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        User user =
                        snapshot.data![index];
                        // You can now use userData to display information about the user
                        return InkWell(child: ListElement(name: user.username,status: "Typing...",
                            imagePath: user.logo,time: "14:28"
                          // Add other fields as needed
                        ),onTap: (){Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Conversation(receiver: user)));});
                      },
                    );
                  }
                },
              ))
            ],
          ),
        ));
  }
}
