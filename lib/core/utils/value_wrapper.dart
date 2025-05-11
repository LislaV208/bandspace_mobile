/// Generyczna klasa opakowująca (wrapper), służąca do jawnego przekazywania wartości `null`
/// w metodach `copyWith`.
///
/// Pomaga to odróżnić sytuację, gdy pole nie jest przekazywane do `copyWith`
/// (i tym samym zachowuje ono swoją poprzednią wartość) od sytuacji,
/// gdy pole jest celowo ustawiane na `null`.
class Value<T> {
  final T value;
  const Value(this.value);
}
