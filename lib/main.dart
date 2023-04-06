
import 'package:flutter/material.dart';
import 'package:untitled/Login.dart';
import 'package:untitled/Pages/Principal.dart';
import 'package:untitled/Pages/Questionary.dart';


import 'Inicio.dart';
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    theme: ThemeData(
        primaryColor: Colors.black54,
        accentColor: Colors.lightGreenAccent
    ),
    debugShowCheckedModeBanner: false,
    home: Login(),


  ));}
