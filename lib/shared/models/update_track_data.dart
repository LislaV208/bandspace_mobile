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
}
