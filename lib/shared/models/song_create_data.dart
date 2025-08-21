class CreateSongData {
  final String title;
  final int? bpm;

  const CreateSongData({
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
