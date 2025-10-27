# Testing Checklist - BandSpace Mobile

## Ekrany do testowania (kolejność alfabetyczna)

### 1. ✓ change_password_screen.dart
- [ ] Walidacja: wszystkie pola puste → błąd
- [ ] Walidacja: hasło < 6 znaków → błąd
- [ ] Walidacja: hasła się nie zgadzają → błąd
- [ ] Walidacja: nowe = aktualne hasło → błąd
- [ ] Prawidłowe hasła: formularz wysyła, loading spinner się pojawia
- [ ] Sukces: SnackBar + powrót do poprzedniego ekranu
- [ ] Błąd API: wyświetla się komunikat błędu

