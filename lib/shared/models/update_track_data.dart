/// Model danych do aktualizacji ścieżki
class UpdateTrackData {
  final String title;
  final int? bpm;

  const UpdateTrackData({
    required this.title,
    this.bpm,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'bpm': bpm,
    };
  }
}
