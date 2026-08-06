import '../exceptions/task_exceptions.dart';

/// Niveaux de priorité disponibles pour une [Task].
/// L'ordre de déclaration (low, medium, high) est important : il sert
/// de base à la comparaison de priorité via `Priority.index`
enum Priority {
  low,
  medium,
  high;

  /// Parse une [Priority] à partir de sa représentation textuelle(insensible à la casse)
  
  /// Lève une [InvalidPriorityException] si [value] ne correspond à aucune priorité connu
  static Priority fromString(String value) {
    final normalized = value.trim().toLowerCase();
    for (final p in Priority.values) {
      if (p.name == normalized) return p;
    }
    throw InvalidPriorityException(value);
  }

  @override
  String toString() => name;
}
