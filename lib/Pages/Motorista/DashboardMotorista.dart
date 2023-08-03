import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:untitled/Pages/DetalhesCorrida.dart';

import 'dart:convert';

import '../../Classes/Corrida.dart';
import '../../Classes/Usuario.dart';


class DashboardMotorista extends StatefulWidget {
  final Motorista motorista;
  DashboardMotorista({Key? key, required this.motorista}) : super(key: key);
  @override
  _DashboardMotoristaState createState() => _DashboardMotoristaState();
}

class _DashboardMotoristaState extends State<DashboardMotorista> {

  List<String> itensMenu = [
    "Configurações", "Deslogar"
  ];
  final _controller = StreamController<List<dynamic>>.broadcast();
  List<dynamic> listaCorridas = [];
  Color _corBotao = Colors.lightGreenAccent;
  String _textoBotao = "Estou Disponível";
  bool _boolCorBotao = true;


_alteraarBotao(){
  setState(() {
    _boolCorBotao = !_boolCorBotao;
  });
  if(_boolCorBotao){
    setState(() {
      _corBotao = Colors.lightGreenAccent;
      //TODO _alterarStatus(1);
      _textoBotao = "Estou disponível";
    });
  }else{
    setState(() {
      _corBotao = Colors.redAccent;
      //TODO _alterarStatus(0);
      _textoBotao = "Estou Indisponível";

    });
  }
}
  void _alterarStatus(int _status)async {
    //var headers = {'Content-Type': 'application/json'};
    var url = Uri.parse(
        '  https://obdi.com.br/obdigt/api/motorista/update_status/${widget.motorista.id}/$_status'); // Url of the website where we get the data from.
    var request = http.Request('GET', url); // Now set our  request to POST
    //request.headers.addAll(headers);
    http.StreamedResponse response = await request.send(); // Send request.
    // Check if response is okay
    if (response.statusCode == 200) {
      dynamic data =
      await response.stream.bytesToString();
      print(data.toString());
    }else{
      print("ERRO");
    }
  }



  _escolhaMenuItem( String escolha ){

    switch( escolha ){
      case "Deslogar" :

        break;
      case "Configurações" :

        break;
    }

  }
  bool verifica(int booleano){
    if(booleano == 1){
      return true;
    }
    return false;
  }

  _adicionarListenerRequisicoes(){


    final _stream = getCorridas(widget.motorista);

    _stream.listen((dados){
      print("chegamos aqui");
      var jsonResponse =
      jsonDecode(dados.body);
      print("controller add : ${jsonResponse['travels']}");
      _controller.add( jsonResponse['travels'] );
      print(_controller.toString());

    });



  }

  Stream<http.Response> getCorridas(Usuario _usuario) async* {
    yield* Stream.periodic(Duration(seconds: 5), (_) async{
      print("Ate aqui");
      //var url = Uri.parse("https://obdi.com.br/obdigt/api/motorista/ultimas_corridas/${_usuario.id}");
      var url = Uri.parse("https://obdi.com.br/obdigt/api/motorista/get_travels/${_usuario.id}");
      // You will wait for the response and then decode the JSON string.
      var response = await http.get(url);
      print("resposta : $response");
      if (response.statusCode != 200) {
        print("${response.statusCode}");
      } else {
        var jsonResponse =
        jsonDecode(response.body);
        print("jresposta : $jsonResponse");

        Dio dio = new Dio();
        var resposta=await dio.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615%2C,-73.9976592&key=AIzaSyA_RfdiNc8HBwKEWjnUp89ND3NtqW8y5w8");
        print("distancia");
        print(resposta.data);

        print('Number of books about http: ${jsonResponse['travels']}');
        listaCorridas = jsonResponse['travels'];

      }
      return response;
    }).asyncMap((event) async => await event);
  }


  @override
  void initState() {
    super.initState();

    //adiciona listener para recuperar requisições
    _adicionarListenerRequisicoes();

  }

  @override
  Widget build(BuildContext context) {

    var mensagemCarregando = Center(
      child: Column(
        children: <Widget>[
          Text("Carregando corridas..."),
          CircularProgressIndicator(color: Colors.lightGreenAccent,)
        ],
      ),
    );

    var mensagemNaoTemDados = Center(
      child: Text(
        "Não há nenhuma corrida no momento ",
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text("Dasboard", style: TextStyle(color: Colors.lightGreenAccent),),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context){

              return itensMenu.map((String item){

                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );

              }).toList();

            },
          )
        ],
      ),
      body:
          Stack(children: [
            StreamBuilder<List<dynamic>>(

                stream: _controller.stream,
                builder: (context, snapshot){
                  switch( snapshot.connectionState ){
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return mensagemCarregando;
                      break;
                    case ConnectionState.active:
                    case ConnectionState.done:

                      if( snapshot.hasError ){
                        return Text("Erro ao carregar os dados!");
                      }else {

                        var mapa = snapshot.data;
                        if( listaCorridas.isEmpty){
                          return mensagemNaoTemDados;
                        }else{

                          return
                            Column(

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(padding: EdgeInsets.only(top: 20, left: 10),
                                  child:Text("Aqui estão suas", style: TextStyle(fontSize: 18),),
                                ),
                                Padding(padding: EdgeInsets.only(top: 0, left: 10),
                                  child: Text("próximas corridas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
                                ),
                                Padding(padding: EdgeInsets.all(12)),


                                Flexible(child:
                                ListView.separated(

                                    itemCount: listaCorridas.length,
                                    separatorBuilder: (context, indice) => Divider(
                                      height: 2,
                                      color: Colors.grey,
                                    ),
                                    itemBuilder: (context, indice){

                                      List<dynamic> requisicoes = listaCorridas;
                                      Map<String, dynamic> item = requisicoes[ indice ];


                                      Color _corTexto = Colors.lightGreenAccent;
                                      Color _corDecorativa = Colors.white;



                                      var bairroOrigem = item["bairro_partida"];
                                      var dataCorrida = item["data"];
                                      Corrida corrida = Corrida();
                                      corrida.observacoes = item["observacoes"];
                                      corrida.endereco_destino = item["endereco_destino"];
                                      corrida.endereco_partida = item["endereco_partida"];
                                      corrida.pernoite = verifica(item["pernoite"]);
                                      corrida.data = item["data"];
                                      corrida.hora = item["hora"];





                                      return GestureDetector(

                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(
                                                builder: (context) => DetalhesCorrida(corrida: corrida, viagemAtual: true,)

                                            ));
                                          },
                                          child: Card(

                                              color: Colors.black87,
                                              child: Padding(

                                                padding: EdgeInsets.all(12),
                                                child:
                                                Column(

                                                  children: [


                                                    Row(children: [
                                                      Icon(Icons.directions_car_sharp, color: Colors.white,),

                                                      Padding(padding: EdgeInsets.only(left: 32, right: 32, ), child:
                                                      Column(
                                                        children: [ Text(
                                                          bairroOrigem,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold
                                                          ),
                                                        ),
                                                          Padding(padding: EdgeInsets.only(top: 6),),
                                                          Text(
                                                            dataCorrida,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.lightGreenAccent,

                                                            ),
                                                          ),

                                                        ],
                                                      )


                                                        ,),
                                                      Icon(Icons.arrow_forward, color: Colors.lightGreenAccent,)
                                                    ],


                                                    )
                                                    ,


                                                  ],

                                                )
                                                ,

                                              )
                                          )
                                      );

                                    }
                                )
                                )
                              ],
                            );


                        }

                      }

                      break;
                  }
                }
            ),


            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Padding(
                  padding: Platform.isIOS
                      ? EdgeInsets.fromLTRB(20, 10, 20, 25)
                      : EdgeInsets.all(10),
                  child: Column(children: [
                    MaterialButton(
                        child: Text(
                          _textoBotao,
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        color: _corBotao,
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        onPressed: (){
                        _alteraarBotao();
                        }),




                  ],)
              ),
            )


          ],)


    );
  }
}
