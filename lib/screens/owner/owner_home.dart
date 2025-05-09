import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Early return si no hay usuario autenticado
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
      builder: (context, snapshot) {
        // Estados de carga y error
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Datos de usuario no encontrados')),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return _buildHomeScreen(context, userData);
      },
    );
  }

  Widget _buildHomeScreen(BuildContext context, Map<String, dynamic> userData) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${userData['name']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/owner_profile'),
            tooltip: 'Perfil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoCard(context, userData),
            const SizedBox(height: 24),
            _buildMainActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(
    BuildContext context,
    Map<String, dynamic> userData,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: ${userData['email'] ?? 'No proporcionado'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Rol: ${userData['role']?.toString().toUpperCase() ?? 'USUARIO'}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActions(BuildContext context) {
    return Column(
      children: [
        _buildActionCard(
          context,
          icon: Icons.pets,
          iconColor: Colors.amber,
          title: 'Mis Mascotas',
          subtitle: 'Administra tus mascotas registradas',
          onTap: () => Navigator.pushNamed(context, '/my_pets'),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          icon: Icons.calendar_today,
          title: 'Recordatorios',
          subtitle: 'Controles y vacunas',
          onTap: () => Navigator.pushNamed(context, '/reminders'),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          icon: Icons.local_hospital,
          title: 'Veterinarios cercanos',
          subtitle: 'Encuentra profesionales',
          onTap: () => Navigator.pushNamed(context, '/nearby_vets'),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    Color iconColor = Colors.blue,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 36, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
