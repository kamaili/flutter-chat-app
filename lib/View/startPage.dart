import 'package:chat/View/login.dart';
import 'package:chat/View/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
      child: Stack(
        children: [
          Align(alignment: const Alignment(0,-0.4),child: Image.asset(
            "assets/images/appLogo.jpg",
            width: width,
            height: height / 3,
          )),
          Align(alignment: const Alignment(0,0.2),child: Text(
            "Welcome to Halodek",
            style: GoogleFonts.poppins(
                fontSize: (height+width) / 30, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          )),
          Align(alignment: const Alignment(0,0.45),child: Text(
            "Halodek supports sending and receiving a variety of media: text, photos, videos, documents and location, as well as voice calls.",
            style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: (height + width) / 100,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          )),
          Align(alignment: const Alignment(0,0.75),child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp(previous: false)),
                  );
                },
                style: ButtonStyle(
                    padding:
                        MaterialStateProperty.all(EdgeInsets.all(
                            height / 100)),
                    elevation: MaterialStateProperty.all<double>(15),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Button's border radius
                      ),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(const Color.fromARGB(255, 248, 99, 0)!)),
                child: Text(
                  "Let's Get Started",
                  style: GoogleFonts.poppins(
                      fontSize: (width + height) / 75,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                )),
          )),
      Align(alignment: const Alignment(0,0.95),child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
            Text(
              "Already have account?",
              style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: (height + width) / 100,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            TextButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login(previous: false)),
                  );
                },
                child: Text(
              "Login",
              style: GoogleFonts.poppins(
                  color: Colors.deepOrange,
                  fontSize: (height + width) / 80,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ))
          ]))
        ],
      ),
    ));
  }
}
