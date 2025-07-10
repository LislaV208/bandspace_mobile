class CreateSongData {
  final String title;
  final String? description;

  const CreateSongData({
    required this.title,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}
