# 🤖 Infomaniak Euria for iOS

Welcome to the official repository for **Infomaniak Euria**, an AI-powered assistant app for iOS, iPadOS. 👋

[<img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1662076800" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;">](https://apps.apple.com/app/infomaniak-euria/id6754152858)

## 📖 About Infomaniak Euria

Infomaniak Euria is part of the <a href="https://www.infomaniak.com/">Infomaniak</a> ecosystem, providing a privacy-focused 🔒, Swiss-based 🇨🇭 AI assistant with a beautiful native iOS experience. Built with Swift and SwiftUI, this app offers a fast, secure, and user-friendly way to interact with AI for your daily tasks.

## 🏗️ Architecture

The project follows a modular architecture with clear separation of concerns:

- **Euria**: Main app target containing SwiftUI views, scenes, and app lifecycle
- **EuriaCore**: Business logic framework with API layer, state managers, and data models
- **EuriaCoreUI**: Shared UI components and view modifiers
- **EuriaResources**: Assets, localized strings, and resources
- **EuriaFeatures**: Feature modules including PreloadingView, OnboardingView, MainView, and RootView
- **Extensions**: Share extension and Widget extensions

## 🛠️ Technology Stack

- **Language**: Swift 5.10
- **UI Framework**: SwiftUI (primary) with UIKit integration
- **Build System**: <a href="https://tuist.io/">Tuist</a> for project generation and SPM dependency management
- **Tool Management**: <a href="https://mise.jdx.dev/">Mise</a> for managing tool versions
- **Networking**: Alamofire (via Infomaniak frameworks)
- **Minimum iOS**: 16.6+

## 🚀 Getting Started

### Prerequisites

1. Install <a href="https://mise.jdx.dev/">Mise</a> for tool version management:
   ```bash
   curl https://mise.run | sh
   ```

2. Bootstrap the development environment:
   ```bash
   mise install
   eval "$(mise activate bash --shims)"
   ```

3. Install dependencies and generate the Xcode project:
   ```bash
   tuist install
   tuist generate
   ```

### Building and Running

Open the generated `Euria.xcworkspace` in Xcode and build the project, or use:
```bash
xcodebuild -scheme "Euria"
```
