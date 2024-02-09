import 'package:chat/View/Home.dart';
import 'package:chat/View/formFiled.dart';
import 'package:chat/View/signup.dart';
import 'package:chat/services/database_IO.dart';
import 'package:chat/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {

  bool previous; // 0 is StartPage & 1 is SignUp page
  Login({super.key, required this.previous});

  @override
  State<StatefulWidget> createState() => LoginState();
}
class LoginState extends State<Login>{
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  late bool connecting;
  @override
  void initState() {
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    connecting = false;
    super.initState();
  }
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / 20),
          child: ListView(
            children: <Widget>[
              (MediaQuery.of(context).viewInsets.bottom<=0)?Image.asset(
                    "assets/images/logo.png",
                    width: width / 2,
                  ):const SizedBox.shrink(),
              Text("Login to your account",style: GoogleFonts.poppins(
                      fontSize: (height + width) / 50,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
              CustomFormField(controller: usernameController,hintText: "Username",page: false),
              CustomFormField(controller: passwordController,hintText: "Password",page: false),
              SizedBox(height: height/50),
              SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: connecting?null:() async{
                            setState(() {
                              connecting = true;
                            });
                            if(!await DatabaseIO.establishConnection(usernameController.text, passwordController.text)){
                              setState(() {
                                connecting = false;
                              });
                              // ignore: use_build_context_synchronously
                              _showDialog(context);
                            }else{
                              await LocalStorage.setUserId(DatabaseIO.getCurrentUser().userID);
                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Home()),
                              );
                            }
                          },
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.all(height / 80)),
                              elevation: MaterialStateProperty.all<double>(5),
                              shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Button's border radius
                                ),
                              ),
                              backgroundColor: connecting?MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 231, 231, 231)):
                              MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 248, 99, 0)
                              !)),
                          child: !connecting?Text(
                            "Sign in",
                            style: GoogleFonts.poppins(
                                fontSize: (width + height) / 75,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ):Image.asset("assets/gifs/loading.gif"
                          ,width: height*0.04,height: height*0.04,)
                      )),
              SizedBox(height: height/40),
              Text("or sign in with",style: GoogleFonts.poppins(
                      fontSize: (height + width) / 100,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
              SizedBox(height: height/40),
              Padding(padding: EdgeInsets.symmetric(horizontal: width/5),child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[InkWell(
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
                    ),])),
              SizedBox(height: height/40),
              Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                Text(
                  "Don't have an account?",
                  style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: (height + width) / 100,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                TextButton(onPressed: (){
                  (widget.previous)?Navigator.pop(context):
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp(previous: true)),
                  );
                }, child: Text(
                  "Sign up",
                  style: GoogleFonts.poppins(
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.deepOrange, // Optional: Set the underline color
                      decorationThickness: 2.0,
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
  Future<void> _showDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wrong Credentials'),
          content: const Text(
            'Invalid username or password',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
