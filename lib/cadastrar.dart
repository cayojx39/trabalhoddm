import 'package:flutter/material.dart';

import 'tarefa.dart';

class PaginaAdicionarTarefa extends StatefulWidget {
  const PaginaAdicionarTarefa({super.key});

  @override
  State<PaginaAdicionarTarefa> createState() => _EstadoPaginaAdicionarTarefa();
}

class _EstadoPaginaAdicionarTarefa extends State<PaginaAdicionarTarefa> {
  final TextEditingController _titulo = TextEditingController();
  final TextEditingController _descricao = TextEditingController();
  // Controlar e ler o que o usuário digitou

  void _salvar() {
    final Tarefa tarefa = Tarefa(
      titulo: _titulo.text,
      descricao: _descricao.text,
    );
    Navigator.pop(context, tarefa);
    // Pegar a tarefa criada e retornar para a página anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _titulo,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descricao,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
            ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Salvar tarefa'),
              ),
            ],
          ),
        ),
      );
  }
}