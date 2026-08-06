import 'priority.dart';
import 'task.dart';

/// Une tâche ordinaire, sans comportement particulier au-delà de
/// [Task]. Sa priorité est choisie librement par l'utilisateur
class NormalTask extends Task {
  NormalTask({
    required super.id,
    required super.title,
    required super.priority,
    super.dueDate,
    super.isCompleted,
    super.createdAt,
  });

  @override
  String get typeName => 'normal';

  @override
  String describe() {
    final status = isCompleted ? '[x]' : '[ ]';
    final due = dueDate != null
        ? ' (échéance : ${dueDate!.toIso8601String().split('T').first})'
        : '';
    return '$status $title — ${priority.name}$due';
  }
}
