import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("Loading .env...");
  await dotenv.load(fileName: ".env");
  print(".env loaded ✅");

  print("Initializing Supabase...");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );
  print("Supabase initialized ✅");

  runApp(const BazarioApp());
}

class BazarioApp extends StatelessWidget {
  const BazarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bazario - The Neighbor Goods',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const AuthWrapper(),
    );
  }
}
