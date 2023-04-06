
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/Classes/Usuario.dart';

import 'dart:io';

import 'package:untitled/Inicio.dart';
import 'package:untitled/Pages/Profile/MinhasCorridas.dart';




class ProfileMotorista extends StatefulWidget {
  final Motorista motorista;
  ProfileMotorista({Key? key, required this.motorista}) : super(key: key);
  @override
  _ProfileMotoristaState createState() => _ProfileMotoristaState();

}

class _ProfileMotoristaState extends State<ProfileMotorista> {

  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerDes = TextEditingController();
  File? _imagem;
  String _idUsuarioLogado = "";
  bool _subindoImagem = false;
  String _urlImagemRecuperada = "";


  Future _recuperarImagem(String origemImagem) async {
    XFile imagemSelecionada;
    final ImagePicker _picker = ImagePicker();
    if(origemImagem == "galeria"){
      imagemSelecionada = (await _picker.pickImage(source: ImageSource.gallery) )! ;
    }else{
      imagemSelecionada = (await _picker.pickImage(source: ImageSource.camera) )! ;
    }

    setState(() {

      _imagem =  File(imagemSelecionada.path);
      if( _imagem != null ){
        _subindoImagem = true;
        _uploadImagem();
      }
    });

  }

  Future _uploadImagem() async {

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child("perfil")
        .child(_idUsuarioLogado + ".jpg");

    //Upload da imagem
    UploadTask task = arquivo.putFile(_imagem!);

    //Controlar progresso do upload
    task.snapshotEvents.listen((TaskSnapshot storageEvent){

      if( storageEvent.state == TaskState.running ){
        setState(() {
          _subindoImagem = true;
        });
      }else if( storageEvent.state == TaskState.success ){
        setState(() {
          _subindoImagem = false;
        });
      }

    });

    //Recuperar url da imagem
    task.whenComplete(() => null).then((TaskSnapshot snapshot){
      _recuperarUrlImagem(snapshot);
    });


  }

  Future _recuperarUrlImagem(TaskSnapshot snapshot) async {

    String url = await snapshot.ref.getDownloadURL();
    _atualizarUrlImagemFirestore( url );

    setState(() {
      _urlImagemRecuperada = url;
    });

  }

  _atualizarNomeFirestore(){

    String nome = _controllerNome.text;
    String des  = _controllerDes.text;
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "nome" : nome,
      "descricao" : des
    };

    db.collection("usuarios")
        .doc(_idUsuarioLogado)
        .update( dadosAtualizar );

  }

  _atualizarUrlImagemFirestore(String url){

    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "foto" : url
    };

    db.collection("usuarios")
        .doc(_idUsuarioLogado)
        .update( dadosAtualizar );

  }


  _recuperarDadosUsuario() async {


    String _foto = widget.motorista.imagem_perfil;
    if( _foto != null ){
      setState(() {
        _urlImagemRecuperada = _foto;
        print("ACHAMOS A");
        print(_urlImagemRecuperada);
        _controllerNome.text = widget.motorista.nome;
      });

    }

  }




  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,

      body: Container(
        padding: EdgeInsets.all(6),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(3),
                  child: _subindoImagem
                      ? CircularProgressIndicator()
                      : Container(),
                ),

                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                        radius: 75,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                        _urlImagemRecuperada != null
                            ? NetworkImage(_urlImagemRecuperada)
                            : null
                    )
                  ], ),




                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    MaterialButton(
                      child: Text("Câmera", style: TextStyle(color: Colors.white),),
                      onPressed: (){
                        _recuperarImagem("camera");

                      },
                    ),
                    MaterialButton(
                      child: Text("Galeria", style: TextStyle(color: Colors.white),),
                      onPressed: (){
                        _recuperarImagem("galeria");
                      },
                    )
                  ],
                ),
                Padding(

                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    cursorColor: Colors.lightGreenAccent,
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    onChanged: (texto){
                      _atualizarNomeFirestore();
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 8, 8, 16),
                      hintText: "Nome",
                      filled: true,
                      focusColor: Colors.lightGreenAccent,
                      fillColor: Colors.white,
                      hoverColor: Colors.lightGreenAccent,

                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),

                ),
                Padding(padding:
                EdgeInsets.all(12),
                  child: MaterialButton(
                    padding: EdgeInsets.all(20),
                    color: Colors.lightGreenAccent,
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => MinhasCorridas(usuario: widget.motorista)
                      ));
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [

                        SizedBox(width: 20,),
                        Text("Últimas Corridas", style: TextStyle(color: Colors.black),),



                      ],
                    ),
                  ),
                ),
                Padding(padding:
                EdgeInsets.all(12),
                  child: MaterialButton(
                    padding: EdgeInsets.all(20),
                    color: Colors.lightGreenAccent,
                    onPressed: (){
                      /* Navigator.push(context, MaterialPageRoute(
                          builder: (context) => Inicio()
                      ));*/
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [

                        SizedBox(width: 20,),
                        Text("Corridas Canceladas", style: TextStyle(color: Colors.black),),



                      ],
                    ),
                  ),
                ),



                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: MaterialButton(
                      child: Text(
                        "Salvar",
                        style: TextStyle(color: Colors.lightGreenAccent, fontSize: 20),
                      ),
                      color: Colors.black38,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        _atualizarNomeFirestore();
                      }
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}