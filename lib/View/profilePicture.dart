import 'dart:io';
import 'package:chat/View/Home.dart';
import 'package:chat/services/database_IO.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  ProfilePictureState createState() =>
      ProfilePictureState();
}

class ProfilePictureState
    extends State<ProfilePicture> {
  File? _selectedImage;
  late bool loading;

  @override
  void initState(){
    loading = false;
    super.initState();
  }
  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(actions: [Padding(padding: const EdgeInsets.all(10),
          child:ElevatedButton(onPressed: (){},
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red[100]),
          foregroundColor: MaterialStateProperty.all(Colors.deepOrange)),
          child: const Text("skip"),))],),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImage != null
                ? CircleAvatar(
              radius: width/3,
              backgroundImage: FileImage(_selectedImage!),
            )
                : const CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            SizedBox(height: height/20),
            Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
              IconButton(
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange)
                ),
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt_outlined,size: width/7),
              ),
              SizedBox(width: width/5),
              IconButton(
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange)
                ),
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.image_outlined,size: width/7,),
              )
            ],),
            SizedBox(height: height/20),
            _selectedImage != null?SizedBox(
                width: width/1.5,
                child: ElevatedButton(
                    onPressed: ()async{
                      setState(() {
                        loading = true;
                      });
                      await DatabaseIO.saveProfilePicture(_selectedImage!);
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Home()),
                      );
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
                        backgroundColor: loading?MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 231, 231, 231)):
                        MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 248, 99, 0))),
                    child: loading?
                    Image.asset("assets/gifs/loading.gif",width: height*0.04,height: height*0.04,):
                    Text(
                      "Continue",
                      style: GoogleFonts.poppins(
                          fontSize: (width + height) / 75,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ))):const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

