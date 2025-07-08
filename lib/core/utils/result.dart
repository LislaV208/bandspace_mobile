/// Klasa Result reprezentuje wynik operacji, która może zakończyć się sukcesem lub niepowodzeniem.
/// Jest to alternatywa dla rzucania wyjątków i pozwala na bardziej funkcjonalny styl obsługi błędów.
///
/// Przykład użycia:
/// ```dart
/// Result<String, Exception> fetchData() {
///   try {
///     final data = performNetworkCall();
///     return Result.success(data);
///   } catch (e) {
///     return Result.failure(e as Exception);
///   }
/// }
///
/// final result = fetchData();
/// if (result.isSuccess) {
///   print('Data: ${result.data}');
/// } else {
///   print('Error: ${result.error}');
/// }
/// ```
sealed class Result<T, E> {
  const Result();

  /// Tworzy wynik reprezentujący sukces
  const factory Result.success(T data) = Success<T, E>;

  /// Tworzy wynik reprezentujący niepowodzenie
  const factory Result.failure(E error) = Failure<T, E>;

  /// Sprawdza czy wynik reprezentuje sukces
  bool get isSuccess => this is Success<T, E>;

  /// Sprawdza czy wynik reprezentuje niepowodzenie
  bool get isFailure => this is Failure<T, E>;

  /// Zwraca dane w przypadku sukcesu, w przeciwnym przypadku null
  T? get data => switch (this) {
    Success<T, E> success => success.data,
    Failure<T, E> _ => null,
  };

  /// Zwraca błąd w przypadku niepowodzenia, w przeciwnym przypadku null
  E? get error => switch (this) {
    Success<T, E> _ => null,
    Failure<T, E> failure => failure.error,
  };

  /// Wykonuje funkcję transformującą dane w przypadku sukcesu
  Result<R, E> map<R>(R Function(T) transform) {
    return switch (this) {
      Success<T, E> success => Result.success(transform(success.data)),
      Failure<T, E> failure => Result.failure(failure.error),
    };
  }

  /// Wykonuje funkcję transformującą błąd w przypadku niepowodzenia
  Result<T, R> mapError<R>(R Function(E) transform) {
    return switch (this) {
      Success<T, E> success => Result.success(success.data),
      Failure<T, E> failure => Result.failure(transform(failure.error)),
    };
  }

  /// Wykonuje funkcję zwracającą Result w przypadku sukcesu (flatMap)
  Result<R, E> flatMap<R>(Result<R, E> Function(T) transform) {
    return switch (this) {
      Success<T, E> success => transform(success.data),
      Failure<T, E> failure => Result.failure(failure.error),
    };
  }

  /// Wykonuje odpowiednią funkcję w zależności od typu wyniku
  R fold<R>(R Function(T) onSuccess, R Function(E) onFailure) {
    return switch (this) {
      Success<T, E> success => onSuccess(success.data),
      Failure<T, E> failure => onFailure(failure.error),
    };
  }

  /// Zwraca dane w przypadku sukcesu, w przeciwnym przypadku wartość domyślną
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T, E> success => success.data,
      Failure<T, E> _ => defaultValue,
    };
  }

  /// Zwraca dane w przypadku sukcesu, w przeciwnym przypadku wynik funkcji
  T getOrElseCall(T Function() defaultValue) {
    return switch (this) {
      Success<T, E> success => success.data,
      Failure<T, E> _ => defaultValue(),
    };
  }
}

/// Klasa reprezentująca sukces
final class Success<T, E> extends Result<T, E> {
  @override
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T, E> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Klasa reprezentująca niepowodzenie
final class Failure<T, E> extends Result<T, E> {
  @override
  final E error;

  const Failure(this.error);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T, E> && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Rozszerzenia dla Result z wyjątkami
extension ResultException<T> on Result<T, Exception> {
  /// Rzuca wyjątek w przypadku niepowodzenia, w przeciwnym przypadku zwraca dane
  T getOrThrow() {
    return switch (this) {
      Success<T, Exception> success => success.data,
      Failure<T, Exception> failure => throw failure.error,
    };
  }
}
