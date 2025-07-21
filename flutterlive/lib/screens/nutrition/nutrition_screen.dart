import 'package:flutter/material.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Nutrition Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}