# LiveStyle

Livestyle is a Flutter application built with Material Design 3 that does intensive lifestyle intervention for losing weight.

## AI Coaches

At its core, Livestyle has three AI coaches, an expert AI nutritionist, an expert AI personal trainer, and an expert psychotherapist. Each day, 3 times a day, each of the coaches will synthesize all of the relevant data and provide advice to the user.

Initailly each of the AI coaches will be built using Gemini 2.5 Pro with web browsing.

## Data

Livestyle heavily integrates into Android Health Connect and also Apple Health (eventually). Most of the workout tracking and weight tracking will be done via other applications, so Livestyle just needs to get the data from those applications via Health Connect.

## AI Metabolic Rate Estimation

Using the food data and weight data and body fat percentage data, Livestyle will estimate the user's BMR and build a calorie deficit to lose 1-2 pounds a week. This BMR will be adjusted based on the observed weight data.

## AI Calorie and Macro Estimation from Images

Livestyle will estimate the calories and macronutrient levels of foods based on the images that the user takes using Gemini 2.5 Pro. These calorie and macronutrient counts will be logged and will help the coaches assess if the user has enough of a calorie deficit and is getting enough macronutrients to sustain their diet and muscle building goals.

## Workout Optimization

As best as possible, the personal trainer AI should be keeping an eye on the workout progress and checking to see if the user may be plateauing. If they are, it should offer adjustments. In addition, the goal is to keep fatigue low and adherence up.