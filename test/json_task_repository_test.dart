import 'dart:convert';
import 'dart:io';

import 'package:task_manager_cli/exceptions/task_exceptions.dart';
import 'package:task_manager_cli/models/normal_task.dart';
import 'package:task_manager_cli/models/priority.dart';
import 'package:task_manager_cli/repository/json_task_repository.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String filePath;
  late JsonTaskRepository repository;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('task_manager_test_');
    filePath = '${tempDir.path}/tasks.json';
    repository = JsonTaskRepository(filePath);
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('add() puis getAll() retourne la tâche ajoutée', () async {
    final task = NormalTask(id: 'a1', title: 'Écrire le rapport', priority: Priority.medium);
    await repository.add(task);
    final all = await repository.getAll();
    expect(all, hasLength(1));
    expect(all.first.id, 'a1');
  });

  test('add() lève DuplicateTaskException pour un identifiant en double', () async {
    final task = NormalTask(id: 'a1', title: 'Tâche 1', priority: Priority.low);
    await repository.add(task);
    expect(
      () => repository.add(NormalTask(id: 'a1', title: 'Tâche doublon', priority: Priority.low)),
      throwsA(isA<DuplicateTaskException>()),
    );
  });

  test('getById() lève TaskNotFoundException pour un identifiant inconnu', () async {
    expect(() => repository.getById('inconnu'), throwsA(isA<TaskNotFoundException>()));
  });

  test('delete() retire la tâche et persiste le changement sur disque', () async {
    final task = NormalTask(id: 'a1', title: 'À supprimer', priority: Priority.low);
    await repository.add(task);
    await repository.delete('a1');

    final all = await repository.getAll();
    expect(all, isEmpty);

    final raw = jsonDecode(File(filePath).readAsStringSync()) as List<dynamic>;
    expect(raw, isEmpty);
  });

  test('les données survivent au rechargement depuis une nouvelle instance', () async {
    final task = NormalTask(
      id: 'a1',
      title: 'Persistée',
      priority: Priority.high,
      dueDate: DateTime(2026, 10, 10),
    );
    await repository.add(task);

    final reloaded = JsonTaskRepository(filePath);
    final all = await reloaded.getAll();
    expect(all, hasLength(1));
    expect(all.first.title, 'Persistée');
    expect(all.first.priority, Priority.high);
  });
}
