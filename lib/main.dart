import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Pantallas de autenticación
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forget_password_screen.dart';

// Pantallas principales
import 'screens/home_screen.dart';
import 'screens/owner/owner_home.dart';
import 'screens/owner/my_pets_screen.dart';
import 'screens/owner/add_pet_screen.dart' as add_pet;
import 'screens/owner/owner_profile.dart';
import 'screens/owner/pet_details_screen.dart'; // 1. Importa la nueva pantalla
import 'screens/vet/vet_home.dart';
import 'screens/vet/vet_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mascotas App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forget-password': (context) => const ForgetPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/owner-home': (context) => const OwnerHomeScreen(),
        '/my-pets': (context) => const MyPetsScreen(),
        '/add-pet': (context) => const add_pet.AddPetScreen(),
        '/owner-profile': (context) => const OwnerProfileScreen(),
        '/vet-home': (context) => const VetHomeScreen(),
        '/vet-profile': (context) => const VetProfileScreen(),
        '/pet-details':
            (context) => const PetDetailsScreen(), // 2. Añade esta ruta
      },
    );
  }
}
