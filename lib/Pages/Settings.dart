import 'package:flutter/material.dart';
import 'package:untitled/Classes/Usuario.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Container(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(left: 20, top: 100, right: 20,), child:
              Column(
                children: [Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                  Text("FAQ", style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontSize: 24),)
                ],)
                  ,
                  Padding(padding: EdgeInsets.all(20)),
                  QAItem(title: Text("OBDI Motors?", style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontSize: 20),),
                      children: [Text("OBDI Motors", style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.normal, fontSize: 20),),]),
                  QAItem(title: Text("OBDI Motors?", style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontSize: 20),),
                      children: [Text("OBDI Motors", style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.normal, fontSize: 20),),]),


                 ],
              ),)

          ],
        ),
      ),
    );
  }
}
