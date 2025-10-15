# Design Document

## Overview

This design implements track management functionality for the new track-based architecture. The solution provides a `ManageTracksButton` component that allows users to edit and delete tracks, integrated with a new `TrackDetailCubit` for state management. The design follows the established BLoC pattern and reuses existing UI components while respecting the Track → Version → AudioFile data hierarchy.

## Architecture

### Feature Location Decision
After analyzing the existing structure, the track management functionality will be implemented as a new feature module: `lib/features/track_detail/`. This separation provides:

- Clear separation of concerns between audio playback (`track_player`) and track management (`track_detail`)
- Follows the established pattern where management operations have their own feature modules
- Allows for future expansion of track detail functionality (comments, versions, etc.)
- Maintains consistency with the existing `song_detail` feature structure

### Component Architecture

```
lib/features/track_detail/
├── cubit/
│   ├── track_detail_cubit.dart
│   └── track_detail_state.dart
├── widgets/
│   ├── manage_tracks_button.dart
│   ├── edit_track_dialog.dart
│   └── delete_track_dialog.dart
└── models/
    └── update_track_data.dart
```

## Components and Interfaces

### 1. TrackDetailCubit

**Purpose**: Manages track detail state and operations, similar to `SongDetailCubit` but adapted for the Track model.

**Key Methods**:
- `updateTrack(Track track)` - Updates track information
- `deleteTrack(int trackId)` - Deletes a track
- `refreshTrack()` - Refreshes track data from server

**State Management**:
- Maintains current track and project context
- Handles loading, success, and error states for operations
- Integrates with existing repository patterns

### 2. ManageTracksButton

**Purpose**: Provides the main entry point for track management operations.

**Features**:
- Displays management options in a bottom sheet
- Integrates with `TrackDetailCubit` for state management
- Reuses existing `OptionsBottomSheet` component
- Follows the same UI pattern as `ManageProjectButton`

### 3. EditTrackDialog

**Purpose**: Allows editing of track title and BPM (tempo).

**Key Features**:
- Form fields for track title (Track model field)
- Form field for BPM (Version model field)
- Validation and error handling
- Integration with backend API that handles the cross-model update

### 4. DeleteTrackDialog

**Purpose**: Provides confirmation dialog for track deletion.

**Features**:
- Confirmation dialog with track information
- Handles cascade deletion (Track → Version → AudioFile)
- Error handling and user feedback

## Data Models

### UpdateTrackData Model

```dart
class UpdateTrackData {
  final String? title;    // Updates Track.title
  final int? bpm;         // Updates Version.bpm
  
  const UpdateTrackData({
    this.title,
    this.bpm,
  });
  
  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (bpm != null) 'bpm': bpm,
    };
  }
}
```

### Repository Extensions

Extend `ProjectsRepository` with track management operations:

```dart
// In projects_repository.tracks.dart
extension TracksManagement on ProjectsRepository {
  // Update track (handles both Track and Version fields)
  Future<Track> updateTrack(
    int projectId,
    int trackId,
    UpdateTrackData updateData,
  );
  
  // Delete track (cascade deletes Version and AudioFile)
  Future<void> deleteTrack(int projectId, int trackId);
  
  // Get single track details
  Stream<Track> getTrack(int projectId, int trackId);
  
  // Refresh single track
  Future<void> refreshTrack(int projectId, int trackId);
}
```

## Error Handling

### Validation Rules
- **Title**: Required, non-empty string, max length validation
- **BPM**: Optional positive integer, reasonable range (e.g., 60-200)

### Error States
- **Network Errors**: Display user-friendly messages, retry options
- **Validation Errors**: Real-time field validation with error messages
- **Permission Errors**: Handle cases where user cannot edit/delete tracks
- **Not Found Errors**: Handle cases where track no longer exists

### Loading States
- **Button States**: Disable buttons during operations, show loading indicators
- **Dialog States**: Show loading overlays during save/delete operations
- **Optimistic Updates**: Update UI immediately, rollback on error

## Testing Strategy

### Unit Tests
- `TrackDetailCubit` state transitions and business logic
- `UpdateTrackData` model serialization/validation
- Repository method calls and error handling

### Widget Tests
- `ManageTracksButton` UI interactions and bottom sheet display
- `EditTrackDialog` form validation and submission
- `DeleteTrackDialog` confirmation flow

### Integration Tests
- End-to-end track editing flow
- End-to-end track deletion flow
- Error handling scenarios
- State synchronization between components

## Integration Points

### With TrackPlayer
- **State Synchronization**: Changes in `TrackDetailCubit` should update `TrackPlayerCubit`
- **Navigation**: After track deletion, handle navigation back to track list or next track
- **Audio Playback**: Stop playback if currently playing track is deleted

### With Project Detail
- **Track List Updates**: Ensure project track lists reflect changes
- **Cache Invalidation**: Properly invalidate cached track data

### With Repository Layer
- **Cache Management**: Use existing cache patterns for track data
- **API Integration**: Follow established patterns for API calls
- **Error Propagation**: Consistent error handling across the application

## Performance Considerations

### Caching Strategy
- Leverage existing `CachedRepository` patterns
- Cache track details for offline access
- Invalidate cache appropriately after updates

### Memory Management
- Proper disposal of streams and subscriptions in cubits
- Efficient state updates to minimize rebuilds
- Lazy loading of track details when needed

### Network Optimization
- Batch operations where possible
- Optimistic updates for better user experience
- Proper retry mechanisms for failed operations