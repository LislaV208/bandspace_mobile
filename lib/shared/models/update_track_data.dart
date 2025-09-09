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
        return 'Tytuł utworu nie może być pusty';
      }
      if (title!.length > 255) {
        return 'Tytuł jest za długi (maksymalnie 255 znaków)';
      }
    }

    if (bpm != null) {
      if (bpm! <= 0) {
        return 'Tempo (BPM) musi być liczbą dodatnią';
      }
      if (bpm! > 300) {
        return 'Tempo (BPM) nie może przekraczać 300';
      }
    }

    return null;
  }

  /// Returns true if this update contains any changes
  bool get hasChanges => title != null || bpm != null;
}
