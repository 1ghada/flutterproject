import 'package:flutter/material.dart';
import 'package:flutter_booking/views/ressource_page.dart';
import 'package:flutter_booking/views/calendar/reservation_page.dart';
import 'package:flutter_booking/services/authorization_service.dart';
import 'package:flutter_booking/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthorizationService _authService = AuthorizationService();
  final NotificationService _notificationService = NotificationService();
  String? _userRole;
  String? _userName;
  bool _isLoading = true;
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = await _authService.getCurrentUser();

    // Charger le nombre de notifications non lues
    int unreadCount = 0;
    if (user != null) {
      unreadCount = await _notificationService.countUnreadNotifications(user.id!);
    }

    if (mounted) {
      setState(() {
        _userRole = user?.role;
        _userName = user?.name;
        _unreadNotificationsCount = unreadCount;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Principal'),
        actions: [
          // Bouton de notifications avec badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications').then((_) {
                    // Recharger les informations après avoir consulté les notifications
                    _loadUserInfo();
                  });
                },
                tooltip: 'Notifications',
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadNotificationsCount > 9 ? '9+' : _unreadNotificationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      drawer: _isLoading
          ? null
          : Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Navigation',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Bienvenue, $_userName',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Rôle: $_userRole',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Accueil'),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                  // Afficher les options selon le rôle
                  if (_userRole == AuthorizationService.ROLE_ADMIN)
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Gestion des Ressources'),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const ResourcePage()),
                        );
                      },
                    ),
                  if (_userRole == AuthorizationService.ROLE_USER)
                    ListTile(
                      leading: const Icon(Icons.event),
                      title: const Text('Faire une réservation'),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => BookingScreen()),
                        );
                      },
                    ),
                  if (_userRole == AuthorizationService.ROLE_USER)
                    ListTile(
                      leading: const Icon(Icons.list_alt),
                      title: const Text('Mes Réservations'),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/reservations');
                      },
                    ),
                  if (_userRole == AuthorizationService.ROLE_MANAGER)
                    ListTile(
                      leading: const Icon(Icons.check_circle),
                      title: const Text('Validation des réservations'),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/validation');
                      },
                    ),
                  // Notifications pour tous les utilisateurs
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Row(
                      children: [
                        const Text('Notifications'),
                        if (_unreadNotificationsCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _unreadNotificationsCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/notifications').then((_) {
                        // Recharger les informations après avoir consulté les notifications
                        _loadUserInfo();
                      });
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Déconnexion'),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bienvenue, $_userName!',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Vous êtes connecté en tant que $_userRole',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  // Afficher les boutons d'action selon le rôle
                  if (_userRole == AuthorizationService.ROLE_USER)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.event),
                      label: const Text('Faire une réservation'),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/reservation');
                      },
                    ),
                  if (_userRole == AuthorizationService.ROLE_ADMIN)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.book),
                      label: const Text('Gérer les ressources'),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/ressources');
                      },
                    ),
                  if (_userRole == AuthorizationService.ROLE_MANAGER)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Valider les réservations'),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/validation');
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
