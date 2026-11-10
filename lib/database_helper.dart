import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'api/feriado.dart';
import 'tarefa.dart';

class DatabaseHelper {
  DatabaseHelper._();

  // Mantém uma única instância do acesso ao banco.
  static final DatabaseHelper instance = DatabaseHelper._();

  // Reutiliza a conexão já aberta com o SQLite.
  static Database? _database;
  static Future<Database>? _databaseFuture;
  static const String _databaseName = 'tarefas.db';
  static const int _databaseVersion = 2;
  static const String tableTarefas = 'tarefas';
  static const String tableFeriados = 'feriados';
  static const String columnId = 'id';
  static const String columnTitulo = 'titulo';
  static const String columnDescricao = 'descricao';
  static const String columnPrioridade = 'prioridade';
  static const String columnHorasEstimadas = 'horas_estimadas';
  static const String columnConcluida = 'concluida';
  static const String columnDataEntrega = 'data_entrega';

  // Abre o banco uma vez e compartilha a abertura entre chamadas simultâneas.
  Future<Database> get database {
    if (_database != null) {
      return Future<Database>.value(_database);
    }

    return _databaseFuture ??= _abrirDatabase();
  }

  Future<Database> _abrirDatabase() async {
    try {
      final Database database = await _initDatabase();
      _database = database;
      return database;
    } on Object {
      _databaseFuture = null;
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);
    // Cria ou atualiza o esquema conforme a versão do banco.
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Cria as tabelas usadas para tarefas e feriados.
    await db.execute('''
      CREATE TABLE $tableTarefas (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitulo TEXT NOT NULL,
        $columnDescricao TEXT NOT NULL,
        $columnPrioridade TEXT NOT NULL,
        $columnHorasEstimadas INTEGER NOT NULL,
        $columnConcluida INTEGER NOT NULL,
        $columnDataEntrega TEXT
      )
    ''');
    await _criarTabelaFeriados(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Adiciona campos e tabelas novos sem apagar os dados existentes.
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableTarefas ADD COLUMN $columnDataEntrega TEXT',
      );
      await _criarTabelaFeriados(db);
    }
  }

  Future<void> _criarTabelaFeriados(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE $tableFeriados (
        date TEXT PRIMARY KEY,
        local_name TEXT NOT NULL,
        name TEXT NOT NULL,
        country_code TEXT NOT NULL,
        global INTEGER NOT NULL,
        counties TEXT,
        types TEXT NOT NULL
      )
    ''');
  }

  Future<int> inserirTarefa(Tarefa tarefa) async {
    // Salva uma tarefa e retorna o ID gerado pelo SQLite.
    final Database db = await database;
    return db.insert(tableTarefas, tarefa.toMap());
  }

  Future<List<Tarefa>> listarTarefas() async {
    // Lista as tarefas em ordem de cadastro.
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableTarefas,
      orderBy: '$columnId ASC',
    );
    return maps.map(Tarefa.fromMap).toList();
  }

  // Busca uma tarefa pelo ID salvo nas preferências.
  Future<Tarefa?> obterTarefaPorId(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableTarefas,
      where: '$columnId = ?',
      whereArgs: <Object?>[id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Tarefa.fromMap(maps.first);
  }

  // Atualiza os dados da tarefa com o ID correspondente.
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

  // Remove do banco a tarefa identificada pelo ID.
  Future<int> deletarTarefa(int id) async {
    final Database db = await database;
    return db.delete(
      tableTarefas,
      where: '$columnId = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<void> salvarFeriados(List<Feriado> feriados) async {
    final Database db = await database;
    // Salva os feriados em lote e substitui datas que já existem.
    final Batch batch = db.batch();
    for (final Feriado feriado in feriados) {
      batch.insert(
        tableFeriados,
        feriado.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Feriado>> listarFeriados() async {
    // Retorna os feriados armazenados em ordem de data.
    final Database db = await database;
    final List<Map<String, Object?>> maps = await db.query(
      tableFeriados,
      orderBy: 'date ASC',
    );
    return maps.map(Feriado.fromMap).toList();
  }

  Future<Feriado?> obterFeriadoPorData(DateTime data) async {
    // Compara apenas o dia para encontrar o feriado correspondente.
    final String dataFormatada = DateTime(
      data.year,
      data.month,
      data.day,
    ).toIso8601String().substring(0, 10);
    final Database db = await database;
    final List<Map<String, Object?>> maps = await db.query(
      tableFeriados,
      where: 'date = ?',
      whereArgs: <Object?>[dataFormatada],
      limit: 1,
    );
    return maps.isEmpty ? null : Feriado.fromMap(maps.first);
  }
}
