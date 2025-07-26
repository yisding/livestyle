import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/camera_view.dart';
import '../../widgets/analysis_results.dart';
import '../../widgets/confirmation_buttons.dart';

class FoodScannerScreen extends ConsumerStatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  ConsumerState<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends ConsumerState<FoodScannerScreen> {
  AnalysisState _analysisState = AnalysisState.idle;
  FoodAnalysisResult? _analysisResult;
  String? _capturedImagePath;
  String? _errorMessage;

  void _handleImageCaptured(String imagePath) {
    setState(() {
      _capturedImagePath = imagePath;
      _analysisState = AnalysisState.analyzing;
      _analysisResult = null;
      _errorMessage = null;
    });

    // Simulate AI analysis with dummy data
    _simulateAnalysis();
  }

  Future<void> _simulateAnalysis() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Simulate analysis result with dummy data
    final result = FoodAnalysisResult(
      foodName: 'Grilled Chicken Salad',
      calories: 320,
      protein: 28.5,
      carbs: 12.3,
      fat: 18.7,
      confidence: 0.85,
    );

    if (mounted) {
      setState(() {
        _analysisState = AnalysisState.completed;
        _analysisResult = result;
      });
    }
  }

  void _handleConfirm() {
    // TODO: Add food to diary
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Food added to diary!'),
        backgroundColor: Color(0xFF51946c),
      ),
    );
  }

  void _handleRetake() {
    setState(() {
      _analysisState = AnalysisState.idle;
      _analysisResult = null;
      _capturedImagePath = null;
      _errorMessage = null;
    });
  }

  void _handleManualEntry() {
    // TODO: Navigate to manual food entry screen
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Manual entry not implemented yet'),
        backgroundColor: Color(0xFF51946c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8fbfa),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf8fbfa),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Color(0xFF0e1a13),
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Food',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0e1a13),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Camera view or captured image
                    if (_capturedImagePath == null)
                      Expanded(
                        child: CameraView(
                          onImageCaptured: _handleImageCaptured,
                        ),
                      )
                    else
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(
                                // Using a placeholder food image for demo
                                'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Analysis results
                    AnalysisResults(
                      state: _analysisState,
                      result: _analysisResult,
                      errorMessage: _errorMessage,
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom section with confirmation buttons
            if (_analysisState == AnalysisState.completed && _analysisResult != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ConfirmationButtons(
                  onConfirm: _handleConfirm,
                  onRetake: _handleRetake,
                  onManualEntry: _handleManualEntry,
                  isLoading: false,
                ),
              ),
          ],
        ),
      ),
    );
  }
}