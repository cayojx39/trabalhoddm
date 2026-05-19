import 'package:flutter/material.dart';

import 'tarefa.dart';

class PaginaListaTarefas extends StatefulWidget {
  const PaginaListaTarefas({super.key});

  @override
  State<PaginaListaTarefas> createState() => _EstadoPaginaListaTarefas();
}

class _EstadoPaginaListaTarefas extends State<PaginaListaTarefas> {
  final List<Tarefa> _tarefas = <Tarefa>[];
  // Lista de dados do app, guarda o estado das tarefas

  void _abrirPaginaAdicionar() {
    final ScaffoldMessengerState mensageiro = ScaffoldMessenger.of(context);
    // Navegação: abrir rota para adicionar uma nova tarefa
    Navigator.pushNamed<Tarefa>(context, '/adicionar').then((novaTarefa) {
      if (novaTarefa == null) return;

      setState(() {
        _tarefas.add(novaTarefa);
      });
      // Navegação: adicionar a nova tarefa à lista e atualizar a tela

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
      // Widget de layout: card que envolve cada item de tarefa
      child: ListTile(
        // Widget de layout: item de lista formatado
        title: Row(
          children: <Widget>[
            Expanded(
              // Widget de layout: expande o texto dentro da linha
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
      // Widget de layout: estrutura principal da página
      appBar: AppBar(
        // Widget de layout: barra de navegação superior
        title: const Text('Ver Tarefas'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Widget de layout: espaçamento interno da página
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
              // Widget de layout: preencher o restante do espaço disponível
              child: _tarefas.isEmpty
                  ? const Center(
                      // Widget de layout: mostrar mensagem centralizada
                      child: Text('Nenhuma tarefa cadastrada ainda.'),
                    )
                  : ListView.separated(
                      // Widget de layout: lista rolável de tarefas
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
        // Outro widget: botão flutuante para iniciar o fluxo de navegação
        child: const Icon(Icons.add),
      ),
    );
  }
}