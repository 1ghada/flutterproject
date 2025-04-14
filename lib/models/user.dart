class User {
  final String id;
  final String name;
  final String email;
  final String password;  // Mot de passe
  final String role; // 'admin', 'manager', 'user'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],  // On charge le mot de passe
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,  // On enregistre le mot de passe
    'role': role,
  };

  // Pour faire une copie de l'utilisateur avec un nouvel ID
  User copyWith({String? id}) {
    return User(
      id: id ?? this.id,
      name: this.name,
      email: this.email,
      password: this.password,
      role: this.role,
    );
  }
}
