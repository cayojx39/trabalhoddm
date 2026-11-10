import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_service.dart';
import 'api/feriado.dart';
import 'database_helper.dart';
import 'preferences_helper.dart';
import 'tarefa.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _mensagem = 'Carregando suas tarefas...';

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String nome = prefs.getString('nomeUsuario') ?? 'Usuário';
    await prefs.setString('nomeUsuario', nome);
    await prefs.setString('ultimaVisita', DateTime.now().toIso8601String());

    if (!mounted) {
      return;
    }

    setState(() {
      _mensagem = 'Olá, $nome!';
    });

    final int? ultimaTarefaId = await PreferencesHelper.obterUltimaTarefaId();
    Tarefa? tarefa;
    if (ultimaTarefaId != null) {
      tarefa = await DatabaseHelper.instance.obterTarefaPorId(ultimaTarefaId);
    }

    if (!mounted) {
      return;
    }

    unawaited(_atualizarFeriados());
    if (tarefa != null) {
      Navigator.of(context).pushReplacementNamed('/detalhes', arguments: tarefa);
    } else {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Future<void> _atualizarFeriados() async {
    try {
      final List<Feriado> feriados = await ApiService.instance.buscarFeriados(
        ano: DateTime.now().year,
      );
      await DatabaseHelper.instance.salvarFeriados(feriados);
    } on ApiException catch (error) {
      debugPrint('Não foi possível atualizar os feriados: ${error.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF1E88E5), Color(0xFF6A1B9A)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.task_alt, size: 72, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Organizando tarefas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _mensagem,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
