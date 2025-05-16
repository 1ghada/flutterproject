import 'package:flutter/material.dart';
import '/models/reservation.dart';
import '/models/resource.dart';
import '/services/reservation_service.dart';
import '/services/ressources_service.dart';
import '/services/auth_service.dart';
import '/services/authorization_service.dart';

class ReservationValidationPage extends StatefulWidget {
  const ReservationValidationPage({super.key});

  @override
  State<ReservationValidationPage> createState() => ReservationValidationPageState();
}

class ReservationValidationPageState extends State<ReservationValidationPage> {
  late Future<List<Reservation>> _pendingReservations;
  final ReservationService _reservationService = ReservationService();
  final ResourceService _resourceService = ResourceService();
  final AuthService _authService = AuthService();
  Map<int, Resource> _resourcesMap = {};
  Map<int, String> _userNamesMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Charger toutes les données nécessaires
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Vérifier si l'utilisateur a le droit de valider les réservations
      final authorizationService = AuthorizationService();
      final canValidate = await authorizationService.canValidateReservations();

      if (!canValidate) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vous n\'avez pas les droits pour valider les réservations.'),
              backgroundColor: Colors.red,
            ),
          );

          // Rediriger vers la page d'accueil
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          });

          return;
        }
      }

      // Charger les ressources pour afficher leurs noms
      final resources = await _resourceService.getAllResources();

      // Convertir la liste en Map pour un accès facile par ID
      final resourceMap = {for (var r in resources) r.id!: r};

      // Charger les réservations en attente pour obtenir les IDs des utilisateurs
      final pendingReservations = await _reservationService.getPendingReservations();

      // Créer un ensemble d'IDs d'utilisateurs uniques
      final userIds = pendingReservations.map((r) => r.userId).toSet();

      // Charger les noms des utilisateurs
      final userNamesMap = <int, String>{};
      for (final userId in userIds) {
        final userName = await _authService.getUserNameById(userId);
        userNamesMap[userId] = userName;
      }

      if (mounted) {
        setState(() {
          _resourcesMap = resourceMap;
          _userNamesMap = userNamesMap;
          _isLoading = false;
          _loadPendingReservations();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des données: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loadPendingReservations() {
    _pendingReservations = _reservationService.getPendingReservations();
  }

  // Obtenir le nom de la ressource à partir de son ID
  String _getResourceName(int resourceId) {
    return _resourcesMap[resourceId]?.name ?? 'Ressource #$resourceId';
  }

  // Obtenir le nom de l'utilisateur à partir de son ID
  String _getUserName(int userId) {
    return _userNamesMap[userId] ?? 'Utilisateur #$userId';
  }

  void _validateReservation(int reservationId) async {
    try {
      await _reservationService.validateReservation(reservationId, 'validée');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation validée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _loadPendingReservations(); // Recharger les réservations après validation
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la validation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rejectReservation(int reservationId) async {
    try {
      await _reservationService.validateReservation(reservationId, 'rejetée');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation rejetée'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _loadPendingReservations(); // Recharger les réservations après rejet
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du rejet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation des réservations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            tooltip: 'Accueil',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Reservation>>(
              future: _pendingReservations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'Une erreur est survenue',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucune réservation en attente',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          child: const Text('Retour à l\'accueil'),
                        ),
                      ],
                    ),
                  );
                }

                final reservations = snapshot.data!;

                return ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.business, color: Colors.teal),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getResourceName(reservation.resourceId),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text('Date: ${reservation.date}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text('Créneau: ${reservation.timeSlot}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text('Utilisateur: ${_getUserName(reservation.userId)}'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  label: const Text('Valider'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade50,
                                  ),
                                  onPressed: () => _validateReservation(reservation.id!),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  label: const Text('Rejeter'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade50,
                                  ),
                                  onPressed: () => _rejectReservation(reservation.id!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
