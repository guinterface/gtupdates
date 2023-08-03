import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:untitled/Classes/Corrida.dart';
import 'package:untitled/Classes/Usuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;
import 'package:latlong2/latlong.dart' as LatLng;
import 'package:http/http.dart' as http;
import 'dart:convert';


class CorridaAtual extends StatefulWidget {

  final Corrida corrida;
  final String status;

  CorridaAtual({Key? key, required this.corrida, required this.status}) : super(key: key);

  @override

  _CorridaAtualState createState() => _CorridaAtualState();


}


class _CorridaAtualState extends State<CorridaAtual> {
  @override



  List listOfPoints = [];

  late final MapController _controller =
  MapController();

  // Conversion of listOfPoints into LatLng(Latitude, Longitude) list of points
  List<LatLng.LatLng> points = [];
  List<LatLng.LatLng> recoveredPoints = [];
  List<toolkit.LatLng> convertedPoints = [];
  List<Pagamento> _pagamentos = [];
  String baseUrl = 'https://api.openrouteservice.org/v2/directions/driving-car';
  String apiKey = '5b3ce3597851110001cf6248f55d7a31499e40848c6848d7de8fa624';
  LatLng.LatLng posicaoCamera = LatLng.LatLng(6.131015, 1.223898);
  int k =0;
  double distancia = 0;
  DateTime _tempoInicial = DateTime.fromMicrosecondsSinceEpoch(0);
  DateTime _tempoFinal = DateTime.fromMicrosecondsSinceEpoch(0);

  Marker _showMarker(LatLng.LatLng latLng){

    return Marker(
      point: latLng,
      width: 80,
      height: 80,
      builder: (context) => IconButton(
        onPressed: () {},
        icon: const Icon(Icons.directions_car),
        color: Colors.lightGreen,
        iconSize: 45,
      ),
    );
  }
  _recuperaUltimaLocalizacaoConhecida() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position? position = await Geolocator.getCurrentPosition();

    print(" POSICAO   $position");
    print(" POSICAO   ${position.latitude}");


    if (position != null) {
      _controller.moveAndRotate(LatLng.LatLng(position.latitude, position.longitude), 15, 0);
      //print(_controller.moveAndRotate(LatLng(position.latitude, position.longitude), 19, 0).moveSuccess);
      //_movimentarCamera(LatLng(position.latitude, position.longitude));
      setState(() {
        posicaoCamera = LatLng.LatLng(position.latitude, position.longitude);
      });
    }

  }

  adicionarListenerLocalizacao() {

    var locationOptions =
    LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);



    Geolocator.getPositionStream(locationSettings: locationOptions).listen((Position position) {
      setState(() {
        recoveredPoints.add(LatLng.LatLng(position.latitude, position.longitude));
      });
      print("POSICAO");
      print(position);
      if(recoveredPoints.length>=4){
        int pontos = recoveredPoints.length;
        print("PONTOS CALCULADOS:");
        print("${recoveredPoints[pontos-2].latitude}, ${recoveredPoints[pontos-2].longitude}");
        print("${recoveredPoints[pontos-1].latitude}, ${recoveredPoints[pontos-1].longitude}");
        distancia += Geolocator.distanceBetween(recoveredPoints[pontos-2].latitude, recoveredPoints[pontos-2].longitude, recoveredPoints[pontos-1].latitude, recoveredPoints[pontos-1].longitude);
      }else{
        distancia = 0;
      }
      print("DISTANCIA");
      print(distancia);

      if (position != null) {
        if(convertedPoints.isNotEmpty){
          if(toolkit.PolygonUtil.isLocationOnPath(toolkit.LatLng(position.latitude, position.longitude), convertedPoints, true, tolerance : 10.0
          )){
            print(" Sim, está no caminho");


          }else{
            print("NOPE");
            print(toolkit.LatLng(position.latitude, position.longitude));
            print("convertemos:");
            print(convertedPoints[0]);
            print(convertedPoints[points.length-1]);
            getCoordinates();
          }
        }

        _controller.moveAndRotate(LatLng.LatLng(position.latitude, position.longitude), 15, 0);
        //print(_controller.moveAndRotate(LatLng(position.latitude, position.longitude), 19, 0).moveSuccess);
        //_movimentarCamera(LatLng(position.latitude, position.longitude));
        k+=10;
        print(" total andado: $k m");
        setState(() {
          posicaoCamera = LatLng.LatLng(position.latitude, position.longitude);
        });
        
      }



    });
  }


  _movimentarCamera(LatLng.LatLng latLng){
    _controller.move(latLng, 19);
  }
  getRouteUrl(String startPoint, String endPoint){
    return Uri.parse('$baseUrl?api_key=$apiKey&start=$startPoint&end=$endPoint');
  }


  // Method to consume the OpenRouteService API
  getCoordinates() async {
    // Requesting for openrouteservice api
    print(" achamos");
    print ("37.428230,-122.1688");
    print('${posicaoCamera.longitude},${posicaoCamera.latitude}');
    var response = await http.get(getRouteUrl("${posicaoCamera.longitude},${posicaoCamera.latitude}",
        '-122.259094,37.871960'));
    print(response.body);
    print(response.toString());
    setState(() {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        points = [];
        convertedPoints = [];
        listOfPoints = data['features'][0]['geometry']['coordinates'];
        print("LISTA ");
        print(listOfPoints);
        points = listOfPoints
            .map((p) => LatLng.LatLng(p[1].toDouble(), p[0].toDouble()))
            .toList();
        print("PONTOS");
        print(points);
        convertedPoints = listOfPoints
            .map((p) => toolkit.LatLng(p[1].toDouble(), p[0].toDouble()))
            .toList();
        print(convertedPoints);
        /*for(int i =0; i <points.length; i++){
          convertedPoints[i] = toolkit.LatLng(points[i].latitude, points[i].longitude);
        }*/

      }
    });

  }
  void _alterarStatus(int _status)async {
    //var headers = {'Content-Type': 'application/json'};
    var url = Uri.parse(
        'https://obdi.com.br/obdigt/api/usuario/update_status_travel/${widget
            .corrida
            .id}/status/${_status}/reason/false'); // Url of the website where we get the data from.
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

  FlutterMap _flutterMap(){
    return
      FlutterMap(
        mapController: _controller,
        options: MapOptions(
            zoom: 15,
            center: posicaoCamera,
            slideOnBoundaries: true
        ),
        children: [
          // Layer that adds the map
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          // Layer that adds points the map


          // Polylines layer
          PolylineLayer(
            polylineCulling: false,
            polylines: [
              Polyline(
                  points: points, color: Colors.black, strokeWidth: 5),
            ],
          ),
          PolylineLayer(
            polylineCulling: false,
            polylines: [
              Polyline(
                  points: recoveredPoints, color: Colors.lightGreenAccent, strokeWidth: 5),
            ],
          ),
          MarkerLayer(
            markers: [
              // First Marker
              Marker(
                point: LatLng.LatLng(37.871960,-122.259094),
                width: 80,
                height: 80,
                builder: (context) => IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.location_on),
                  color: Colors.green,
                  iconSize: 45,
                ),
              ),
              // Second Marker
              _showMarker(posicaoCamera)
            ],
          ),
        ],
      );

  }



  void initState() {


    // TODO: implement initState
    super.initState();
    _origem.text = widget.corrida.endereco_partida;
    _destino.text = widget.corrida.endereco_destino;
    _pernoite = widget.corrida.pernoite;
    _tipo.text = widget.corrida.observacoes;
    _datahorario.text = widget.corrida.hora;
    _data.text = widget.corrida.data;
    status = widget.status;

    list.add(widget.corrida.observacoes);



    _recuperaUltimaLocalizacaoConhecida();
    adicionarListenerLocalizacao();
    _tempoInicial = DateTime.now();
  }
  @override
  TextEditingController _origem = TextEditingController();
  TextEditingController _destino = TextEditingController();
  TextEditingController _observacoes = TextEditingController();
  TextEditingController _data = TextEditingController();
  TextEditingController _datahorario = TextEditingController();
  TextEditingController _tipo = TextEditingController();
  TextEditingController _preco = TextEditingController();
  TextEditingController _observacoesAdicionais = TextEditingController();
  List<String> list = <String>[];
  List<String> listaPagamento = <String>["Pedagio", "Almoco"];
  bool _pernoite = true;
  int selectedRadio = 0;
  String status = "Não Iniciada";
  String dropdownValuePayment = "Pedagio";
  bool _mapaVisivel = false;

  _alterarVisibilidadeMapa(){
    _recuperaUltimaLocalizacaoConhecida();
    adicionarListenerLocalizacao();
    getCoordinates();
    setState(() {
      _mapaVisivel = !_mapaVisivel;

    });
    getCoordinates();
    setState(() {
      getCoordinates();
    });
  }
  _criarPagamento(){
    Pagamento _novoPagamento = Pagamento();
    _novoPagamento.preco = int.parse(_preco.text);
    _novoPagamento.tipo_de_pagamento = _tipo.text;
    _novoPagamento.categoria_de_pagamento = dropdownValuePayment;
    print(_novoPagamento.categoria_de_pagamento);
    _pagamentos.add(_novoPagamento);
    print(_pagamentos[0].categoria_de_pagamento);


    setState(() {
      _preco.text = "00,00";
      _observacoesAdicionais.text = "";
    });
  }

  _mudarStatus(String _status, int _novoStatus){
    if(_novoStatus !=0)
    //TODO _alterarStatus(_novoStatus);
    setState(() {
      status = _status;
    });
  }
  _alterarCategoriaPagamento(String _item){
    setState(() {
      dropdownValuePayment = _item;


    });
  }

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

    _exibirTelaCadastro(){

      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Como deseja abrir o Mapa?"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MaterialButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Google Maps")
                  ),
                  MaterialButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Waze")
                  ),
                  MaterialButton(
                      onPressed: (){

                        () => Navigator.pop(context);
                        _alterarVisibilidadeMapa();
                        getCoordinates();
                      },
                      child: Text("Dentro do App")
                  ),


                ],
              ),
              actions: <Widget>[
                MaterialButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancelar")
                ),

              ],
            );
          }
      );

    }

    String dropdownValue = list.first;




    Padding paddig(String _title, TextEditingController _controller, Icon _icon, String tipo){
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
                keyboardType: tipo == "Preco" && _title == "Preco" ? TextInputType.numberWithOptions() : TextInputType.text,
                decoration: InputDecoration(hintText: _title, icon: _icon, iconColor: Colors.lightGreenAccent, fillColor: Colors.lightGreenAccent, focusColor: Colors.lightGreenAccent, hoverColor: Colors.lightGreenAccent

                ),
                controller: _controller,
                enabled: tipo == "Preco",

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
            paddig("Data", _data, Icon(Icons.calendar_today), "Data"),
            Padding(padding: EdgeInsets.all(10)),
            paddig("Horário", _datahorario, Icon(Icons.access_time_outlined), "Horário")
          ],
        ),

      );

    }

    Flexible _exibirListaPagamentos(){
     if(_pagamentos.length>=1)
      return Flexible(child:
      Flexible(

        fit: FlexFit.loose,
        child:SizedBox

          (child:
        SizedBox(
          height: 220,

          child: ListView.separated(
            itemCount: _pagamentos.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(24),

            primary: false,
            shrinkWrap: true,
            separatorBuilder: (context, indice) => Divider( color:  Colors.white, indent: 16,),
            itemBuilder: (context, indice){
              List<Pagamento> requisicoes = _pagamentos;
              Pagamento item = requisicoes[indice];
              String titulo =  item.categoria_de_pagamento;
              int preco =item.preco;



              return


                Container(

                        child: Card(
                            color: Colors.lightGreenAccent,
                            child: Padding(
                                padding: EdgeInsets.all(12),
                                child:
                                Column(

                                    children: [
                                      Padding(padding: EdgeInsets.only(left: 32, right: 32, ), child:
                                      Text(
                                        titulo,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,

                                        ),
                                      )

                                        ,),
                                      Row(
                                        children: [

                                          Column(
                                            children: [

                                              Padding(padding: EdgeInsets.only(left: 32, right: 32, ), child:

                                              Padding(padding: EdgeInsets.only(left: 12, right: 12, ), child:
                                              Text(
                                                "Valor: $preco",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black54
                                                ),
                                              )

                                                ,),

                                              ),




                                            ],
                                          )


                                        ],


                                      )
                                      ,

                                    ]
                                )
                            )
                        )
                    );



            },


          ),

        )

          ,
        ),
      ),
      );
      return Flexible(child: Text("Nenhum pagamento feito durante a corrida"));
    }
    Column _naoIniciada(){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
            
                      Padding(padding: EdgeInsets.only(top: 14, bottom: 14),
                        child: Text("Detalhes da Corrida", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),
            
                      paddig("Origem", _origem, Icon(Icons.label), "Origem"),
                      paddig("Destino", _destino, Icon(Icons.add_location_sharp), "Destino"),
                      Row(children: [
                        SizedBox (height: 80, width: 200, child: paddig("Data", _data, Icon(Icons.calendar_today), "Data"), ),

                        Padding(padding: EdgeInsets.all(1)),
                        SizedBox(height: 80, width: 150, child: paddig("Horário", _datahorario, Icon(Icons.access_time_outlined), "Horário"),),


                      ],),

                      Padding(padding: EdgeInsets.all(8), child:
            
                      Row( mainAxisAlignment: MainAxisAlignment.center, children: [
                        Column(children: [
                          Padding(padding: EdgeInsets.only(bottom: 5), child: Text(
                            "Com Pernoite?",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                          ),),
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
            
            
                      SizedBox(width: 250,
                        child:  MaterialButton(minWidth: 150, height: 50, color: Colors.black87, onPressed: (){
                          _exibirTelaCadastro();
                        }, child: SizedBox(width: 250, child:
                        Row( crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Navegar Para Partida",
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 22),)
                          ],
                        ),) ),
                      ),
                      Padding(padding: EdgeInsets.all(8)),
                      SizedBox(width: 250,
                        child:  MaterialButton(minWidth: 100, height: 50, color: Colors.black87, onPressed: (){
                          _mudarStatus("Iniciada", 5);
                        }, child: SizedBox(width: 250, child:
                        Row( crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Comunicar Chegada",
                              style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontSize: 22),)
                          ],
                        ),) ),
                      ), 
                      Padding(padding: EdgeInsets.all(5))
            
                    ],
            
                  );
    }
    Column _inicada(){
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
            
                        Padding(padding: EdgeInsets.only(top: 18, bottom: 18),
                          child: Text("Detalhes da Corrida", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),),
            
                        paddig("Origem", _origem, Icon(Icons.label), "Destino"),
                        Row(children: [
                          SizedBox (height: 80, width: 200, child: paddig("Data", _data, Icon(Icons.calendar_today), "Data"), ),

                          Padding(padding: EdgeInsets.all(1)),
                          SizedBox(height: 80, width: 150, child: paddig("Horário", _datahorario, Icon(Icons.access_time_outlined), "Horário"),),


                        ],),
                        paddig("Destino", _destino, Icon(Icons.add_location_sharp), "Destino"),
            
                        Padding(padding: EdgeInsets.all(5)),
            
            
                        SizedBox(width: 270,
                          child:  MaterialButton(minWidth: 100, height: 50, color: Colors.black87, onPressed: (){
                            _mudarStatus("Pagamento", 5);
                          }, child: SizedBox(width: 270, child:
                          Row( crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Adicionar Custo Extra",
                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 22),)
                            ],
                          ),) ),
                        ),
                        Padding(padding: EdgeInsets.all(4)),
                        SizedBox(width: 270,
                          child:  MaterialButton(minWidth: 100, height: 50, color: Colors.black87, onPressed: (){
                            _exibirTelaCadastro();
                          }, child: SizedBox(width: 270, child:
                          Row( crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Abrir Mapa",
                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 22),)
                            ],
                          ),) ),
                        ),
                        Padding(padding: EdgeInsets.all(4)),

                        SizedBox(width: 270,
                          child:  MaterialButton(minWidth: 100, height: 50, color: Colors.black87, onPressed: (){
                            _mudarStatus("Concluida", 6);
                            _tempoFinal = DateTime.now();
                            var diferencaTempo = _tempoFinal.difference(_tempoInicial);
                            print("DIFERENCA DE TEMPO EM MINUTOS:");
                            print(diferencaTempo.inMinutes);

                            print("DIFERENCA DE TEMPO EM SEGUNDOS:");
                            print(diferencaTempo.inSeconds);

                          }, child: SizedBox(width: 250, child:
                          Row( crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Concluir Corrida",
                                style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontSize: 22),)
                            ],
                          ),) ),
                        )
            
                      ]
            
                  );
    }
    Column _pagamento(){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
        
                  Padding(padding: EdgeInsets.only(top: 25, bottom: 25),
                    child: Text("Pagamento", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),
        
                  paddig("Preco", _preco, Icon(Icons.payments_rounded), "Preco"),
                  Padding(padding: EdgeInsets.all(8), child:

                  Row( mainAxisAlignment: MainAxisAlignment.center, children: [
                    Column(children: [
                      Padding(padding: EdgeInsets.only(bottom: 5), child: Text(
                        "Forma de Pagamento?",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                      ),),
                      SizedBox(height: 50, width: 150, child:
                      FlutterSwitch(value: _pernoite, disabled: false, onToggle: (val){

                        setSelectedRadio(val);
                      }, showOnOff: true, activeText: "Dinheiro", inactiveText: "Cartão", activeColor: Colors.lightGreenAccent, width: 100, height: 50, )
                        ,),
                    ],),
                    Column(children: [
                      Padding(padding: EdgeInsets.only(bottom: 5), child: Text(
                        "Categoria",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),

                      ),),

                      DropdownButton<String>(

                        value: dropdownValuePayment,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(color: Colors.lightGreen),
                        underline: Container(
                          height: 2,
                          width: 50,
                          color: Colors.lightGreenAccent,
                        ),
                        onChanged: (String? value) {
                          _alterarCategoriaPagamento(value!);
                          // This is called when the user selects an item.
                          setState(() {
                            dropdownValuePayment = value!;


                          });
                        },
                        items: listaPagamento.map<DropdownMenuItem<String>>((String value) {
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
                  paddig("Observações", _observacoesAdicionais, Icon(Icons.text_snippet), "Preco") ,
                  Padding(padding: EdgeInsets.all(5)),




        
                  SizedBox(width: 200,
                    child:  MaterialButton(minWidth: 100, height: 50, color: Colors.black87, onPressed: (){
                      _mudarStatus("Iniciada", 5);
                    }, child: SizedBox(width: 250, child:
                    Row( crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Cancelar",
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 22),)
                      ],
                    ),) ),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  SizedBox(width: 200,
                    child:  MaterialButton(minWidth: 100, height: 50, color: Colors.black87, onPressed: (){
                      _criarPagamento();
                      _mudarStatus("Iniciada", 5);
                    }, child: SizedBox(width: 250, child:
                    Row( crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Concluir",
                          style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontSize: 22),)
                      ],
                    ),) ),
                  )
        
                ],
        
              );
    }


    Column _viagemFinalizada(){
                return Column(

                  mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    Padding(padding:EdgeInsets.only(top: 5, left: 12),
                child: Text("Viagem Concluída!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ),
                ),),
                      Padding(padding:EdgeInsets.only(top: 15, left: 12, bottom: 15),
                        child: Text("Avalie o seu Usuário:", style: TextStyle(fontSize: 18,   color: Colors.grey ),
                        ),),
                      Padding(padding: EdgeInsets.all(5)),
                      RatingBar.builder(
                        initialRating: 3,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                      Padding(padding: EdgeInsets.all(15)),
                Padding(padding:EdgeInsets.only(top: 5, left: 12, bottom: 20),
                child: Text("Veja aqui tudo que ocorreu na viagem:", style: TextStyle(fontSize: 16, ),
                ),),



                Padding(padding:EdgeInsets.only(top: 5, left: 12),
                child: Text("Pagamentos feitos:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),),
                     // _exibirListaPagamentos(),


                      paddig("Origem", _origem, Icon(Icons.label), "Origem"),
                      paddig("Destino", _destino, Icon(Icons.add_location_sharp), "Destino"),
                      Row(children: [
                        SizedBox (height: 80, width: 200, child: paddig("Data", _data, Icon(Icons.calendar_today), "Data"), ),

                        Padding(padding: EdgeInsets.all(1)),
                        SizedBox(height: 80, width: 150, child: paddig("Horário", _datahorario, Icon(Icons.access_time_outlined), "Horário"),),


                      ],),

                      Padding(padding: EdgeInsets.all(8), child:

                      Row( mainAxisAlignment: MainAxisAlignment.center, children: [
                        Column(children: [
                          Padding(padding: EdgeInsets.only(bottom: 5), child: Text(
                            "Com Pernoite?",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                          ),),
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
                          ),


                        ],


                        )


                      ],),


                      ),
                      Padding(padding:EdgeInsets.only(top: 15, left: 12, bottom: 15),
                        child: Text("Distância total percorrida: $distancia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ),
                        ),),
                      Padding(padding: EdgeInsets.all(5)),

                      Padding(padding: EdgeInsets.all(5)),
                      SizedBox(width: 200,
                        child:  MaterialButton(minWidth: 100, height: 50, color: Colors.black87, onPressed: (){
                          _criarPagamento();
                          _mudarStatus("Concluir", 6);
                        }, child: SizedBox(width: 250, child:
                        Row( crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Concluir",
                              style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontSize: 22),)
                          ],
                        ),) ),
                      ),
                      Padding(padding: EdgeInsets.all(5)),











                ],
                );



    }

    Column _viagemConcluida(){
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Padding(padding: EdgeInsets.only(top: 25, bottom: 25),
            child: Text("Pagamento", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),

          Flexible(

              child:
              SizedBox( height: 100, child:

              ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pagamentos.length,

              itemBuilder: (context, index) {
              return ListTile(
              title: Text(_pagamentos[index].categoria_de_pagamento),
              subtitle: Text("${_pagamentos[index].preco}"),
              );
              },
              )
              ,)
          ),
          paddig("Origem", _origem, Icon(Icons.label), "Origem"),
          paddig("Destino", _destino, Icon(Icons.add_location_sharp), "Destino"),
          Row(children: [
            SizedBox (height: 80, width: 200, child: paddig("Data", _data, Icon(Icons.calendar_today), "Data"), ),

            Padding(padding: EdgeInsets.all(1)),
            SizedBox(height: 80, width: 150, child: paddig("Horário", _datahorario, Icon(Icons.access_time_outlined), "Horário"),),


          ],),

          Padding(padding: EdgeInsets.all(8), child:

          Row( mainAxisAlignment: MainAxisAlignment.center, children: [
            Column(children: [
              Padding(padding: EdgeInsets.only(bottom: 5), child: Text(
                "Com Pernoite?",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
              ),),
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
          RatingBar.builder(
          initialRating: 3,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
          print(rating);
          },
          ),
          SizedBox(width: 200,
            child:  MaterialButton(minWidth: 100, height: 50, color: Colors.black87, onPressed: (){
              criarCorrida();
            }, child: SizedBox(width: 250, child:
            Row( crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Cancelar",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 22),)
              ],
            ),) ),
          ),
          Padding(padding: EdgeInsets.all(5)),
          SizedBox(width: 200,
            child:  MaterialButton(minWidth: 100, height: 50, color: Colors.black87, onPressed: (){
              _criarPagamento();
              _mudarStatus("Concluir", 6);
            }, child: SizedBox(width: 250, child:
            Row( crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Concluir",
                  style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontSize: 22),)
              ],
            ),) ),
          )

        ],

      );
    }



    Column _coluna(){
      if(status == "Não Iniciada"){
        return  _naoIniciada();
      }

      if(status == "Iniciada"){

        return  _inicada();
      }

      if(status =="Pagamento"){
        return _pagamento();
      }

      if(status =="Concluida"){
        return _viagemFinalizada();
      }


      return  _naoIniciada();

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
            _coluna(),
            Visibility(child:

              Container(
                height: 500,
                child: _flutterMap(),
              )
              , visible: _mapaVisivel,)



          ],

        ),



      ),
      floatingActionButton: _mapaVisivel ? FloatingActionButton(
        backgroundColor: Colors.lightGreenAccent,
        onPressed: (){
          _alterarVisibilidadeMapa();
          getCoordinates();

        },
        child: const Icon( Icons.close,
          color: Colors.black54,
        ),
      ) : null

    );
  }
}
