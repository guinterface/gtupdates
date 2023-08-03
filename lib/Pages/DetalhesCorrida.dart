import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../Classes/Corrida.dart';
import '../Classes/FormField.dart';
import '../Classes/Usuario.dart';

class DetalhesCorrida extends StatefulWidget {

  final Corrida corrida;
  final bool viagemAtual;

  DetalhesCorrida({Key? key, required this.corrida, required this.viagemAtual}) : super(key: key);

  @override

  _DetalhesCorridaState createState() => _DetalhesCorridaState();


}


class _DetalhesCorridaState extends State<DetalhesCorrida> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _origem.text = widget.corrida.endereco_partida;
    _destino.text = widget.corrida.endereco_destino;
    _pernoite = widget.corrida.pernoite;
    _tipo.text = widget.corrida.observacoes;
    _datahorario.text = widget.corrida.hora;
    _data.text = widget.corrida.data;

    list.add(widget.corrida.observacoes);
  }
  @override
  TextEditingController _origem = TextEditingController();
  TextEditingController _destino = TextEditingController();
  TextEditingController _observacoes = TextEditingController();
  TextEditingController _data = TextEditingController();
  TextEditingController _datahorario = TextEditingController();
  TextEditingController _tipo = TextEditingController();
  List<String> list = <String>[];
  bool _pernoite = true;
  int selectedRadio = 0;

  criarCorrida(){
    Corrida corrida = Corrida();
    corrida.endereco_destino = _destino.text;
    corrida.endereco_partida = _origem.text;
    corrida.observacoes = _observacoes.text;
    corrida.data = _data.text;
    corrida.hora = _datahorario.text;
    print("NOVA CORRIDA");
    print(corrida.toMap());

  }


  setSelectedRadio(bool val) {

    setState(() {
      _pernoite = !_pernoite;
    });
    print("$_pernoite");
  }

  Widget build(BuildContext context) {
    String dropdownValue = list.first;



    Padding paddig(String _title, TextEditingController _controller, Icon _icon){
      return Padding(padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(left: 30), child:  Text(
              "$_title",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
            ),)
            ,
            Padding(
              padding: EdgeInsets.only(bottom: 3, top: 3, left: 25, right: 35),
              child: TextField(cursorColor: Colors.lightGreenAccent,

                decoration: InputDecoration(hintText: _title, icon: _icon, iconColor: Colors.lightGreenAccent, fillColor: Colors.lightGreenAccent, focusColor: Colors.lightGreenAccent, hoverColor: Colors.lightGreenAccent),
                controller: _controller,
                enabled: false,

              ),

            ),
          ],
        )

        ,);
    }
    Padding paddingDate(String _title, TextEditingController data){
      return Padding(padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            paddig("Data", _data, Icon(Icons.calendar_today)),
            Padding(padding: EdgeInsets.all(10)),
            paddig("Horário", _datahorario, Icon(Icons.access_time_outlined))
                ],
              ),

            );

    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black87,
        title: Text("Detalhes Corrida", style: TextStyle(color: Colors.lightGreenAccent),),
      ),

      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child:
        Stack(
          children: [

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Padding(padding: EdgeInsets.only(top: 25, bottom: 25),
                  child: Text("Detalhes da Corrida", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),

                paddig("Origem", _origem, Icon(Icons.label)),
                paddingDate("Data de Partida", _data) ,
                paddig("Destino", _destino, Icon(Icons.add_location_sharp)),

                Padding(padding: EdgeInsets.all(8), child:
                Row( mainAxisAlignment: MainAxisAlignment.center, children: [
                  Column(children: [
                    Padding(padding: EdgeInsets.only(bottom: 5), child: Text(
                      "Com Pernoite?",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                    ),
                    ),
                    SizedBox(height: 50, width: 150, child:
                    FlutterSwitch(value: _pernoite, disabled: true, onToggle: (val){

                      setSelectedRadio(val);
                    }, showOnOff: true, activeText: "Sim", inactiveText: "Não", activeColor: Colors.lightGreenAccent, width: 100, height: 50, )
                      ,),
                  ],),

                  Column(children: [
                    Padding(padding: EdgeInsets.only(bottom: 5), child: Text(
                      "Categoria",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),

                    ),),
                    DropdownButton<String>(

                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      style: const TextStyle(color: Colors.lightGreen),
                      underline: Container(
                        height: 2,
                        width: 50,
                        color: Colors.lightGreenAccent,
                      ),
                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          dropdownValue = value!;
                          _tipo.text = value;
                        });
                      },
                      items: list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )
                  ],

                  )


                ],),


                ),
                Padding(padding: EdgeInsets.all(5)),

               Visibility(visible: widget.viagemAtual,
               child: SizedBox(width: 200,
                 child:  MaterialButton(minWidth: 100, height: 50, color: Colors.black87, onPressed: (){
                   criarCorrida();
                 }, child: SizedBox(width: 250, child:
                 Row( crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text("Concluir",
                       style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontSize: 22),)
                   ],
                 ),) ),
               ) ,
               )



              ],

            ),


          ],

        ),


      ),
    );
  }
}
