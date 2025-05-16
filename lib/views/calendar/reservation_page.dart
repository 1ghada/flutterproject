import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/reservation_service.dart';
import '/services/ressources_service.dart';
import '/services/authorization_service.dart';
import '/models/resource.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> {
  final _reservationService = ReservationService();
  final _resourceService = ResourceService();
  final _authorizationService = AuthorizationService();

  Resource? selectedResource;
  DateTime? selectedDate;
  bool _isLoading = true;
  bool _hasPermission = false;

  List<Resource> resources = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadResources();
  }

  Future<void> _checkPermissionAndLoadResources() async {
    setState(() {
      _isLoading = true;
    });

    // Vérifier si l'utilisateur a le droit de faire une réservation
    final canAddReservation = await _authorizationService.canAddReservation();

    if (mounted) {
      setState(() {
        _hasPermission = canAddReservation;
        _isLoading = false;
      });

      if (canAddReservation) {
        loadResources();
      } else {
        // Rediriger vers la page d'accueil si l'utilisateur n'a pas les droits
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous n\'avez pas les droits pour faire une réservation.'),
            backgroundColor: Colors.red,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      }
    }
  }

  Future<void> loadResources() async {
    final result = await _resourceService.getAllResources();
    setState(() {
      resources = result;
    });
  }

  Future<int?> getUserIdFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> submitReservation() async {
    // Vérifier à nouveau les autorisations
    if (!_hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous n\'avez pas les droits pour faire une réservation.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final userId = await getUserIdFromPreferences();

    if (selectedResource == null || selectedDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une ressource et une date.')),
        );
      }
      return;
    }

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non identifié. Veuillez vous connecter.')),
        );
      }
      return;
    }

    final dateStr = selectedDate!.toIso8601String().split("T").first;

    try {
      await _reservationService.reserve(
        userId: userId,
        resourceId: selectedResource!.id!,
        date: dateStr,
        timeSlot: 'Journée', // Ajout d'une valeur par défaut pour le créneau horaire
      );

      // Vérifier si le widget est toujours monté avant d'utiliser le contexte
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation réussie !'),
            backgroundColor: Colors.green,
          ),
        );

        // Naviguer vers la liste des réservations après une réservation réussie
        Navigator.pushReplacementNamed(context, '/reservations');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
        title: const Text("Réserver une ressource"),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasPermission
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Accès refusé',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vous n\'avez pas les droits pour faire une réservation.',
                        textAlign: TextAlign.center,
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
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButton<Resource>(
                        hint: const Text("Choisir une ressource"),
                        value: selectedResource,
                        items: resources.map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text(r.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedResource = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        child: Text(selectedDate == null
                            ? "Choisir une date"
                            : "${selectedDate!.toLocal()}".split(' ')[0]),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: submitReservation,
                        child: const Text("Réserver"),
                      ),
                    ],
                  ),
                ),
    );
  }
}
