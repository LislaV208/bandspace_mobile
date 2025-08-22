/// Model danych do aktualizacji utworu
class UpdateSongData {
  final String? title;
  final int? bpm;

  const UpdateSongData({
    this.title,
    this.bpm,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (title != null) {
      json['title'] = title;
    }

    if (bpm != null) {
      json['bpm'] = bpm;
    }

    return json;
  }
}
