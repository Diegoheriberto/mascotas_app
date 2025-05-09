import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // -----------------------------------------
  // 1. Login con Email/Contraseña
  // -----------------------------------------
  Future<void> _loginWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Ingrese email y contraseña");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _redirectUser(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: _handleAuthError(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // -----------------------------------------
  // 2. Login con Google
  // -----------------------------------------
  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Guardar datos del usuario en Firestore si es nuevo
      if (userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'role': 'dueño', // Rol por defecto
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await _redirectUser(userCredential.user!.uid);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error en Google Sign-In: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // -----------------------------------------
  // 3. Redirección por rol
  // -----------------------------------------
  Future<void> _redirectUser(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      Fluttertoast.showToast(msg: "Usuario no registrado");
      return;
    }

    final role = userDoc.data()!['role'] ?? 'dueño';

    Navigator.pushReplacementNamed(
      context,
      role == 'veterinario' ? '/vet_home' : '/owner_home',
    );
  }

  // -----------------------------------------
  // 4. Manejo de errores
  // -----------------------------------------
  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no registrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Email inválido';
      default:
        return 'Error al iniciar sesión';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),

            // Contraseña
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),

            const SizedBox(height: 20),

            // Botón Login Email
            ElevatedButton(
              onPressed: _isLoading ? null : _loginWithEmail,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Iniciar Sesión'),
            ),

            // O Divider
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text('O', style: TextStyle(color: Colors.grey)),
            ),

            // Botón Google
            OutlinedButton(
              onPressed: _isLoading ? null : _loginWithGoogle,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.grey),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/google_logo.png', height: 24),
                  const SizedBox(width: 10),
                  const Text('Continuar con Google'),
                ],
              ),
            ),

            // Enlace a Registro
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
