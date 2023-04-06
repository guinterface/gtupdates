import 'dart:io';
//import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:untitled/Pages/Questionary.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import '../Classes/Usuario.dart';

class Principal extends StatefulWidget {
  final Usuario usuario;
  Principal({Key? key, required this.usuario}) : super(key: key);

  @override
  _PrincipalState createState() => _PrincipalState();
}


class _PrincipalState extends State<Principal> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  bool _status = true;
  Set<Marker> _marcadores = {};
  TextEditingController _origem = TextEditingController();
  TextEditingController _destino = TextEditingController();
  CameraPosition _posicaoCamera = CameraPosition(target: LatLng(0.1, 0.1), zoom: 19);
 // GeoMethods geoMethods = GeoMethods(googleApiKey: googleApiKey, language: language);

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
    //_recuperaUltimaLocalizacaoConhecida();
  }

  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        child: Stack(children: [
          /*GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _posicaoCamera,
            onMapCreated: _onMapCreated,
            //myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _marcadores,
            //-23,559200, -46,658878
          ),*/
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
                AnimatedContainer(duration: Duration(milliseconds: 400), color: Colors.white, height: _status ? 0 : 200,
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

                            //_acharLocal(_origem.text),
                            decoration: InputDecoration(
                                labelText: "Local de Partida",
                                hintText: "",

                            ),
                          ),





                          TextField(style: TextStyle(fontSize: 14),
                            controller: _destino,
                            decoration: InputDecoration(
                                labelText: "Destino:",
                                hintText: "Exemplo: Segunda a quinta"
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 14)),

                          MaterialButton(
                              child: Text(
                                "Prossseguir",
                                style: TextStyle(color: Colors.lightGreenAccent, fontSize: 12),
                              ),
                              color: Colors.black54,
                              padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => Questionary(usuario: widget.usuario, origem: _origem.text, destino: _destino.text,)

                                ));
                                setState(() {
                                  _status = !_status;
                                });
                              }),
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
