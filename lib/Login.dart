
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:untitled/Pages/Motorista/DashboardMotorista.dart';
import 'dart:convert';
import 'Classes/Usuario.dart';
import 'Classes/UsuarioFirebase.dart';
import 'Inicio.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'Pages/Motorista/GeralMotorista.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String mensagemErro = "";
  bool _categoriaUsuario = false;

  getDataUsuario(Usuario usuario) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var url = Uri.parse(
        'https://obdi.com.br/obdigt/api/usuario/login'); // Url of the website where we get the data from.
    var request = http.Request('POST', url); // Now set our  request to POST
    request.bodyFields = {"username": "${usuario.username}",
      "senha": "${usuario.senha}" ,};
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send(); // Send request.
    // Check if response is okay
    if (response.statusCode == 200) {
      dynamic data =
      await response.stream.bytesToString();
      String _nome =  "${jsonDecode(data)['nome']}"; // Turn bytes to readable data.
      setState(() => _controllerEmail.text = data);
      //log("@@@ responde ${response as String}");
      Usuario usuario = Usuario();
      usuario.email = jsonDecode(data)['email'];
      usuario.exist = verifica(jsonDecode(data)['exist']) ;
      usuario.nome = jsonDecode(data)['nome'];
      usuario.imagem_perfil = jsonDecode(data)['imagem_perfil'] == null ? "" : jsonDecode(data)['imagem_perfil'];
      usuario.matricula = jsonDecode(data)['matricula'] == null ? "" : jsonDecode(data)['matricula'] ;
      usuario.username = jsonDecode(data)['username'];
      usuario.senha = jsonDecode(data)['senha'];
      usuario.status = verifica( jsonDecode(data)['status']);
      usuario.id_setor = jsonDecode(data)['id_setor'];
      usuario.id_cliente = jsonDecode(data)['id_cliente'];
      usuario.id = jsonDecode(data)['id'];
      usuario.id_usuario_sistema = jsonDecode(data)['id_usuario_sistema'];
      usuario.data_hora_cadastro = jsonDecode(data)['data_hora_cadastro'];
      usuario.usuario_superintendente = verifica(jsonDecode(data)['usuario_superintendente']);
      usuario.termo = verifica(jsonDecode(data)['termo']);
      usuario.cod_notification = jsonDecode(data)['cod_notification'];
      usuario.usuario_ou_motorista = _categoriaUsuario;
     // getCorridas(usuario);
      List<String> arguments = [];
      getRaces(arguments, usuario);
      acharToken(usuario);
     //_logarUsuario(usuario);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Inicio(usuario: usuario)),

      );
    } else {
      print("${response.statusCode} - Something went wrong..");
    }
  }
  getDataMotorsita(Motorista motorista) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var url = Uri.parse(
        'https://obdi.com.br/obdigt/api/motorista/login'); // Url of the website where we get the data from.
    var request = http.Request('POST', url); // Now set our  request to POST
    request.bodyFields = {"username": "${motorista.username}",
      "senha": "${motorista.senha}" ,};
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send(); // Send request.
    // Check if response is okay
    if (response.statusCode == 200) {
      dynamic data =
      await response.stream.bytesToString();
      String _nome =  "${jsonDecode(data)['nome']}"; // Turn bytes to readable data.
      setState(() => _controllerEmail.text = data);
      print(data);
      var dados = jsonDecode(data);
      //log("@@@ responde ${response as String}");
      Motorista motorista = Motorista();
      motorista.email = dados['email'];
      motorista.nome = dados['nome'];
      motorista.imagem_perfil = dados['imagem_perfil'] == null ? "" : dados['imagem_perfil'];
      motorista.username = dados['username'];
      motorista.senha = dados['senha'];
      motorista.status = verifica( dados['status']);
      motorista.id = dados['id'];
      motorista.id_usuario_sistema = dados['id_usuario_sistema'];
      motorista.data_hora_cadastro = dados['data_hora_cadastro'];
      motorista.cod_notification = dados['cod_notification']== null ? "" : dados['cod_notification'];
      motorista.exist = verifica(dados['exist']);
      motorista.id_cidade = dados['id_cidade'];
      motorista.telefone = dados['telefone'];
      motorista.termo = verifica(dados['termo']);

      // getCorridas(usuario);
      //TODO acharToken(motorista);
      //_logarUsuario(motorista);

     Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GeralMotorista(motorista: motorista)),

      );
    } else {
      print("${response.statusCode} - Something went wrong..");
    }
  }
  acharToken(Usuario _usuario)async{
    String? deviceToken = await FirebaseMessaging.instance.getToken();
    print("TOKEN: $deviceToken");

    //var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var url = Uri.parse(
        'https://obdi.com.br/obdigt/api/usuario/update_cod_notify/${_usuario.id}/${deviceToken}'); // Url of the website where we get the data from.
    var request = http.Request('GET', url); // Now set our  request to POST
    //request.headers.addAll(headers);
    http.StreamedResponse response = await request.send(); // Send request.
    if (response.statusCode == 200) {
      dynamic data =
      await response.stream.bytesToString();
      print("Conseguimos $data");


    } else {
      print("${response.statusCode} - Something went wrong..");
    }

  }

  bool verifica(int booleano){
    if(booleano == 1){
      return true;
    }
    return false;
  }
  getCorridas(Usuario _usuario)async{
    print(_usuario.id);
final dadosCorridas =
  await http.get(Uri.parse("https://obdi.com.br/obdigt/api/ultimas_corridas/${_usuario.id}"));
if(dadosCorridas.statusCode == 200){
  setState(() => _controllerEmail.text = dadosCorridas.body);

}else{
  for(int i = 0; i< 25; i++){print("ERRO");}

}

  }


  void getRaces(List<String> arguments, Usuario _usuario) async {
    print("Ate aqui");
    var url = Uri.parse("https://obdi.com.br/obdigt/api/usuario/ultimas_corridas/${_usuario.id}");

    // You will wait for the response and then decode the JSON string.
    var response = await http.get(url);
    if (response.statusCode != 200) {
      print("${response.statusCode}");
    } else {
      var jsonResponse =
           jsonDecode(response.body) as Map<String, dynamic>;

      print('Number of books about http: ${jsonResponse['travels'][0]['id']}');
    }
  }
  _verificaCadastro()async{

    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var url = Uri.parse(
        'https://obdi.com.br/obdigt/api/usuario/login'); // Url of the website where we get the data from.
    var request = http.Request('POST', url); // Now set our  request to POST
    request.bodyFields = {"username": _controllerEmail.text,
      "senha": _controllerSenha.text,};
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send(); // Send request.
    // Check if response is okay
    if (response.statusCode == 200) {
      dynamic data =
      await response.stream.bytesToString();
      bool exist =  jsonDecode(data)["exist"];
      if(exist){
        _criarUsuario(data); // Turn bytes to readable data.
      }
      setState(() => _controllerEmail.text = data);
      log("@@@ responde ${response as String}");
    } else {
      print("${response.statusCode} - Something went wrong..");
    }
  }
  _criarUsuario(String dataUsuario){
    Usuario usuario = Usuario();
    usuario.id = jsonDecode(dataUsuario)["id"];
    usuario.termo = jsonDecode(dataUsuario)["termo"];
    usuario.exist = jsonDecode(dataUsuario)["exist"];
    usuario.usuario_superintendente = jsonDecode(dataUsuario)["usuario_superintendente"];
    usuario.data_hora_cadastro = jsonDecode(dataUsuario)["id_usuario_sistema"];
    usuario.id_usuario_sistema = jsonDecode(dataUsuario)["id"];
    usuario.cod_notification = jsonDecode(dataUsuario)["cod_notification"];
    usuario.id_cliente = jsonDecode(dataUsuario)["id_cliente"];
    usuario.id_setor = jsonDecode(dataUsuario)["id_setor"];
    usuario.status = jsonDecode(dataUsuario)["status"];
    usuario.senha = jsonDecode(dataUsuario)["senha"];
    usuario.username = jsonDecode(dataUsuario)["username"];
    usuario.email = jsonDecode(dataUsuario)["email"];
    usuario.matricula = jsonDecode(dataUsuario)["matricula"];
    usuario.imagem_perfil = jsonDecode(dataUsuario)["imagem_perfil"];
    usuario.nome = jsonDecode(dataUsuario)["nome"];


  }
  _cadastrarUsuario( Usuario usuario ){
    FirebaseFirestore db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    auth.createUserWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha
    ).then((firebaseUser){
 }).catchError((error){
      print("erro app: " + error.toString() );
      setState(() {
        mensagemErro = "Erro ao cadastrar usuário, verifique os campos e tente novamente!";
      });

    });

  }

  _validarCampos(){


    String _email = _controllerEmail.text;
    String _senha = _controllerSenha.text;
    if(_senha.isNotEmpty){
      if(_email.isNotEmpty){
        setState(() {
          mensagemErro = "";

        });

        if(!_categoriaUsuario){
          Usuario usuario = Usuario();
          usuario.username = _email;
          usuario.senha = _senha;
          getDataUsuario(usuario);
        }else{
          Motorista motorista = Motorista();
          motorista.username = _email;
          motorista.senha = _senha;
          getDataMotorsita(motorista);
        }



      }else{ setState(() {
        mensagemErro = "Preencha o e-mail!";
      });}
    }else{ setState(() {
      mensagemErro = "Preencha a sua senha!";
    });}
  }
  _logarUsuario(Usuario usuario){
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(
        email: usuario.email, password: usuario.senha
    ).then((firebaseUser){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Inicio(usuario: usuario,)),

      );
    }).catchError((){

      setState(() {
        mensagemErro = " Algo deu errado, tente novamente! ";
      });

    })
    ;


  }

  setSelectedRadio(bool value){
    setState(() {
      _categoriaUsuario = value;
    });
  }
  Future _verificaUsuarioLogado()async{
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = await auth.currentUser;
    if(usuarioLogado != null){
      Usuario _usuario = Usuario();
      _usuario.email = usuarioLogado!.email!;
      //getDataUsuario(_usuario);
      /*Navigator.push(context, MaterialPageRoute(
          builder: (context) => Inicio(usuario: ,)

      ));

*/
    }

  }
  @override
  void initState() {
    _verificaUsuarioLogado();
    // TODO: implement initState
    super.initState();
    //_verificaCadastro();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(

        decoration: BoxDecoration(color: Colors.black87
       , /*image: DecorationImage(
            image: AssetImage("bck1/bck1.png"),
            fit: BoxFit.cover
        )*/

        ),


        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Padding(

                  padding: EdgeInsets.only(top: 2, left: 12, ),
                  child:  Text("Olá,", style: TextStyle(fontSize: 22, color: Colors.lightGreenAccent)),
                ) ,
                Padding(padding: EdgeInsets.only(top: 2, left: 8, right: 32, bottom: 32),
                    child:  Text("bem-vindo de volta!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent),)
                ) ,
                Padding(padding: EdgeInsets.only(top: 0),
                  child: TextField(autofocus: true,
                    controller: _controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 2, 32, 16),
                        hintText: ("E-mail"),
                        filled: true,
                        fillColor: Colors.lightGreenAccent,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32)
                        )
                    ),
                  ),
                ),
                TextField(obscureText : true,
                  controller: _controllerSenha,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: ("Senha"),
                      filled: true,
                      fillColor: Colors.lightGreenAccent,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)
                      )
                  ),
                ),

                Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

                  Padding(padding: EdgeInsets.only(top: 16, bottom: 10),
                    child: MaterialButton(
                      child: Text("Entrar", style: TextStyle(color: Colors.black54 , fontSize: 20),),
                      color: Colors.lightGreenAccent,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)
                      ),
                      onPressed: (){

                        _validarCampos();

                      },
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      child: Text("CRIE UMA CONTA", style: TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.bold),),
                      onTap: ()async{
                        Usuario usuario = Usuario();
                        usuario.username = _controllerEmail.text;
                        usuario.senha = _controllerSenha.text;
                        getDataUsuario(usuario);
                        _cadastrarUsuario(usuario);
                        /*
                      User1 user = await createuser();
                      setState(() {
                        _controllerEmail.text = user.senha;
                      });*/

                        /*
                      Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => Cadastro()

                      )
                      );*/
                      },
                    ),
                  ),

                ],)
                , Padding (
                  padding: EdgeInsets.only(top: 16),),

                Text(
                  mensagemErro, style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 20
                ),

                ),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Usuario", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),),
                        SizedBox(height: 50, width: 50,
                          child:  Switch(value: _categoriaUsuario, onFocusChange: (val){
                          setSelectedRadio(val);
                        }, onChanged: (val){
                          setSelectedRadio(val);

                        },


                        )
                          ,),
                        Text("Motorista", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),),
                      ],
                    )






              ],
            ),
          ),
        ),


      ),

    );
  }
}