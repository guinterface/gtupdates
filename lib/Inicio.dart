import 'package:flutter/material.dart';

import 'Classes/Usuario.dart';
import 'Pages/Principal.dart';
import 'Pages/Profile.dart';
import 'Pages/Settings.dart';


class Inicio extends StatefulWidget {
  final Usuario usuario;
  Inicio({Key? key, required this.usuario}) : super(key: key);

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  int _indiceatual = 0;
  String Resultado = "";

  @override
  Widget build(BuildContext context) {
    List<Widget> telas = [
      Principal(usuario: widget.usuario,),
      Profile(usuario: widget.usuario),
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
