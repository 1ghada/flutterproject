import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_booking/providers/auth_provider.dart';
import 'signup_view.dart'; // Assurez-vous que ce chemin est correct

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;

  Future<void> _login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.login(_emailController.text.trim(), _passwordController.text.trim());

      final role = authProvider.userRole;

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (role == 'manager') {
        Navigator.pushReplacementNamed(context, '/manager');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _error = 'Utilisateur non trouvé ou mot de passe incorrect !';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Bienvenue ! Connectez-vous avec votre email et mot de passe'),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,  // Masque le mot de passe
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Se connecter'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup'); // Aller vers la page de signup
              },
              child: const Text("Créer un compte"),
            ),
          ],
        ),
      ),
    );
  }
}
