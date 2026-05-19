import 'package:flutter/material.dart';

import 'cadastrar.dart';
import 'layout.dart';
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
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      // Widget de navegação: define rotas e páginas do app
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
          default:
            return null;
        }
      },
    );
  }
}

