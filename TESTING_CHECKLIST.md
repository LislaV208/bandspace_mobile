# Testing Checklist - BandSpace Mobile

## Ekrany do testowania (kolejność alfabetyczna)

### 1. ✓ change_password_screen.dart
- [x] Walidacja: wszystkie pola puste → błąd
- [x] Walidacja: hasło < 6 znaków → błąd
- [x] Walidacja: hasła się nie zgadzają → błąd
- [x] Walidacja: nowe = aktualne hasło → błąd
- [x] Prawidłowe hasła: formularz wysyła, loading spinner się pojawia
- [x] Sukces: SnackBar + powrót do poprzedniego ekranu
- [x] Błąd API: wyświetla się komunikat błędu