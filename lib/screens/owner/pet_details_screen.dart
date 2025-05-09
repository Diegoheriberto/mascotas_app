import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetDetailsScreen extends StatelessWidget {
  const PetDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Mascota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Opcional: Navegar a pantalla de edición
              Navigator.pushNamed(context, '/edit-pet', arguments: petId);
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('pets').doc(petId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Mascota no encontrada'));
          }

          final petData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPetHeader(context, petData),
                const SizedBox(height: 24),
                _buildPetInfoSection(petData),
                if (petData['vaccines'] != null &&
                    (petData['vaccines'] as List).isNotEmpty)
                  _buildVaccinesSection(petData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetHeader(BuildContext context, Map<String, dynamic> petData) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blue[50],
          child: Icon(
            Icons.pets,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                petData['pet_name'] ?? 'Sin nombre',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_getPetType(petData['type'])} • ${_getPetAge(petData['birth_date']?.toDate())}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPetInfoSection(Map<String, dynamic> petData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoItem('Tipo', _getPetType(petData['type'])),
        _buildInfoItem(
          'Fecha de Nacimiento',
          petData['birth_date']?.toDate().toString() ?? 'Desconocida',
        ),
        _buildInfoItem('Raza', petData['breed'] ?? 'No especificada'),
        _buildInfoItem('Color', petData['color'] ?? 'No especificado'),
      ],
    );
  }

  Widget _buildVaccinesSection(Map<String, dynamic> petData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Vacunas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        ...(petData['vaccines'] as List)
            .map(
              (vaccine) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services, size: 20),
                    const SizedBox(width: 8),
                    Text(vaccine.toString()),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getPetType(String? type) {
    switch (type?.toLowerCase()) {
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

  String _getPetAge(DateTime? birthDate) {
    if (birthDate == null) return 'Edad desconocida';
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;
    return '$age ${age == 1 ? 'año' : 'años'}';
  }
}
