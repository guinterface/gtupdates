import 'package:flutter/material.dart';

class Usuario {

  int _id = 0;
  String _imagem_perfil = "";
  String _matricula = "";
  String _nome = "";
  String _email = "";
  String _username = "";
  String _senha = "";
  bool _status = false;
  int _id_setor = 0;
  int _id_cliente = 0;
  String _cod_notification = "";
  int _id_usuario_sistema = 0;
  String _data_hora_cadastro = "";
  bool _usuario_superintendente = false;
  bool _exist = false;
  bool _termo = false;





  Usuario();

  Map<String, dynamic> toMap() {


    Map<String, dynamic> map = {
    "id" : this.id,
    "imagem_perfil": this.imagem_perfil,
    "matricula ": this.matricula,
    "nome" : this.nome,
    "email" : this.email,
    "username": this.username,
    "senha" : this.senha,
    "status" : this.status,
    "id_setor" : this.id_setor,
    "id_cliente" : this.id_cliente,
    "cod_notification" : this.cod_notification,
    "id_usuario_sistema": this.id_usuario_sistema,
    "data_hora_cadastro"  : this.data_hora_cadastro,
    "usuario_superintendente" : this.usuario_superintendente,
    "exist" : this.exist,
    "termo" : this.termo,





    };
    return map;

  }



  bool get termo => _termo;

  set termo(bool value) {
    _termo = value;
  }

  bool get exist => _exist;

  set exist(bool value) {
    _exist = value;
  }

  bool get usuario_superintendente => _usuario_superintendente;

  set usuario_superintendente(bool value) {
    _usuario_superintendente = value;
  }

  String get data_hora_cadastro => _data_hora_cadastro;

  set data_hora_cadastro(String value) {
    _data_hora_cadastro = value;
  }

  int get id_usuario_sistema => _id_usuario_sistema;

  set id_usuario_sistema(int value) {
    _id_usuario_sistema = value;
  }

  String get cod_notification => _cod_notification;

  set cod_notification(String value) {
    _cod_notification = value;
  }

  int get id_cliente => _id_cliente;

  set id_cliente(int value) {
    _id_cliente = value;
  }

  int get id_setor => _id_setor;

  set id_setor(int value) {
    _id_setor = value;
  }

  bool get status => _status;

  set status(bool value) {
    _status = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get username => _username;

  set username(String value) {
    _username = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get matricula => _matricula;

  set matricula(String value) {
    _matricula = value;
  }

  String get imagem_perfil => _imagem_perfil;

  set imagem_perfil(String value) {
    _imagem_perfil = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }


}



class QAItem extends StatelessWidget {
  const QAItem({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  final Widget title;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      backgroundColor: Colors.black12,
      title: title,
      children: children,
    );
  }
}


 class Motorista extends Usuario {

  String _telefone = "";
  int _id_cidade = 0;
  bool _motoirsta_superintendente = false;
  String _horario_entrada = "";
  String _horario_saida = "";
  int _valor_hora_extra = 0;




  Motorsita() {
    // TODO: implement Motorsita
    throw UnimplementedError();
  }

  Map<String, dynamic> toMap() {


    Map<String, dynamic> map = {
      "id" : this.id,
      "imagem_perfil": this.imagem_perfil,
      "matricula ": this.matricula,
      "nome" : this.nome,
      "email" : this.email,
      "username": this.username,
      "senha" : this.senha,
      "status" : this.status,
      "id_setor" : this.id_setor,
      "id_cliente" : this.id_cliente,
      "cod_notification" : this.cod_notification,
      "id_usuario_sistema": this.id_usuario_sistema,
      "data_hora_cadastro"  : this.data_hora_cadastro,
      "usuario_superintendente" : this.usuario_superintendente,
      "exist" : this.exist,
      "termo" : this.termo,
      "telefone" : this.telefone,
      "id_cidade" : this.id_cidade,
      "motorista_superintendente" : this.motoirsta_superintendente,
      "horario_entrada" : this.horario_entrada,
      "horario_saida": this.horario_saida,
      "valor_hora_extra": this.valor_hora_extra






    };
    return map;

  }

  String get telefone => _telefone;

  set telefone(String value) {
    _telefone = value;
  }


  int get id_cidade => _id_cidade;

  set id_cidade(int value) {
    _id_cidade = value;
  }

  int get valor_hora_extra => _valor_hora_extra;

  set valor_hora_extra(int value) {
    _valor_hora_extra = value;
  }

  String get horario_saida => _horario_saida;

  set horario_saida(String value) {
    _horario_saida = value;
  }

  String get horario_entrada => _horario_entrada;

  set horario_entrada(String value) {
    _horario_entrada = value;
  }

  bool get motoirsta_superintendente => _motoirsta_superintendente;

  set motoirsta_superintendente(bool value) {
    _motoirsta_superintendente = value;
  }
}