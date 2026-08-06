import 'dart:convert';
import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/normal_task.dart';
import '../models/priority.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import 'repository.dart';

/// Implémentation de [Repository<Task>] qui persiste les tâches dans
/// un fichier JSON local, avec un cache en mémoire synchronisé avec le disque à chaque écriture
 
class JsonTaskRepository implements Repository<Task> {
  final File _file;
  List<Task> _cache = [];
  bool _loaded = false;

  JsonTaskRepository(String path) : _file = File(path);

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    if (await _file.exists()) {
      try {
        final content = await _file.readAsString();
        if (content.trim().isEmpty) {
          _cache = [];
        } else {
          final decoded = jsonDecode(content) as List<dynamic>;
          _cache = decoded
              .map((e) => _taskFromJson(e as Map<String, dynamic>))
              .toList();
        }
      } on FormatException catch (e) {
        throw RepositoryIOException('fichier JSON invalide (${e.message}).');
      }
    } else {
      _cache = [];
    }
    _loaded = true;
  }

  Task _taskFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'normal';
    final id = json['id'] as String;
    final title = json['title'] as String;
    final priority = Priority.fromString(json['priority'] as String);
    final dueDate =
        json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null;
    final isCompleted = json['isCompleted'] as bool? ?? false;
    final createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null;

    switch (type) {
      case 'urgent':
        return UrgentTask(
          id: id,
          title: title,
          dueDate: dueDate,
          isCompleted: isCompleted,
          createdAt: createdAt,
          escalationLevel: json['escalationLevel'] as int? ?? 1,
        );
      case 'normal':
      default:
        return NormalTask(
          id: id,
          title: title,
          priority: priority,
          dueDate: dueDate,
          isCompleted: isCompleted,
          createdAt: createdAt,
        );
    }
  }

  Future<void> _persist() async {
    try {
      final jsonList = _cache.map((t) => t.toJson()).toList();
      const encoder = JsonEncoder.withIndent('  ');
      await _file.writeAsString(encoder.convert(jsonList));
    } on IOException catch (e) {
      throw RepositoryIOException(e.toString());
    }
  }

  @override
  Future<void> add(Task item) async {
    await _ensureLoaded();
    if (_cache.any((t) => t.id == item.id)) {
      throw DuplicateTaskException(item.id);
    }
    _cache.add(item);
    await _persist();
  }

  @override
  Future<List<Task>> getAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_cache);
  }

  @override
  Future<Task> getById(String id) async {
    await _ensureLoaded();
    return _cache.firstWhere(
      (t) => t.id == id,
      orElse: () => throw TaskNotFoundException(id),
    );
  }

  @override
  Future<void> update(Task item) async {
    await _ensureLoaded();
    final index = _cache.indexWhere((t) => t.id == item.id);
    if (index == -1) throw TaskNotFoundException(item.id);
    _cache[index] = item;
    await _persist();
  }

  @override
  Future<void> delete(String id) async {
    await _ensureLoaded();
    final index = _cache.indexWhere((t) => t.id == id);
    if (index == -1) throw TaskNotFoundException(id);
    _cache.removeAt(index);
    await _persist();
  }
}
