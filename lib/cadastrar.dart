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
  // Controladores para os campos de input do formulário

  void _salvar() {
    final Tarefa tarefa = Tarefa(
      titulo: _titulo.text,
      descricao: _descricao.text,
    );
    Navigator.pop(context, tarefa);
    // Navegação: retornar para a página anterior com o resultado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Widget de layout: estrutura da página de cadastro
      appBar: AppBar(
        title: const Text('Adicionar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Widget de layout: espaço interno da área de formulário
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _titulo,
              // Widget de input: campo para título da tarefa
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descricao,
              // Widget de input: campo para descrição da tarefa
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
          ElevatedButton(
              onPressed: _salvar,
              // Outro widget: botão de ação para salvar a tarefa
              child: const Text('Salvar tarefa'),
            ),
            ],
          ),
        ),
      );
  }
}