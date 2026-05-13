class Tarefa {
  final String titulo;
  final String descricao;
  final bool importante;
  final bool notificar;
  final DateTime dataLimite;

  Tarefa({
    required this.titulo,
    required this.descricao,
    required this.importante,
    required this.notificar,
    required this.dataLimite,
  });
}
