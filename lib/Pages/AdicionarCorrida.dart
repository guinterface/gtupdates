import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;
import 'package:latlong2/latlong.dart' as LatLng;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:maps_toolkit/src/latlng.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:open_route_service/open_route_service.dart' as ors;

class MapScreen extends StatefulWidget {


  @override
  State<MapScreen> createState() => _MapScreenState();
}


class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperaUltimaLocalizacaoConhecida();
    adicionarListenerLocalizacao();
    _metodo();
  }
  // Raw coordinates got from  OpenRouteService
  List listOfPoints = [];

  late final MapController _controller =
  MapController();

  // Conversion of listOfPoints into LatLng(Latitude, Longitude) list of points
  List<LatLng.LatLng> points = [];
  List<LatLng.LatLng> recoveredPoints = [];
  List<toolkit.LatLng> convertedPoints = [];
   String baseUrl = 'https://api.openrouteservice.org/v2/directions/driving-car';
   String apiKey = '5b3ce3597851110001cf6248f55d7a31499e40848c6848d7de8fa624';
   LatLng.LatLng posicaoCamera = LatLng.LatLng(6.131015, 1.223898);
   int k =0;
  double distancia = 0;

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

  void _metodo(){
    final OpenRouteService ola = OpenRouteService(apiKey: "5b3ce3597851110001cf62480deb6eaf6268496980c7c64b8c0553dd");
    Future<GeoJsonFeatureCollection> helo = ors.ORSGeocode(ola).geocodeAutoCompleteGet(text: "Cuiaba");
    print(helo);
    print(helo.toString());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => getCoordinates(),
        child: const Icon( Icons.route,
          color: Colors.white,
        ),
      ),
    );
  }
}