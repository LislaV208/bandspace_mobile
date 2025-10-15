import 'package:equatable/equatable.dart';

/// Model przechowujący metadane dla nowej wersji utworu
class AddVersionData extends Equatable {
  final int? bpm;

  const AddVersionData({
    this.bpm,
  });

  /// Tworzy kopię z możliwością zmiany wybranych pól
  AddVersionData copyWith({
    int? bpm,
  }) {
    return AddVersionData(
      bpm: bpm ?? this.bpm,
    );
  }

  /// Sprawdza czy BPM jest prawidłowe (opcjonalne, ale jeśli podane to > 0)
  bool get isValid {
    return bpm == null || bpm! > 0;
  }

  /// Konwertuje do Map dla API call
  Map<String, dynamic> toJson() {
    return {
      if (bpm != null) 'bpm': bpm,
    };
  }

  @override
  List<Object?> get props => [bpm];
}