import '../exceptions/task_exceptions.dart';
import 'priority.dart';
import 'task.dart';

/// Une tâche urgente : toujours en priorité `high`, et qui garde la
/// trace du nombre de fois où elle a été escaladée (ex : relance à un
/// responsable). Illustre l'héritage Task -> UrgentTask 
class UrgentTask extends Task {
  int escalationLevel;

  UrgentTask({
    required String id,
    required String title,
    DateTime? dueDate,
    bool isCompleted = false,
    DateTime? createdAt,
    this.escalationLevel = 1,
  }) : super(
          id: id,
          title: title,
          priority: Priority.high,
          dueDate: dueDate,
          isCompleted: isCompleted,
          createdAt: createdAt,
        ) {
    if (escalationLevel < 1) {
      throw InvalidTaskException('le niveau d\'escalade doit être >= 1.');
    }
  }

  /// Escalade la tâche (par exemple relance à un niveau supérieur).
  void escalate() => escalationLevel++;

  @override
  String get typeName => 'urgent';

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'escalationLevel': escalationLevel,
      };

  @override
  String describe() {
    final status = isCompleted ? '[x]' : '[ ]';
    final due = dueDate != null
        ? ' (échéance : ${dueDate!.toIso8601String().split('T').first})'
        : '';
    return '$status URGENT (niveau $escalationLevel) $title$due';
  }
}
