enum VersionCategory {
  idea('Pomysł'),
  rehearsal('Próba'),
  demo('Demo'),
  mix('Miks'),
  master('Master');

  const VersionCategory(this.apiValue);
  final String apiValue;
}