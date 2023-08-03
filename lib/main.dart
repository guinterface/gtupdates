
import 'package:flutter/material.dart';
import 'package:untitled/Login.dart';
import 'package:untitled/Pages/AdicionarCorrida.dart';
import 'package:untitled/Pages/Motorista/ProfileMotorista/Offline.dart';
import 'package:untitled/Pages/Principal.dart';
import 'package:untitled/Pages/Questionary.dart';
import 'package:firebase_core/firebase_core.dart';


import 'Inicio.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(
        primaryColor: Colors.black54, hintColor: Colors.black54, secondaryHeaderColor: Colors.lightGreenAccent, colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.lightGreenAccent)
    ),
    debugShowCheckedModeBanner: false,
    home: Login(),


  ));}
