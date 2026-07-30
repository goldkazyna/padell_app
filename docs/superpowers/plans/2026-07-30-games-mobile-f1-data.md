# Games Mobile — F1 (Слой данных: модели + сервис + провайдер) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`).

**Goal:** Слой данных для нового раздела «Игры» (games) в приложении: модели, `GameService` (все эндпоинты games-API), `GameProvider` (ChangeNotifier), регистрация в `main.dart`. UI — следующие слайсы (F2–F6).

**Architecture:** Полное зеркало модуля `challenge` (`lib/models/challenge.dart`, `lib/services/challenge_service.dart`, `lib/providers/challenge_provider.dart`), но под games-API. Backend уже готов (S0–S12).

**Tech Stack:** Flutter/Dart, provider, http через общий `ApiService`. Проверка — `flutter analyze` (0 issues).

## Контекст API (эндпоинты и форма ответа)
Base: `https://padel-p.kz/api/mobile` (уже в `ApiService`). Токен — последним позиционным аргументом. Ответ — конверт `{success, data, ...}`; ленты дают `{success, data:[...], meta:{current_page, per_page, total, last_page}}`.

**Game JSON** (из бэкового `formatGame`): `id, creator_id, is_creator, club{id,name}|null, court_id, starts_at, ends_at, type, type_name, visibility, format, format_name, format_meta(Map), rating_min, rating_max, capacity, price, description, status, status_name, score_locked, share_token, share_active, available_positions(List<int>), accepted_count, players[], is_participant, my_status, my_position, my_score_confirmed, rounds[], americano_ranking`.
- **player**: `id, position, status, source, out_of_range, full_name, avatar, rating(int), level(double), is_me, score_confirmed`.
- **round**: `id, round_no, pair_a(List<int>), pair_b(List<int>), score_a, score_b, tiebreak_a, tiebreak_b, is_played`.
- **americano_ranking item**: `user_id, points, wins, diff, place`.

**Эндпоинты:**
- `GET /games/clubs` → список клубов (как challenge getClubs).
- `GET /games?club_id=&format=&type=&date_from=&date_to=&show_out_of_level=&per_page=&page=` → лента (конверт с meta).
- `GET /games/my?status=&per_page=&page=` → мои игры.
- `GET /games/invitations?status=` → инбокс: `[{invitation_id, status, expires_at, inviter{id,name}, game{...}}]`.
- `GET /games/{id}` → детали.
- `POST /games` (create), `PUT /games/{id}` (update).
- `POST /games/search-player {phone}` → `{partners:[...]}` (ключ `partners`, как в турнирах).
- `POST /games/{id}/invite {user_id}` ; `/apply` ; `/applications/{playerId}/approve|reject` ; `/accept` ; `/decline` ; `/leave` ; `/players/{playerId}/remove`.
- `POST /games/{id}/start` ; `/start/cancel` ; `/finish` ; `/confirm-score` ; `/schedule/regenerate`.
- `POST /games/{id}/rounds {pair_a,pair_b,score_a?,score_b?,tiebreak_a?,tiebreak_b?}` ; `PUT /games/{id}/rounds/{roundId}` ; `DELETE /games/{id}/rounds/{roundId}`.
- `POST /games/{id}/share/rotate` ; `/share/revoke` ; `GET /games/by-share/{token}` (публичный).
- `POST /games/{id}/transfer {to_user_id}` ; `/transfer/cancel` ; `/transfer/accept` ; `/transfer/decline`.
- `GET /games/{id}/logs`.

## Global Constraints
- Строки для UI позже — в этом слайсе кода с пользовательскими строками почти нет (только дефолтные тексты ошибок в провайдере, как в challenge — там русские литералы; допустимо, т.к. это временный fallback, но предпочтительно нейтральные). Модели/сервис строк не содержат.
- Стиль 1:1 как `challenge_*`: те же имена приватных полей+геттеров, те же records `({bool success, String message, ...})` для действий, тот же паттерн загрузки токена/`notifyListeners`.
- `flutter analyze` — 0 issues на изменённых файлах.
- НЕ пушить репозиторий. НЕ менять существующий модуль challenge.

---

### Task 1: Модели games

**Files:**
- Create: `lib/models/game.dart`
- Test: (нет unit-тестов в проекте; верификация — `flutter analyze`)

**Interfaces:**
- Produces классы (все с `fromJson`, безопасный парсинг nested в try/catch как в `challenge.dart`):
  - `GamePlayer` — поля `id, position, status, source, outOfRange(bool), fullName, avatar(String?), rating(int), level(double), isMe(bool), scoreConfirmed(bool)`; геттеры `initials`, `isAccepted/isInvited/isCandidate` по строке status.
  - `GameRound` — `id, roundNo, pairA(List<int>), pairB(List<int>), scoreA(int?), scoreB(int?), tiebreakA(int?), tiebreakB(int?), isPlayed(bool)`.
  - `GameRankingRow` — `userId, points, wins, diff, place`.
  - `GameClub` — `id, name` (как ChallengeClub).
  - `Game` — все поля из формы Game JSON выше; `formatMeta` как `Map<String,dynamic>?`; `players List<GamePlayer>`, `rounds List<GameRound>`, `americanoRanking List<GameRankingRow>`, `availablePositions List<int>`; геттеры: `isOpen/isFull/isInProgress/isFinished/isCancelled` по status, `isRated/isFriendly`, `isSets/isPoints/isAmericano` по format, `isPrivate`, `dateFormatted/timeFormatted/dayOfWeek` (по образцу challenge, но по возможности через intl; допустимо повторить хардкод как в challenge), `isPendingConfirmation` = `isInProgress && scoreLocked`.
  - `GameInvitationItem` — `invitationId, status, expiresAt(DateTime?), inviterId, inviterName, game(Game)`.

- [ ] **Step 1: Реализация**

Создать `lib/models/game.dart`, зеркаля стиль `lib/models/challenge.dart` (прочитать его целиком как образец: конструкторы, `fromJson` с `?? 0`/`?? ''`, try/catch вокруг парсинга списков, геттеры). Все int из API парсить с `?? 0`, level как `double.tryParse(...) ?? 0` (может прийти строкой или num). `starts_at`/`ends_at`/`expires_at` — `DateTime.tryParse`.

- [ ] **Step 2: Проверка**

Run: `flutter analyze lib/models/game.dart`
Expected: `No issues found`.

- [ ] **Step 3: Commit**

```bash
git add lib/models/game.dart
git commit -m "feat(games): модели данных (F1)"
```

---

### Task 2: GameService

**Files:**
- Create: `lib/services/game_service.dart`

**Interfaces:**
- Consumes: `ApiService` (constructor injection, как `ChallengeService(this._api)`), модели из Task 1.
- Produces методы (каждый: собрать endpoint, вызвать `_api.get/post/put/delete(endpoint, [body], token)`, распарсить `response['data']`):
  - `Future<List<GameClub>> getClubs(String token)` — GET /games/clubs.
  - `Future<({List<Game> items, int total, int lastPage, int currentPage})> getFeed(Map<String,dynamic> query, String token)` — GET /games с query-string; парсит `data`+`meta`.
  - `Future<({List<Game> items, int total, int lastPage, int currentPage})> getMyGames(Map<String,dynamic> query, String token)` — GET /games/my.
  - `Future<List<GameInvitationItem>> getInvitations(String? status, String token)` — GET /games/invitations.
  - `Future<Game> getDetails(int id, String token)` — GET /games/{id}.
  - `Future<Game> create(Map<String,dynamic> data, String token)` ; `Future<Game> update(int id, Map<String,dynamic> data, String token)`.
  - `Future<List<Map<String,dynamic>>> searchPartner(int gameId, String phone, String token)` — POST /games/{id}/search-player, ключ ответа `partners`.
  - Действия, возвращающие `Future<Game>` (перечитывают деталь из ответа `data`): `invite(id, userId)`, `apply(id)`, `approveApplication(id, playerId)`, `rejectApplication(id, playerId)`, `accept(id)`, `decline(id)`, `leave(id)`, `removePlayer(id, playerId)`, `start(id)`, `startCancel(id)`, `finish(id)`, `confirmScore(id)`, `regenerateSchedule(id)`, `addRound(id, body)`, `updateRound(id, roundId, body)`, `deleteRound(id, roundId)`, `shareRotate(id)`, `shareRevoke(id)`, `transferInitiate(id, toUserId)`, `transferCancel(id)`, `transferAccept(id)`, `transferDecline(id)`.
  - `Future<Game> resolveByShare(String tokenParam, String authToken)` — GET /games/by-share/{token}.
  - `Future<List<Map<String,dynamic>>> getLogs(int id, String token)` — GET /games/{id}/logs.

> ПРИМЕЧАНИЕ: для эндпоинтов, где бэкенд возвращает `{success, data:formatGame}`, метод возвращает `Game.fromJson(response['data'])`. Для query-строки собрать `?k=v&...` из непустых значений. `search-player` — тело `{phone: ...}`, ответ `response['partners'] ?? response['data']['partners']` (проверь оба; у challenge — `partners`).

- [ ] **Step 1: Реализация** — создать `lib/services/game_service.dart` по образцу `challenge_service.dart`.
- [ ] **Step 2: Проверка** — `flutter analyze lib/services/game_service.dart` → No issues.
- [ ] **Step 3: Commit**
```bash
git add lib/services/game_service.dart
git commit -m "feat(games): GameService — все эндпоинты (F1)"
```

---

### Task 3: GameProvider + регистрация

**Files:**
- Create: `lib/providers/game_provider.dart`
- Modify: `lib/main.dart` (инстанс `GameService` + `ChangeNotifierProvider` для `GameProvider`)

**Interfaces:**
- Consumes: `GameService`, `StorageService` (constructor, как `ChallengeProvider(service, storage)`).
- Produces `GameProvider extends ChangeNotifier`:
  - Состояние (поле + геттер): `_feed(List<Game>)`, `_myGames(List<Game>)`, `_invitations(List<GameInvitationItem>)`, `_currentGame(Game?)`, `_clubs(List<GameClub>)`, `_isLoadingFeed`, `_isLoadingMy`, `_isLoadingDetail`, `_isActionLoading`, `_error`, плюс meta ленты (`_feedTotal/_feedPage/_feedLastPage`).
  - Read-методы (паттерн challenge: взять токен, `if null return`, set loading, try/catch, `notifyListeners`): `loadFeed({Map filters})`, `loadMyGames({Map filters})`, `loadInvitations({String? status})`, `loadDetails(int id)`, `loadClubs()`.
  - Action-методы, возвращающие records `({bool success, String message})` (для create — с `Game? game`): `createGame(data)`, `updateGame(id,data)`, `invite(id,userId)`, `apply(id)`, `approve(id,playerId)`, `reject(id,playerId)`, `accept(id)`, `decline(id)`, `leave(id)`, `removePlayer(id,playerId)`, `start(id)`, `startCancel(id)`, `finish(id)`, `confirmScore(id)`, `regenerate(id)`, `addRound(id,body)`, `updateRound(id,roundId,body)`, `deleteRound(id,roundId)`, `shareRotate(id)`, `shareRevoke(id)`, `transferInitiate(id,toUserId)`, `transferCancel(id)`, `transferAccept(id)`, `transferDecline(id)`, `searchPartner(id,phone)` (возвращает список), `clearCurrentGame()`, `clearError()`. После успешного действия обновлять `_currentGame` из ответа и по необходимости дёргать `loadDetails(id)` (как challenge resync на ошибке).

- [ ] **Step 1: Реализация** — создать `lib/providers/game_provider.dart` по образцу `challenge_provider.dart`; в `lib/main.dart` рядом с `final challengeService = ChallengeService(apiService);` добавить `final gameService = GameService(apiService);`, и в список `providers` рядом с `ChallengeProvider` — `ChangeNotifierProvider(create: (_) => GameProvider(gameService, storageService)),`. Импортировать новые файлы.
- [ ] **Step 2: Проверка** — `flutter analyze lib/providers/game_provider.dart lib/main.dart` → No issues.
- [ ] **Step 3: Commit**
```bash
git add lib/providers/game_provider.dart lib/main.dart
git commit -m "feat(games): GameProvider + регистрация (F1)"
```

---

## Порядок выполнения
Task 1 (модели) → 2 (сервис) → 3 (провайдер+регистрация).

## Не входит (следующие слайсы)
F2 лента `GamesScreen`; F3 создание; F4 лобби/детали; F5 счёт/финал; F6 инбокс.
