import 'package:flutter/material.dart';
import 'package:untitled/Classes/Usuario.dart';
import 'package:untitled/Pages/Motorista/DashboardMotorista.dart';
import 'package:untitled/Pages/Motorista/ProfileMotorista/ProfileMotorista.dart';

import '../Settings.dart';




class GeralMotorista extends StatefulWidget {
  final Motorista motorista;
  GeralMotorista({Key? key, required this.motorista}) : super(key: key);

  @override
  _GeralMotoristaState createState() => _GeralMotoristaState();
}

class _GeralMotoristaState extends State<GeralMotorista> {
  @override
  int _indiceatual = 0;
  String Resultado = "";

  @override
  Widget build(BuildContext context) {
    List<Widget> telas = [
      DashboardMotorista(motorista: widget.motorista,),
      ProfileMotorista(motorista: widget.motorista),
      Settings(),

    ];
    return Scaffold(
      backgroundColor: Colors.black54,

      body: telas[_indiceatual],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _indiceatual,
          onTap: (indice) {
            setState(() {
              _indiceatual = indice;
            });
          },
          fixedColor: Colors.lightGreenAccent,
          unselectedItemColor: Colors.lightGreen,
          backgroundColor: Colors.black54,
          items: [
            BottomNavigationBarItem(
                label: "Principal",
                icon: Icon(Icons.directions_car_rounded)
            ),
            BottomNavigationBarItem(
                label: "Perfil",
                icon: Icon(Icons.person)
            ),
            BottomNavigationBarItem(
                label: "FAQ",
                icon: Icon(Icons.question_answer
                )),

          ]),


    );
  }

}
