import 'dart:async';

/// Enum reprezentujący wydarzenia związane z uwierzytelnianiem
enum AuthEvent {
  /// Token refresh się nie powiódł - użytkownik powinien zostać wylogowany
  tokenRefreshFailed,
}

/// Serwis zarządzający wydarzeniami uwierzytelniania w całej aplikacji.
///
/// Używa wzorca Provider i Stream do komunikacji między komponentami
/// architektury uwierzytelniania.
class AuthEventService {
  final StreamController<AuthEvent> _eventController =
      StreamController<AuthEvent>.broadcast();

  /// Stream wydarzeń uwierzytelniania
  Stream<AuthEvent> get events => _eventController.stream;

  /// Emituje wydarzenie uwierzytelniania
  void emit(AuthEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  /// Zamyka kontroler streamów
  void dispose() {
    _eventController.close();
  }
}
