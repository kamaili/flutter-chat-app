import 'package:chat/View/login.dart';
import 'package:chat/View/profilePicture.dart';
import 'package:chat/services/database_IO.dart';
import 'package:chat/services/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:chat/View/formFiled.dart';

class SignUp extends StatelessWidget {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController password2Controller = TextEditingController();
  bool previous; // 0 is StartPage & 1 is Login page
  SignUp({super.key, required this.previous});
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Padding(
      padding: EdgeInsets.symmetric(horizontal: width / 20),
      child: ListView(
        children: <Widget>[
          (MediaQuery.of(context).viewInsets.bottom <= 0)
              ? Image.asset(
                  "assets/images/logo.png",
                  width: width / 2,
                )
              : const SizedBox.shrink(),
          Text(
            "Create your account",
            style: GoogleFonts.poppins(
                fontSize: (height + width) / 50,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          CustomFormField(
              controller: usernameController, hintText: "Username", page: true),
          CustomFormField(
              controller: emailController,
              hintText: "Email address",
              page: true),
          CustomFormField(
              controller: passwordController, hintText: "Password", page: true),
          CustomFormField(
              controller: password2Controller,
              hintText: "Confirm Password",
              page: true),
          SizedBox(height: height / 50),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () async {
                    String username = usernameController.text;
                    String email = emailController.text;
                    String pwd = passwordController.text;
                    String pwd2 = password2Controller.text;
                    final RegExp usernameRegex =
                        RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9_.-]{3,15}$');
                    if (!usernameRegex.hasMatch(username)) {
                      context.read<MyProvider>().validateUsername(false);
                      usernameController.clear();
                      return;
                    }
                    if (!EmailValidator.validate(email)) {
                      context.read<MyProvider>().validateEmail(false);
                      return;
                    }
                    if (pwd.length < 6) {
                      context.read<MyProvider>().validatePwd(false);
                      return;
                    }
                    if (pwd != pwd2) {
                      context.read<MyProvider>().validateConfirmation(false);
                      return;
                    }
                    if (!await DatabaseIO.isUsernameAvailable(
                        usernameController.text)) {
                      usernameController.clear();
                      // ignore: use_build_context_synchronously
                      context.read<MyProvider>().setExistance(true);
                    } else {
                      DatabaseIO.createUser(usernameController.text,
                          emailController.text, passwordController.text);
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePicture()),
                      );
                    }
                  },
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          EdgeInsets.all(height / 80)),
                      elevation: MaterialStateProperty.all<double>(5),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Button's border radius
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 248, 99, 0)!)),
                  child: Text(
                    "Create account",
                    style: GoogleFonts.poppins(
                        fontSize: (width + height) / 75,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ))),
          SizedBox(height: height / 40),
          Text(
            "or sign up with",
            style: GoogleFonts.poppins(
                decorationColor:
                    Colors.blue, // Optional: Set the underline color
                decorationThickness: 2.0,
                fontSize: (height + width) / 100,
                fontWeight: FontWeight.w700,
                color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: height / 40),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      child: SvgPicture.asset("assets/icons/facebook_ic.svg",
                          width: width / 100, height: height / 25),
                      onTap: () {},
                    ),
                    InkWell(
                      child: SvgPicture.asset("assets/icons/google_ic.svg",
                          width: width / 100, height: height / 25),
                      onTap: () {},
                    ),
                    InkWell(
                      child: SvgPicture.asset("assets/icons/linked_ic.svg",
                          width: width / 100, height: height / 25),
                      onTap: () {},
                    ),
                  ])),
          SizedBox(height: height / 40),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text(
              "Already have account?",
              style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: (height + width) / 100,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            TextButton(
                onPressed: () {
                  context.read<MyProvider>().reset();
                  (previous)
                      ? Navigator.pop(context)
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Login(previous: true)),
                        );
                },
                child: Text(
                  "Login",
                  style: GoogleFonts.poppins(
                      decoration: TextDecoration.underline,
                      color: Colors.deepOrange,
                      fontSize: (height + width) / 80,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ))
          ])
        ],
      ),
    ));
  }
}
