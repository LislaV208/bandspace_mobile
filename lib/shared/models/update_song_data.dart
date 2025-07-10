/// Model danych do aktualizacji utworu
class UpdateSongData {
  final String? title;

  const UpdateSongData({
    this.title,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (title != null) {
      json['title'] = title;
    }

    return json;
  }
}
