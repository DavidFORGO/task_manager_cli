import 'dart:math';

import '../models/normal_task.dart';
import '../models/priority.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import '../repository/repository.dart';

/// Mode de tri disponible pour [TaskService.listTasks].
enum SortMode { priority, dueDate }

class TaskService {
  final Repository<Task> _repository;
  final Random _random = Random();

  TaskService(this._repository);

  String _generateId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final suffix = _random.nextInt(9999).toString().padLeft(4, '0');
    return '$timestamp$suffix';
  }

  /// Ajoute une nouvelle tâche. Si [urgent] vaut `true`, une
  /// [UrgentTask] est créée (toujours priorité `high`) ; sinon une
  /// [NormalTask] est créée avec la [priority] fournie
  Future<Task> addTask({
    required String title,
    Priority priority = Priority.medium,
    DateTime? dueDate,
    bool urgent = false,
  }) async {
    final id = _generateId();
    final task = urgent
        ? UrgentTask(id: id, title: title, dueDate: dueDate)
        : NormalTask(id: id, title: title, priority: priority, dueDate: dueDate);
    await _repository.add(task);
    return task;
  }

  /// Retourne toutes les tâches, triées par priorité (par défaut) ou par date limite.
  Future<List<Task>> listTasks({SortMode sortBy = SortMode.priority}) async {
    final tasks = List<Task>.from(await _repository.getAll());
    if (sortBy == SortMode.priority) {
      tasks.sort();
    } else {
      tasks.sort((a, b) => a.compareByDueDate(b));
    }
    return tasks;
  }

  /// Marque la tâche [id] comme terminée et persiste le changement.
  Future<Task> completeTask(String id) async {
    final task = await _repository.getById(id);
    task.complete();
    await _repository.update(task);
    return task;
  }

  /// Supprime la tâche [id] du repository.
  Future<void> deleteTask(String id) async {
    await _repository.delete(id);
  }
}
