import 'package:flutter/material.dart';

import 'tarefa.dart';
import 'cadastrar.dart';

class PaginaListaTarefas extends StatefulWidget {
  const PaginaListaTarefas({super.key});

  @override
  State<PaginaListaTarefas> createState() => _EstadoPaginaListaTarefas();
}

class _EstadoPaginaListaTarefas extends State<PaginaListaTarefas> {
  final List<Tarefa> _tarefas = [
    Tarefa(
      titulo: 'Comprar leite',
      descricao: 'Ir ao mercado e pegar 2 litros de leite.',
      importante: true,
      notificar: true,
      dataLimite: DateTime.now().add(const Duration(days: 1)),
    ),
    Tarefa(
      titulo: 'Enviar relatório',
      descricao: 'Enviar relatório semanal para o professor.',
      importante: false,
      notificar: false,
      dataLimite: DateTime.now().add(const Duration(days: 2)),
    ),
  ];

  void _abrirPaginaAdicionar() {
    final ScaffoldMessengerState mensageiro = ScaffoldMessenger.of(context);
    Navigator.push<Tarefa>(
      context,
      MaterialPageRoute<Tarefa>(
        builder: (BuildContext context) {
          return const PaginaAdicionarTarefa();
        },
      ),
    ).then((novaTarefa) {
      if (novaTarefa != null) {
        setState(() {
          _tarefas.add(novaTarefa);
        });
        mensageiro.showSnackBar(
          SnackBar(
            content: Text('Tarefa "${novaTarefa.titulo}" adicionada.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _excluirTarefa(int indice) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir tarefa'),
          content: Text('Deseja excluir "${_tarefas[indice].titulo}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final Tarefa removida = _tarefas[indice];
                setState(() {
                  _tarefas.removeAt(indice);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tarefa "${removida.titulo}" excluída.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDetalhesTarefa(Tarefa tarefa) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                tarefa.titulo,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(tarefa.descricao),
              const SizedBox(height: 10),
              Text('Notificar: ${tarefa.notificar ? 'Sim' : 'Não'}'),
              Text('Data: ${tarefa.dataLimite.toLocal().toString().split(' ').first}'),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
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
                  color: tarefa.importante ? Colors.red.shade700 : Colors.black87,
                ),
              ),
            ),
            if (tarefa.importante)
              const Tooltip(
                message: 'Importante',
                child: Icon(Icons.label_important, color: Colors.redAccent, size: 20),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(tarefa.descricao),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _excluirTarefa(indice),
        ),
        onTap: () => _mostrarDetalhesTarefa(tarefa),
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
