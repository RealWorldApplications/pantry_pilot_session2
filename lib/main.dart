import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/camera_screen.dart';
import 'theme/pantry_theme.dart';

// ─── Entry Point ─────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env so GeminiService can read GEMINI_API_KEY at runtime.
  await dotenv.load(fileName: '.env');
  runApp(const PantryPilotApp());
}

// ─── Root Application ─────────────────────────────────────────────────────────
class PantryPilotApp extends StatelessWidget {
  const PantryPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pantry Pilot',
      debugShowCheckedModeBanner: false,
      theme: PantryTheme.darkTheme,
      home: const CameraScreen(),
    );
  }
}
