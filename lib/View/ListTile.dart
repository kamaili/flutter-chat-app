import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ListElement extends StatelessWidget {
  final String imagePath;
  final String name, time, status;
  const ListElement({
    super.key,
    required this.imagePath,
    required this.name,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(children: <Widget>[
      Align(
          alignment: Alignment.topCenter,
          child: ListTile(
              leading: ClipOval(
                child: Image.network(
                  imagePath,
                  width: (width+height)/25, // Adjust the width as needed
                  height: (width+height)/25, // Adjust the height as needed
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: (height + width) / 70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                status,
                style: const TextStyle(color: Colors.deepOrangeAccent),
              ),
              trailing: Text(time))),
      Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(
              width: width * 0.8,
              height: 1,
              child: Container(
                color: Colors.grey[300],
              )))
    ]);
  }
}

class CircularImageField extends StatelessWidget {
  final String imagePath;
  final Color borderColor;
  final double borderWidth;
  final double size;

  const CircularImageField({
    super.key,
    required this.imagePath,
    required this.size,
    this.borderColor = Colors.green,
    this.borderWidth = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, // Set the desired width
      height: size, // Set the desired height
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: CircleAvatar(
        radius: 48.0, // Set the radius of the CircleAvatar
        backgroundColor: Colors.transparent, // Make the background transparent
        backgroundImage: AssetImage(imagePath),
      ),
    );
  }
}
