/// Classe de base abstraite pour toutes les exceptions du domaine
/// "gestion de tâches". Permet d'attraper toutes les erreurs métier
/// avec un seul `on TaskManagerException`
abstract class TaskManagerException implements Exception {
  final String message;

  const TaskManagerException(this.message);

  @override
  String toString() => message;
}

/// Levée quand on demande une tâche dont l'identifiant n'existe pas
/// dans le dépôt (repository)
class TaskNotFoundException extends TaskManagerException {
  final String taskId;

  TaskNotFoundException(this.taskId)
      : super('Aucune tâche trouvée avec l\'identifiant "$taskId".');
}

/// Levée quand les données d'une tâche ne respectent pas les règles
/// de validation (ex : titre vide, niveau d'escalade invalide)
class InvalidTaskException extends TaskManagerException {
  InvalidTaskException(String reason) : super('Tâche invalide : $reason');
}

/// Levée quand une chaîne de caractères ne correspond à aucune
/// valeur connue de [Priority]
class InvalidPriorityException extends TaskManagerException {
  InvalidPriorityException(String value)
      : super('Priorité invalide : "$value". Valeurs acceptées : '
            'low, medium, high.');
}

/// Levée quand on tente d'ajouter une tâche avec un identifiant déjà
/// utilisé par une autre tâche du dépôt
class DuplicateTaskException extends TaskManagerException {
  DuplicateTaskException(String id)
      : super('Une tâche avec l\'identifiant "$id" existe déjà.');
}

/// Levée quand la lecture ou l'écriture du fichier de persistance
/// échoue (fichier corrompu, JSON invalide, erreur disque)
class RepositoryIOException extends TaskManagerException {
  RepositoryIOException(String reason) : super('Erreur de persistance : $reason');
}
