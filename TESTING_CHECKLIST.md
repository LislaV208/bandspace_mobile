# Testing Checklist - BandSpace Mobile

## Account

### change_password_screen.dart ✅
- [x] Walidacja: wszystkie pola puste → błąd
- [x] Walidacja: hasło < 6 znaków → błąd
- [x] Walidacja: hasła się nie zgadzają → błąd
- [x] Walidacja: nowe = aktualne hasło → błąd
- [x] Prawidłowe hasła: formularz wysyła, loading spinner się pojawia
- [x] Sukces: SnackBar + powrót do poprzedniego ekranu
- [x] Błąd API: wyświetla się komunikat błędu

### profile_screen.dart ✅
- [x] Edycja nazwy: edit → edytowalne → check → sukces/błąd
- [x] Zmiana hasła: przycisk widoczny dla local auth → redirect
- [x] Usuwanie konta: dialog → potwierdzenie → wylogowanie lub błąd
- [x] Loading/Error states działają

---

## Auth

### auth_screen.dart
**Google Login:**
- [ ] Kliknięcie "Kontynuuj z kontem Google" → loading → sukces/błąd
- [ ] Sukces: redirect do dashboard

**Email/Password Login:**
- [ ] Przełączenie na "Użyj adresu email i hasła" → pokazuje formularz email
- [ ] Walidacja: puste pola → błąd
- [ ] Prawidłowe dane: loading spinner → sukces/błąd
- [ ] Sukces: redirect do dashboard
- [ ] Toggle visibility hasła działa

**Register:**
- [ ] Przełączenie na "Zarejestruj się" → pokazuje pole "Potwierdź hasło"
- [ ] Walidacja: puste pola → błąd
- [ ] Walidacja: hasła się nie zgadzają → błąd
- [ ] Prawidłowe dane: loading spinner → sukces/błąd
- [ ] Sukces: redirect do dashboard
- [ ] Toggle visibility obu haseł działa

**Reset hasła:**
- [ ] "Zapomniałeś hasła?" → redirect do reset_password_screen

**Ogólne:**
- [ ] Błędy wyświetlają się w dialogu (ErrorDialog)

## Dashboard
- TBD

## Project Detail
- TBD

## Song Detail
- TBD

## Track Detail
- TBD

## Track Player
- TBD

## Track Versions
- TBD

## Splash
- TBD
