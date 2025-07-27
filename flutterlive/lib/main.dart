import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'dart:async';
import 'config/theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/nutrition/nutrition_screen.dart';
import 'screens/workout/workout_screen.dart';
import 'screens/profile/profile_screen.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Initialize MCP Toolkit
      MCPToolkitBinding.instance
        ..initialize() // Initializes the Toolkit
        ..initializeFlutterToolkit(); // Adds Flutter related methods to the MCP server
      
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      // Configure Firestore settings
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Initialize Firebase AI model
      FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stack) {
      // Critical: Handle zone errors for MCP server error reporting
      MCPToolkitBinding.instance.handleZoneError(error, stack);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiveStyle',
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of screens to display
  final List<Widget> _screens = [
    const HomeScreen(),
    const NutritionScreen(),
    const WorkoutScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
