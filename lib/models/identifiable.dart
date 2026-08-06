/// Interface implémentée par tout modèle possédant un identifiant
/// unique. C'est cette interface qui permet au [Repository] générique
/// de manipuler n'importe quel type `T` sans connaître ses détail
abstract interface class Identifiable {
  String get id;
}
