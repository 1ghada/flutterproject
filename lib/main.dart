import 'package:flutter/material.dart';
import 'package:flutter_booking/views/home/ReservationValidationPage.dart';
import 'package:flutter_booking/views/reservation_list_screen.dart';
import 'package:flutter_booking/views/notifications_screen.dart';

import 'views/home/home_page.dart';
import 'views/ressource_page.dart';
import 'views/calendar/reservation_page.dart';
import 'views/login_view.dart';  // Assure-toi que le chemin d'importation est correct
import 'views/signup_view.dart';  // Assure-toi que le chemin d'importation est correct


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Booking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/login', // Route initiale
      routes: {
        '/login': (context) => const LoginView(), // Route pour la connexion
        '/signup': (context) => const SignupView(), // Route pour l'inscription
        '/home': (context) => const HomePage(), // Route pour la page d'accueil
        '/ressources': (context) => const ResourcePage(), // Route pour la gestion des ressources
        '/reservation': (context) =>  BookingScreen(), // Route pour la réservation
        '/validation': (context) =>  ReservationValidationPage(), // Route pour la validation des réservations par le manager
        '/reservations': (context) => const ReservationListScreen(), // Route pour la liste des réservations
        '/notifications': (context) => const NotificationsScreen(), // Route pour les notifications
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
