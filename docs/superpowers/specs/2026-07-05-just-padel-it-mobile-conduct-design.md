# Just Padel It в приложении — под-проект B: проведение + live (дизайн)

**Дата:** 2026-07-05
**Статус:** утверждён, к плану реализации
**Область:** приложение (Flutter `padel_app`) + мобильный API (Laravel `padel`)

## Контекст

Под-проект A (создание JPI-турнира с телефона) готов. Сейчас при попытке
запустить JPI-турнир мобильный бэкенд отвечает «Неизвестный тип турнира»
(`MobileAdminTournamentDetailController::start()`, ветка `else`) — проведение
формата на мобилке ещё не подключено. B подключает полный цикл: посев/пары →
старт → раунды/счёт → итоговая таблица → завершение, плюс live-экран просмотра
для игроков/зрителей.

Вся доменная логика формата уже написана и работает на вебе:
`JustPadelItService` — метод-в-метод копия `KingOfCourtService` (те же имена и
сигнатуры: `arePairsCreated`, `startTournament(Tournament, ?array $order)`,
`saveMatchResult(JustPadelItMatch, int, int)`, `canGenerateNextRound`,
`generateNextRound`, `canFinishTournament`, `finishTournament`,
`getPairStandings`, `createPairs`). Задача B — тонкий мобильный API-слой поверх
этого сервиса + экраны в приложении. Паттерн — **зеркалирование интеграции
Короля корта** (KoC), т.к. JPI построен на его движке.

## Решения (из брейншторма)

- Полный цикл проведения в приложении, включая **live-экран** просмотра для
  игроков/зрителей (не только админ).
- **Посев solo — как на вебе:** авто по рейтингу + возможность вручную
  переставить игроков по кортам перед стартом (в приложении делаем экран
  посева, аналог веб-seeding). `JustPadelItService::startTournament` уже
  принимает `?array $order` — старт отправляет выбранный порядок.
- **Парный:** сначала создать пары (экран, аналог KoC-пар), затем старт;
  пары авто-сеются по сумме рейтинга (как на вебе — парный стартует напрямую,
  без ручного посева пар).
- **Тип подсчёта — по очкам** (v1), как в A.
- Таблица: сумма очков (с бонусами за корт) и число побед; сортировка
  очки↓ → победы↓ (веб-поведение, `getPairStandings`).

## Точки интеграции — бэкенд (`C:\projects\padel`)

Везде — ветка `just_padel_it`, вызывающая инъектированный
`JustPadelItService $jpi` (копии соответствующих KoC-веток).

### `MobileAdminTournamentDetailController` (админское проведение)
- **`start()`** — JPI-ветка: если парный и `!$jpi->arePairsCreated()` →
  ответ `{ success:false, message:'Сначала создайте пары', pairs_required:true }`
  (422); иначе прочитать `order` из запроса (массив id, `nullable|array`) и
  вызвать `$jpi->startTournament($tournament, $order ?: null)`. Для solo без
  `order` — авто-посев по рейтингу (сервис так и делает при `null`).
- **`show()`** — JPI-ветка сборки детального payload: раунды, матчи текущего
  раунда, итоговая таблица (`getPairStandings`), флаги
  `can_next_round`/`can_finish`, `is_paired`, `pairs_created`. Копия
  KoC-секции, поля идентичны.
- **`matches()`** — JPI-ветка: матчи по раундам (копия KoC).
- **`nextRound()`** — JPI-ветка: `canGenerateNextRound` → `generateNextRound`.
- **`finish()`** — JPI-ветка: `canFinishTournament` → `finishTournament`.
- **`saveJustPadelItScore(Tournament, JustPadelItMatch, Request)`** — новый
  метод (копия `saveKingOfCourtScore`): валидирует `team1_score`/`team2_score`
  (целые ≥0, ничьи запрещены — победитель обязателен), вызывает
  `$jpi->saveMatchResult($match, $t1, $t2)`. POST и PUT (как у KoC —
  создание и правка счёта одинаковы).
- **`jpiPairs(Tournament)` / `saveJpiPairs(Tournament, Request)`** — новые
  методы (копии `kocPairs`/`saveKocPairs`): GET отдаёт участников + текущие
  пары; POST принимает массив пар и вызывает `$jpi->createPairs()`.
- **`jpiSeeding(Tournament)`** — новый GET для экрана посева solo: возвращает
  `{ participants: [{id, name, rating}], courts_count }`, участники в
  авто-порядке по рейтингу (сильные — корт 1). Аналог веб-seeding-контроллера,
  но JSON. Только для solo JPI (для парного — 404/redirect-семантика: парный
  идёт через пары).

### `MobileTournamentController` (публичный live)
- **`live()`** (диспетчер по типу) — добавить ветку → `liveJustPadelIt()`.
- **`liveJustPadelIt(Tournament, $user)`** — новый метод (копия
  `liveKingOfCourt`): раунды, матчи, таблица, подсветка текущего игрока.
  Питает live-экран приложения через `GET /tournaments/{id}/live`.

### `routes/api.php`
- `POST|PUT /admin/tournaments/{tournament}/justpadelit/matches/{match}/score`
  → `saveJustPadelItScore` (route-model binding `JustPadelItMatch $match`).
- `GET /admin/tournaments/{tournament}/justpadelit/pairs` → `jpiPairs`.
- `POST /admin/tournaments/{tournament}/justpadelit/pairs` → `saveJpiPairs`.
- `GET /admin/tournaments/{tournament}/justpadelit/seeding` → `jpiSeeding`.

«Король корта» и его методы/маршруты **не изменяются** — только добавляются
JPI-ветки/методы рядом.

## Точки интеграции — приложение (`C:\projects\padel_app`)

### `lib/services/admin_service.dart`
- `saveJpiScore({tournamentId, matchId, team1Score, team2Score})` — POST на
  `.../justpadelit/matches/{match}/score` (копия `saveKocScore`).
- `getJpiPairs(tournamentId)` / `saveJpiPairs(tournamentId, pairs)` — копии
  `getKocPairs`/`saveKocPairs`.
- `getJpiSeeding(tournamentId)` — GET `.../justpadelit/seeding`.
- `startTournamentWithOrder(tournamentId, order)` — вариант старта с `order[]`
  (или расширить существующий `startTournament` опциональным `order`).
- `generateNextRound` — уже общий (POST `/nextRound`), заработает с
  JPI-веткой бэка; отдельный метод не нужен.

### `lib/screens/admin/admin_tournament_detail_screen.dart`
- `_needPairs`: добавить `type == 'just_padel_it' && isPaired && !pairsCreated`.
- `_openCreatePairs`: для JPI открыть `AdminJpiCreatePairsScreen`.
- Старт solo JPI: открывать `AdminJpiSeedingScreen`; по подтверждению —
  старт с выбранным `order`.
- Ввод счёта матча: для JPI звать `saveJpiScore`.
- «Следующий раунд» / «Завершить» / таблица: JPI-ветки (данные из `show()`).

### Новые экраны
- **`lib/screens/admin/admin_jpi_create_pairs_screen.dart`** — копия
  `admin_koc_create_pairs_screen.dart`, эндпоинты JPI-пар.
- **`lib/screens/admin/admin_jpi_seeding_screen.dart`** — экран посева solo:
  грузит `getJpiSeeding`, рисует корты × 4 слота, авто-раскладка по рейтингу,
  ручная перестановка (swap при выборе — как на вебе), кнопка «Начать турнир»
  → старт с `order[]`.
- **`lib/screens/tournament_live_justpadelit_screen.dart`** — копия
  `tournament_live_kingofcourt_screen.dart`, тот же `GET /tournaments/{id}/live`.

### Навигация
- `lib/utils/tournament_navigation.dart` (и/или экран списка турниров): для
  `just_padel_it` открывать `tournament_live_justpadelit_screen` (как KoC).

## Тестирование B

- **Бэкенд (PHPUnit):** solo — старт (авто-посев) создаёт 1-й раунд и матчи;
  старт с `order[]` уважает порядок; сохранение счёта начисляет очки+бонус
  победителям (корт 1 → +3 и т.д.); `nextRound` двигает победителей вверх;
  таблица сортируется очки↓→победы↓; `finish` завершает. Парный — `start` без
  пар возвращает `pairs_required`; после `saveJpiPairs` старт проходит.
  Мирроринг существующих KoC-тестов (`MobileAdminKocPairsTest`,
  live-тесты) под JPI.
- **App:** ручной smoke — solo (посев→редактирование→старт→счёт→след. раунд→
  таблица→финиш) и парный (пары→старт→…); live-экран у игрока показывает
  раунды и таблицу.

## Правила проекта (Global Constraints)
- Тип везде ровно `just_padel_it` (snake_case).
- «Король корта» (код/маршруты/таблицы) не изменять — только добавлять JPI.
- Бэкенд (`padel`) коммитим и пушим сразу; приложение (`padel_app`) НЕ пушим
  (юзер собирает локально `flutter run`).
- Ничьи в матче запрещены — победитель обязателен.
- Строки админ-экранов — можно хардкод RU (правило проекта). Live-экран —
  пользовательский: строки через AppLocalizations (как у KoC live).

## Вне области B
- Замена игрока посреди турнира (после вбитого счёта) — как на вебе, нет.
- «По сетам» — нет (v1 по очкам).
- Изменение движка/бонусов — уже готово на бэке, не трогаем.
