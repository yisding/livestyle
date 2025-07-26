import 'package:flutter/material.dart';
import '../screens/food_scanner/food_scanner_screen.dart';

class ScanButton extends StatelessWidget {
  final VoidCallback? onPressed;
  
  const ScanButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed ?? () => _navigateToFoodScanner(context),
      backgroundColor: const Color(0xFF51946C),
      foregroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(
        Icons.camera_alt,
        size: 24,
      ),
      label: Text(
        'Scan Food',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  void _navigateToFoodScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FoodScannerScreen(),
      ),
    );
  }
}