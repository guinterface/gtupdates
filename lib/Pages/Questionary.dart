import 'dart:convert';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:http/http.dart' as http;
import '../Classes/Corrida.dart';
import '../Classes/FormField.dart';
import '../Classes/Usuario.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Questionary extends StatefulWidget {

  final String origem;
  final String destino;
  final Usuario usuario;
  Questionary({Key? key, required this.usuario, required this.destino, required this.origem}) : super(key: key);

  @override

  _QuestionaryState createState() => _QuestionaryState();


}


class _QuestionaryState extends State<Questionary> {
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _origem.text = widget.origem;
    _destino.text = widget.destino;
  }
  @override
  TextEditingController _origem = TextEditingController();
  TextEditingController _destino = TextEditingController();
  TextEditingController _observacoes = TextEditingController();
  TextEditingController _data = TextEditingController();
  TextEditingController _datahorario = TextEditingController();
  TextEditingController _tipo = TextEditingController();
  List<String> list = <String>['Pessoas', 'Pessoas e Material', 'Material', 'Pequenos Volumes', 'SUV 4X4 Necessária'];
  bool _pernoite = true;
  int selectedRadio = 0;

  String paraString(var a){
    return "${a}";
  }

  criarCorrida()async{
    Corrida corrida = Corrida();
    corrida.endereco_destino = _destino.text;
    corrida.endereco_partida = _origem.text;
    corrida.observacoes = _observacoes.text;
    corrida.data = _data.text;
    corrida.hora = _datahorario.text;
    List<Placemark> _listaEnderecosPartida = await placemarkFromCoordinates(-22.905833, -43.226111);
    List<Placemark> _listaEnderecoDestino = await placemarkFromCoordinates(-22.905833, -43.226111);
    Placemark _enderecoPartida = _listaEnderecosPartida[0];
    Placemark _enderecoDestino = _listaEnderecoDestino[0];
    corrida.bairro_partida = _enderecoPartida.subLocality!;
    corrida.cidade_partida = _enderecoPartida.locality!;
    print(" cidade :  ${corrida.cidade_partida}");
    corrida.estado_partida = _enderecoPartida.administrativeArea!;
    corrida.cep_partida = _enderecoPartida.postalCode!;

    corrida.complemento_partida = _enderecoPartida.subLocality!;

    corrida.bairro_destino = _enderecoDestino.subLocality!;
    corrida.cidade_destino = _enderecoDestino.locality!;
    corrida.estado_destino = _enderecoDestino.administrativeArea!;
    corrida.cep_destino = _enderecoDestino.postalCode!;

    corrida.complemento_destino = _enderecoDestino.subLocality!;





    print("NOVA CORRIDA");
    print(corrida.toMap());

    salvarCorrida(widget.usuario, corrida);

  }
salvarCorrida(Usuario usuario, Corrida corrida) async {
  var headers = {'Content-Type': 'application/x-www-form-urlencoded'};


  var schedule = {
    'id_usuario': paraString(usuario.id),
    'data': paraString(corrida.data),
    'hora': paraString(corrida.hora),
    'data_retorno': "2023-04-14",
    'hora_retorno': "09:00",
    'starting_address':
    paraString({
      'endereco_completo': corrida.endereco_partida,
      'endereco_partida': "RJ",
      'numero_partida': "10",
      'bairro_partida': corrida.bairro_partida,
      'cidade_partida': "curitiba",
      'estado_partida': "RJ",
      'observacoes': corrida.complemento_partida
    },),
    'end_address':
        paraString({
          'endereco_completo': corrida.endereco_destino,
          'endereco_destino': corrida.endereco_destino,
          'numero_destino': "99",
          'bairro_destino': corrida.bairro_destino,
          'cidade_destino': "curitiba",
          'estado_destino': "RJ"
        },),


    'opcoes': "[]",
    'paradas': "[]",
    'parada_nome': "[]",
    'tipo_agendamento': "0",
    'pernoite': "0"
  };
  print(schedule);
  BaseOptions options = new BaseOptions(
    baseUrl: "https://obdi.com.br/obdigt/api/usuario",
    );
  Dio dio = new Dio(options);
//
  Map<String, dynamic> params = schedule;

//



  var url = Uri.parse(
      'https://obdi.com.br/obdigt/api/usuario/save_travel'); // Url of the website where we get the data from.
  var request = http.Request('POST', url); // Now set our  request to POST
  request.bodyFields = schedule;
  request.headers.addAll(headers);
  http.StreamedResponse response = await request.send(); // Send request.
  // Check if response is okay
  if (response.statusCode == 200) {
    dynamic data =
    await response.stream.bytesToString();
    print(data.toString());
    // Turn bytes to readable data.




  } else {
    print("${response.statusCode} - Something went wrong..");
    print(response.toString());
  }
  var resposta = await dio.post("/save_travel/", data: FormData.fromMap(params));
  print(resposta);
  print(resposta.data);
  print(resposta.statusCode);
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
            Padding(padding: EdgeInsets.only(left: 30), child:  Text(
              "$_title",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
            ),)
            ,
            Padding(
              padding: EdgeInsets.only(bottom: 3, top: 3, left: 25, right: 35),
              child: Row(
                children: [
                  /*SizedBox(height: 60, width: 100,
                    child: InputDatePickerFormField(firstDate: DateTime.now(), initialDate: DateTime.now(), lastDate: DateTime(2100),
                    )
                    ,),*/
                Padding(padding: EdgeInsets.all(10)),
                  SizedBox(height: 80, width: 150,
                    child: DateTimePicker(
                      type: DateTimePickerType.date,
                      dateMask: 'd MMM, yyyy',
                      initialValue: DateTime.now().toString(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      icon: Icon(Icons.event),
                      dateLabelText: "Data",
                      timeLabelText: "Horário",

                      selectableDayPredicate: (date) {

                        // Disable weekend days to select from the calendar
                        if (date.weekday == 6 || date.weekday == 7) {
                          return false;
                        }

                          _data.text = date.toString();

                        return true;
                      },
                      onChanged: (val) => data.text = val,
                      validator: (val) {
                        print(val);
                        return null;
                      },
                      onSaved: (val) => print(val),
                    )
                    ,),
                  Padding(padding: EdgeInsets.all(10)),
                  SizedBox(height: 80, width: 50,
                    child: DateTimePicker(
                      type: DateTimePickerType.time,
                     initialValue: "12:00",
                     timeLabelText: "Hora",
                      onChanged: (val) => _datahorario.text = val,



                      //onChanged:
                      /*validator: (val) {
                        print(val);
                        return null;
                      },
                      */

                     // onSaved: (val) => print(val),
                    )
                    ,)


                ],
              ),

            ),
          ],
        )

        ,);
    }

  return Scaffold(
    appBar: AppBar(backgroundColor: Colors.black87,
    title: Text("Adicionar Corrida", style: TextStyle(color: Colors.lightGreenAccent),),
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
                  child: Text("Adicionar Corrida", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),

                  paddig("Origem", _origem, Icon(Icons.label)),
                  paddingDate("Data de Partida", _data) ,
                  paddig("Destino", _destino, Icon(Icons.add_location_sharp)),
                 /* paddingDate("Data de Chegada", _data) ,
                  paddig("Observações", _observacoes, Icon(Icons.note_add)),*/
                  Padding(padding: EdgeInsets.all(8), child:

                  Row( mainAxisAlignment: MainAxisAlignment.center, children: [
                    Column(children: [
                      Padding(padding: EdgeInsets.only(bottom: 5), child: Text(
                        "Com Pernoite?",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                      ),),
                      SizedBox(height: 50, width: 150, child:
                      FlutterSwitch(value: _pernoite, onToggle: (val){
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


                  SizedBox(width: 200,
                    child:  MaterialButton(minWidth: 100, height: 50, color: Colors.black87, onPressed: (){
                      criarCorrida();
                    }, child: SizedBox(width: 250, child:
                    Row( crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Concluir",
                          style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontSize: 22),)
                      ],
                    ),) ),
                    )

                ],

              ),


              ],

            ),


      ),
    );
  }
}
