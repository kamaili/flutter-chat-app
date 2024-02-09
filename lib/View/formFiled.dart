import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/provider.dart';

class CustomFormField extends StatelessWidget{
  static String _pwd = "";
  final TextEditingController controller;
  final String hintText;
  final bool page; // if true = signUp page
  const CustomFormField({super.key,
    required this.controller,
    required this.hintText,
    required this.page});


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    bool exists = context.select((MyProvider provider) => provider.isExists);
    bool validEmail = context.select((MyProvider provider) => provider.isEmailValid);
    bool validPwd = context.select((MyProvider provider) => provider.isPwdValid);
    bool matchesPwd = context.select((MyProvider provider) => provider.isPwdMatches);
    bool validUsername = context.select((MyProvider provider) => provider.isUsernameValid);

    return SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 5,
          child: TextFormField(
            onChanged: (value){
              if(!page){return;}
              context.read<MyProvider>().setExistance(false);
              if(hintText[0] == 'U'){
                if(RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9_.-]{3,15}$').hasMatch(value)){
                  context.read<MyProvider>().validateUsername(true);
                }else{
                  context.read<MyProvider>().validateUsername(false);
                }
                return;
              }
              if(hintText[0] == 'E'){
                if(EmailValidator.validate(value)){
                  context.read<MyProvider>().validateEmail(true);
                }else{
                  context.read<MyProvider>().validateEmail(false);
                }
                return;
              }
              if(hintText[0] == 'P'){
                if(value.length < 6){
                context.read<MyProvider>().validatePwd(false);
                }else{
                  context.read<MyProvider>().validatePwd(true);
                }
                _pwd = value;
                return;
              }
              if(hintText[0] == 'C'){
                if(value != _pwd){
                  context.read<MyProvider>().validateConfirmation(false);
                }else{
                  context.read<MyProvider>().validateConfirmation(true);
                }
              }
            },
            controller: controller,
            obscureText: (hintText[0] == 'P' || hintText[0] == 'C')?true:false,
            style: TextStyle(fontSize: height / 50),
            decoration: InputDecoration(
              hintText: (hintText[0] == "U" && exists && page) ? "Username already exists" :(hintText[0] == "U" && !context.read<MyProvider>().isUsernameValid) ? "Invalid username!" : hintText,
              filled: true,
              fillColor: page && ((hintText[0] == "U" && exists)||
                  (hintText[0] == "E" && !validEmail)||
                  (hintText[0] == "P" && !validPwd)||
                  (hintText[0] == "C" && !matchesPwd)||
                  (hintText[0] == "U" && !validUsername))?Colors.red:Colors.white,
              // Use errorBorder when the condition is true, and enabledBorder otherwise
              border: const OutlineInputBorder(
                borderSide: BorderSide.none, // Customize regular border
              ),
              hintStyle: GoogleFonts.rubik(
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
    );
  }
}