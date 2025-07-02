# Testowanie Fazy 2: Audio Cache System

## 🎯 Status: Gotowe do testowania

**Faza 2.1 ✅ COMPLETE**: Audio Cache Service  
**Faza 2.2 ✅ COMPLETE**: Audio Player Offline Integration

## 📱 Co można przetestować:

### 1. **Podstawowe funkcjonalności offline**
```bash
# Uruchom aplikację
flutter run
```

#### **Kroki testowe:**
1. Przejdź do szczegółów dowolnego utworu (Song Detail)
2. Załaduj pliki audio
3. Sprawdź czy AudioPlayerWidget pokazuje nowe kontrolki cache

### 2. **Offline Indicators**

#### **Co powinno być widoczne w AudioPlayerWidget:**
- **Cache Status**: Obok rozmiaru pliku powinien być status cache ("Online", "Pobrano", etc.)
- **Download Button**: Po prawej stronie powinna być opcja "Pobierz" dla plików nie-cache'owanych  
- **Offline Badge**: Gdy plik odtwarzany z cache, powinien pojawić się badge "Offline"

### 3. **Testowanie Download Process**

#### **Scenariusz testowy:**
```
1. Wybierz plik audio w Song Detail
2. Kliknij przycisk "Pobierz" w AudioPlayerWidget
3. Powinien pojawić się:
   - Circular progress indicator
   - Procentowy postęp (0% → 100%)
   - Przycisk anulowania (X)
4. Po zakończeniu:
   - Status zmieni się na "Pobrano" 
   - Przycisk zmieni się na "Usuń"
```

### 4. **Testowanie Offline Playback**

#### **Scenariusz testowy:**
```
1. Pobierz plik (jak wyżej)
2. Włącz tryb samolotowy / wyłącz WiFi
3. Spróbuj odtworzyć plik
4. Powinien pojawić się badge "Offline"
5. Plik powinien odtwarzać się z cache lokalnego
```

## 🔧 **Diagnostyka problemów:**

### **Problem: Nie widać nowych kontrolek cache**
```bash
# Sprawdź logi Flutter
flutter logs

# Szukaj błędów związanych z:
# - AudioCacheService initialization
# - Database creation errors
# - Permission issues
```

### **Problem: Download nie działa**
```bash
# Sprawdź czy dependencies są zainstalowane
flutter pub get

# Sprawdź pozwolenia storage (Android)
# W settings telefonu → Apps → BandSpace → Permissions
```

### **Problem: Cache nie persystuje**
```bash
# Sprawdź ścieżki storage
# Cache powinien być w: /data/data/app.bandspace.pl/files/audio_cache/
```

## 📊 **Expected Behavior:**

### **AudioPlayerWidget nowe elementy:**
1. **Cache Status Indicator** - kolorowy wskaźnik obok info o pliku
2. **Download/Action Button** - po prawej stronie file info
3. **Offline Badge** - gdy odtwarzany z cache
4. **Progress Indicator** - podczas pobierania

### **AudioPlayerCubit nowe metody:**
- `downloadForOffline(SongFile file)` 
- `removeFromCache(SongFile file)`
- `cancelDownload(int fileId)`
- `checkOfflineAvailability()`

### **Cache Database:**
- SQLite w `/documents/audio_cache.db`
- Tabela `cached_audio_files` z metadanymi
- Fizyczne pliki w `/documents/audio_cache/`

## ⚠️ **Znane ograniczenia (Phase 2.1-2.2):**

1. **No bulk operations** - cache tylko pojedyncze pliki
2. **No settings UI** - brak ekranu zarządzania cache
3. **Basic error handling** - podstawowa obsługa błędów
4. **No download speed limits** - brak throttling
5. **No WiFi-only option** - pobiera przez WiFi i mobile

## 🚀 **Następne kroki (Faza 2.3):**

Po przetestowaniu podstawowych funkcjonalności będziemy implementować:
- **DownloadButton component** - standalone download button  
- **Song File Download UI** - bulk download options
- **Offline Settings Screen** - zarządzanie cache
- **Cache Size Indicators** - wizualizacja użycia storage

## 📞 **Raportowanie błędów:**

Jeśli znajdziesz problem, sprawdź:
1. **Flutter logs** - `flutter logs`
2. **Console errors** - błędy w console
3. **File permissions** - uprawnienia storage
4. **Network connectivity** - czy download URL działa

---

**Gotowe do testowania!** 🎉 Uruchom `flutter run` i przetestuj AudioPlayer z nowymi funkcjonalnościami cache.