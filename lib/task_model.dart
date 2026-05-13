class Task {
  final String title;
  final String description;
  final bool important;
  final bool notify;
  final String priority;
  final DateTime dueDate;

  Task({
    required this.title,
    required this.description,
    required this.important,
    required this.notify,
    required this.priority,
    required this.dueDate,
  });
}
