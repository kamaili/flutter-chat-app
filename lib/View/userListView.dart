import 'package:chat/View/Conversation.dart';
import 'package:chat/View/ListTile.dart';
import 'package:chat/services/database_IO.dart';
import 'package:chat/model/user.dart';
import 'package:flutter/material.dart';

class UserListView extends StatelessWidget {

  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<User>>(
      stream: DatabaseIO.getFriends(),
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
    );
  }

  }
