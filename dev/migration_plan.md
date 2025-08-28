### Zaktualizowany Plan Implementacji (Podejście Równoległe)

**Faza 1: Implementacja Nowej Funkcjonalności (Równolegle do Istniejącej)**

1.  **Dodanie Modeli i Enumów**: Stworzę wszystkie nowe pliki modeli (`track.dart`, `version.dart`, `album.dart`, `comment.dart`) oraz definicje `enum`. **Istniejący model `song.dart` pozostanie nietknięty.**
2.  **Dodanie Nowych Metod w API i Repozytoriach**: Dodam nowe metody (`getTracks`, `getVersions` itd.) obok istniejących (`getSongs`). Stare metody nie będą na razie usuwane.
3.  **Stworzenie Nowych BLoC-ów/Cubitów**: Zaimplementuję nowe BLoC-i (`TrackDetailBloc`, `VersionDetailBloc`) do zarządzania nową logiką. Istniejące BLoC-i obsługujące `Song` pozostaną bez zmian.
4.  **Stworzenie Nowych Ekranów UI**: Równolegle do istniejących ekranów `Song`, stworzę nowe ekrany dla `Track` i `Version`. Nawigacja do nich może być tymczasowo podpięta w menu deweloperskim lub w mniej widocznym miejscu, aby umożliwić testowanie.

**Faza 2: Migracja i Czyszczenie Kodu (Po Zakończeniu Fazy 1)**

5.  **Weryfikacja**: Po pełnym zaimplementowaniu i przetestowaniu nowej ścieżki (Track -> Version -> Comments), upewnimy się, że wszystko działa zgodnie z oczekiwaniami.
6.  **Przełączenie Nawigacji**: Główna nawigacja w aplikacji zostanie przełączona ze starych ekranów `Song` na nowe ekrany `Track`.
7.  **Usunięcie Starego Kodu**: Dopiero na tym etapie, gdy nowa funkcjonalność będzie w pełni zintegrowana i aktywna, rozpocznę proces bezpiecznego usuwania:
    *   Modelu `song.dart`.
    *   Starych ekranów i widgetów powiązanych z `Song`.
    *   Przestarzałych metod w API, repozytoriach i BLoC-ach.
    *   Wszelkich pozostałych odwołań do `Song` w całej aplikacji.
