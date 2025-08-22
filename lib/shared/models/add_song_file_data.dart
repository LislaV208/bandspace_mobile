class AddSongFileData {
  final int projectId;
  final int songId;
  final String filePath;

  const AddSongFileData({
    required this.projectId,
    required this.songId,
    required this.filePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'songId': songId,
      'filePath': filePath,
    };
  }
}