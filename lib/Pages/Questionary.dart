import 'dart:convert';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:http/http.dart' as http;
import 'package:open_route_service/open_route_service.dart';
import '../Classes/Corrida.dart';
import '../Classes/FormField.dart';
import '../Classes/Usuario.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:open_route_service/open_route_service.dart' as ors;
class Questionary extends StatefulWidget {

  final String origem;
  final String destino;
  final Usuario usuario;
  final latitudePartida;
  final longitudePartida;
  final latitudeChegada;
  final longitudeChegada;
  Questionary({Key? key, required this.usuario, required this.destino, required this.origem, required this.latitudePartida, required this.longitudePartida, required this.latitudeChegada, required this.longitudeChegada}) : super(key: key);

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
    print("PARTIDA: ${widget.latitudePartida}, ${widget.longitudePartida}");
    print("CHEGADA: ${widget.latitudeChegada}, ${widget.longitudeChegada}");
  }
  @override
  TextEditingController _origem = TextEditingController();
  TextEditingController _destino = TextEditingController();
  TextEditingController _observacoes = TextEditingController();
  TextEditingController _data = TextEditingController();
  TextEditingController _dataRetorno = TextEditingController();
  TextEditingController _datahorario = TextEditingController();
  TextEditingController _datahorarioRetorno = TextEditingController();
  TextEditingController _tipo = TextEditingController();
  List<String> list = <String>['Pessoas', 'Pessoas e Material', 'Material', 'Pequenos Volumes', 'SUV 4X4 Necessária'];
  bool _pernoite = true;
  int selectedRadio = 0;

  String paraString(var a){
    return "${a}";
  }

  void _metodo()async{
    final OpenRouteService ola = OpenRouteService(apiKey: "5b3ce3597851110001cf62480deb6eaf6268496980c7c64b8c0553dd");
    GeoJsonFeatureCollection helo = await ors.ORSGeocode(ola).geocodeAutoCompleteGet(text: "Fortale");
    print(helo);
    print(helo.toString());
    List<dynamic> lista = helo.features;
    for(int i = 0; i<1; i++){
      print(lista[i].properties['label']);
    }

  }

   criarCorrida()async{
    Corrida corrida = Corrida();
    corrida.endereco_destino = _destino.text;
    corrida.endereco_partida = _origem.text;
    corrida.observacoes = _observacoes.text;
    corrida.data = _data.text;
    corrida.hora = _datahorario.text;
    corrida.data_retorno = _dataRetorno.text;
    corrida.hora_retorno = _datahorarioRetorno.text;
    List<Placemark> _listaEnderecosPartida = await placemarkFromCoordinates(widget.latitudePartida, widget.longitudePartida);
    List<Placemark> _listaEnderecoDestino = await placemarkFromCoordinates(widget.latitudeChegada, widget.longitudeChegada);
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




  var schedule = {
    'id_usuario': usuario.id,
    "data": paraString(corrida.data),
    "hora": paraString(corrida.hora),
    "data_retorno": paraString(corrida.data_retorno),
    "hora_retorno": paraString(corrida.hora_retorno),
    'starting_address':
    paraString({
      'bairro_partida': paraString(corrida.bairro_partida),
      'cep_partida': paraString(corrida.cep_partida),
      'endereco_completo': paraString(corrida.endereco_partida),
      'endereco_partida': paraString(corrida.endereco_partida),
      'numero_partida': paraString(corrida.numero_partida),
      'cidade_partida': paraString(corrida.cidade_partida),
      'estado_partida': paraString(corrida.estado_partida),
      'observacoes': paraString(corrida.observacoes)
    },),
    'end_address':
        paraString({
          'bairro_destino': paraString(corrida.bairro_destino),
          'cep_destino': paraString(corrida.cep_destino),
          'endereco_completo': paraString(corrida.endereco_destino),
          'endereco_destino': paraString(corrida.endereco_destino),
          'numero_destino': paraString(corrida.numero_destino),
          'cidade_destino': paraString(corrida.cidade_destino),
          'estado_destino': paraString(corrida.estado_destino)
        },),


    'opcoes': "[]",
    'paradas': "[]",
    'parada_nome': "[]",
    'tipo_agendamento': 1,
    'pernoite': (_pernoite ? 1 : 0)
  };
  print(schedule);

  BaseOptions options = new BaseOptions(
    baseUrl: "https://obdi.com.br/obdigt/api/usuario",
    );
  Dio dio = new Dio(options);
//


//
  var schedule2 = {
    "id_usuario": 2688,
    "data": "2023-05-20",
    "hora": "10:00",
    "data_retorno": "2023-05-20",
    "hora_retorno": "12:00",
    "starting_address": {
      "cep_partida": "20031-900",
      "endereco_completo": "",
      "endereco_partida": "Rio de Janeiro",
      "numero_partida": "",
      "bairro_partida": "São Cristóvão",
      "cidade_partida": "",
      "estado_partida": "Rio de Janeiro",
      "observacoes": "São Cristóvão"
    },
    "end_address": {
      "cep_destino": "20031-900",
      "endereco_completo": "",
      "endereco_destino": "",
      "numero_destino": "",
      "bairro_destino": "São Cristóvão",
      "cidade_destino": "",
      "estado_destino": "Rio de Janeiro"
    },
    "opcoes": [],
    "paradas": [],
    "parada_nome": [],
    "tipo_agendamento": 1,
    "pernoite": 0
  };

  Map<String, dynamic> params = schedule;
  print(schedule);

  var headers = {'Content-Type': 'application/json'};
  print(json.encode(schedule));
  //TODO
  /* var url = Uri.parse(
      'https://obdi.com.br/obdigt/api/usuario/save_travel'); // Url of the website where we get the data from.
  var request = http.Request('POST', url); // Now set our  request to POST
  request.body = json.encode(schedule);

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

   */

}
adicionarNotificacao(Usuario usuario) async {

  //var headers = {'Content-Type': 'application/json'};
  var url = Uri.parse(
      "https://obdi.com.br/obdigt/api/usuario/update_cod_notify/" + "${usuario.id}" + "/" + "cod");
  var request = http.Request('GET', url); // Now set our  request to POST

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

}

  setSelectedRadio(bool val) {

    setState(() {
      _pernoite = !_pernoite;
    });
    print("$_pernoite");
  }

  Widget build(BuildContext context) {
    String dropdownValue = list.first;



    Padding paddig(String _title, TextEditingController _controller, Icon _icon, bool _changeable){
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

              decoration: InputDecoration(enabled: _changeable, hintText: _title, icon: _icon, iconColor: Colors.lightGreenAccent, fillColor: Colors.lightGreenAccent, focusColor: Colors.lightGreenAccent, hoverColor: Colors.lightGreenAccent),
              controller: _controller,

            ),

          ),
        ],
      )

        ,);
    }
    Padding paddingDate(String _title, TextEditingController data, TextEditingController hora){
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
                      dateMask: 'yyy-MM-dd',
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
                      onChanged: (val) => hora.text = val,



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
                  //Padding(padding: EdgeInsets.all(10))

                 Padding(padding: EdgeInsets.only(top: 25, bottom: 10), child: Text("Adicionar Corrida", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),),

                  paddig("Origem", _origem, Icon(Icons.label), false),
                  paddingDate("Data de Partida", _data, _datahorario) ,
                  paddig("Destino", _destino, Icon(Icons.add_location_sharp), false),
                 /* paddingDate("Data de Chegada", _data) ,
                  paddig("Observações", _observacoes, Icon(Icons.note_add)),*/
                  paddingDate("Data de Retorno", _dataRetorno, _datahorarioRetorno) ,
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
                  paddig("Observações", _observacoes, Icon(Icons.note_add), true),


                  SizedBox(width: 200,
                    child:  MaterialButton(minWidth: 100, height: 50, color: Colors.black87, onPressed: (){
                      if(_data.text != "" && _datahorario.text != "" && _dataRetorno.text != "" && _datahorarioRetorno.text != "")
                      {
                        criarCorrida();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Corrida Adicionada! Aguardando Confirmação"))
                        );
                        Navigator.pop(context);

                      }

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
