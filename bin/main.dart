import 'dart:io';

import 'package:task_manager_cli/exceptions/task_exceptions.dart';
import 'package:task_manager_cli/models/priority.dart';
import 'package:task_manager_cli/repository/json_task_repository.dart';
import 'package:task_manager_cli/services/task_service.dart';

Future<void> main(List<String> arguments) async {
  final repository = JsonTaskRepository('tasks.json');
  final service = TaskService(repository);

  if (arguments.isEmpty) {
    _printUsage();
    exit(0);
  }

  final command = arguments.first;
  final rest = arguments.skip(1).toList();

  try {
    switch (command) {
      case 'add':
        await _handleAdd(service, rest);
        break;
      case 'list':
        await _handleList(service, rest);
        break;
      case 'done':
        await _handleDone(service, rest);
        break;
      case 'delete':
        await _handleDelete(service, rest);
        break;
      case 'help':
      case '--help':
      case '-h':
        _printUsage();
        break;
      default:
        stderr.writeln('Commande inconnue : "$command"');
        _printUsage();
        exit(64);
    }
  } on TaskManagerException catch (e) {
    // Toutes les erreurs métier (tâche introuvable, doublon, JSON
    // invalide, titre vide...) remontent ici sous une forme lisible.
    stderr.writeln('Erreur : ${e.message}');
    exit(1);
  }
}

Map<String, String> _parseOptions(List<String> args) {
  final options = <String, String>{};
  for (final arg in args) {
    if (arg.startsWith('--') && arg.contains('=')) {
      final withoutPrefix = arg.substring(2);
      final separatorIndex = withoutPrefix.indexOf('=');
      final key = withoutPrefix.substring(0, separatorIndex);
      final value = withoutPrefix.substring(separatorIndex + 1);
      options[key] = value;
    } else if (arg.startsWith('--')) {
      options[arg.substring(2)] = 'true';
    }
  }
  return options;
}

Future<void> _handleAdd(TaskService service, List<String> rest) async {
  final positional = rest.where((a) => !a.startsWith('--')).toList();
  final options = _parseOptions(rest);

  if (positional.isEmpty) {
    stderr.writeln(
        'Usage : add "<titre>" [--priority=low|medium|high] [--due=AAAA-MM-JJ] [--urgent]');
    exit(64);
  }

  final title = positional.join(' ');
  final priority = options.containsKey('priority')
      ? Priority.fromString(options['priority']!)
      : Priority.medium;
  final dueDate = options.containsKey('due') ? DateTime.parse(options['due']!) : null;
  final urgent = options['urgent'] == 'true';

  final task = await service.addTask(
    title: title,
    priority: priority,
    dueDate: dueDate,
    urgent: urgent,
  );
  print('Tâche ajoutée : ${task.describe()} (id: ${task.id})');
}

Future<void> _handleList(TaskService service, List<String> rest) async {
  final options = _parseOptions(rest);
  final sortMode = options['sort'] == 'date' ? SortMode.dueDate : SortMode.priority;
  final tasks = await service.listTasks(sortBy: sortMode);

  if (tasks.isEmpty) {
    print('Aucune tâche pour le moment.');
    return;
  }

  print('${tasks.length} tâche(s) :');
  for (final task in tasks) {
    print('  ${task.id} | ${task.describe()}');
  }
}

Future<void> _handleDone(TaskService service, List<String> rest) async {
  if (rest.isEmpty) {
    stderr.writeln('Usage : done <id>');
    exit(64);
  }
  final task = await service.completeTask(rest.first);
  print('Tâche marquée comme terminée : ${task.describe()}');
}

Future<void> _handleDelete(TaskService service, List<String> rest) async {
  if (rest.isEmpty) {
    stderr.writeln('Usage : delete <id>');
    exit(64);
  }
  await service.deleteTask(rest.first);
  print('Tâche supprimée : ${rest.first}');
}

void _printUsage() {
  print('''
Gestionnaire de tâches — CLI Dart

Usage :
  dart run bin/main.dart add "<titre>" [--priority=low|medium|high] [--due=AAAA-MM-JJ] [--urgent]
  dart run bin/main.dart list [--sort=priority|date]
  dart run bin/main.dart done <id>
  dart run bin/main.dart delete <id>
  dart run bin/main.dart help
''');
}
