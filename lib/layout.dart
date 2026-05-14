import 'package:flutter/material.dart';

import 'tarefa.dart';

class PaginaListaTarefas extends StatefulWidget {
  const PaginaListaTarefas({super.key});

  @override
  State<PaginaListaTarefas> createState() => _EstadoPaginaListaTarefas();
}

class _EstadoPaginaListaTarefas extends State<PaginaListaTarefas> {
  final List<Tarefa> _tarefas = <Tarefa>[];
  // Manter a lista de tarefas cadastradas

  void _abrirPaginaAdicionar() {
    final ScaffoldMessengerState mensageiro = ScaffoldMessenger.of(context);
    // Abrir a página de cadastro e esperar o resultado
    Navigator.pushNamed<Tarefa>(context, '/adicionar').then((novaTarefa) {
      if (novaTarefa == null) return;

      setState(() {
        _tarefas.add(novaTarefa);
      });
      //adicionar a nova tarefa à lista e atualizar a tela

      mensageiro.showSnackBar(
        SnackBar(
          content: Text('Tarefa "${novaTarefa.titulo}" adicionada.'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  Widget _construirItemTarefa(Tarefa tarefa, int indice) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                tarefa.titulo,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(tarefa.descricao),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Tarefas'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Minhas tarefas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Toque em um item para ver detalhes. Use o + para adicionar uma nova tarefa.'),
            const SizedBox(height: 16),
            Expanded(
              child: _tarefas.isEmpty
                  ? const Center(
                      child: Text('Nenhuma tarefa cadastrada ainda.'),
                    )
                  : ListView.separated(
                      itemCount: _tarefas.length,
                      separatorBuilder: (BuildContext context, int index) => const Divider(),
                      itemBuilder: (BuildContext context, int index) {
                        return _construirItemTarefa(_tarefas[index], index);
                       },
                    ),
                    // Mostrar a lista de tarefas ou uma mensagem se estiver vazia
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirPaginaAdicionar,
        tooltip: 'Adicionar tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }
}