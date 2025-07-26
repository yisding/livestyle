import 'package:flutter/material.dart';

class ConfirmationButtons extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onRetake;
  final VoidCallback onManualEntry;
  final bool isLoading;

  const ConfirmationButtons({
    super.key,
    required this.onConfirm,
    required this.onRetake,
    required this.onManualEntry,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Confirm button (primary action)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF51946c),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: const Color(0xFF51946c).withOpacity(0.5),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Add to Diary',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary actions row
        Row(
          children: [
            // Retake button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onRetake,
                icon: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Color(0xFF51946c),
                ),
                label: const Text(
                  'Retake',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF51946c),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(
                    color: Color(0xFF51946c),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Manual entry button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onManualEntry,
                icon: const Icon(
                  Icons.edit,
                  size: 18,
                  color: Color(0xFF51946c),
                ),
                label: const Text(
                  'Edit',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF51946c),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(
                    color: Color(0xFF51946c),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Manual entry alternative (full width)
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: isLoading ? null : onManualEntry,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFe8f2ec),
              foregroundColor: const Color(0xFF0e1a13),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Enter Manually',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}