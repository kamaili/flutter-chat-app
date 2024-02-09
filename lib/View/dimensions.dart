import 'package:flutter/cupertino.dart';

class Dimensions{
  static late final double height,width;
  static setDimensions(BuildContext context){
    try{height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;}catch(_){}
  }
}