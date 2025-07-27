# LiveStyle Product Overview

LiveStyle is a Flutter-based health and fitness application focused on intensive lifestyle intervention for weight loss. The app combines AI coaching, health data integration, and personalized recommendations to help users achieve their weight loss goals.

## Core Features

- **AI Coaches**: Three specialized AI coaches (nutritionist, personal trainer, and psychotherapist) powered by Firebase AI and Gemini 2.5 Flash model
- **Health Data Integration**: Integration with Android Health Connect and Apple Health for workout and weight tracking data
- **AI Food Analysis**: Uses Gemini AI image recognition to estimate calories and macronutrients from food photos via camera scanning
- **Metabolic Rate Estimation**: AI-powered BMR estimation and calorie deficit planning (1-2 lbs/week) based on user data
- **Workout Optimization**: Monitors workout progress to prevent plateaus while maintaining low fatigue and high adherence

## User Experience

The app follows Material Design 3 principles with a clean, modern interface using the Manrope font family. The main navigation consists of four bottom tabs:

1. **Home**: User profile, health stats (weight, BMI, body fat), and AI coach recommendations
2. **Nutrition**: Food logging with camera-based image scanning and calorie tracking
3. **Workout**: Exercise tracking with workout history and progress monitoring
4. **Profile**: Personal information, settings, and user preferences

## Target Users

Health-conscious individuals seeking data-driven, AI-guided weight loss through integrated nutrition, exercise, and psychological support.

## Technical Integration

- Firebase backend with AI capabilities
- MCP (Model Context Protocol) toolkit integration for enhanced debugging and inspection
- Cross-platform support (Android, iOS, Web, macOS)
- Real-time health data synchronization