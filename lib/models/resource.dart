class Resource {
  int? id;
  String name;
  String type;
  String description;
  int capacity;

  Resource({
    this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.capacity,
  });

  // Convertir un objet Resource en Map (pour SQLite)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'type': type,
      'description': description,
      'capacity': capacity,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Créer un objet Resource à partir d’un Map (depuis SQLite)
  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      description: map['description'],
      capacity: map['capacity'],
    );
  }
}
