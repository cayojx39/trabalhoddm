import 'package:shared_preferences/shared_preferences.dart';

// Helper para gerenciar as preferências de últimas tarefas acessadas
class PreferencesHelper {
  PreferencesHelper._();

  static const String _keyUltimaTarefaId = 'ultima_tarefa_id';

  // Salva o ID da última tarefa que o usuário visualizou
  static Future<void> salvarUltimaTarefaId(int? tarefaId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (tarefaId == null) {
      await prefs.remove(_keyUltimaTarefaId);
    } else {
      await prefs.setInt(_keyUltimaTarefaId, tarefaId);
    }
  }

  // Recupera o ID da última tarefa acessada para restaurar na próxima abertura
  static Future<int?> obterUltimaTarefaId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUltimaTarefaId);
  }
}
