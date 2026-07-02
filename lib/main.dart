import 'package:flutter/material.dart';

import 'cadastrar.dart';
import 'detalhes_tarefa.dart';
import 'layout.dart';
import 'resumo.dart';
import 'tarefa.dart';

void main() {
  runApp(const AppTarefas());
}

class AppTarefas extends StatelessWidget {
  const AppTarefas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => const PaginaListaTarefas(),
              settings: settings,
            );
          case '/adicionar':
            return MaterialPageRoute<Tarefa>(
              builder: (BuildContext context) => const PaginaAdicionarTarefa(),
              settings: settings,
            );
          case '/resumo':
            final List<Tarefa> tarefas = settings.arguments is List<Tarefa>
                ? settings.arguments as List<Tarefa>
                : <Tarefa>[];
            return MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => PaginaResumoTarefas(tarefas: tarefas),
              settings: settings,
            );
          case '/detalhes':
            final Tarefa? tarefa = settings.arguments is Tarefa ? settings.arguments as Tarefa : null;
            return MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => tarefa == null
                  ? const Scaffold(body: Center(child: Text('Tarefa não encontrada.')))
                  : PaginaDetalhesTarefa(tarefa: tarefa),
              settings: settings,
            );
          default:
            return null;
        }
      },
    );
  }
}

