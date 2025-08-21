
# Bandspace Mobile - Gemini Agent Context

This document provides context for the Gemini agent to understand the Bandspace Mobile Flutter project.

## Project Overview

Bandspace Mobile is a Flutter application designed for musicians and bands to collaborate. It allows users to manage projects, record audio, and share their work. The app is built with a feature-based architecture, separating concerns into `core`, `features`, and `shared` directories.

### Key Technologies

*   **Framework:** Flutter
*   **State Management:** Flutter Bloc
*   **HTTP Client:** Dio
*   **Authentication:** Google Sign-In, JWT with secure storage
*   **Routing:** `MaterialApp` with custom page transitions
*   **Local Storage:** `sqflite`, `shared_preferences`
*   **Audio:** `just_audio`
*   **Environment:** `flutter_dotenv`
*   **Dependency Injection:** `provider` (for BLoCs)

### Architecture

The project follows a feature-driven architecture:

*   `lib/core`: Contains core functionalities like API services, authentication, dependency injection, navigation, and theme.
*   `lib/features`: Each feature of the application (e.g., `auth`, `dashboard`, `project_detail`) has its own directory containing screens, cubits/blocs, and widgets.
*   `lib/shared`: Contains shared models, repositories, services, and widgets used across multiple features.

## Building and Running

### Prerequisites

*   Flutter SDK installed
*   An emulator or physical device

### Running the app

The project has two entry points:

*   **`lib/main.dart`**: The main entry point for the production environment. It uses the `.env` file for configuration.
*   **`lib/main_local.dart`**: The entry point for the local development environment. It uses the `.env.local` file for configuration.

To run the app, use the following commands:

*   **Production:** `flutter run`
*   **Local:** `flutter run -t lib/main_local.dart`

### Building the app

To build the app for a specific platform, use the standard Flutter build commands:

*   **Android:** `flutter build apk` or `flutter build appbundle`
*   **iOS:** `flutter build ios`

## Development Conventions

*   **State Management:** Use Flutter Bloc (or Cubit for simpler cases) for managing the state of widgets and features.
*   **Dependency Injection:** BLoCs and other dependencies are provided to the widget tree using `MultiBlocProvider` in `lib/core/di/app_providers.dart`.
*   **Styling:** The app uses a custom dark theme defined in `lib/core/theme/theme.dart`.
*   **Environment Variables:** All environment-specific configurations (like API endpoints) are stored in `.env` files and accessed through the `EnvConfig` class.
*   **Null Safety:** The project is null-safe.
*   **Linting:** The project uses `flutter_lints` for code analysis. Adhere to the linting rules defined in `analysis_options.yaml`.
