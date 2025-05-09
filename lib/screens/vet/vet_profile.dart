import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/user_service.dart';

class VetProfileScreen extends StatefulWidget {
  const VetProfileScreen({super.key});

  @override
  _VetProfileScreenState createState() => _VetProfileScreenState();
}

class _VetProfileScreenState extends State<VetProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final _nameController = TextEditingController();
  final _clinicController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final userData = await _userService.getUserData(
      FirebaseAuth.instance.currentUser!.uid,
    );

    if (userData != null) {
      _nameController.text = userData['name'] ?? '';
      _clinicController.text = userData['clinicName'] ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _userService
          .updateUserProfile(FirebaseAuth.instance.currentUser!.uid, {
            'name': _nameController.text.trim(),
            'clinicName': _clinicController.text.trim(),
          });
      Fluttertoast.showToast(msg: 'Perfil actualizado');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil Veterinario')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Ingrese su nombre' : null,
                      ),
                      TextFormField(
                        controller: _clinicController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la Clínica',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateProfile,
                        child: const Text('Guardar Cambios'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
