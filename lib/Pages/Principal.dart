import 'dart:convert';
import 'dart:io';
//import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:open_route_service/open_route_service.dart' as ors;
import 'package:untitled/Pages/ProximasCorridas.dart';
import 'package:untitled/Pages/Questionary.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import '../Classes/Usuario.dart';
import 'package:http/http.dart' as http;

class Principal extends StatefulWidget {
  final Usuario usuario;
  Principal({Key? key, required this.usuario}) : super(key: key);

  @override
  _PrincipalState createState() => _PrincipalState();
}


class _PrincipalState extends State<Principal> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  String _proximaCorrida = "Você não tem nenhuma próxima corrida confirmada no momento";
  bool _status = true;
  Set<Marker> _marcadores = {};
  bool _visivelPartida = false;
  bool _visivelChegada = false;
  bool _concluidoPartida = false;
  bool _concluidoChegada = false;
  String _textoAlerta = "";
  var latitudePartida = 0.0;
  var longitudePartida = 0.0;
  var latitudeChegada = 0.0;
  var longitudeChegada = 0.0;
  var _controllerStreamData = [];
  String _autoCorretorPartida = "";
  String _autoCorretorChegada = "";
  TextEditingController _origem = TextEditingController();
  TextEditingController _destino = TextEditingController();
  CameraPosition _posicaoCamera = CameraPosition(target: LatLng(0.1, 0.1), zoom: 19);
  final _controllerStream = StreamController<List<dynamic>>.broadcast();
  List<dynamic> listaCorridas = [];

  // GeoMethods geoMethods = GeoMethods(googleApiKey: googleApiKey, language: language);

  void _alterarVisibilidade(String partidaOuChegada, String origem)async{
    bool _visivel = true;
    if(partidaOuChegada == "partida"){
      _visivelPartida = _visivel;
      _concluidoPartida = false;
      print("PARTIDA: $_concluidoPartida");

      setState(()  {

      });
    }else{
      if(partidaOuChegada == "chegada"){
        _visivelChegada = _visivel;
        _concluidoChegada = false;
        print("CHEGADA: $_concluidoChegada");
        setState(()  {

        });
      }
    }
    String _autocorretor;
    _autocorretor = await _metodo(origem, partidaOuChegada);


    if(partidaOuChegada == "partida"){

      _autoCorretorPartida =  _autocorretor;


    }else{
      if(partidaOuChegada == "chegada"){
        _autoCorretorChegada =  _autocorretor;


      }
    }
  }
  _modificarTextoProximaCorrida(){
    if(listaCorridas.length >=1){
      setState(() {
        _proximaCorrida = "Próxima corrida: ${listaCorridas[0]['endereco_destino']}, ${listaCorridas[0]['data']}, ${listaCorridas[0]['hora']}";
      });
    }
  }
  _adicionarListenerRequisicoes(){

    print("chegamos aqui nas requisicoes");
    final _stream = getCorridas(widget.usuario);
    print("concluimos");

    _stream.listen((dados){

      var jsonResponse =
      jsonDecode(dados.body);
      print("controller add : ${jsonResponse['travels']}");
      _controllerStream.add( jsonResponse['travels'] );

      print(_controllerStream.toString());
      _controllerStreamData = jsonResponse['travels'];

        });



  }
  Stream<http.Response> getCorridas(Usuario _usuario) async* {
    yield* Stream.periodic(Duration(minutes: 10), (_) async{
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
        _modificarTextoProximaCorrida();

      }
      return response;
    }).asyncMap((event) async => await event);
  }
  Future<String> _metodo(String local, String _categoria)async{
    final OpenRouteService ola = OpenRouteService(apiKey: "5b3ce3597851110001cf62480deb6eaf6268496980c7c64b8c0553dd");
    GeoJsonFeatureCollection helo = await ors.ORSGeocode(ola).geocodeAutoCompleteGet(text: local);
    print("HELLO");
    print(helo);
    print(helo.toString());
    List<dynamic> lista = helo.features;
    for(int i = 0; i<1; i++){
      print(lista[i].properties['label']);

      if(_categoria == "partida"){
        print("LATITUDE1");
        latitudePartida = lista[i].geometry.coordinates[0][0].latitude;
        print(lista[i].geometry.coordinates[0][0].latitude);
        print("LONGITUDE1");
        longitudePartida = lista[i].geometry.coordinates[0][0].longitude;
        print(lista[i].geometry.coordinates[0][0].longitude);
      }else{
        if(_categoria == "chegada"){
          print("LATITUDE2");
          latitudeChegada = lista[i].geometry.coordinates[0][0].latitude;
          print(lista[i].geometry.coordinates[0][0].latitude);
          print("LONGITUDE2");
          longitudeChegada = lista[i].geometry.coordinates[0][0].longitude;
          print(lista[i].geometry.coordinates[0][0].longitude);
        }
      }

    }
    return  lista[0].properties['label'];

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

    setState(() {
      if (position != null) {
        _exibirMarcadorPassageiro(position);

        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 19);
        _movimentarCamera(_posicaoCamera);
      }
    });
  }
  _exibirMarcadorPassageiro(Position local) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "imagens/passageiro.png")
        .then((BitmapDescriptor icone) {
      Marker marcadorPassageiro = Marker(
          markerId: MarkerId("marcador-passageiro"),
          position: LatLng(local.latitude, local.longitude),
          infoWindow: InfoWindow(title: "Meu local"),
          icon: icone);

      setState(() {
        _marcadores.add(marcadorPassageiro);
      });
    });
  }
  _movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  /*_acharLocal(String local)async{
    List<Location> locations = await locationFromAddress(local);
    print(locations[0]);
  }*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperaUltimaLocalizacaoConhecida();
    _adicionarListenerRequisicoes();
  }

  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        child: Stack(children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _posicaoCamera,
            onMapCreated: _onMapCreated,
            //myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _marcadores,
            //-23,559200, -46,658878
          ),
          Positioned(child: MaterialButton(
              child: Row(children: [
                SizedBox(
                    width: 230, child:
                Text(
                  _proximaCorrida,
                  softWrap: true,
                  style: TextStyle(color: Colors.lightGreenAccent, fontSize: 12,),
                )
                ),
                IconButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ProximasCorridas(categoriaUsuario: "usuario", usuario: widget.usuario, controller: _controllerStreamData, listaCorridas: listaCorridas,)

                  ));
                }, icon: Icon(Icons.expand_more), color: Colors.lightGreenAccent,)
              ],),
              color: Colors.black87,
              padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
              onPressed: (){
                setState(() {
                  _status = !_status;
                });
              }),),
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
                "Nova Corrida",
                style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                color: Colors.lightGreenAccent,
                padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                onPressed: (){
                  setState(() {
                  _status = !_status;
                });
                }),
                Padding(padding: EdgeInsets.only(top: 10)),
                AnimatedContainer(duration: Duration(milliseconds: 400), color: Colors.white, height: _status ? 0 : 300,
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.all(10),
                      child:
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            style: TextStyle(fontSize: 14),
                            controller: _origem,
                            autofocus: true,
                            onChanged: (String a){
                              _alterarVisibilidade("partida", a);


                              },
                            onSubmitted: (String a){
                              setState(() {
                                _origem.text = "";
                                _visivelPartida = false;
                              });
                            },

                            //_acharLocal(_origem.text),
                            decoration: InputDecoration(
                                labelText: "Local de Partida",
                                hintText: "Exemplo: Rua Manoel da Silva, 987",


                            ),
                          ),
                          Visibility(child: MaterialButton(
                            child: Text(_autoCorretorPartida), onPressed: (){
                              setState(() {
                                _origem.text = _autoCorretorPartida;
                                _concluidoPartida = true;
                              });
                          },
                          ), visible: _visivelPartida,),





                          TextField(style: TextStyle(fontSize: 14),

                            controller: _destino,
                            onChanged: (String a){ _alterarVisibilidade("chegada", a); },
                            onSubmitted: (String a){
                              setState(() {
                                _destino.text = "";
                                _visivelChegada = false;
                              });
                            },
                            decoration: InputDecoration(
                                labelText: "Destino:",
                                hintText: "Exemplo: Rua João de Souza, 1234",

                            ),
                          ),
                          Visibility(child: MaterialButton(
                            child: Text(_autoCorretorChegada), onPressed: (){
                            setState(() {
                              _destino.text = _autoCorretorChegada;
                              _concluidoChegada = true;
                            });
                          },
                          ), visible: _visivelChegada,),
                          Padding(padding: EdgeInsets.only(top: 14, bottom: 10),
                          child: Visibility(
                            visible: !(_concluidoPartida && _concluidoChegada),
                            child: Text(_textoAlerta,
                              style: TextStyle(color: Colors.black38),),),),

                          MaterialButton(
                              child: Text(
                                "Prossseguir",
                                style: TextStyle(color: Colors.lightGreenAccent, fontSize: 12),
                              ),
                              color: Colors.black54,
                              padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                              onPressed: (){
                                print("PARTIDA: $_concluidoPartida");
                                print("CHEGADA: $_concluidoChegada");
                                if(_concluidoChegada && _concluidoPartida){
                                  setState(() {
                                    _textoAlerta = "";
                                  });
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => Questionary(usuario: widget.usuario, origem: _origem.text, destino: _destino.text,
                                          latitudePartida: latitudePartida, longitudePartida: longitudePartida,
                                          latitudeChegada: latitudeChegada, longitudeChegada: longitudeChegada,
                                      )

                                  ));
                                  setState(() {
                                    _status = !_status;
                                  });
                                }else{
                                  setState(() {
                                    _textoAlerta = "Selecione um Endereço";
                                  });

                                  }
                                }

                              ),
                        ],
                      ),


                      )],
                ),)


              ],)
            ),
          )
        ],)
      ),
    );
  }
}
