class User {
  final int? id; // Le champ peut être nul
  final String name;
  final String email;
  final String password;
  final String role;

  // Constructeur avec paramètres requis et id facultatif
  User({
    this.id, // Le id est optionnel, il peut être nul
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  // Factory pour créer un utilisateur à partir d'un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?, // Le id peut être nul
      name: json['name'] ?? '', // Valeur par défaut si le nom est nul
      email: json['email'] ?? '', // Valeur par défaut si l'email est nul
      password: json['password'] ?? '', // Valeur par défaut si le mot de passe est nul
      role: json['role'] ?? '', // Valeur par défaut si le rôle est nul
    );
  }

  // Méthode pour convertir l'utilisateur en Map (JSON)
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
    // Ajoute l'id seulement si ce dernier est non nul
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Méthode de copie de l'objet en permettant de modifier le champ id
  User copyWith({int? id}) {
    return User(
      id: id ?? this.id, // Utilise id passé en paramètre, sinon conserve celui de l'objet
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }
}
