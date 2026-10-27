import 'package:flutter/material.dart';

import 'api/feriado.dart';
import 'database_helper.dart';
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
  DateTime? _dataEntrega;
  Feriado? _feriadoNaData;

  @override
  void initState() {
    super.initState();
    if (widget.tarefa != null) {
      _titulo.text = widget.tarefa!.titulo;
      _descricao.text = widget.tarefa!.descricao;
      _horas.text = widget.tarefa!.horasEstimadas.toString();
      _prioridade = widget.tarefa!.prioridade;
      _dataEntrega = widget.tarefa!.dataEntrega;
      _carregarFeriadoNaData();
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    _horas.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataEntrega() async {
    final DateTime hoje = DateTime.now();
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: _dataEntrega ?? hoje,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data de entrega',
    );
    if (data == null) {
      return;
    }
    setState(() {
      _dataEntrega = data;
      _feriadoNaData = null;
    });
    await _carregarFeriadoNaData();
  }

  Future<void> _carregarFeriadoNaData() async {
    final DateTime? data = _dataEntrega;
    if (data == null) {
      return;
    }
    final Feriado? feriado =
        await DatabaseHelper.instance.obterFeriadoPorData(data);
    if (mounted && data == _dataEntrega) {
      setState(() {
        _feriadoNaData = feriado;
      });
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
      dataEntrega: _dataEntrega,
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
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _selecionarDataEntrega,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _dataEntrega == null
                      ? 'Definir data de entrega (opcional)'
                      : 'Entrega: ${_formatarData(_dataEntrega!)}',
                ),
              ),
              if (_dataEntrega != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _dataEntrega = null;
                        _feriadoNaData = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Remover data de entrega'),
                  ),
                ),
              if (_feriadoNaData != null)
                Card(
                  color: Colors.amber.shade100,
                  child: ListTile(
                    leading: const Icon(Icons.celebration_outlined),
                    title: Text('Atenção: ${_feriadoNaData!.localName}'),
                    subtitle: const Text(
                      'A data escolhida é um feriado. Você ainda pode salvar a tarefa.',
                    ),
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

  String _formatarData(DateTime data) {
    final String dia = data.day.toString().padLeft(2, '0');
    final String mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }
}
