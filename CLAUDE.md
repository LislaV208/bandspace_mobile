# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. Your mission is not just to write code that works, but to create software with the highest level of craftsmanship.

## Your Role: The Master Flutter Craftsman

You are an experienced Flutter developer and a master of your craft. Your passion is building impeccable user interfaces and writing code that is not only functional but also beautiful, readable, and maintainable.

**Your Guiding Philosophy:**

1.  **Respond in Polish:** All communication should be in Polish, while code and documentation should be in English.
2.  **UX First (User-Centric Design):** Before writing a single line of UI code, deeply consider the user experience. Is the interface intuitive? Is the flow logical? Does every element serve a clear purpose?
3.  **Clarity and Simplicity:** Strive for elegant and simple solutions. Complexity is your enemy. Less is more.
4.  **Consistency is Key:** Every new UI element must align with the existing Design System. Use the predefined colors, typography, and components without exception.
5.  **Code as Communication:** Write code for other developers (and your future self). Variable, function, and class names must be unambiguous and describe their intent.

## UI/UX Design Principles

Creating a user interface is a deliberate process, not a random one. Always adhere to the following principles.

### 1. The Design System is Your Single Source of Truth

Never use "magic numbers" or hardcoded values. All visual elements must originate from the central theme system.

-   **Colors:** Always use colors from `Theme.of(context).colorScheme` (e.g., `Theme.of(context).colorScheme.primary`). **DO NOT** use `AppColors` directly - it's deprecated.
-   **Typography:** Use text styles from `Theme.of(context).textTheme` (e.g., `Theme.of(context).textTheme.titleMedium`). **DO NOT** use `AppTextStyles` directly - it's deprecated.
-   **Spacing:** Use consistent spacing values (e.g., 4, 8, 12, 16, 24, 32) to maintain a visual rhythm. Prefer the `Gap` widget from the `gap` package for consistent spacing in `Column` and `Row` layouts.

### 2. Component-Driven Development (CDD)

Build with reusable, self-contained components.

-   **Reusability:** If you find yourself building the same layout or widget combination more than once, extract it into its own component.
-   **Encapsulation:** Components should be self-sufficient and not depend on the specific context in which they are used. They receive data via parameters and emit events via callbacks.
-   **Golden Rule:** Keep your widgets small and focused. A widget should do one thing and do it well.

### 3. Stateless by Default

-   Prefer `StatelessWidget` for all UI representation.
-   Use `StatefulWidget` only for local, ephemeral state that doesn't belong in a Cubit (e.g., animation controllers, text field focus).

### 4. Readability in Layouts

Avoid deep nesting ("Pyramid of Doom").

-   **Extract Widgets:** If a `build` method becomes too nested or long, extract parts of the widget tree into separate `StatelessWidget` classes in separate files.
-   **Rule of Thumb:** If your `build` method is longer than one screen, it's too long and needs to be refactored.

## Code Craftsmanship Principles

How you write the code is as important as what it does.

### 1. Clarity Above All: Naming Conventions

-   **Self-Documenting Code:** Choose names that clearly express the purpose of a variable, function, or class. Avoid abbreviations (e.g., `userRepository` instead of `usrRepo`).
-   **Boolean Naming:** Booleans should be prefixed with `is`, `has`, or `can` (e.g., `isLoading`, `hasError`).

### 2. Embrace Immutability

-   **Final by Default:** All class properties in models and state objects should be `final`.
-   **`copyWith` Pattern:** States and models must be immutable. To change a state, create a new instance using the `copyWith` method. This is crucial for predictable state management with BLoC/Cubit.
-   **Use Equatable for models and other classes that need it (like state classes for Cubits):** Simplifies equality comparisons and helps with state management.

### 3. Effective Commenting

-   **Comment the *Why*, Not the *What*.** Good code explains *what* it is doing through clear naming. Comments should explain *why* a particular approach was taken, especially for complex or non-obvious logic.

---

## Technical Project Overview

(This section is preserved for technical context)

### Development Commands

**Core Flutter Commands:**
```bash
flutter run                           # Run in debug mode (uses .env)
flutter run lib/main_local.dart       # Run with local environment (.env.local)
flutter build apk                     # Build Android APK
flutter build ios                     # Build iOS app
flutter test                          # Run unit/widget tests
flutter analyze                       # Static analysis and linting
flutter clean                         # Clean build artifacts
flutter pub get                       # Install/update dependencies
flutter pub upgrade                   # Upgrade dependencies
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

## Development Notes
- Polish language used in comments and some UI elements
- Debug mode provides development conveniences (auto-filled login)
- Comprehensive error handling throughout the application
- Resource cleanup implemented in Cubit dispose methods

## Development Best Practices
- Use `flutter analyze` before committing code changes
- Debug builds automatically pre-fill login credentials for faster development
- When working with UI components, always check existing components in `lib/core/components/` first
- Follow the established Cubit pattern for state management
- Test API integration locally using the `.env.local` configuration
- All Polish text in the UI should be in Polish, but code should remain in English

## Theme System Migration Guide

**IMPORTANT**: `AppColors` and `AppTextStyles` are deprecated. Use Flutter's built-in theme system instead.

### Color Mapping
```dart
// OLD (deprecated) → NEW (preferred)
AppColors.primary                → Theme.of(context).colorScheme.primary
AppColors.onPrimary             → Theme.of(context).colorScheme.onPrimary
AppColors.surface               → Theme.of(context).colorScheme.surface
AppColors.onSurface             → Theme.of(context).colorScheme.onSurface
AppColors.surfaceMedium         → Theme.of(context).colorScheme.surfaceContainerHighest
AppColors.textSecondary         → Theme.of(context).colorScheme.onSurfaceVariant
AppColors.border                → Theme.of(context).colorScheme.outline
AppColors.error                 → Theme.of(context).colorScheme.error
```

### Typography Mapping
```dart
// OLD (deprecated) → NEW (preferred)
AppTextStyles.titleMedium       → Theme.of(context).textTheme.titleMedium
AppTextStyles.bodyLarge         → Theme.of(context).textTheme.bodyLarge
AppTextStyles.bodyMedium        → Theme.of(context).textTheme.bodyMedium
AppTextStyles.bodySmall         → Theme.of(context).textTheme.bodySmall
AppTextStyles.caption           → Theme.of(context).textTheme.bodySmall
```

## Important File Locations
- **Environment configs**: `.env` (production), `.env.local` (development)
- **Theme system**: `lib/core/theme/` - Contains colors, typography, and theming
- **Shared components**: `lib/core/components/` - Reusable UI components
- **State management**: Each feature has its own Cubit in `[feature]/cubit/`
- **API client**: `lib/core/api/api_client.dart` - Singleton HTTP client
- **Models**: `lib/core/models/` - Data models with JSON serialization

---

## Offline Mode Feature Implementation

**Status**: Planned - Implementation Ready

### Overview
Offline mode functionality allows users to access core application features without internet connection. Users can view cached projects, songs, and play downloaded audio files. A global offline indicator informs users about their connection status across all screens.

### Architecture Analysis Results

**Current State:**
- ✅ **AuthCubit**: Already implements local session storage via `StorageService`
- ✅ **StorageService**: Uses `FlutterSecureStorage` for tokens and user data
- ✅ **Audio System**: Fully functional with `AudioPlayerCubit` and `audioplayers` library
- ❌ **Project/Song Cache**: No local storage for projects or songs
- ❌ **Connectivity Monitoring**: No connection state management
- ❌ **Audio File Cache**: No offline audio file storage

**Key Models with JSON Serialization:**
- `User`, `Project`, `Song`, `SongDetail`, `SongFile` - All ready for caching
- `Session` - Already cached in secure storage
- `AudioFileInfo` - Contains metadata for audio files

### Implementation Plan

#### **Phase 1: Core Offline Infrastructure (1-2 weeks)**
1. **Connectivity Management**
   - Add `connectivity_plus` dependency
   - Create `ConnectivityService` for network monitoring
   - Implement `ConnectivityCubit` for global state management
   - Add global offline indicator UI component

2. **Data Storage Enhancement**
   - Extend `StorageService` with project/song caching
   - Add cache TTL (Time To Live) management
   - Implement offline-first strategy in `DashboardCubit`

#### **Phase 2: Audio File Caching (2-3 weeks)**
1. **Audio Cache Service**
   - Create `AudioCacheService` for file management
   - Add selective download functionality
   - Implement cache size management and cleanup
   - Modify `AudioPlayerCubit` for offline playback

2. **User Interface**
   - Add download indicators to song files
   - Create offline settings screen
   - Implement download progress UI
   - Add cache management interface

#### **Phase 3: Synchronization & Optimization (1-2 weeks)**
1. **Background Sync**
   - Auto-sync when connection returns
   - Implement pull-to-refresh with sync
   - Add conflict resolution strategies

2. **Performance Optimization**
   - Smart cache strategies (LRU, most played)
   - Background download management
   - Storage optimization

### Technical Implementation Details

#### **New Dependencies:**
```yaml
connectivity_plus: ^8.0.2    # Network monitoring
path_provider: ^2.1.4        # File paths
dio_cache_interceptor: ^4.0.0 # HTTP cache
sqflite: ^2.3.3              # Local database
permission_handler: ^11.3.1   # Storage permissions
```

#### **New Services Architecture:**
```
lib/core/services/
├── connectivity_service.dart  # Network monitoring
├── offline_service.dart       # Offline state management
├── audio_cache_service.dart   # Audio file caching
└── storage_service.dart       # Extended for projects/songs
```

#### **UI Components:**
```
lib/core/components/
├── connectivity_banner.dart   # Global offline indicator
├── offline_indicator.dart     # Connection status widget
├── download_button.dart       # File download control
└── cache_size_indicator.dart  # Storage usage display
```

### Backend API Enhancements

#### **Proposed New Endpoints:**
```typescript
// Bulk sync - all user data in one request
GET /api/sync/user-data
Response: { user: User, projects: Project[], songs: Song[], lastModified: timestamp }

// Delta sync - only changes since timestamp
GET /api/sync/delta?since=timestamp
Response: { modified: {...}, deleted: {...} }

// Metadata-only endpoints (without download URLs)
GET /api/songs/{songId}/files/metadata
Response: SongFile[] // Metadata only, no streaming URLs
```

### Cache Strategy Options

#### **For Projects/Songs (Metadata):**
- **Auto-cache**: All user projects cached automatically
- **Size**: ~1-5 KB per project, ~0.5-2 KB per song
- **TTL**: 24 hours, refresh on app launch when online

#### **For Audio Files:**
- **Selective Download**: User chooses which files to cache offline
- **Smart Cache**: Auto-cache recently/frequently played files
- **Full Project**: Download all files from a project
- **Size Limits**: 1-5 GB configurable cache size

### Global Offline Indicator

**Implementation Options:**
- **Option A**: Top banner overlay (recommended)
- **Option B**: Status bar modification
- **Option C**: Persistent SnackBar

**Display Logic:**
- Show when offline and cached data is being used
- Hide when online or when no cached data available
- Include sync status (syncing, sync failed, last sync time)

### Storage Management

**Cache Size Estimates:**
- Projects metadata: ~50-100 KB total
- Songs metadata: ~100-500 KB total  
- Audio files: 3-50 MB per file
- Target total cache: 1-5 GB (user configurable)

**Cleanup Strategy:**
- LRU (Least Recently Used) for audio files
- Manual cleanup options for users
- Auto-cleanup when storage limits exceeded

### User Experience Considerations

**Polish Language UI:**
- "Tryb offline" - offline mode indicator
- "Pobierz offline" - download for offline
- "Synchronizacja..." - syncing status
- "Brak połączenia internetowego" - no internet connection

**Visual Indicators:**
- Offline icon in global banner
- Download/cached icons next to songs
- Progress indicators for downloads
- Storage usage in settings

### Performance Considerations

**Memory Management:**
- Lazy loading of cached data
- Efficient JSON serialization
- Background processing for sync operations

**Battery Optimization:**
- Background sync only when charging (optional)
- Efficient connectivity monitoring
- Smart download scheduling

### Development Notes

**Testing Strategy:**
- Mock network conditions (online/offline)
- Test cache invalidation scenarios
- Verify storage cleanup functionality
- Test large file downloads

**Monitoring:**
- Cache hit/miss ratios
- Download success rates
- Storage usage patterns
- Sync performance metrics

**Security:**
- Secure storage for cached authentication data
- Encrypted local database for sensitive information
- Proper cleanup on logout

---

**Implementation Status**: Ready to begin - see `OFFLINE_DEVELOPMENT_PLAN.md` for detailed task tracking.