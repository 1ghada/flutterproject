import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'auth_service.dart';

class AuthorizationService {
  final AuthService _authService = AuthService();

  // Constantes pour les rôles
  static const String ROLE_USER = 'user';
  static const String ROLE_ADMIN = 'admin';
  static const String ROLE_MANAGER = 'manager';

  // Récupérer l'utilisateur actuellement connecté
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    
    if (userId == null) {
      return null;
    }
    
    return _authService.getUserById(userId);
  }

  // Vérifier si l'utilisateur a un rôle spécifique
  Future<bool> hasRole(String role) async {
    final user = await getCurrentUser();
    return user?.role == role;
  }

  // Vérifier si l'utilisateur est un utilisateur standard
  Future<bool> isUser() async {
    return await hasRole(ROLE_USER);
  }

  // Vérifier si l'utilisateur est un administrateur
  Future<bool> isAdmin() async {
    return await hasRole(ROLE_ADMIN);
  }

  // Vérifier si l'utilisateur est un manager
  Future<bool> isManager() async {
    return await hasRole(ROLE_MANAGER);
  }

  // Vérifier si l'utilisateur peut ajouter une réservation (user)
  Future<bool> canAddReservation() async {
    return await isUser();
  }

  // Vérifier si l'utilisateur peut consulter ses réservations (user)
  Future<bool> canViewOwnReservations() async {
    return await isUser();
  }

  // Vérifier si l'utilisateur peut ajouter une ressource (admin)
  Future<bool> canAddResource() async {
    return await isAdmin();
  }

  // Vérifier si l'utilisateur peut consulter la liste des ressources (admin)
  Future<bool> canViewResources() async {
    return await isAdmin();
  }

  // Vérifier si l'utilisateur peut valider les réservations (manager)
  Future<bool> canValidateReservations() async {
    return await isManager();
  }

  // Récupérer le rôle de l'utilisateur actuel
  Future<String?> getCurrentUserRole() async {
    final user = await getCurrentUser();
    return user?.role;
  }
}
