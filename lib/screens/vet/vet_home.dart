import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VetHomeScreen extends StatelessWidget {
  const VetHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: Text('Dr. ${userData['name']}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => Navigator.pushNamed(context, '/vet_profile'),
              ),
            ],
          ),
          body: Column(
            children: [
              Text('Clínica: ${userData['clinicName'] ?? 'No especificada'}'),
              // Widgets específicos para veterinarios
              // Ej: Lista de pacientes, calendario, etc.
            ],
          ),
        );
      },
    );
  }
}
