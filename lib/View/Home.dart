import 'dart:io';

import 'package:chat/View/ListTile.dart';
import 'package:chat/View/invite.dart';
import 'package:chat/View/userListView.dart';
import 'package:chat/services/database_IO.dart';
import 'package:chat/services/provider.dart';
import 'package:chat/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  final User user = DatabaseIO.getCurrentUser();

  @override
  Widget build(BuildContext context) {
    DatabaseIO.listenForUpdates();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final selectedButtonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.all(height / 55)),
      elevation: MaterialStateProperty.all<double>(10),
      backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      textStyle: MaterialStateProperty.all(GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: (height + width) / 100,
          fontWeight: FontWeight.bold)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Button's border radius
        ),
      ), // Set text color
    );
    final unselectedButtonStyle = ButtonStyle(
      elevation: MaterialStateProperty.all<double>(0),
      backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange[50]!),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange),
      textStyle: MaterialStateProperty.all(GoogleFonts.montserrat(
          color: Colors.deepOrange,
          fontSize: (height + width) / 100,
          fontWeight: FontWeight.bold)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Button's border radius
        ),
      ), // Set text color
    );

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(height / 10),
          child: AppBar(automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            title: Text("HALODEK",
                style: GoogleFonts.montserrat(
                    fontSize: height / 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrangeAccent)),
            actions: [
              IconButton(
                  onPressed: () {

                  },
                  icon: SvgPicture.asset("assets/icons/search_ic.svg")),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
            ],
          ),
        ),
        body: Consumer<MyProvider>(builder: (context, provider, child) {
          return Container(
            padding: EdgeInsets.all(width / 25),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(height / 185),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.deepOrange[50]),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: FilledButton(
                        onPressed: () {
                          provider.changeActiveField(0);
                        },
                        style: provider.activeField == 0
                            ? selectedButtonStyle
                            : unselectedButtonStyle,
                        child: const Text('Chat'),
                      )),
                      Expanded(
                          child: FilledButton(
                        onPressed: () {
                          provider.changeActiveField(1);
                        },
                        style: provider.activeField == 1
                            ? selectedButtonStyle
                            : unselectedButtonStyle,
                        child: const Text('Status'),
                      )),
                      Expanded(
                          child: FilledButton(
                        onPressed: () {
                          provider.changeActiveField(2);
                        },
                        style: provider.activeField == 2
                            ? selectedButtonStyle
                            : unselectedButtonStyle,
                        child: const Text('Calls'),
                      )),
                    ],
                  ),
                ),
                SizedBox(height: height/90),
                const Expanded(child: UserListView())
              ],
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Invite())
            );
          }, // Icon for the "+" symbol
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white, // Set the background color
          shape: const CircleBorder(),
          child: const Icon(Icons.add), // Make it circular
        ));
  }
}
