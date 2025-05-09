import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  DateTime? _birthDate;
  String? _selectedGender;

  final List<String> _petTypes = ['Perro', 'Gato', 'Conejo', 'Ave', 'Otro'];
  final List<String> _genders = ['Macho', 'Hembra'];

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Mascota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePet,
            tooltip: 'Guardar mascota',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNameField(),
              const SizedBox(height: 20),
              _buildTypeDropdown(),
              const SizedBox(height: 20),
              _buildBreedField(),
              const SizedBox(height: 20),
              _buildBirthDatePicker(),
              const SizedBox(height: 20),
              _buildGenderRadio(),
              const SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nombre de la mascota',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.pets),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa un nombre';
        }
        return null;
      },
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _typeController.text.isEmpty ? null : _typeController.text,
      decoration: const InputDecoration(
        labelText: 'Tipo de mascota',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items:
          _petTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
      onChanged: (value) {
        setState(() {
          _typeController.text = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecciona un tipo';
        }
        return null;
      },
    );
  }

  Widget _buildBreedField() {
    return TextFormField(
      controller: _breedController,
      decoration: const InputDecoration(
        labelText: 'Raza (opcional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.emoji_nature),
      ),
    );
  }

  Widget _buildBirthDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha de nacimiento (opcional)',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _birthDate == null
                  ? 'Seleccionar fecha'
                  : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Género',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children:
              _genders.map((gender) {
                return Expanded(
                  child: RadioListTile<String>(
                    title: Text(gender),
                    value: gender,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save),
        label: const Text('Guardar Mascota'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _savePet,
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _savePet() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Fluttertoast.showToast(msg: "Usuario no autenticado");
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('pets').add({
          'name': _nameController.text,
          'type': _typeController.text,
          'breed':
              _breedController.text.isNotEmpty ? _breedController.text : null,
          'birthDate': _birthDate,
          'gender': _selectedGender,
          'ownerId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        Fluttertoast.showToast(msg: "Mascota guardada exitosamente");
        Navigator.pop(context);
      } catch (e) {
        Fluttertoast.showToast(msg: "Error al guardar: ${e.toString()}");
      }
    }
  }
}
