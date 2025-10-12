# Track Player - Propozycja Refaktoryzacji Architektury

## Status Quo - Problemy

Obecny `TrackPlayerCubit` (464 linie) ma 9 różnych odpowiedzialności:
- Audio player lifecycle
- Stream orchestration
- Playlist management
- Playback control
- File system cache management
- HTTP downloads
- Pre-caching orchestration
- Track state mutations
- Dynamic audio source rebuilding

**Konsekwencje:**
- Trudność w testowaniu (wszystko wymaga integration tests)
- Kruchy kod (zmiana w cache może zepsuć playback)
- Tight coupling (AudioPlayer + Dio + File I/O + State management w jednej klasie)
- Parallel development niemożliwy
- Long onboarding time

---

## Proponowane Rozwiązanie - Layered Architecture

### Architektura Wysokopoziomowa

```
┌─────────────────────────────────────────┐
│      TrackPlayerCubit (Orchestration)    │  ← UI State Management
└─────────────────────────────────────────┘
            ↓         ↓            ↓
┌──────────────┐  ┌──────────────┐  ┌─────────────────────────┐
│AudioPlayer   │  │AudioSource   │  │AudioPreCaching          │
│Service       │  │Factory       │  │Orchestrator             │
└──────────────┘  └──────────────┘  └─────────────────────────┘
                         ↓                      ↓
                  ┌──────────────────────────────────┐
                  │  AudioCacheRepository            │
                  └──────────────────────────────────┘
                         ↓            ↓
                  ┌──────────┐  ┌──────────┐
                  │   Dio    │  │ File I/O │
                  └──────────┘  └──────────┘
```

---

## Moduły - Szczegółowy Opis

### 1. AudioCacheRepository

**Odpowiedzialność:** Zarządzanie cache'owaniem plików audio na dysku.

**Zależności:**
- `Dio` (injected) - do pobierania plików
- `path_provider` - do lokalizacji temp directory
- `int projectId` (constructor param) - do organizacji cache per-project

**Publiczne Metody:**

#### `Future<File> getCacheFile(int trackId)`
- **Input:** Track ID
- **Output:** File object reprezentujący lokalizację cache dla tego tracka
- **Logika:**
  1. Pobierz temporary directory z path_provider
  2. Utwórz ścieżkę: `{tempDir}/audio_cache/project_{projectId}/track_{trackId}.cache`
  3. Jeśli katalog `project_{projectId}` nie istnieje, utwórz rekursywnie
  4. Zwróć File object (nie sprawdza czy plik istnieje)
- **Edge cases:**
  - Jeśli tworzenie katalogu się nie powiedzie → throw exception (caller decyduje o reakcji)

#### `Future<bool> isCached(int trackId)`
- **Input:** Track ID
- **Output:** true jeśli plik istnieje w cache, false w przeciwnym razie
- **Logika:**
  1. Wywołaj `getCacheFile(trackId)`
  2. Sprawdź `file.exists()`
  3. Zwróć wynik
- **Edge cases:** Nie throw'uje - zwraca false jeśli coś pójdzie nie tak

#### `Future<void> downloadToCache(String url, int trackId)`
- **Input:** URL pliku audio, Track ID
- **Output:** void (side effect: plik na dysku)
- **Logika:**
  1. Wywołaj `getCacheFile(trackId)` aby uzyskać target path
  2. Sprawdź `file.exists()` - jeśli plik już istnieje → return (skip download)
  3. Użyj `dio.download(url, file.path)` aby pobrać plik
  4. Loguj sukces: "Downloaded track {trackId} to cache"
- **Error handling:**
  - Jeśli download się nie powiedzie → loguj error i **rethrow exception**
  - Repository nie decyduje o error handling strategy (to caller's responsibility)
- **Edge cases:**
  - Duplicate download prevention (exists check)
  - Partial downloads: obecnie brak handling (można dodać w przyszłości: sprawdzanie file size, checksums)

#### `Future<void> clearCache()` (opcjonalne, na przyszłość)
- **Logika:** Usuwa całą zawartość `audio_cache/project_{projectId}`
- **Use case:** User czyści cache z ustawień aplikacji

**Nie robi:**
- ❌ Nie tworzy AudioSource (to AudioSourceFactory)
- ❌ Nie trackuje progress (to PreCachingOrchestrator)
- ❌ Nie zarządza AudioPlayer

**Testowanie:**
- Mock'ować Dio
- Mock'ować file system (lub użyć temporary directory w testach)
- Verify że dio.download jest wywoływany z poprawnymi params

---

### 2. AudioSourceFactory

**Odpowiedzialność:** Tworzenie AudioSource objects z URL, z graceful degradation do streaming.

**Zależności:**
- `AudioCacheRepository` (injected)

**Publiczne Metody:**

#### `Future<AudioSource> createAudioSource(String url, int trackId)`
- **Input:** URL pliku audio, Track ID
- **Output:** AudioSource (LockCachingAudioSource lub AudioSource.uri)
- **Logika:**
  1. Try:
     - Wywołaj `_cacheRepo.getCacheFile(trackId)` aby uzyskać cache file path
     - Utwórz `LockCachingAudioSource(Uri.parse(url), cacheFile: file)`
     - Zwróć audio source
  2. Catch (any exception):
     - Loguj warning: "Failed to create caching audio source for track {trackId}: {error}. Falling back to streaming."
     - Utwórz fallback `AudioSource.uri(Uri.parse(url))` (pure streaming, no cache)
     - Zwróć fallback source
- **Graceful Degradation:**
  - Jeśli cokolwiek pójdzie nie tak (brak cache, błąd file system, brak uprawnień) → fallback do streaming
  - User nie widzi błędu, track jest nadal grywalny
- **Decision point:** LockCachingAudioSource z just_audio **automatycznie** fallback'uje do streaming jeśli cache file nie istnieje, więc teoretycznie catch block może nigdy nie być wywołany. Ale mamy go dla defensive programming.

**Nie robi:**
- ❌ Nie downloaduje plików (to Repository)
- ❌ Nie zarządza playback (to AudioPlayerService)
- ❌ Nie trackuje cache status (to PreCachingOrchestrator)

**Testowanie:**
- Mock AudioCacheRepository
- Verify że tworzy LockCachingAudioSource gdy repository działa
- Verify że fallback'uje do AudioSource.uri gdy repository throw'uje

---

### 3. AudioPlayerService

**Odpowiedzialność:** Wrapper nad AudioPlayer z just_audio. Enkapsuluje playback primitives.

**Zależności:**
- `AudioPlayer` (injected lub utworzony w constructor)

**Publiczne Properties (Streams):**
- `Stream<Duration> positionStream` - pozycja odtwarzania
- `Stream<Duration> bufferedPositionStream` - pozycja bufferowania
- `Stream<Duration?> durationStream` - całkowity czas trwania
- `Stream<PlayerState> playerStateStream` - stan playera (playing/paused/loading/etc)

**Publiczne Metody:**

#### `Future<void> setAudioSources(List<AudioSource> sources)`
- **Input:** Lista AudioSource
- **Output:** void
- **Logika:** Delegacja do `_audioPlayer.setAudioSource(ConcatenatingAudioSource(children: sources))`
- **Edge cases:** Jeśli sources jest puste → może throw exception lub no-op (do ustalenia)

#### `Future<void> play()`
- **Logika:** Wywołaj `_audioPlayer.play()`

#### `Future<void> pause()`
- **Logika:** Wywołaj `_audioPlayer.pause()`

#### `Future<void> stop()`
- **Logika:** Wywołaj `_audioPlayer.stop()`

#### `Future<void> seek(Duration position, {int? index})`
- **Input:** Pozycja docelowa, opcjonalny index tracka
- **Logika:** Wywołaj `_audioPlayer.seek(position, index: index)`

#### `Future<void> seekToNext()`
- **Logika:** Wywołaj `_audioPlayer.seekToNext()`

#### `Future<void> seekToPrevious()`
- **Logika:** Wywołaj `_audioPlayer.seekToPrevious()`

#### `Future<void> setLoopMode(LoopMode mode)`
- **Logika:** Wywołaj `_audioPlayer.setLoopMode(mode)`

#### `List<IndexedAudioSource> get sequence`
- **Output:** Obecna sekwencja audio sources w playerze
- **Logika:** Return `_audioPlayer.sequence ?? []`

#### `void dispose()`
- **Logika:** Wywołaj `_audioPlayer.dispose()`

**Nie robi:**
- ❌ Nie zarządza state (to Cubit)
- ❌ Nie tworzy AudioSource (to Factory)
- ❌ Nie mapuje PlayerState → PlayerUiStatus (to Cubit)

**Testowanie:**
- Mock AudioPlayer
- Verify że metody są wywoływane z poprawnymi params
- Bardzo proste testy (to thin wrapper)

---

### 4. AudioPreCachingOrchestrator

**Odpowiedzialność:** Background pre-caching wszystkich tracków w projekcie z progress tracking.

**Zależności:**
- `AudioCacheRepository` (injected)

**Internal State:**
- `StreamController<CacheProgress> _progressController` - broadcast stream do komunikacji z UI

**Publiczne Properties:**
- `Stream<CacheProgress> progressStream` - stream emitujący progress updates

**Publiczne Metody:**

#### `Future<void> preCacheTracks(List<Track> tracks)`
- **Input:** Lista wszystkich tracków do pre-cache'owania
- **Output:** void (async operation, komunikacja przez stream)
- **Logika:**
  1. Inicjalizuj `Map<int, CacheStatus> tracksCacheStatus` dla wszystkich tracków → CacheStatus.notStarted
  2. Emit initial progress przez `_progressController.add(CacheProgress(tracksCacheStatus))`
  3. For każdy track w tracks:
     - Wywołaj `_cacheTrack(track, tracksCacheStatus)` (await)
  4. Po zakończeniu wszystkich: isComplete będzie true w ostatnim emitowanym CacheProgress
- **Strategia:** Sekwencyjne cache'owanie (jeden po drugim). Można zmienić na parallel w przyszłości jeśli potrzeba.

#### `Future<void> _cacheTrack(Track track, Map<int, CacheStatus> statusMap)`
- **Input:** Track do cache'owania, mutable statusMap
- **Output:** void (modyfikuje statusMap jako side effect)
- **Logika:**
  1. Pobierz `url = track.mainVersion?.file?.downloadUrl`
  2. Jeśli url == null:
     - Ustaw `statusMap[track.id] = CacheStatus.noFile`
     - Loguj: "Track {track.id} has no download URL, skipping cache"
     - Emit progress i return
  3. Try:
     - Ustaw `statusMap[track.id] = CacheStatus.caching`
     - Emit progress
     - Wywołaj `_cacheRepo.downloadToCache(url, track.id)` (await)
     - Ustaw `statusMap[track.id] = CacheStatus.cached`
     - Loguj success: "Successfully cached track {track.id}"
  4. Catch:
     - Ustaw `statusMap[track.id] = CacheStatus.error`
     - Loguj warning: "Failed to cache track {track.id}: {error}. Track will stream instead."
     - NIE rethrow - graceful degradation
  5. Finally:
     - Emit progress
- **Graceful degradation:** Błąd cache'owania jednego tracka nie zatrzymuje cache'owania pozostałych

#### `void _emitProgress(Map<int, CacheStatus> statusMap)`
- **Logika:** Utwórz `CacheProgress(statusMap)` i emit przez `_progressController.add(...)`

#### `void dispose()`
- **Logika:** Wywołaj `_progressController.close()`

**Nie robi:**
- ❌ Nie zarządza AudioPlayer
- ❌ Nie tworzy AudioSource (to się dzieje osobno podczas buildPlaylist)
- ❌ Nie blokuje UI (async, fire-and-forget z Cubita)

**Testowanie:**
- Mock AudioCacheRepository
- Listen do progressStream
- Verify że progress jest emitowany poprawnie (notStarted → caching → cached)
- Verify error handling (failed download nie zatrzymuje kolejnych)

---

### 5. CacheProgress (Value Object)

**Odpowiedzialność:** Immutable snapshot cache progress dla komunikacji z UI.

**Properties:**
- `Map<int, CacheStatus> tracksCacheStatus` - status każdego tracka

**Computed Properties:**

#### `int get cachedCount`
- **Logika:** Count ile tracków ma status == CacheStatus.cached

#### `int get totalCount`
- **Logika:** `tracksCacheStatus.length`

#### `bool get isComplete`
- **Logika:** Sprawdź czy wszystkie tracki mają status != notStarted && != caching
- **Use case:** Użyte w Cubit do ustawienia `isPreCaching = !progress.isComplete`

---

### 6. TrackPlayerCubit (Slim Orchestrator)

**Odpowiedzialność:** UI State management i orchestracja services. Jedyny layer który "widzi" UI concerns.

**Zależności (Injected):**
- `AudioPlayerService`
- `AudioSourceFactory`
- `AudioPreCachingOrchestrator`

**Internal State:**
- `Map<int, int> _trackIdToPlayerIndex` - mapowanie Track ID → index w AudioPlayer sequence
- 3 StreamSubscriptions:
  - `_playerStateSubscription` - słucha player state changes
  - `_positionSubscription` - słucha position updates
  - `_cacheProgressSubscription` - słucha cache progress updates

**Constructor:**
- Przyjmuje 3 dependencies przez parameters
- Wywołuje `_listenToPlayerEvents()` i `_listenToCacheProgress()`

---

#### Metoda: `void _listenToPlayerEvents()`
**Odpowiedzialność:** Subscribe do player service streams i map do UI state.

**Logika:**
1. Subscribe do `_playerService.playerStateStream`:
   - Mapuj PlayerState → PlayerUiStatus przez `_mapProcessingStateToPlayerUiStatus(state)`
   - Emit `state.copyWith(playerUiStatus: newStatus)`
2. Subscribe do `_playerService.positionStream`:
   - Jeśli `!state.isSeeking` → emit `state.copyWith(currentPosition: position)`
   - (Podczas seekingu ignorujemy player position updates, używamy local seekPosition)
3. Subscribe do `_playerService.bufferedPositionStream`:
   - Emit `state.copyWith(bufferedPosition: bufferedPosition)`
4. Subscribe do `_playerService.durationStream`:
   - Emit `state.copyWith(totalDuration: duration ?? Duration.zero)`

**Edge cases:**
- Subscriptions mogą emit'ować po dispose → guard w listen callback lub cancel w close()

---

#### Metoda: `void _listenToCacheProgress()`
**Odpowiedzialność:** Subscribe do pre-caching progress i update UI state.

**Logika:**
1. Subscribe do `_preCachingOrchestrator.progressStream`
2. Na każdy `CacheProgress`:
   - Emit `state.copyWith(tracksCacheStatus: progress.tracksCacheStatus, cachedTracksCount: progress.cachedCount, isPreCaching: !progress.isComplete)`

---

#### Metoda: `Future<void> loadTracksDirectly(List<Track> tracks, int initialTrackId, int projectId)`
**Odpowiedzialność:** Główny entry point - load tracków, zbuduj playlist, start pre-caching.

**Input:**
- `tracks` - lista wszystkich tracków w projekcie
- `initialTrackId` - który track zaznaczyć jako currentTrack
- `projectId` - ID projektu (dla cache directory)

**Logika:**
1. Znajdź initialIndex: `tracks.indexWhere((t) => t.id == initialTrackId)`
2. Emit state:
   - `tracks: tracks`
   - `currentTrackIndex: initialIndex != -1 ? initialIndex : 0`
   - `currentProjectId: projectId`
3. Await `_buildPlaylist(tracks, initialTrackId)` - buduje audio sources i load do playera
4. Fire-and-forget: `unawaited(_preCachingOrchestrator.preCacheTracks(tracks))`
   - **Decyzja:** Pre-caching nie blokuje UI, dzieje się w background
   - User może natychmiast zacząć odtwarzanie (streaming)

**Edge cases:**
- Jeśli initialTrackId nie istnieje w tracks → fallback do index 0

---

#### Metoda: `Future<void> _buildPlaylist(List<Track> tracks, int initialTrackId)`
**Odpowiedzialność:** Zbuduj AudioSource list i załaduj do AudioPlayer.

**Logika:**
1. Inicjalizuj `List<AudioSource> sources = []`
2. Wyczyść `_trackIdToPlayerIndex.clear()`
3. For każdy track w tracks:
   - Pobierz `url = track.mainVersion?.file?.downloadUrl`
   - Jeśli url == null:
     - Loguj warning: "Track {track.id} has no download URL, skipping from playlist"
     - Continue (skip this track)
   - Try:
     - Wywołaj `source = await _sourceFactory.createAudioSource(url, track.id)`
     - Zapisz mapping: `_trackIdToPlayerIndex[track.id] = sources.length`
     - Dodaj do sources: `sources.add(source)`
   - Catch:
     - Loguj error: "Failed to create audio source for track {track.id}: {error}. Skipping."
     - Continue (graceful degradation - skip this track, build playlist z pozostałych)
4. Jeśli sources.isNotEmpty:
   - Wywołaj `await _playerService.setAudioSources(sources)`
5. Else:
   - Loguj error: "No playable tracks available in playlist"
   - (Player pozostaje pusty)

**Graceful degradation:**
- Tracki bez URL są skip'owane
- Tracki z błędami podczas tworzenia source są skip'owane
- Playlist jest zbudowana z dostępnych tracków

---

#### Metoda: `void selectTrack(int index)`
**Odpowiedzialność:** Zmień obecnie wybrany track (highlight w UI).

**Input:** Index w liście tracks

**Logika:**
1. Validation: jeśli `index < 0 || index >= state.tracks.length` → return
2. Emit `state.copyWith(currentTrackIndex: index)`

**Nie robi:** Nie wywołuje play - to tylko selection (user może selection'ować bez odtwarzania)

---

#### Metoda: `Future<void> playSelectedTrack()`
**Odpowiedzialność:** Odtwórz obecnie wybrany track.

**Logika:**
1. Pobierz `track = state.currentTrack` (computed property z state)
2. Jeśli track == null:
   - Loguj: "No track selected"
   - Return
3. Pobierz `playerIndex = _trackIdToPlayerIndex[track.id]`
4. Jeśli playerIndex != null:
   - Await `_playerService.seek(Duration.zero, index: playerIndex)` (seek do początku tego tracka)
   - Await `_playerService.play()`
5. Else:
   - Loguj error: "Track {track.id} not found in player index. Cannot play."
   - (Track nie jest w playlist - nie powinno się zdarzyć, ale defensive)

---

#### Metoda: `Future<void> togglePlayPause()`
**Odpowiedzialność:** Toggle play/pause based on current player status.

**Logika:** Switch na `state.playerUiStatus`:
- **Case playing:**
  - Await `_playerService.pause()`
- **Case paused:**
  - Await `_playerService.play()`
- **Case idle lub completed:**
  - Await `playSelectedTrack()` (rozpocznij odtwarzanie wybranego tracka od początku)
- **Case loading:**
  - Loguj warning: "Cannot toggle play/pause while loading"
  - Return (user musi poczekać aż loading się skończy)

**Explicit error handling:** Loading state jest handled (ignored), nie ma implicit behavior.

---

#### Metoda: `Future<void> pausePlayback()`
**Odpowiedzialność:** Force pause (używane gdy user nawiguje do innego ekranu).

**Logika:**
1. Jeśli `state.playerUiStatus == PlayerUiStatus.playing`:
   - Await `_playerService.pause()`
2. Else: no-op

---

#### Metoda: `void seek(Duration position)`
**Odpowiedzialność:** Seek do określonej pozycji w obecnie odtwarzanym tracku.

**Logika:** Delegacja do `_playerService.seek(position)`

---

#### Metoda: `void startSeeking()`
**Odpowiedzialność:** User zaczyna drag slider (gesture start).

**Logika:**
1. Emit `state.copyWith(isSeeking: true, seekPosition: state.currentPosition)`
2. Od teraz ignorujemy position updates z playera (patrz `_listenToPlayerEvents`)

---

#### Metoda: `void updateSeekPosition(double value)`
**Odpowiedzialność:** User przeciąga slider (gesture update).

**Input:** value w zakresie 0.0-1.0 (normalized position)

**Logika:**
1. Jeśli `!state.isSeeking` → return (invalid state)
2. Oblicz `newPosition = Duration(milliseconds: (value * state.totalDuration.inMilliseconds).round())`
3. Emit `state.copyWith(seekPosition: newPosition)`
4. (UI pokazuje seekPosition, nie currentPosition)

---

#### Metoda: `Future<void> endSeeking()`
**Odpowiedzialność:** User kończy drag slider (gesture end).

**Logika:**
1. Jeśli `!state.isSeeking || state.seekPosition == null` → return (invalid state)
2. Pobierz `targetPosition = state.seekPosition!`
3. Emit `state.copyWith(isSeeking: false, seekPosition: null, currentPosition: targetPosition)`
4. Await `_playerService.seek(targetPosition)` - faktyczny seek w playerze
5. Od teraz znowu słuchamy position updates z playera

---

#### Metoda: `void seekToNext()`
**Odpowiedzialność:** Przejdź do następnego tracka.

**Logika:**
1. Jeśli `state.hasNext` (computed property):
   - Wywołaj `selectTrack(state.currentTrackIndex + 1)`
   - Wywołaj `_playerService.seekToNext()`
2. Else: no-op

---

#### Metoda: `void seekToPrevious()`
**Odpowiedzialność:** Przejdź do poprzedniego tracka.

**Logika:**
1. Jeśli `state.hasPrevious` (computed property):
   - Wywołaj `selectTrack(state.currentTrackIndex - 1)`
   - Wywołaj `_playerService.seekToPrevious()`
2. Else: no-op

---

#### Metoda: `void setLoopMode(LoopMode mode)`
**Odpowiedzialność:** Ustaw tryb zapętlania (none/one/all).

**Logika:**
1. Wywołaj `_playerService.setLoopMode(mode)`
2. Emit `state.copyWith(loopMode: mode)`

---

#### Metoda: `void updateTrack(Track updatedTrack)`
**Odpowiedzialność:** Zaktualizuj konkretny track w state (całościowa wymiana).

**Use case:** External update (np. user zmienił title tracka)

**Logika:**
1. Skopiuj `currentTracks = List<Track>.from(state.tracks)`
2. Znajdź `trackIndex = currentTracks.indexWhere((t) => t.id == updatedTrack.id)`
3. Jeśli trackIndex != -1:
   - `currentTracks[trackIndex] = updatedTrack`
   - Emit `state.copyWith(tracks: currentTracks)`
4. Else: no-op (track nie istnieje w playlist)

**Nie robi:** Nie rebuild audio sources (track title nie wpływa na audio)

---

#### Metoda: `void updateTrackMainVersion(int trackId, Version newMainVersion)`
**Odpowiedzialność:** Zaktualizuj mainVersion dla tracka (hot-swap audio file).

**Use case:** User dodał nową wersję tracka i oznaczył ją jako main.

**Logika:**
1. Skopiuj `currentTracks = List<Track>.from(state.tracks)`
2. Znajdź `trackIndex = currentTracks.indexWhere((t) => t.id == trackId)`
3. Jeśli trackIndex == -1:
   - Loguj warning: "Track {trackId} not found in playlist"
   - Return
4. Pobierz `currentTrack = currentTracks[trackIndex]`
5. Sprawdź czy wersja się faktycznie zmieniła:
   - Jeśli `currentTrack.mainVersion?.id == newMainVersion.id`:
     - Loguj: "Version unchanged for track {trackId}, skipping update"
     - Return (no-op, prevent unnecessary rebuilds)
6. Utwórz `updatedTrack = currentTrack.copyWith(mainVersion: newMainVersion)`
7. `currentTracks[trackIndex] = updatedTrack`
8. Emit `state.copyWith(tracks: currentTracks)`
9. Loguj: "Updated main version for track {trackId} to version {newMainVersion.id}"
10. **Hot-swap decision:** Jeśli `state.currentTrack?.id == trackId`:
    - Wywołaj `unawaited(_rebuildAudioSourceForTrack(updatedTrack))`
    - (Fire-and-forget, nie blokuje UI)

**Critical decision point:** Czy rebuild powinien być await czy fire-and-forget?
- **Fire-and-forget:** User nie musi czekać, ale jeśli rebuild się nie powiedzie, stary source pozostaje
- **Await:** User czeka, ale mamy pewność że source został wymieniony

**Obecna propozycja:** Fire-and-forget dla lepszego UX. Jeśli rebuild się nie powiedzie, logujemy error i gracefully degradate (stary source nadal działa).

---

#### Metoda: `Future<void> _rebuildAudioSourceForTrack(Track track)`
**Odpowiedzialność:** Hot-swap audio source w już załadowanej playlist.

**Use case:** User zmienił main version podczas gdy playlist jest już załadowana.

**Logika:**
1. Pobierz `url = track.mainVersion?.file?.downloadUrl`
2. Jeśli url == null:
   - Loguj warning: "Cannot rebuild audio source - no URL for track {track.id}"
   - Return (graceful degradation - stary source pozostaje)
3. Pobierz `playerIndex = _trackIdToPlayerIndex[track.id]`
4. Jeśli playerIndex == null:
   - Loguj warning: "Track {track.id} not in player index, cannot rebuild"
   - Return (nie powinno się zdarzyć, defensive)
5. Try:
   - Wywołaj `newSource = await _sourceFactory.createAudioSource(url, track.id)`
   - Pobierz `currentSequence = _playerService.sequence`
   - Skopiuj `sources = List<AudioSource>.from(currentSequence)`
   - `sources[playerIndex] = newSource` (replace na tym samym indexie)
   - Await `_playerService.setAudioSources(sources)` (rebuild całej playlist z nowym source)
   - Loguj success: "Rebuilt audio source for track {track.id}"
6. Catch:
   - Loguj error: "Failed to rebuild audio source for track {track.id}: {error}"
   - NIE rethrow (graceful degradation - stary source nadal działa)

**Potential issue:** Czy `setAudioSources` resetuje playback position?
- **Jeśli tak:** Trzeba będzie najpierw zapamiętać position, potem restore
- **Jeśli nie:** OK

**Decision:** Trzeba przetestować behavior just_audio. Jeśli resetuje position, dodać logic:
```
savedPosition = player.position
savedIndex = player.currentIndex
await setAudioSources(...)
await player.seek(savedPosition, index: savedIndex)
```

---

#### Metoda: `PlayerUiStatus _mapProcessingStateToPlayerUiStatus(PlayerState playerState)`
**Odpowiedzialność:** Map internal PlayerState (z just_audio) → UI-friendly enum.

**Logika:** Switch na `playerState.processingState`:
- **idle:** Return `PlayerUiStatus.idle`
- **loading:** Return `PlayerUiStatus.loading`
- **buffering:** Return `PlayerUiStatus.loading` (z perspektywy UI to to samo)
- **ready:**
  - Jeśli `playerState.playing` → `PlayerUiStatus.playing`
  - Else → `PlayerUiStatus.paused`
- **completed:** Return `PlayerUiStatus.paused` (track skończył się, pokazujemy pause button)

---

#### Metoda: `Future<void> close()`
**Odpowiedzialność:** Cleanup podczas dispose Cubita.

**Logika:**
1. Cancel all subscriptions:
   - `_playerStateSubscription?.cancel()`
   - `_positionSubscription?.cancel()`
   - `_cacheProgressSubscription?.cancel()`
2. Dispose dependencies:
   - `_preCachingOrchestrator.dispose()`
   - `_playerService.dispose()`
3. Await `super.close()`

---

## Dependency Injection Setup

**Provider Structure:**

```
Dio (singleton)
  ↓
AudioCacheRepository (scoped to projectId)
  ↓
AudioSourceFactory
  ↓
AudioPreCachingOrchestrator

AudioPlayer (new instance)
  ↓
AudioPlayerService

TrackPlayerCubit (depends on: AudioPlayerService, AudioSourceFactory, AudioPreCachingOrchestrator)
```

**Problem:** AudioCacheRepository zależy od `projectId`, który jest known dopiero w runtime (gdy user otwiera projekt).

**Rozwiązanie:**
- Opcja 1: Utwórz AudioCacheRepository wewnątrz TrackPlayerCubit w `loadTracksDirectly(projectId)`
- Opcja 2: Użyj factory pattern - `AudioCacheRepositoryFactory(dio).create(projectId)`

**Rekomendacja:** Opcja 2 - factory pattern, bo pozwala na dependency injection testing.

---

## Migration Strategy (Step-by-Step)

### Etap 1: Extract AudioCacheRepository (1-2 dni)
**Cel:** Wydzielić cache management do osobnej klasy.

**Kroki:**
1. Utwórz `lib/features/track_player/services/audio_cache_repository.dart`
2. Przenieś metody: `_getCacheFileForTrack`, `_downloadTrackToCache`
3. Update `TrackPlayerCubit`:
   - Inject `AudioCacheRepository`
   - Replace direct calls z calls do repository
4. Napisz unit tests dla repository (mock Dio)
5. Verify że aplikacja nadal działa

**Risk:** Low (cache logic jest już oddzielony metodami)

---

### Etap 2: Extract AudioPlayerService (1 dzień)
**Cel:** Wrapper nad AudioPlayer.

**Kroki:**
1. Utwórz `lib/features/track_player/services/audio_player_service.dart`
2. Przenieś AudioPlayer instance do service
3. Expose streams i playback methods
4. Update `TrackPlayerCubit`:
   - Inject `AudioPlayerService`
   - Replace `_audioPlayer.xxx` z `_playerService.xxx`
5. Napisz unit tests dla service (mock AudioPlayer)
6. Verify że aplikacja nadal działa

**Risk:** Low (to thin wrapper, mało logic)

---

### Etap 3: Extract AudioSourceFactory (0.5 dnia)
**Cel:** Factory pattern dla AudioSource creation.

**Kroki:**
1. Utwórz `lib/features/track_player/services/audio_source_factory.dart`
2. Przenieś `_createCachingAudioSource` logic
3. Dodaj graceful degradation (fallback do streaming)
4. Update `TrackPlayerCubit`: używaj factory
5. Napisz unit tests
6. Verify że aplikacja nadal działa

**Risk:** Low (prosta logic)

---

### Etap 4: Extract AudioPreCachingOrchestrator (1 dzień)
**Cel:** Background pre-caching z progress tracking.

**Kroki:**
1. Utwórz `lib/features/track_player/services/audio_pre_caching_orchestrator.dart`
2. Przenieś pre-caching logic z Cubita
3. Zmień z direct state emits na stream-based progress
4. Update `TrackPlayerCubit`:
   - Inject orchestrator
   - Listen do progressStream
   - Map progress → state
5. Napisz unit tests
6. Verify że aplikacja nadal działa

**Risk:** Medium (asynchronous logic, stream coordination)

---

### Etap 5: Slim Down Cubit (1 dzień)
**Cel:** Remove extracted logic, keep tylko orchestration.

**Kroki:**
1. Review Cubit - usuń wszystkie metody które już są w services
2. Verify że Cubit tylko:
   - Zarządza UI state
   - Orchestruje services
   - Mapuje domain events → UI state
3. Refactor naming (jeśli potrzeba)
4. Full integration tests
5. Code review

**Risk:** Low (jeśli poprzednie etapy przeszły, to jest tylko cleanup)

---

## Porównanie: Przed vs Po

| Metryka | Przed (Monolith) | Po (Layered) |
|---------|------------------|--------------|
| **Cubit LOC** | 464 linie | ~150-200 linii |
| **Modules count** | 1 | 5 (Cubit + 4 services) |
| **Testability** | Integration tests tylko | Unit tests dla każdego modułu |
| **Bug isolation** | Cache bug wpływa na playback | Cache bug izolowany w Repository |
| **Parallel dev** | Niemożliwy (merge conflicts) | 5 devs, 5 plików |
| **Onboarding** | 2-3 dni (zrozumienie 464 linii) | 1 dzień (clear boundaries) |
| **Error propagation** | Jedna exception rozsypuje cały flow | Graceful degradation na każdym poziomie |

---

## Otwarte Pytania / Decision Points

### 1. Hot-swap audio sources - await vs fire-and-forget?
**Context:** Gdy user zmienia main version, rebuild'ujemy audio source.

**Opcje:**
- A) **Fire-and-forget** (`unawaited`) - lepszy UX, ale jeśli rebuild fail, stary source pozostaje
- B) **Await** - user czeka, ale pewność że source wymieniony

**Rekomendacja:** Fire-and-forget (A) - jeśli rebuild się nie powiedzie, track nadal gra (graceful degradation)

---

### 2. Pre-caching strategy - sequential vs parallel?
**Context:** Obecnie cache'ujemy tracki jeden po drugim.

**Opcje:**
- A) **Sequential** (obecne) - prostsze, mniej obciążenia sieci, przewidywalny progress
- B) **Parallel** (np. 3 jednocześnie) - szybsze, ale complexity w error handling

**Rekomendacja:** Sequential (A) dla MVP. Parallel można dodać później jeśli potrzeba.

---

### 3. Cache invalidation - kiedy implementować?
**Context:** Obecnie nie ma mechanizmu invalidacji (np. gdy backend zmieni plik).

**Opcje:**
- A) **Teraz** - dodaj cache version checking (ETag, Last-Modified)
- B) **Później** - ship without, dodaj gdy będzie realny problem

**Rekomendacja:** Później (B) - nie mamy potwierdzenia że to jest problem. YAGNI.

---

### 4. AudioCacheRepository - per-project czy global?
**Context:** Repository jest scoped do projectId.

**Opcje:**
- A) **Per-project instance** - każdy projekt ma swój repository (current proposal)
- B) **Global singleton** - jeden repository, metody przyjmują projectId

**Rekomendacja:** Per-project (A) - lepsze dla testowania i DI

---

## Następne Kroki

1. **Review tego dokumentu** - czy architektura ma sens dla Twojego use case?
2. **Decyzje na otwarte pytania** - potrzebuję Twoich decyzji na Decision Points
3. **Approve migration strategy** - czy etapowe podejście (5 kroków) jest OK?
4. **Rozpocząć od testów?** - czy najpierw napisać testy dla obecnego Cubita (safety net) czy od razu refactor?

**Co decydujesz?**
