import 'package:flutter/material.dart';
import 'ui/screens/home_screen.dart';
import 'data/database_provider.dart'; // Optionnel : pour créer/ouvrir la DB au lancement

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // (Optionnel) Pré-initialiser la base pour créer le fichier tôt et logguer le chemin
  try {
    await DatabaseProvider().database;
  } catch (_) {
    // En prod, loggez si besoin : debugPrint('DB init error: $_');
  }

  runApp(const KYTMOContactApp());
}

class KYTMOContactApp extends StatelessWidget {
  const KYTMOContactApp({super.key});

  static const Color kBrandColor = Color(0xFF1E6C99); // Couleur du logo

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kBrandColor,
        brightness: Brightness.light,
      ),
      snackBarTheme:
          const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kBrandColor,
        brightness: Brightness.dark,
      ),
      snackBarTheme:
          const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    return MaterialApp(
      title: 'KYTMO CONTACT',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
