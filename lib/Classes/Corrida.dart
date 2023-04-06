import 'package:flutter/material.dart';

class Corrida {

  int _id = 0;
  String _data = "";
  String _hora = "";
  String _data_retorno = "";
  String _hora_retorno = "";
  String _cep_partida = "";
  String _endereco_partida = "";
  int _numero_partida = 0;
  String _complemento_partida = "";
  String _bairro_partida = "";
  String _cidade_partida = "";
  String _estado_partida = "";
  String _cep_destino = "";
  String _endereco_destino = "";
  int _numero_destino = 0;
  String _complemento_destino = "";
  String _bairro_destino = "";
  String _cidade_destino = "";
  String _estado_destino = "";
  String _id_tamanho_bagagem = "";
  int _tipo_necessidade = 0;
  String _reason_cancel = "";
  int _tipo = 2;
  String _observacoes = "";
  int _id_motorista = 0;
  int _id_usuario = 0;
  int _id_socilicitante = 0;
  int _codigo_agendamento = 0;
  int _id_usuario_sistema = 0;
  int _id_gerente = 0;
  String _data_hora_cadastro = "";
  String _data_hora_aprovacao = "";
  int _id_aprovador = 0;
  int _km_inicial = 0;
  int _km_final = 0;
  int _ordem = 0;
  String _placa = "";
  int _id_categoria_carro = 0;
  int _id_gps_ini = 0;
  int _id_gps_fim = 0;
  bool _viagem_atestada = false;
  bool _motorista_visualizou_viagem = false;
  String _justificativa = "";
  bool _pernoite = false;





  Corrida();

  Map<String, dynamic> toMap() {


    Map<String, dynamic> map = {
      "id": this.id,
      "data": this.data,
      "hora": this.hora,
      "data_retorno": this.data_retorno,
      "hora_retorno": this.hora_retorno,
      "cep_partida": this.cep_partida,
      "endereco_partida": this.endereco_partida,
      "numero_partida": this.numero_partida,
      "complemento_partida": this.complemento_partida,
      "bairro_partida": this.bairro_partida,
      "cidade_partida": this.cidade_partida,
      "estado_partida": this.estado_partida,
      "cep_destino": this.cep_destino,
      "endereco_destino": this.endereco_destino,
      "numero_destino": this.numero_destino,
      "complemento_destino": this.complemento_destino,
      "bairro_destino": this.bairro_destino,
      "cidade_destino": this.cidade_destino,
      "estado_destino": this.estado_destino,
      "id_tamanho_bagagem": this.id_tamanho_bagagem,
      "tipo_necessidade": this.tipo_necessidade,
      "reason_cancel": this.reason_cancel,
      "tipo": this.tipo,
      "observacoes": this.observacoes,
      "id_motorista": this.id_motorista,
      "id_usuario": this.id_usuario,
      "id_socilicitante": this.id_socilicitante,
      "codigo_agendamento": this.codigo_agendamento,
      "id_usuario_sistema": this.id_usuario_sistema,
      "id_gerente": this.id_gerente,
      "data_hora_cadastro": this.data_hora_cadastro,
      "data_hora_aprovacao": this.data_hora_aprovacao,
      "id_aprovador": this.id_aprovador,
      "km_inicial": this.km_inicial,
      "km_final": this.km_final,
      "ordem": this.ordem,
      "placa": this.placa,
      "id_categoria_carro": this.id_categoria_carro,
      "id_gps_ini": this.id_gps_ini,
      "id_gps_fim": this.id_gps_fim,
      "viagem_atestada": this.viagem_atestada,
      "motorista_visualizou_viagem": this.motorista_visualizou_viagem,
      "justificativa": this.justificativa,
      "pernoite": this.pernoite,



  };
    return map;

  }

  bool get pernoite => _pernoite;

  set pernoite(bool value) {
    _pernoite = value;
  }

  String get justificativa => _justificativa;

  set justificativa(String value) {
    _justificativa = value;
  }

  bool get motorista_visualizou_viagem => _motorista_visualizou_viagem;

  set motorista_visualizou_viagem(bool value) {
    _motorista_visualizou_viagem = value;
  }

  bool get viagem_atestada => _viagem_atestada;

  set viagem_atestada(bool value) {
    _viagem_atestada = value;
  }

  int get id_gps_fim => _id_gps_fim;

  set id_gps_fim(int value) {
    _id_gps_fim = value;
  }

  int get id_gps_ini => _id_gps_ini;

  set id_gps_ini(int value) {
    _id_gps_ini = value;
  }

  int get id_categoria_carro => _id_categoria_carro;

  set id_categoria_carro(int value) {
    _id_categoria_carro = value;
  }

  String get placa => _placa;

  set placa(String value) {
    _placa = value;
  }

  int get ordem => _ordem;

  set ordem(int value) {
    _ordem = value;
  }

  int get km_final => _km_final;

  set km_final(int value) {
    _km_final = value;
  }

  int get km_inicial => _km_inicial;

  set km_inicial(int value) {
    _km_inicial = value;
  }

  int get id_aprovador => _id_aprovador;

  set id_aprovador(int value) {
    _id_aprovador = value;
  }

  String get data_hora_aprovacao => _data_hora_aprovacao;

  set data_hora_aprovacao(String value) {
    _data_hora_aprovacao = value;
  }

  String get data_hora_cadastro => _data_hora_cadastro;

  set data_hora_cadastro(String value) {
    _data_hora_cadastro = value;
  }

  int get id_gerente => _id_gerente;

  set id_gerente(int value) {
    _id_gerente = value;
  }

  int get id_usuario_sistema => _id_usuario_sistema;

  set id_usuario_sistema(int value) {
    _id_usuario_sistema = value;
  }

  int get codigo_agendamento => _codigo_agendamento;

  set codigo_agendamento(int value) {
    _codigo_agendamento = value;
  }

  int get id_socilicitante => _id_socilicitante;

  set id_socilicitante(int value) {
    _id_socilicitante = value;
  }

  int get id_usuario => _id_usuario;

  set id_usuario(int value) {
    _id_usuario = value;
  }

  int get id_motorista => _id_motorista;

  set id_motorista(int value) {
    _id_motorista = value;
  }

  String get observacoes => _observacoes;

  set observacoes(String value) {
    _observacoes = value;
  }

  int get tipo => _tipo;

  set tipo(int value) {
    _tipo = value;
  }

  String get reason_cancel => _reason_cancel;

  set reason_cancel(String value) {
    _reason_cancel = value;
  }

  int get tipo_necessidade => _tipo_necessidade;

  set tipo_necessidade(int value) {
    _tipo_necessidade = value;
  }

  String get id_tamanho_bagagem => _id_tamanho_bagagem;

  set id_tamanho_bagagem(String value) {
    _id_tamanho_bagagem = value;
  }

  String get estado_destino => _estado_destino;

  set estado_destino(String value) {
    _estado_destino = value;
  }

  String get cidade_destino => _cidade_destino;

  set cidade_destino(String value) {
    _cidade_destino = value;
  }

  String get bairro_destino => _bairro_destino;

  set bairro_destino(String value) {
    _bairro_destino = value;
  }

  String get complemento_destino => _complemento_destino;

  set complemento_destino(String value) {
    _complemento_destino = value;
  }

  int get numero_destino => _numero_destino;

  set numero_destino(int value) {
    _numero_destino = value;
  }

  String get endereco_destino => _endereco_destino;

  set endereco_destino(String value) {
    _endereco_destino = value;
  }

  String get cep_destino => _cep_destino;

  set cep_destino(String value) {
    _cep_destino = value;
  }

  String get estado_partida => _estado_partida;

  set estado_partida(String value) {
    _estado_partida = value;
  }

  String get cidade_partida => _cidade_partida;

  set cidade_partida(String value) {
    _cidade_partida = value;
  }

  String get bairro_partida => _bairro_partida;

  set bairro_partida(String value) {
    _bairro_partida = value;
  }

  String get complemento_partida => _complemento_partida;

  set complemento_partida(String value) {
    _complemento_partida = value;
  }

  int get numero_partida => _numero_partida;

  set numero_partida(int value) {
    _numero_partida = value;
  }

  String get endereco_partida => _endereco_partida;

  set endereco_partida(String value) {
    _endereco_partida = value;
  }

  String get cep_partida => _cep_partida;

  set cep_partida(String value) {
    _cep_partida = value;
  }

  String get hora_retorno => _hora_retorno;

  set hora_retorno(String value) {
    _hora_retorno = value;
  }

  String get data_retorno => _data_retorno;

  set data_retorno(String value) {
    _data_retorno = value;
  }

  String get hora => _hora;

  set hora(String value) {
    _hora = value;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
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


