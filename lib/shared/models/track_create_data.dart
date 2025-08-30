class CreateTrackData {
  final String title;
  final int? bpm;

  const CreateTrackData({
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