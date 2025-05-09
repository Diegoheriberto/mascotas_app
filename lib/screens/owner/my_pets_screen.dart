import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirestorePaths {
  static const petsCollection = 'pets';
  static const ownerField = 'owner';
  static const petNameField = 'pet_name';
  static const typeField = 'type';
  static const birthDateField = 'birth_date';
  static const vaccinesField = 'vaccines';
}

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mascotas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddPet(context),
            tooltip: 'Agregar mascota',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddPet(context),
        tooltip: 'Agregar nueva mascota',
        child: const Icon(Icons.add),
      ),
      body: _buildPetList(context, userId),
    );
  }

  void _navigateToAddPet(BuildContext context) {
    Navigator.pushNamed(context, '/add-pet').then((_) {
      if (mounted) {
        Fluttertoast.showToast(msg: "Mascota agregada");
      }
    });
  }

  Widget _buildPetList(BuildContext context, String? userId) {
    if (userId == null) {
      return _buildAuthError();
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection(FirestorePaths.petsCollection)
              .where(FirestorePaths.ownerField, isEqualTo: userId)
              .orderBy(FirestorePaths.petNameField)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error?.toString() ?? 'Error desconocido');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        return _buildPetListView(snapshot.data!.docs);
      },
    );
  }

  Widget _buildAuthError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'Debes iniciar sesión para ver tus mascotas',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String error) {
    Fluttertoast.showToast(msg: "Error: $error");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'Ocurrió un error al cargar las mascotas',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'No tienes mascotas registradas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Agregar primera mascota'),
            onPressed: () => _navigateToAddPet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPetListView(List<QueryDocumentSnapshot> pets) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final pet = pets[index];
        final petData = pet.data() as Map<String, dynamic>;

        return _buildPetCard(context, pet.id, petData);
      },
    );
  }

  Widget _buildPetCard(
    BuildContext context,
    String petId,
    Map<String, dynamic> petData,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToPetDetails(context, petId),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildPetAvatar(petData),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petData[FirestorePaths.petNameField] ?? 'Sin nombre',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getPetType(petData)} • ${_getPetAge(petData)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (petData[FirestorePaths.vaccinesField] != null &&
                        (petData[FirestorePaths.vaccinesField] as List)
                            .isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Chip(
                          label: Text(
                            '${(petData[FirestorePaths.vaccinesField] as List).length} vacuna${(petData[FirestorePaths.vaccinesField] as List).length > 1 ? 's' : ''}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.green[50],
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetAvatar(Map<String, dynamic> petData) {
    final type = petData[FirestorePaths.typeField]?.toString().toLowerCase();
    IconData icon;
    Color color;

    switch (type) {
      case 'dog':
        icon = Icons.pets;
        color = Colors.amber;
        break;
      case 'cat':
        icon = Icons.pets;
        color = Colors.blue;
        break;
      case 'bird':
        icon = Icons.air;
        color = Colors.green;
        break;
      default:
        icon = Icons.pets;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color),
    );
  }

  String _getPetType(Map<String, dynamic> petData) {
    final type = petData[FirestorePaths.typeField]?.toString().toLowerCase();
    switch (type) {
      case 'dog':
        return 'Perro';
      case 'cat':
        return 'Gato';
      case 'bird':
        return 'Ave';
      default:
        return 'Mascota';
    }
  }

  String _getPetAge(Map<String, dynamic> petData) {
    final birthDate = petData[FirestorePaths.birthDateField]?.toDate();
    if (birthDate == null) return 'Edad desconocida';

    final age = DateTime.now().difference(birthDate).inDays ~/ 365;
    return '$age ${age == 1 ? 'año' : 'años'}';
  }

  void _navigateToPetDetails(BuildContext context, String petId) {
    Navigator.pushNamed(context, '/pet-details', arguments: petId).then((_) {
      if (mounted) {
        Fluttertoast.showToast(msg: "Actualizando lista...");
      }
    });
  }
}
