import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'register_screen.dart'; // Asegúrate de crear este archivo
import 'forget_password_screen.dart'; // Asegúrate de crear este archivo

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;

  // Método para login con email/contraseña
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navegar a Home después del login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_getErrorMessage(e.code))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Método para login con Google
  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn(
            clientId:
                '835255393361-iicn38qc2gc8d2khr071f4bvnm318og1.apps.googleusercontent.com',
          ).signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      // Navegar a Home después del login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error con Google: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // Mensajes de error para Firebase
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No hay cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      default:
        return 'Error al iniciar sesión';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: Colors.blue,
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
                Image.asset('assets/images/app_logo.png', height: 120),
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
                        // Campo de email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Campo de contraseña
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.blue,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.blue,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        // Botón de login con email/contraseña
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
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
                                      'Iniciar Sesión',
                                      style: TextStyle(fontSize: 16),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('O', style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 20),
                        // Botón de Google Sign-In
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed:
                                _isGoogleLoading ? null : _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:
                                _isGoogleLoading
                                    ? const CircularProgressIndicator()
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/google_logo.png',
                                          height: 24,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Continuar con Google',
                                          style: TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Enlaces adicionales
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgetPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
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
}
