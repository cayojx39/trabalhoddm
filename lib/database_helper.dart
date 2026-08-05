import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'tarefa.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;
  static const String _databaseName = 'tarefas.db';
  static const int _databaseVersion = 1;
  static const String tableTarefas = 'tarefas';
  static const String columnId = 'id';
  static const String columnTitulo = 'titulo';
  static const String columnDescricao = 'descricao';
  static const String columnPrioridade = 'prioridade';
  static const String columnHorasEstimadas = 'horas_estimadas';
  static const String columnConcluida = 'concluida';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);
    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTarefas (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitulo TEXT NOT NULL,
        $columnDescricao TEXT NOT NULL,
        $columnPrioridade TEXT NOT NULL,
        $columnHorasEstimadas INTEGER NOT NULL,
        $columnConcluida INTEGER NOT NULL
      )
    ''');
  }

  Future<int> inserirTarefa(Tarefa tarefa) async {
    final Database db = await database;
    return db.insert(tableTarefas, tarefa.toMap());
  }

  Future<List<Tarefa>> listarTarefas() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableTarefas,
      orderBy: '$columnId ASC',
    );
    return maps.map(Tarefa.fromMap).toList();
  }

  Future<int> atualizarTarefa(Tarefa tarefa) async {
    if (tarefa.id == null) {
      return 0;
    }

    final Database db = await database;
    return db.update(
      tableTarefas,
      tarefa.toMap(),
      where: '$columnId = ?',
      whereArgs: <Object?>[tarefa.id],
    );
  }

  Future<int> deletarTarefa(int id) async {
    final Database db = await database;
    return db.delete(
      tableTarefas,
      where: '$columnId = ?',
      whereArgs: <Object?>[id],
    );
  }
}
