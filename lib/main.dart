import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travellog_app/Screens/home_page.dart';
import 'package:travellog_app/Screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://hlmpsayeplthegbbokmn.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsbXBzYXllcGx0aGVnYmJva21uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0NDU2MTIsImV4cCI6MjA3MjAyMTYxMn0.RKmZ69wFjk5xKU9buArcJXsCAYMpio-aqHhKpkd7m2c",
  );

  runApp(const ProviderScope(child: TravelLogApp()));
}

class TravelLogApp extends StatelessWidget {
  const TravelLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Journal',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: LoginScreen(),
    );
  }
}
