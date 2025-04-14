import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_booking/providers/auth_provider.dart';
import 'package:flutter_booking/models/user.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _error;

 Future<void> _signup() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  try {
    // Créer un nouvel utilisateur
    final user = User(
      id: '',  // L'id sera généré automatiquement par la base de données
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: 'user', // Par défaut, l'utilisateur a un rôle 'user'
    );

    await authProvider.signup(user);  // Appel de la méthode signup avec l'objet User

    // Après la création, aller directement à la page d'accueil ou page de login
    Navigator.pushReplacementNamed(context, '/login');
  } catch (e) {
    setState(() {
      _error = 'Erreur lors de la création du compte';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Créez un compte avec vos informations'),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
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
              obscureText: true,
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
              onPressed: _signup,
              child: const Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
