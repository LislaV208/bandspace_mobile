# BandSpace Mobile - Project Structure

## Root Directory Organization

```
bandspace_mobile/
├── lib/                    # Main Dart source code
├── android/               # Android-specific configuration
├── ios/                   # iOS-specific configuration
├── web/                   # Web platform files
├── linux/                 # Linux platform files
├── macos/                 # macOS platform files
├── windows/               # Windows platform files
├── product-documentation/ # Product requirements and specs
├── dev/                   # Development utilities and docs
├── .env                   # Production environment variables
├── .env.local            # Local development environment
└── pubspec.yaml          # Flutter dependencies and metadata
```

## Core Library Structure (`lib/`)

### Feature-Based Architecture
The codebase follows a feature-based architecture where each business domain has its own module:

```
lib/
├── main.dart              # App entry point
├── main_local.dart        # Local development entry point
├── core/                  # Shared core functionality
├── features/              # Business feature modules
└── shared/                # Cross-feature shared components
```

## Core Module (`lib/core/`)
Shared utilities, configurations, and foundational components:

```
core/
├── api/                   # API client and repository base classes
├── auth/                  # Authentication interceptors and services
├── config/                # Environment and app configuration
├── cubits/                # Core business logic (audio player, etc.)
├── di/                    # Dependency injection setup
├── navigation/            # Custom page routes and navigation
├── storage/               # Database and storage abstractions
├── theme/                 # App theming and styling
├── utils/                 # Utility functions and helpers
└── widgets/               # Reusable core UI components
```

## Features Module (`lib/features/`)
Each feature follows a consistent internal structure:

```
features/
├── auth/                  # Authentication and user management
├── dashboard/             # Main dashboard and project overview
├── project_detail/        # Project management and details
├── song_detail/           # Individual song management
├── account/               # User account settings
├── splash/                # App initialization screen
└── track_player/          # Audio playback functionality
```

### Feature Internal Structure
Each feature module follows this pattern:

```
feature_name/
├── cubit/                 # State management (BLoC pattern)
│   ├── feature_cubit.dart
│   └── feature_state.dart
├── repository/            # Data layer and API integration
│   └── feature_repository.dart
├── screens/               # Full-screen UI components
│   └── feature_screen.dart
├── views/                 # Reusable view components
│   └── feature_view.dart
└── widgets/               # Feature-specific UI components
    └── feature_widget.dart
```

## Shared Module (`lib/shared/`)
Cross-feature components and utilities:

```
shared/
├── cubits/                # Shared state management
├── models/                # Data models and DTOs
├── repositories/          # Shared data access layer
├── services/              # Cross-cutting services
└── widgets/               # Reusable UI components
```

## Naming Conventions

### Files and Classes
- **Screens**: `*_screen.dart` - Full-screen UI components
- **Views**: `*_view.dart` - Reusable view sections
- **Widgets**: `*_widget.dart` - Custom UI components
- **Cubits**: `*_cubit.dart` - Business logic controllers
- **States**: `*_state.dart` - State definitions for cubits
- **Repositories**: `*_repository.dart` - Data access layer
- **Models**: Use descriptive names without suffixes
- **Services**: `*_service.dart` - Business services

### Directories
- Use lowercase with underscores: `project_detail/`
- Group related functionality: `cubit/`, `widgets/`, `screens/`
- Keep feature modules self-contained

## Code Organization Principles

### Separation of Concerns
- **Screens**: Handle navigation and high-level UI structure
- **Views**: Contain business logic presentation
- **Widgets**: Focus on reusable UI components
- **Cubits**: Manage state and business logic
- **Repositories**: Handle data access and API calls
- **Models**: Define data structures

### Dependencies Flow
```
Screens → Views → Widgets
   ↓       ↓       ↓
 Cubits → Repositories → API/Storage
   ↓
 Models
```

### Import Organization
1. Flutter/Dart imports first
2. Third-party package imports
3. Local project imports (core, features, shared)
4. Relative imports last

Example:
```dart
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'package:bandspace_mobile/core/theme/app_theme.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

import '../widgets/login_form.dart';
```

## Asset Organization
- **Images**: `assets/images/` (if added)
- **Icons**: Use `icons_plus` and `lucide_icons_flutter` packages
- **Fonts**: `assets/fonts/` (if custom fonts added)
- **Environment files**: `.env`, `.env.local` in root

## Testing Structure (Future)
When tests are added, follow this structure:
```
test/
├── unit/                  # Unit tests
├── widget/                # Widget tests
├── integration/           # Integration tests
└── helpers/               # Test utilities
```

## Platform-Specific Code
- **Android**: `android/app/src/main/`
- **iOS**: `ios/Runner/`
- **Web**: `web/`
- Keep platform code minimal, prefer Flutter solutions