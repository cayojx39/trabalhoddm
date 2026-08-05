import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_helper.dart';
import 'tarefa.dart';

class PaginaListaTarefas extends StatefulWidget {
  const PaginaListaTarefas({super.key});

  @override
  State<PaginaListaTarefas> createState() => _EstadoPaginaListaTarefas();
}

class _EstadoPaginaListaTarefas extends State<PaginaListaTarefas> {
  final List<Tarefa> _tarefas = <Tarefa>[];
  String _nomeUsuario = 'Usuário';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String nome = prefs.getString('nomeUsuario') ?? 'Usuário';
    final List<Tarefa> tarefasSalvas = await DatabaseHelper.instance.listarTarefas();

    if (!mounted) {
      return;
    }

    setState(() {
      _nomeUsuario = nome;
      _tarefas
        ..clear()
        ..addAll(tarefasSalvas);
    });
  }

  Future<void> _abrirPaginaAdicionar() async {
    final ScaffoldMessengerState mensageiro = ScaffoldMessenger.of(context);
    final Tarefa? novaTarefa = await Navigator.pushNamed<Tarefa>(context, '/adicionar');

    if (novaTarefa == null) {
      return;
    }

    final int idSalvo = await DatabaseHelper.instance.inserirTarefa(novaTarefa);
    final Tarefa tarefaSalva = Tarefa(
      id: idSalvo,
      titulo: novaTarefa.titulo,
      descricao: novaTarefa.descricao,
      prioridade: novaTarefa.prioridade,
      horasEstimadas: novaTarefa.horasEstimadas,
      concluida: novaTarefa.concluida,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _tarefas.add(tarefaSalva);
    });

    mensageiro.showSnackBar(
      SnackBar(
        content: Text('Tarefa "${tarefaSalva.titulo}" adicionada.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _alternarConclusao(Tarefa tarefa) async {
    final int index = _tarefas.indexWhere((item) => item.id == tarefa.id);
    if (index < 0) {
      return;
    }

    final Tarefa atualizada = Tarefa(
      id: tarefa.id,
      titulo: tarefa.titulo,
      descricao: tarefa.descricao,
      prioridade: tarefa.prioridade,
      horasEstimadas: tarefa.horasEstimadas,
      concluida: !tarefa.concluida,
    );

    await DatabaseHelper.instance.atualizarTarefa(atualizada);

    if (!mounted) {
      return;
    }

    setState(() {
      _tarefas[index] = atualizada;
    });
  }

  Future<void> _editarTarefa(Tarefa tarefa) async {
    final Tarefa? tarefaAtualizada = await Navigator.pushNamed<Tarefa>(
      context,
      '/adicionar',
      arguments: tarefa,
    );

    if (tarefaAtualizada == null) {
      return;
    }

    await DatabaseHelper.instance.atualizarTarefa(tarefaAtualizada);

    if (!mounted) {
      return;
    }

    setState(() {
      final int index = _tarefas.indexWhere((item) => item.id == tarefaAtualizada.id);
      if (index >= 0) {
        _tarefas[index] = tarefaAtualizada;
      }
    });
  }

  Future<void> _confirmarExclusao(Tarefa tarefa) async {
    final bool? resultado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Confirmar exclusão'),
          content: Text('Deseja realmente excluir a tarefa "${tarefa.titulo}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (resultado == true) {
      await _deletarTarefa(tarefa);
    }
  }

  Future<void> _deletarTarefa(Tarefa tarefa) async {
    if (tarefa.id == null) {
      return;
    }

    await DatabaseHelper.instance.deletarTarefa(tarefa.id!);

    if (!mounted) {
      return;
    }

    setState(() {
      _tarefas.removeWhere((item) => item.id == tarefa.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarefa "${tarefa.titulo}" excluída com sucesso.'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _construirTabelaTarefas() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          border: TableBorder.symmetric(
            inside: const BorderSide(color: Color(0xFFDFE4F5), width: 1),
            outside: const BorderSide(color: Color(0xFFDFE4F5), width: 1),
          ),
          headingRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            return const Color(0xFFE8EEF9);
          }),
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F3B72)),
          dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            return Colors.white;
          }),
          dataTextStyle: const TextStyle(color: Color(0xFF243656)),
          dividerThickness: 1,
          columns: const <DataColumn>[
            DataColumn(label: Text('Título')),
            DataColumn(label: Text('Prioridade')),
            DataColumn(label: Text('Horas')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Ações')),
          ],
          rows: _tarefas.map((Tarefa tarefa) {
            return DataRow(
              cells: <DataCell>[
                DataCell(
                  Text(tarefa.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => Navigator.pushNamed(context, '/detalhes', arguments: tarefa),
                ),
                DataCell(Text(tarefa.prioridadeTexto)),
                DataCell(Text('${tarefa.horasEstimadas}h')),
                DataCell(
                  Chip(
                    label: Text(
                      tarefa.concluida ? 'Concluída' : 'Pendente',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: tarefa.concluida ? Colors.green.shade100 : Colors.orange.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        tooltip: tarefa.concluida ? 'Marcar como pendente' : 'Marcar como concluída',
                        icon: Icon(tarefa.concluida ? Icons.undo : Icons.check_circle_outline),
                        color: tarefa.concluida ? Colors.orange : Colors.green,
                        onPressed: () => _alternarConclusao(tarefa),
                      ),
                      IconButton(
                        tooltip: 'Editar tarefa',
                        icon: const Icon(Icons.edit_outlined),
                        color: Colors.blue.shade700,
                        onPressed: () => _editarTarefa(tarefa),
                      ),
                      IconButton(
                        tooltip: 'Excluir tarefa',
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.redAccent,
                        onPressed: () => _confirmarExclusao(tarefa),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // soma as horas estimadas das tarefas cadastradas.
    final int totalHoras = _tarefas.fold<int>(0, (soma, tarefa) => soma + tarefa.horasEstimadas);
    // quantas tarefas já foram concluídas.
    final int tarefasConcluidas = _tarefas.where((tarefa) => tarefa.concluida).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Tarefas'),
        centerTitle: true,
      ),
      body: Container(
        // Esta parte cria a estilização visual da tela com cores e layout.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Color(0xFFF8F9FF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Olá, $_nomeUsuario',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Tarefas cadastradas: ${_tarefas.length}'),
                      Text('Horas estimadas: $totalHoras h'),
                      Text('Tarefas concluídas: $tarefasConcluidas'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/resumo', arguments: _tarefas);
                },
                icon: const Icon(Icons.insights),
                label: const Text('Resumo'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Minhas tarefas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _tarefas.isEmpty
                    ? const Center(
                        child: Text('Nenhuma tarefa cadastrada ainda.'),
                      )
                    : SingleChildScrollView(
                        child: _construirTabelaTarefas(),
                      ),
              ),
            ],
          ),
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

class _ItemTarefaAnimado extends StatefulWidget {
  final Tarefa tarefa;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ItemTarefaAnimado({
    required this.tarefa,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<_ItemTarefaAnimado> createState() => _ItemTarefaAnimadoState();
}

class _ItemTarefaAnimadoState extends State<_ItemTarefaAnimado>
    with SingleTickerProviderStateMixin {
  // Esta animação usa ScaleTransition para fazer a tarefa crescer ao aparecer.
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 999),
    );
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Card(
          elevation: 3,
          child: ListTile(
            onTap: widget.onTap,
            leading: CircleAvatar(
              backgroundColor: widget.tarefa.corPrioridade.withValues(alpha: 0.15),
              child: Icon(Icons.assignment_turned_in, color: widget.tarefa.corPrioridade),
            ),
            title: Text(
              widget.tarefa.titulo,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: widget.tarefa.concluida ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 4),
                Text(widget.tarefa.descricao),
                const SizedBox(height: 4),
                Text('${widget.tarefa.prioridadeTexto} • ${widget.tarefa.horasEstimadas}h'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Chip(
                  label: Text(widget.tarefa.concluida ? 'Concluída' : 'Pendente'),
                  backgroundColor: widget.tarefa.concluida ? Colors.green.shade100 : Colors.orange.shade100,
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: widget.tarefa.concluida ? 'Marcar como pendente' : 'Marcar como concluída',
                  onPressed: widget.onToggle,
                  icon: Icon(widget.tarefa.concluida ? Icons.undo : Icons.check_circle_outline),
                  color: widget.tarefa.concluida ? Colors.orange : Colors.green,
                ),
                IconButton(
                  tooltip: 'Excluir tarefa',
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}