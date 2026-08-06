# Task Manager CLI — Dart
Application en ligne de commande de gestion de tâches, écrite en **Dart pur**
(sans Flutter), avec persistance des données dans un fichier JSON local.

## Fonctionnalités

- Ajouter une tâche (titre, priorité `low`/`medium`/`high`, date limite optionnelle)
- Lister toutes les tâches, triées par priorité ou par date limite
- Marquer une tâche comme terminée
- Supprimer une tâche
- Persistance automatique dans `tasks.json`

## Architecture

```
lib/
  models/
    identifiable.dart     -> interface Identifiable { String get id; }
    priority.dart          -> enum Priority (low/medium/high) + parsing
    task.dart               -> classe abstraite Task (implements Comparable, Identifiable)
    normal_task.dart        -> NormalTask extends Task
    urgent_task.dart        -> UrgentTask extends Task (héritage, toujours priorité high)
  exceptions/
    task_exceptions.dart   -> TaskManagerException et ses sous-classes
  repository/
    repository.dart         -> interface générique Repository<T extends Identifiable>
    json_task_repository.dart -> implémentation JSON de Repository<Task>
  services/
    task_service.dart       -> logique métier (ajout, tri, complétion, suppression)
bin/
  main.dart                 -> point d'entrée CLI (parsing des arguments)
test/
  task_test.dart
  json_task_repository_test.dart
  task_service_test.dart
```

### Exigences techniques couvertes

| Exigence | Où |

| Classes abstraites + héritage | `Task` (abstraite) → `NormalTask`, `UrgentTask` |
| Interface implémentée | `Task implements Comparable<Task>, Identifiable` ; `Repository` et `Identifiable` sont des `abstract interface class` |
| Génériques | `abstract interface class Repository<T extends Identifiable>`, implémenté par `JsonTaskRepository implements Repository<Task>` |
| Exceptions personnalisées | `TaskManagerException` et ses sous-classes (`TaskNotFoundException`, `InvalidTaskException`, `InvalidPriorityException`, `DuplicateTaskException`, `RepositoryIOException`) |
| Persistance JSON | `JsonTaskRepository` lit/écrit `tasks.json` via `dart:io` + `dart:convert` |
| Tests unitaires (≥ 5) | 17 tests répartis sur 3 fichiers, package `test` |

## Prérequis

- [Dart SDK](https://dart.dev/get-dart) ≥ 3.0.0

Vérifier l'installation :

```bash
dart --version
```

## Installation

```bash
git clone <url-du-repo>
cd task_manager_cli
dart pub get
```

## Lancer l'application

```bash
# Ajouter une tâche normale
dart run bin/main.dart add "Préparer la présentation" --priority=medium --due=2026-09-01

# Ajouter une tâche urgente (toujours priorité high)
dart run bin/main.dart add "Serveur en panne" --urgent

# Lister les tâches (triées par priorité)
dart run bin/main.dart list

# Lister les tâches triées par date limite
dart run bin/main.dart list --sort=date

# Marquer une tâche comme terminée (utiliser l'id affiché par `list`)
dart run bin/main.dart done <id>

# Supprimer une tâche
dart run bin/main.dart delete <id>

# Aide
dart run bin/main.dart help
```

Les données sont automatiquement sauvegardées dans `tasks.json`, créé dans le
répertoire courant au premier ajout.

## Lancer les tests

```bash
dart test
```

Pour lancer un seul fichier de tests :

```bash
dart test test/task_test.dart
```

## Analyse statique (optionnel)

```bash
dart analyze
```
