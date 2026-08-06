import 'identifiable.dart';
import 'priority.dart';
import '../exceptions/task_exceptions.dart';

/// Classe abstraite représentant une tâche à accomplir
///
/// Toute tâche concrète doit hériter de [Task] et implémenter
/// [describe] et [typeName]. [Task] implémente également
/// [Comparable] (tri par priorité) et [Identifiable] (nécessaire au
/// [Repository] générique), ce qui illustre l'implémentation
/// d'interfaces en plus de l'héritage
abstract class Task implements Comparable<Task>, Identifiable {
  @override
  final String id;
  String title;
  Priority priority;
  DateTime? dueDate;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required String title,
    required this.priority,
    this.dueDate,
    this.isCompleted = false,
    DateTime? createdAt,
  })  : title = _validateTitle(title),
        createdAt = createdAt ?? DateTime.now();

  static String _validateTitle(String title) {
    if (title.trim().isEmpty) {
      throw InvalidTaskException('le titre ne peut pas être vide.');
    }
    return title.trim();
  }

  /// Marque cette tâche comme terminée.
  void complete() => isCompleted = true;

  /// Retourne une description courte et propre à chaque sous-classe.
  /// C'est ici que le polymorphisme intervient : chaque sous-classe
  /// affiche ses tâches différemment.
  String describe();

  /// Discriminant de type utilisé pour la (dé)sérialisation JSON.
  String get typeName;

  /// Sérialise la tâche vers une Map compatible JSON. Les
  /// sous-classes peuvent enrichir cette map (voir [UrgentTask]).
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': typeName,
        'title': title,
        'priority': priority.name,
        'dueDate': dueDate?.toIso8601String(),
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Ordonne les tâches par priorité (high en premier), puis par date
  /// limite (la plus proche en premier) en cas d'égalité.
  @override
  int compareTo(Task other) {
    final byPriority = other.priority.index.compareTo(priority.index);
    if (byPriority != 0) return byPriority;
    return compareByDueDate(other);
  }

  /// Compare uniquement par date limite (utilisé pour le tri "--sort=date").
  /// Les tâches sans date limite sont classées en dernier.
  int compareByDueDate(Task other) {
    if (dueDate == null && other.dueDate == null) return 0;
    if (dueDate == null) return 1;
    if (other.dueDate == null) return -1;
    return dueDate!.compareTo(other.dueDate!);
  }

  @override
  String toString() => describe();
}
