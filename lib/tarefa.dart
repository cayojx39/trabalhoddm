import 'package:flutter/material.dart';

enum Prioridade { baixa, media, alta }

class Tarefa {
  final String titulo;
  final String descricao;
  final Prioridade prioridade;
  final int horasEstimadas;
  final bool concluida;

  Tarefa({
    required this.titulo,
    required this.descricao,
    this.prioridade = Prioridade.media,
    this.horasEstimadas = 1,
    this.concluida = false,
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
}
