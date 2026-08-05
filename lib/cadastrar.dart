import 'package:flutter/material.dart';

import 'tarefa.dart';

class PaginaAdicionarTarefa extends StatefulWidget {
  const PaginaAdicionarTarefa({super.key, this.tarefa});

  final Tarefa? tarefa;

  @override
  State<PaginaAdicionarTarefa> createState() => _EstadoPaginaAdicionarTarefa();
}

class _EstadoPaginaAdicionarTarefa extends State<PaginaAdicionarTarefa> {
  final TextEditingController _titulo = TextEditingController();
  final TextEditingController _descricao = TextEditingController();
  final TextEditingController _horas = TextEditingController(text: '1');
  Prioridade _prioridade = Prioridade.media;

  @override
  void initState() {
    super.initState();
    if (widget.tarefa != null) {
      _titulo.text = widget.tarefa!.titulo;
      _descricao.text = widget.tarefa!.descricao;
      _horas.text = widget.tarefa!.horasEstimadas.toString();
      _prioridade = widget.tarefa!.prioridade;
    }
  }

  void _salvar() {
    final int horas = int.tryParse(_horas.text) ?? 1;
    final Tarefa tarefa = Tarefa(
      id: widget.tarefa?.id,
      titulo: _titulo.text,
      descricao: _descricao.text,
      prioridade: _prioridade,
      horasEstimadas: horas,
      concluida: widget.tarefa?.concluida ?? false,
    );
    Navigator.pop(context, tarefa);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdicao = widget.tarefa != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Tarefa' : 'Adicionar Tarefa'),
        centerTitle: true,
      ),
      body: Container(
        // Esta parte aplica a estilização da tela de cadastro.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFF8F9FF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              Text(
                isEdicao ? 'Atualize os dados da tarefa' : 'Cadastre sua nova tarefa',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titulo,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.task_alt),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descricao,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<Prioridade>(
                initialValue: _prioridade,
                decoration: const InputDecoration(
                  labelText: 'Prioridade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: Prioridade.values.map((Prioridade valor) {
                  return DropdownMenuItem<Prioridade>(
                    value: valor,
                    child: Text(valor.name[0].toUpperCase() + valor.name.substring(1)),
                  );
                }).toList(),
                onChanged: (Prioridade? valor) {
                  if (valor != null) {
                    setState(() {
                      _prioridade = valor;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _horas,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Horas estimadas',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save_alt),
                label: Text(isEdicao ? 'Atualizar tarefa' : 'Salvar tarefa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
