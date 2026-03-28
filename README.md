# Party Chaos

A fun multiplayer party games app built with Flutter and Supabase.

## Features

- Multiplayer party games
- Player profiles with avatars and colors
- Real-time game sessions
- Multiple game modes

## Getting Started

### Prerequisites

- Flutter SDK (3.5.0 or higher)
- Dart SDK (3.5.0 or higher)

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

### Building

```bash
# Debug build
flutter build apk --debug

# Release build (Android)
flutter build apk --release

# Web build
flutter build web
```

## Project Structure

```
lib/
├── core/          # Core utilities and theme
├── data/           # Game content and questions
├── models/         # Data models
├── providers/      # State management
├── screens/        # App screens
├── services/       # External services (Supabase)
└── widgets/        # Reusable widgets
```

## Tech Stack

- Flutter
- Provider (state management)
- Supabase (backend)
- GoRouter (navigation)
