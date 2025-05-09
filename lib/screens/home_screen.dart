import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mascotas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              '¡Bienvenido!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            if (user?.email != null) ...[
              Text(
                'Email: ${user!.email}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Verificado: ${user.emailVerified ? 'Sí' : 'No'}',
                style: TextStyle(
                  color: user.emailVerified ? Colors.green : Colors.orange,
                ),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.pets),
              label: const Text('Mis mascotas'),
              onPressed: () {
                Navigator.pushNamed(context, '/my-pets'); // Agrega esta línea
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Agregar nueva mascota
        },
      ),
    );
  }
}
