# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Your role

You are an experienced Flutter developer. You should write clean and readable code.
You are passionate about creating clean and readable UI, you always think twice when creating an UI code.

## Development Commands

**Core Flutter Commands:**
```bash
flutter run                           # Run in debug mode
flutter run lib/main_local.dart       # Run with local environment (.env.local)
flutter build apk                     # Build Android APK
flutter build ios                     # Build iOS app
flutter test                          # Run tests
flutter analyze                       # Static analysis and linting
```

**Environment Setup:**
- Production: Uses `.env` file with API_BASE_URL=https://app.bandspace.pl/
- Local development: Uses `.env.local` file
- Debug builds include pre-filled credentials for faster development

## Architecture Overview

**BandSpace Mobile** is a Flutter application following **Clean Architecture** principles with BLoC/Cubit state management.

### Core Structure
- **lib/core/**: Contains shared infrastructure (API client, repositories, models, services, components)
- **Feature modules** (auth/, dashboard/, splash/): Self-contained features with their own components and state management
- **Repository Pattern**: Data access abstraction with BaseRepository
- **Cubit Pattern**: State management using flutter_bloc

### Key Components

**API Layer:**
- `ApiClient`: Singleton Dio-based HTTP client with comprehensive error handling
- Custom exceptions: `ApiException`, `NetworkException`, `TimeoutException`
- Bearer token authentication with secure storage

**State Management:**
- `AuthCubit`: Global authentication state
- Feature-specific Cubits for local state
- Immutable state objects with `copyWith` patterns

**Data Models:**
- Core models: `User`, `Project`, `Session`
- Extended models: `DashboardProject` (includes member info)
- All models implement proper equality comparison

### Navigation Flow
1. `SplashScreen` → checks authentication status
2. `AuthScreen` → handles login/registration
3. `DashboardScreen` → main app interface

### Environment Configuration
- `EnvConfig`: Singleton for environment variable management
- Multiple environment support through separate entry points
- Secure storage for authentication tokens

### Theming System
- `AppTheme`: Material 3 dark theme implementation
- `AppColors`: Centralized color definitions
- Comprehensive typography system

## Platform Support
Multi-platform Flutter app supporting Android, iOS, Web, and Desktop platforms with platform-specific configurations.

## Related Projects
- **Backend API**: /Users/sebastianlisiecki/bandspace-nestjs - NestJS REST API for BandSpace application
  - Available endpoints:
    - `POST api/auth/login` - User login
    - `POST api/auth/register` - User registration  
    - `POST api/auth/logout` - User logout
    - `GET api/users` - Get all users
    - `GET api/users/:id` - Get user by ID
    - `POST api/users` - Create user
    - `PATCH api/users/:id` - Update user
    - `DELETE api/users/:id` - Delete user

## Development Notes
- Polish language used in comments and some UI elements
- Debug mode provides development conveniences (auto-filled login)
- Comprehensive error handling throughout the application
- Resource cleanup implemented in Cubit dispose methods

## Other
- Respond in Polish
- Update this file after any changes that make it outdated