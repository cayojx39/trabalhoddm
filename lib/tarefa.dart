import 'package:flutter/material.dart';

enum Prioridade { baixa, media, alta }

class Tarefa {
  final int? id;
  final String titulo;
  final String descricao;
  final Prioridade prioridade;
  final int horasEstimadas;
  final bool concluida;
  final DateTime? dataEntrega;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    this.prioridade = Prioridade.media,
    this.horasEstimadas = 1,
    this.concluida = false,
    this.dataEntrega,
  });

  String get prioridadeTexto {
    switch (prioridade) {
      case Prioridade.baixa:
        return 'Baixa';
      case Prioridade.media:
        return 'Média';
      case Prioridade.alta:
        return 'Alta';
    }
  }

  Color get corPrioridade {
    switch (prioridade) {
      case Prioridade.baixa:
        return Colors.green;
      case Prioridade.media:
        return Colors.orange;
      case Prioridade.alta:
        return Colors.redAccent;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'titulo': titulo,
      'descricao': descricao,
      'prioridade': prioridade.name,
      'horas_estimadas': horasEstimadas,
      'concluida': concluida ? 1 : 0,
      'data_entrega': dataEntrega == null
          ? null
          : DateTime(dataEntrega!.year, dataEntrega!.month, dataEntrega!.day)
              .toIso8601String()
              .substring(0, 10),
    };
  }

  static Tarefa fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      prioridade: Prioridade.values.firstWhere(
        (Prioridade valor) => valor.name == map['prioridade'],
        orElse: () => Prioridade.media,
      ),
      horasEstimadas: map['horas_estimadas'] as int,
      concluida: (map['concluida'] as int) == 1,
      dataEntrega: map['data_entrega'] == null
          ? null
          : DateTime.parse(map['data_entrega'] as String),
    );
  }
}
