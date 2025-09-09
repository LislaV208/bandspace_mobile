# BandSpace Mobile - Technical Stack

## Framework & Platform
- **Flutter 3.8.1+** - Cross-platform mobile development framework
- **Dart** - Primary programming language
- **Target Platforms**: iOS, Android, macOS, Linux, Windows, Web

## Architecture Pattern
- **BLoC (Business Logic Component)** - State management using `flutter_bloc`
- **Repository Pattern** - Data layer abstraction
- **Dependency Injection** - Centralized provider configuration in `core/di/`
- **Feature-based Architecture** - Organized by business features

## Key Dependencies

### State Management & Architecture
- `flutter_bloc: ^9.1.1` - BLoC pattern implementation
- `provider: ^6.1.5` - Dependency injection and state management
- `equatable: ^2.0.7` - Value equality for state objects

### Audio & Media
- `just_audio: ^0.10.4` - Audio playback functionality
- `file_picker: ^10.2.0` - File selection from device storage
- `permission_handler: ^12.0.1` - Device permissions management

### Networking & API
- `dio: ^5.8.0+1` - HTTP client for API communication
- `connectivity_plus: ^6.1.4` - Network connectivity monitoring

### Storage & Persistence
- `sembast: ^3.8.5` - NoSQL database for local storage
- `sqflite: ^2.3.3` - SQLite database
- `shared_preferences: ^2.5.3` - Simple key-value storage
- `flutter_secure_storage: ^9.2.4` - Secure credential storage
- `path_provider: ^2.1.5` - File system path access

### Authentication & Security
- `google_sign_in: ^7.1.1` - Google OAuth integration
- `crypto: ^3.0.6` - Cryptographic functions

### UI & UX
- `gap: ^3.0.1` - Spacing widgets
- `icons_plus: ^5.0.0` - Extended icon sets
- `lucide_icons_flutter: ^3.0.6` - Lucide icon library
- `flutter_keyboard_visibility: ^6.0.0` - Keyboard state detection

### Configuration & Environment
- `flutter_dotenv: ^5.2.1` - Environment variable management
- `package_info_plus: ^8.3.1` - App package information

### Reactive Programming
- `rxdart: ^0.28.0` - Reactive extensions for Dart

## Build System & Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run in production mode (uses .env)
flutter run

# Run in local development mode (uses .env.local)
flutter run -t lib/main_local.dart

# Hot reload during development
# Press 'r' in terminal or use IDE hot reload
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

### Building
```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android)
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Build for web
flutter build web --release
```

### Code Quality
```bash
# Format code
dart format .

# Fix common issues
dart fix --apply

# Check for outdated dependencies
flutter pub outdated
```

## Environment Configuration
- `.env` - Production environment variables
- `.env.local` - Local development environment variables
- Environment files are loaded via `EnvConfig` class
- Two entry points: `main.dart` (production) and `main_local.dart` (development)

## Authentication & Security
- **JWT Authentication**: Secure token-based authentication with secure storage
- **Google Sign-In**: OAuth integration for user authentication
- **Secure Storage**: Sensitive data stored using `flutter_secure_storage`

## Development Practices
- **Null Safety**: Full null safety compliance
- **Code Analysis**: Uses `flutter_lints` with rules defined in `analysis_options.yaml`
- **Widget Architecture**: Prefer separate `StatelessWidget`/`StatefulWidget` classes over inline `_build` methods
- **Dependency Injection**: BLoCs provided via `MultiBlocProvider` in `lib/core/di/app_providers.dart`
- **Custom Theming**: Dark theme implementation in `lib/core/theme/theme.dart`
- **Custom Navigation**: `MaterialApp` with custom page transitions

## Project Structure Conventions
- Use `lib/core/` for shared utilities and configurations
- Use `lib/features/` for business feature modules
- Use `lib/shared/` for cross-feature shared components
- Follow BLoC naming: `*_cubit.dart`, `*_state.dart`
- Repository classes end with `_repository.dart`
- Screen classes end with `_screen.dart`

## Agent Integration Guidelines
- Code analysis with `flutter analyze` is sufficient (no need to check compilation)