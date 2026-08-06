import 'dart:io';

import 'package:task_manager_cli/exceptions/task_exceptions.dart';
import 'package:task_manager_cli/models/priority.dart';
import 'package:task_manager_cli/repository/json_task_repository.dart';
import 'package:task_manager_cli/services/task_service.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late TaskService service;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('task_manager_service_test_');
    final repository = JsonTaskRepository('${tempDir.path}/tasks.json');
    service = TaskService(repository);
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('addTask(urgent: true) crée une UrgentTask en priorité high', () async {
    final task = await service.addTask(title: 'Panne critique', urgent: true);
    expect(task.priority, Priority.high);
  });

  test('completeTask() marque la tâche correspondante comme terminée', () async {
    final added = await service.addTask(title: 'Relire le contrat', priority: Priority.medium);
    final completed = await service.completeTask(added.id);
    expect(completed.isCompleted, isTrue);
  });

  test('deleteTask() retire la tâche des listages suivants', () async {
    final added = await service.addTask(title: 'À jeter', priority: Priority.low);
    await service.deleteTask(added.id);
    final tasks = await service.listTasks();
    expect(tasks.where((t) => t.id == added.id), isEmpty);
  });

  test('completeTask() lève TaskNotFoundException pour un identifiant inexistant', () async {
    expect(() => service.completeTask('inexistant'), throwsA(isA<TaskNotFoundException>()));
  });

  test('listTasks(sortBy: priority) place les tâches high avant les low', () async {
    await service.addTask(title: 'Basse priorité', priority: Priority.low);
    await service.addTask(title: 'Haute priorité', urgent: true);
    final tasks = await service.listTasks(sortBy: SortMode.priority);
    expect(tasks.first.priority, Priority.high);
  });
}
