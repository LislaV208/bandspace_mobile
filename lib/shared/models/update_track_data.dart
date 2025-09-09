/// Model danych do aktualizacji ścieżki
class UpdateTrackData {
  final String? title;
  final int? bpm;

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

  /// Validates the update data
  String? validate() {
    if (title != null) {
      if (title!.trim().isEmpty) {
        return 'Title cannot be empty';
      }
      if (title!.length > 255) {
        return 'Title cannot exceed 255 characters';
      }
    }

    if (bpm != null) {
      if (bpm! <= 0) {
        return 'BPM must be a positive number';
      }
      if (bpm! > 300) {
        return 'BPM cannot exceed 300';
      }
    }

    return null;
  }

  /// Returns true if this update contains any changes
  bool get hasChanges => title != null || bpm != null;
}
