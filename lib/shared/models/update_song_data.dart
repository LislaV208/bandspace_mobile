/// Model danych do aktualizacji utworu
class UpdateSongData {
  final String? title;
  final int? bpm;

  const UpdateSongData({
    this.title,
    this.bpm,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'bpm': bpm,
    };
  }
}
