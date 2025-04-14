import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_booking/providers/auth_provider.dart';
import 'views/auth/login_view.dart'; // Page de connexion
import 'views/auth/signup_view.dart'; // Page de création de compte
import 'views/ressource_page.dart'; // Page des ressources

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Fournisseur pour AuthProvider
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Booking',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        // La logique pour décider de la première page à afficher
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginView(),
          '/signup': (context) => const SignupView(), // Route vers Signup
          '/home': (context) => const ResourcePage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Vérifier si l'utilisateur est connecté avec le provider
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isAuthenticated) {
      // Si l'utilisateur est connecté, afficher la page des ressources
      return const ResourcePage();
    } else {
      // Si l'utilisateur n'est pas connecté, afficher la page de connexion
      return const LoginView();
    }
  }
}
