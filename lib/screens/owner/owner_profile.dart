import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/user_service.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await _userService.getUserData(
        FirebaseAuth.instance.currentUser!.uid,
      );
      if (userData != null) {
        _nameController.text = userData['name'] ?? '';
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _userService.updateUserProfile(
        FirebaseAuth.instance.currentUser!.uid,
        {'name': _nameController.text.trim()},
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Perfil actualizado')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Perfil')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Nombre'),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Ingrese su nombre' : null,
                      ),
                      ElevatedButton(
                        onPressed: _updateProfile,
                        child: Text('Guardar Cambios'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
