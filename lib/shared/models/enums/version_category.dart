enum VersionCategory {
  idea('Pomysł'),
  rehearsal('Próba'),
  demo('Demo'),
  mix('Miks'),
  master('Master');

  const VersionCategory(this.apiValue);
  final String apiValue;

  static VersionCategory? fromJson(String? value) {
    if (value == null) return null;
    try {
      return VersionCategory.values.firstWhere((e) => e.apiValue == value);
    } catch (e) {
      return null;
    }
  }
}
