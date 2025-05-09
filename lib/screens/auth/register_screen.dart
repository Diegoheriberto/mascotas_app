import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Controladores
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _clinicNameController = TextEditingController();

  // Variables
  String _selectedRole = 'dueño';
  bool _isLoading = false;

  // Roles disponibles
  final List<String> _roles = ['dueño', 'veterinario'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _clinicNameController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 2. Guardar información adicional en Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        if (_selectedRole == 'veterinario')
          'clinicName': _clinicNameController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Navegar al home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: _getErrorMessage(e.code),
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error desconocido: $e',
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'El correo ya está registrado';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      default:
        return 'Error al registrar: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator:
                    (value) => value!.isEmpty ? 'Ingrese su nombre' : null,
              ),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                validator:
                    (value) =>
                        !value!.contains('@')
                            ? 'Ingrese un correo válido'
                            : null,
              ),

              // Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator:
                    (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),

              // Confirmar contraseña
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                ),
                validator:
                    (value) =>
                        value != _passwordController.text
                            ? 'Las contraseñas no coinciden'
                            : null,
              ),

              // Selector de rol
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items:
                    _roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(
                          role == 'dueño' ? 'Dueño de mascota' : 'Veterinario',
                        ),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _selectedRole = value!),
                decoration: const InputDecoration(labelText: 'Tipo de usuario'),
              ),

              // Campo condicional para veterinarios
              if (_selectedRole == 'veterinario')
                TextFormField(
                  controller: _clinicNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la clínica',
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty
                              ? 'Ingrese el nombre de la clínica'
                              : null,
                ),

              const SizedBox(height: 20),

              // Botón de registro
              ElevatedButton(
                onPressed: _isLoading ? null : _registerUser,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
