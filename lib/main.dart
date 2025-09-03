import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("Loading .env...");
  await dotenv.load(fileName: ".env");
  print(".env loaded ✅");

  print("App initialized ✅");

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
