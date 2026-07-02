import 'package:flutter/material.dart';

import 'tarefa.dart';

class PaginaDetalhesTarefa extends StatelessWidget {
  final Tarefa tarefa;

  const PaginaDetalhesTarefa({super.key, required this.tarefa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Tarefa'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tarefa.titulo,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(tarefa.descricao),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Chip(label: Text('Prioridade: ${tarefa.prioridadeTexto}')),
                        const SizedBox(width: 8),
                        Chip(label: Text('Horas: ${tarefa.horasEstimadas}h')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tarefa.concluida ? 'Esta tarefa já foi concluída.' : 'Ainda está pendente.',
              style: TextStyle(
                fontSize: 16,
                color: tarefa.concluida ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
