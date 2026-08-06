import '../models/identifiable.dart';

/// Contrat générique pour une collection d'objets de type [T],

abstract interface class Repository<T extends Identifiable> {
  Future<void> add(T item);
  Future<List<T>> getAll();
  Future<T> getById(String id);
  Future<void> update(T item);
  Future<void> delete(String id);
}
