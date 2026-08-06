import 'package:task_manager_cli/exceptions/task_exceptions.dart';
import 'package:task_manager_cli/models/normal_task.dart';
import 'package:task_manager_cli/models/priority.dart';
import 'package:task_manager_cli/models/urgent_task.dart';
import 'package:test/test.dart';

void main() {
  group('Priority', () {
    test('fromString parse les valeurs valides sans tenir compte de la casse', () {
      expect(Priority.fromString('HIGH'), Priority.high);
      expect(Priority.fromString('low'), Priority.low);
    });

    test('fromString lève InvalidPriorityException pour une valeur inconnue', () {
      expect(
        () => Priority.fromString('urgentissime'),
        throwsA(isA<InvalidPriorityException>()),
      );
    });
  });

  group('NormalTask', () {
    test('lève InvalidTaskException si le titre est vide', () {
      expect(
        () => NormalTask(id: '1', title: '   ', priority: Priority.low),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('complete() marque la tâche comme terminée', () {
      final task = NormalTask(id: '1', title: 'Faire les courses', priority: Priority.medium);
      expect(task.isCompleted, isFalse);
      task.complete();
      expect(task.isCompleted, isTrue);
    });
  });

  group('UrgentTask', () {
    test('est toujours créée avec la priorité high', () {
      final task = UrgentTask(id: '2', title: 'Serveur en panne');
      expect(task.priority, Priority.high);
    });

    test('escalate() incrémente le niveau d\'escalade', () {
      final task = UrgentTask(id: '2', title: 'Serveur en panne', escalationLevel: 1);
      task.escalate();
      expect(task.escalationLevel, 2);
    });

    test('lève InvalidTaskException si le niveau d\'escalade initial est < 1', () {
      expect(
        () => UrgentTask(id: '2', title: 'Serveur en panne', escalationLevel: 0),
        throwsA(isA<InvalidTaskException>()),
      );
    });
  });

  group('Tri des tâches (Comparable)', () {
    test('les tâches de priorité high passent avant les tâches low', () {
      final low = NormalTask(id: '1', title: 'Peu urgent', priority: Priority.low);
      final high = NormalTask(id: '2', title: 'Urgent', priority: Priority.high);
      final tasks = [low, high]..sort();
      expect(tasks.first, high);
    });

    test('à priorité égale, la date limite la plus proche passe en premier', () {
      final later = NormalTask(
        id: '1',
        title: 'Plus tard',
        priority: Priority.medium,
        dueDate: DateTime(2026, 12, 1),
      );
      final sooner = NormalTask(
        id: '2',
        title: 'Bientôt',
        priority: Priority.medium,
        dueDate: DateTime(2026, 9, 1),
      );
      final tasks = [later, sooner]..sort();
      expect(tasks.first, sooner);
    });
  });
}
