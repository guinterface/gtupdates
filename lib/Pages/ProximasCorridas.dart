import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:untitled/Pages/Motorista/CorridaAtual.dart';

import 'dart:convert';

import '../../Classes/Corrida.dart';
import '../../Classes/Usuario.dart';



class ProximasCorridas extends StatefulWidget {
  final Usuario usuario;
  final String categoriaUsuario;
  final controller;
  final List<dynamic> listaCorridas;

  ProximasCorridas({Key? key, required this.usuario, required this.categoriaUsuario, required this.listaCorridas, required this.controller}) : super(key: key);
  @override
  _ProximasCorridasState createState() => _ProximasCorridasState();
}

class _ProximasCorridasState extends State<ProximasCorridas> {

  List<String> itensMenu = [
    "Configurações", "Deslogar"
  ];
  final _controller = StreamController<List<dynamic>>.broadcast();
  List<dynamic> listaCorridas = [];
  bool _listenerAtivo = true;







  bool verifica(int booleano){
    if(booleano == 1){
      return true;
    }
    return false;
  }



  @override
  void initState() {
    super.initState();

    //adiciona listener para recuperar requisições
    _adicionarListenerRequisicoes();

  }
   _adicionarListenerRequisicoes(){


    final _stream = getCorridas(widget.usuario);

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
      var url = Uri.parse("https://obdi.com.br/obdigt/api/usuario/get_travels/${_usuario.id}");
      // You will wait for the response and then decode the JSON string.
      var response = await http.get(url);
      print("resposta : $response");
      if (response.statusCode != 200) {
        print("${response.statusCode}");
      } else {
        var jsonResponse =
        jsonDecode(response.body);
        print("jresposta : $jsonResponse");



        print('Number of books about http: ${jsonResponse['travels']}');
        listaCorridas = jsonResponse['travels'];

      }
      return response;
    }).asyncMap((event) async => await event);
  }
  /*_adicionarDadosRequisicoes()
  {
    listaCorridas = widget.listaCorridas;
    _controller.add(widget.controller);
    setState(() {
      listaCorridas = widget.listaCorridas;
      _controller.add(widget.controller);
    });
  }*/
  @override
  Widget build(BuildContext context) {

    var mensagemCarregando = Center(
      child: Column(
        children: <Widget>[
          Text("Carregando corridas...."),
          CircularProgressIndicator(color: Colors.lightGreenAccent,)
        ],
      ),
    );

    var mensagemNaoTemDados = Center(
      child: Text(
        "Você ainda não adicionou nenhuma corrida",
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text("Próximas Corridas", style: TextStyle(color: Colors.lightGreenAccent),),

      ),
      body:

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
                            child: Text("Próximas corridas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
                          ),
                          /*Padding(padding: EdgeInsets.only(top: 0, left: 10, bottom: 16),
                            child: Image.asset("bck1/list1.png", width: 230),
                          ),*/

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



                                Corrida corrida = Corrida();
                                corrida.bairro_partida = item["bairro_partida"] != null? item["bairro_partida"] : "";
                                corrida.observacoes = item["observacoes"] != null? item["observacoes"] : "";
                                corrida.endereco_destino = item["endereco_destino"] != null? item["endereco_destino"] : "";
                                corrida.endereco_partida = item["endereco_partida"] != null? item["endereco_partida"] : "";
                                corrida.pernoite =  item["pernoite"] != null ? verifica(item["pernoite"]): false;
                                corrida.data = item["data"]!= null? item["data"] : "";
                                corrida.hora = item["hora"]!= null? item["hora"] : "";







                                return GestureDetector(

                                    onTap: (){
                                      setState(() {
                                        _listenerAtivo = false;
                                      });
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => CorridaAtual(corrida: corrida, status: "Não Iniciada",)

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
                                                    corrida.bairro_partida,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                    Padding(padding: EdgeInsets.only(top: 6),),
                                                    Text(
                                                      corrida.data,
                                                      style: TextStyle(
                                                        fontSize: 18,
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

    );
  }
}
