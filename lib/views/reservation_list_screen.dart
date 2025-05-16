import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/reservation_service.dart';
import '/models/reservation.dart';
import '/services/ressources_service.dart';
import '/services/authorization_service.dart';
import '/models/resource.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  State<ReservationListScreen> createState() => ReservationListScreenState();
}

class ReservationListScreenState extends State<ReservationListScreen> {
  final _reservationService = ReservationService();
  final _resourceService = ResourceService();
  final _authorizationService = AuthorizationService();
  List<Reservation> reservations = [];
  Map<int, Resource> resourcesMap = {};
  bool _isLoading = true;
  bool _hasPermission = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadData();
  }

  // Afficher un message d'erreur et rediriger si nécessaire
  void _showErrorAndRedirect(String message, {bool redirect = false, int delaySeconds = 2}) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: delaySeconds),
      ),
    );

    if (redirect) {
      Future.delayed(Duration(seconds: delaySeconds), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }
  }

  Future<void> _checkPermissionAndLoadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Vérifier si l'utilisateur a le droit de consulter ses réservations
      final canViewReservations = await _authorizationService.canViewOwnReservations();

      if (mounted) {
        setState(() {
          _hasPermission = canViewReservations;
        });

        if (canViewReservations) {
          _loadData();
        } else {
          _showErrorAndRedirect(
            'Vous n\'avez pas les droits pour consulter les réservations.',
            redirect: true
          );
        }
      }
    } catch (e) {
      _showErrorAndRedirect('Erreur lors de la vérification des droits: $e');
    }
  }

  // Récupérer l'ID de l'utilisateur connecté
  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // Charger les données nécessaires
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Récupérer l'ID de l'utilisateur connecté
      final userId = await _getCurrentUserId();

      if (userId == null) {
        _showErrorAndRedirect(
          'Utilisateur non connecté. Veuillez vous connecter.',
          redirect: true,
          delaySeconds: 3
        );
        return;
      }

      try {
        // Charger les réservations de l'utilisateur
        final userReservations = await _reservationService.getUserReservations(userId);

        // Préparer la map des ressources
        Map<int, Resource> resourceMap = {};

        // Si l'utilisateur a des réservations, charger les ressources
        if (userReservations.isNotEmpty) {
          // Charger les ressources pour afficher leurs noms
          final resources = await _resourceService.getAllResources();

          // Convertir la liste en Map pour un accès facile par ID
          resourceMap = {for (var r in resources) r.id!: r};
        }

        if (mounted) {
          setState(() {
            reservations = userReservations;
            resourcesMap = resourceMap;
            _isLoading = false;
          });

          // Afficher un message si aucune réservation n'est trouvée
          if (userReservations.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vous n\'avez aucune réservation.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        // Erreur lors du chargement des données
        _showErrorAndRedirect('Erreur lors du chargement des réservations: $e');
      }
    } catch (e) {
      // Erreur générale
      _showErrorAndRedirect('Erreur lors du chargement des données: $e');
    }
  }

  // Obtenir le nom de la ressource à partir de son ID
  String _getResourceName(int resourceId) {
    return resourcesMap[resourceId]?.name ?? 'Ressource #$resourceId';
  }

  // Construire un badge pour le statut de la réservation
  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;
    String label = status;

    switch (status.toLowerCase()) {
      case 'validée':
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejetée':
        backgroundColor = Colors.red;
        icon = Icons.cancel;
        break;
      case 'en_attente':
      default:
        backgroundColor = Colors.orange;
        icon = Icons.hourglass_empty;
        label = 'En attente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: textColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
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
                  ),
                )
              : reservations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Aucune réservation trouvée."),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/reservation');
                            },
                            child: const Text('Faire une réservation'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                          final reservation = reservations[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                      _buildStatusBadge(reservation.status),
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
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.cancel, color: Colors.red),
                                        label: const Text('Annuler'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade50,
                                        ),
                                        onPressed: () async {
                                          // Confirmation avant suppression
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Confirmation'),
                                              content: const Text('Voulez-vous vraiment annuler cette réservation?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Non'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('Oui'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            try {
                                              await _reservationService.cancelReservation(reservation.id!);
                                              // Recharger les données après la suppression
                                              if (mounted) {
                                                setState(() {
                                                  // Supprimer la réservation de la liste locale pour une mise à jour immédiate
                                                  reservations.removeWhere((r) => r.id == reservation.id);
                                                });
                                                // Recharger toutes les données en arrière-plan
                                                _loadData();
                                              }
                                            } catch (e) {
                                              // Ne rien faire en cas d'erreur, _loadData() affichera l'erreur si nécessaire
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
