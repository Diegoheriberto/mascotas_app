import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>(); // <-- Línea corregida
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _emailSent = false;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() => _emailSent = true);
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('¡Éxito!'),
                content: const Text(
                  'El email de recuperación fue enviado. Revisa tu bandeja.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo
                      Navigator.pop(context); // Vuelve a login si quieres
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessage(e.code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe cuenta con este email';
      case 'invalid-email':
        return 'Email no válido';
      default:
        return 'Error al enviar email: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.lock_reset, size: 100, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'Ingresa tu email para recibir un enlace de recuperación',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.blue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su email';
                            }
                            if (!RegExp(
                              r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Email no válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendResetEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'Enviar Email',
                                      style: TextStyle(fontSize: 16),
                                    ),
                          ),
                        ),
                        if (_emailSent) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Revisa tu bandeja de entrada y sigue las instrucciones',
                            style: TextStyle(color: Colors.green),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Volver a Inicio de Sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
