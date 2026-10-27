import 'package:flutter/material.dart';

import 'api/feriado.dart';
import 'database_helper.dart';
import 'tarefa.dart';

class PaginaResumoTarefas extends StatefulWidget {
  final List<Tarefa> tarefas;

  const PaginaResumoTarefas({super.key, required this.tarefas});

  @override
  State<PaginaResumoTarefas> createState() => _PaginaResumoTarefasState();
}

class _PaginaResumoTarefasState extends State<PaginaResumoTarefas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Future<List<Feriado>> _feriadosFuture;

  @override
  void initState() {
    super.initState();
    _feriadosFuture = DatabaseHelper.instance.listarFeriados();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Este cálculo mostra o total de horas das tarefas cadastradas.
    final int totalHoras = widget.tarefas.fold<int>(
      0,
      (soma, tarefa) => soma + tarefa.horasEstimadas,
    );
    // Este cálculo conta quantas tarefas têm prioridade alta.
    final int tarefasAlta = widget.tarefas
        .where((tarefa) => tarefa.prioridade == Prioridade.alta)
        .length;
    final int concluidas = widget.tarefas
        .where((tarefa) => tarefa.concluida)
        .length;
    // Este cálculo mostra o percentual de tarefas concluídas.
    final double percentual = widget.tarefas.isEmpty
        ? 0
        : (concluidas / widget.tarefas.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo das Tarefas'),
        centerTitle: true,
      ),
      body: Container(
        // Esta parte define a estilização da tela de resumo.
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E5F5), Color(0xFFE1F5FE)],
          ),
        ),
        child: FadeTransition(
          // Esta animação usa FadeTransition para mostrar a tela aos poucos.
          opacity: _fadeAnimation,
          child: SlideTransition(
            // Esta animação usa SlideTransition para a tela deslizar de baixo para cima.
            position: _slideAnimation,
            child: ListView(
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Progresso geral',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: percentual / 100,
                          minHeight: 10,
                        ),
                        const SizedBox(height: 8),
                        Text('${percentual.toStringAsFixed(0)}% concluído'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Feriado>>(
                  future: _feriadosFuture,
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<List<Feriado>> snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.error_outline),
                              title: const Text(
                                'Não foi possível carregar feriados',
                              ),
                              subtitle: Text('${snapshot.error}'),
                            ),
                          );
                        }

                        final List<Feriado> feriados =
                            snapshot.data ?? <Feriado>[];
                        final DateTime hoje = DateTime.now();
                        final List<Feriado> proximos = feriados
                            .where((Feriado feriado) {
                              final DateTime data = DateTime(
                                feriado.date.year,
                                feriado.date.month,
                                feriado.date.day,
                              );
                              return !data.isBefore(
                                DateTime(hoje.year, hoje.month, hoje.day),
                              );
                            })
                            .take(3)
                            .toList();
                        final List<Tarefa> tarefasProximas = widget.tarefas
                            .where(
                              (Tarefa tarefa) =>
                                  feriadoProximo(
                                    tarefa.dataEntrega,
                                    feriados,
                                  ) !=
                                  null,
                            )
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      'Próximos feriados',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (proximos.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Nenhum feriado próximo disponível no cache.',
                                        ),
                                      )
                                    else
                                      ...proximos.map((Feriado feriado) {
                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: const Icon(
                                            Icons.celebration_outlined,
                                          ),
                                          title: Text(feriado.localName),
                                          subtitle: Text(
                                            '${feriado.date.day.toString().padLeft(2, '0')}/${feriado.date.month.toString().padLeft(2, '0')}/${feriado.date.year}',
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                            if (tarefasProximas.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 12),
                              const Text(
                                'Entregas próximas a feriados',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...tarefasProximas.map((Tarefa tarefa) {
                                final Feriado feriado = feriadoProximo(
                                  tarefa.dataEntrega,
                                  feriados,
                                )!;
                                return Card(
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.event_busy,
                                      color: Colors.deepOrange,
                                    ),
                                    title: Text(tarefa.titulo),
                                    subtitle: Text(
                                      'Entrega próxima de ${feriado.localName}',
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ],
                        );
                      },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _CardResumo(
                      titulo: 'Horas',
                      valor: '$totalHoras h',
                      icone: Icons.access_time,
                    ),
                    _CardResumo(
                      titulo: 'Prioridade alta',
                      valor: '$tarefasAlta',
                      icone: Icons.flag,
                    ),
                    _CardResumo(
                      titulo: 'Concluídas',
                      valor: '$concluidas',
                      icone: Icons.check_circle,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tarefas com maior urgência',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...widget.tarefas
                    .where((tarefa) => tarefa.prioridade == Prioridade.alta)
                    .map((tarefa) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                          ),
                          title: Text(tarefa.titulo),
                          subtitle: Text(
                            '${tarefa.horasEstimadas} horas estimadas',
                          ),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardResumo extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const _CardResumo({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icone, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(valor),
            ],
          ),
        ),
      ),
    );
  }
}
