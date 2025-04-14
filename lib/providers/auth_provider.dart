import 'package:flutter/material.dart';
import 'package:flutter_booking/models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;

  bool get isAuthenticated => _user != null;

  String get userRole => _user?.role ?? 'user';

  // Méthode de login
  Future<void> login(String email, String password) async {
    // Logique pour la connexion de l'utilisateur
    // Exemple : vérifier dans la base de données si l'email et le mot de passe correspondent
    // Puis assigner à _user si la connexion réussie
  }

  // Méthode de création de compte (signup)
  Future<void> signup(User user) async {
    // Logique pour enregistrer un nouvel utilisateur
    // Exemple : enregistrer l'utilisateur dans la base de données
    // Après cela, tu peux assigner à _user
    _user = user;
    notifyListeners();
  }

  // Méthode pour déconnecter l'utilisateur
  void logout() {
    _user = null;
    notifyListeners();
  }
}
