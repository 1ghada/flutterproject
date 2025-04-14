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

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      description: map['description'],
      capacity: map['capacity'],
    );
  }

  // ✅ Méthode fromJson utilisée par Reservation
  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      capacity: json['capacity'],
    );
  }

  // ✅ Méthode toJson si tu fais des appels HTTP ou Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'capacity': capacity,
    };
  }
}
