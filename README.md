# PassioQuickStart iOS Demo

Welcome to Passio Quick Start iOS demo application. It is designed to showcase the capabilities of the PassioNutritionAI SDK for iOS - featuring food recognition, detailed nutritional analysis, and portion size estimation. The codebase in this repository shows a clean UIKit implementation that can be partially or fully adopted by developers to integrate PassioNutritionAI SDK into their applications.

## Features

- 📸 Food recognition using device camera
- 🖼️ Food recognition from gallery images  
- 🔍 Detailed nutritional information display
- 📊 Macronutrient breakdown with visual charts
- ⚖️ Dynamic serving size adjustments
- 🎯 Support for multiple measurement units
- 📱 Clean, modern iOS UI/UX

## Requirements

- iOS 14.0+
- Xcode 14.0+
- Swift 5.0+
- [PassioNutritionAI SDK](https://github.com/Passiolife/Passio-Nutrition-AI-iOS-SDK-Distribution) 3.2.2+
- Valid Passio SDK Key

## Installation

1. Clone the repository

  ```bash
  git clone https://github.com/Passiolife/PassioQuickStart-iOS.git
  ```

2. Install dependencies via Swift Package Manager (SPM)
   - The PassioNutritionAI SDK will be automatically installed through SPM

3. Configure SDK Key
   - Copy `Config.example.swift` to `Config.swift`
   - Replace `YOUR_PASSIO_KEY_HERE` with your valid Passio SDK key

4. Build and run the project in Xcode

## Usage

### Camera-based Recognition
1. Launch the app
2. Grant camera permissions when prompted
3. Point camera at food item
4. Tap capture button
5. View recognition results and nutritional details

### Gallery-based Recognition
1. Tap gallery button
2. Select food image from device
3. View recognition results and nutritional details

### Nutritional Information
- View comprehensive macro and micronutrient breakdown
- Adjust serving sizes using slider or text input
- Switch between different measurement units
- View percentage distribution of macronutrients via donut chart

## Architecture

The app follows standard iOS architecture patterns:

- **UI Layer**: Storyboard-based UI with custom XIB components
- **View Controllers**: Handle user interaction and data presentation
- **Custom Views**: Reusable UI components like DonutChartView
- **Extensions**: Utility extensions for UIKit components
- **Delegates**: Clean communication between components

Key Components:
- `ImageSelectionVC`: Handles camera/gallery image capture
- `RecognizeImageVC`: Manages food recognition process
- `FoodDetailVC`: Displays detailed nutritional information
- `FoodNutrientsCell`: Visualizes nutritional data
- `DonutChartView`: Custom chart for macronutrient ratios

## Example Code

Here's how to initialize the PassioSDK:

  ```swift
  private let passioSDK = PassioNutritionAI.shared
  private var passioConfig = PassioConfiguration(key: Config.PASSIO_KEY)
  
  func configurePassioSDK() {
      passioConfig.debugMode = 0
      passioSDK.statusDelegate = self
      passioConfig.remoteOnly = true
      
      passioSDK.configure(passioConfiguration: passioConfig) { status in
          print("Mode = \(status.mode)")
          print("Missingfiles = \(String(describing: status.missingFiles))")
      }
  }
  ```

## Learning from this Demo

### For New App Development
- **Architecture Pattern**: Study the MVVC implementation and file organization
- **Core Integration**: `ImageSelectionVC` shows camera setup and image capture workflow
- **Recognition Flow**: `RecognizeImageVC` demonstrates the food recognition pipeline
- **Results Handling**: `FoodDetailVC` shows how to present nutritional data
- **UI Components**: Reuse custom components like `DonutChartView` for macro visualization

### For Existing App Integration
- **Minimal Dependencies**: The SDK requires only UIKit - no additional frameworks needed
- **Modular Components**: Copy specific components like:
  - `FoodNutrientsCell` for nutrition display
  - `ServingSizeCell` for portion control
  - `DonutChartView` for macro ratio visualization
- **SDK Configuration**: See `configurePassioSDK()` for minimal setup requirements
- **Permission Handling**: Check Info.plist for required camera/photo permissions
- **UI Integration**: Use either:
  - Full screens (copy relevant ViewControllers)
  - Individual components (copy specific Cells/Views)

### Key Integration Points
1. SDK Initialization:
  ```swift
  private let passioSDK = PassioNutritionAI.shared
  passioSDK.configure(passioConfiguration: config) { status in
      // Handle configuration status
  }
  ```

2. Image Recognition:
  ```swift
  PassioNutritionAI.shared.recognizeImageRemote(image: image) { foods in
      // Handle recognition results
  }
  ```

3. Nutrition Display:
  ```swift
  // Use FoodNutrientsCell for detailed nutrition
  // Or access raw data:
  let calories = foodItem.nutrientsReference().calories()?.value
  let protein = foodItem.nutrientsReference().protein()?.value
  ```

## Support

- [SDK Documentation](https://passio.gitbook.io/nutrition-ai)
- [Nutrition AI Hub](https://passio.gitbook.io/nutrition-ai-hub)
- [Support Email](admin@passiolife.com)

## About Passio

[Passio](https://passio.ai) is a innovative AI technology company specializing in computer vision and machine learning solutions for nutrition, fitness and health. Our SDKs and APIs power food recognition and nutritional analysis in applications worldwide.

---

Made with ❤️ by Passio 