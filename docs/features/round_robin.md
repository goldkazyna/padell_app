# Round Robin (индивидуальный турнир)

Новый тип турнира `round_robin`. Полная фича на весь стек: создание (веб +
мобила), проведение (веб + мобила), live-просмотр игроком, история турниров,
рейтинг, пуши. Начато 2026-06-11.

- **Бэкенд:** `C:\projects\padel` (репо `goldkazyna/padel`, прод `padel-p.kz`)
- **Фронтенд:** `C:\projects\padel_app` (репо `goldkazyna/padell_app`)

---

## 1. Спецификация (что это за турнир)

Как **Американо** (2×2, партнёры меняются каждый раунд, индивидуальный зачёт), НО:

- **Ранжирование по числу выигранных МАТЧЕЙ** (победа +1, поражение +0). Ничьих нет.
- **Tie-break:** разница геймов → личные встречи (H2H) → рейтинг.
- За матч: победители +1 победа; геймы идут в копилку (4:2 → победители +4 «за»,
  +2 «против»; проигравшие +0 побед, +2 «за», +4 «против»).
- **Раунды генерятся ВРУЧНУЮ** — кнопка «Следующий раунд» / «Завершить турнир»
  в любой момент (как **Король корта**, НЕ авто как в Американо).
- **Расписание круга** считается на старте и сохраняется (JSON). Для 8 игроков
  круг = 7 раундов (каждый партнёрит с каждым 1 раз, играет против каждого 2 раза).
  После круга можно генерить дальше — расписание зацикливается (раунд N =
  `schedule[(N-1) mod len]`).
- **Досрочное завершение:** после любого доигранного раунда. Таблица — по сыгранному.
- Без групп и без плей-офф (одна общая таблица).
- **Рейтинг** считается тем же ядром (трейт `RatingCalculator`), что и Американо/
  Король корта — чистый ELO по матчам (рейтинг команды = среднее двух игроков,
  эволюционирует по ходу турнира). Не привязан к месту в таблице.

Архитектурно RR — это **клон Король корта** (ручные раунды, индивидуальные статы,
один лидерборд) + **расписание Американо** (круговая раскладка пар). Поэтому везде,
где можно, переиспользуется инфраструктура Король корта.

---

## 2. Бэкенд (Laravel, `C:\projects\padel`)

### Данные
- **Миграция:** `database/migrations/2026_06_11_000003_create_round_robin_tables.php`
  - в enum `tournaments.type` добавлен `round_robin`
  - колонка `tournaments.round_robin_schedule` (JSON) — сохранённое расписание круга
  - таблицы: `round_robin_players` (статы: wins, losses, points_for, points_against,
    position, rating_before, rating_after), `round_robin_rounds` (round_number, status),
    `round_robin_matches` (court_number, 4 player FK, team1_score/team2_score, status)
- **Модели:** `app/Models/RoundRobinPlayer.php`, `RoundRobinRound.php`, `RoundRobinMatch.php`
- **Tournament.php:** `isRoundRobin()`, связи `roundRobinPlayers()` / `roundRobinRounds()`,
  `round_robin_schedule` в `$fillable` + cast `array`; метка типа в `getTypeNameAttribute()`
  = «Round Robin».

### Ядро (сервис)
- **`app/Services/RoundRobinService.php`** — вся логика:
  - `startTournament` — проверка (≥4, кратно 4), шаффл, создание игроков, построение и
    сохранение расписания (`buildIndexSchedule` → оптимальные схемы 8/12 или круговой
    метод), создание раунда 1.
  - `saveMatchResult` — идемпотентно (откат старых статов + применение).
  - `canGenerateNextRound` / `generateNextRound` — по сохранённому расписанию (цикл).
  - `canFinishTournament` / `finishTournament` — ELO если `is_rated`, запись `RatingHistory`.
  - `calculateEloForMatch` — идентичен Американо/KoC (трейт `RatingCalculator`).
  - `standings($tournament)` — таблица: победы → разница геймов → H2H → рейтинг.
    Возвращает строки `['user', 'user_id', 'wins', 'losses', 'points_for',
    'points_against', 'diff', 'rating']`. **Это главный источник правды для места/таблицы.**

### Веб-проведение (админка)
- **`app/Http/Controllers/Club/RoundRobinController.php`** — `show` (грузит данные +
  `standings`), `saveScore` / `updateScore` (с отбивкой ничьей), `generateNextRound`
  (+ пуш через `notifyRoundRobinRoundGenerated`).
- **`app/Http/Controllers/Club/TournamentController.php`** — диспетчеры по типу:
  `start()`, `finish()`, `show()` + валидация типа в `store()`.
- **Вью:** `resources/views/club/tournaments/round_robin/show.blade.php` — шапка,
  таблица лидеров (# · Игрок · В · П · З · ПР · ±), раунды (сворачиваемые, ввод счёта
  по тапу), кнопки «Следующий раунд» / «Завершить».
- **Форма создания:** `resources/views/club/tournaments/create.blade.php` — опция типа
  + инфо-блок + JS-toggle.
- **Роуты:** `routes/web.php` — `club.roundRobin.{saveScore,updateScore,nextRound}`.

### Мобильное API — админ-проведение
- **`app/Http/Controllers/Api/MobileAdminTournamentController.php`** — `round_robin`
  в enum валидации создания (`tournamentValidationRules`).
- **`app/Http/Controllers/Api/MobileAdminTournamentDetailController.php`**:
  - диспетчеры `start` / `matches` / `nextRound` / `finish` — ветка round_robin
  - `saveRoundRobinScore` — эндпоинт счёта
  - `buildRoundRobinMatches` / `buildRoundRobinLeaderboard` — отдаёт «виртуальную группу»
    (раунды + таблица + summary с `can_finish`/`can_generate_next_round`) той же формы,
    что Король корта → фронт рендерит обобщённо
  - `nextRound` шлёт пуш участникам (через `RoundRobinController::notifyRoundRobinRoundGenerated`)
- **Роуты:** `routes/api.php` — `…/round_robin/matches/{match}/score` (POST/PUT).

### Мобильное API — игрок (live / история / рейтинг)
- **`app/Http/Controllers/Api/MobileTournamentController.php`**:
  - `live()` → ветка round_robin → **`liveRoundRobin`** (структура как KoC: лидерборд +
    раунды + дельты рейтинга по раундам; обслуживает идущие/завершённые/чужой профиль
    через `player_id`). Таблица по `standings`.
  - `getUserPlace()` → ветка round_robin через `standings` — место в архиве/своей истории.
- **`app/Http/Controllers/Api/MobileRatingController.php`**:
  - `getTournamentPlace()` → ветка round_robin через `standings` — место в истории
    **чужого** профиля (открытого из рейтинга). ⚠️ Это ОТДЕЛЬНЫЙ метод от `getUserPlace`!
  - `player()` → в подмешивании нерейтинговых турниров добавлен `roundRobinPlayers`
    в `whereHas` (иначе личный нерейтинговый RR не попадал в чужой профиль).

### Пуши
- **`app/Http/Controllers/Club/RoundRobinController.php`** —
  `notifyRoundRobinRoundGenerated(id, name, round)` (public static, subtype
  `round_robin_round_generated`). Зовётся из веб- и мобильного контроллеров.
- Аналогично для KoC сделали `KingOfCourtController::notifyKocRoundGenerated` (заодно,
  чтобы пуш слался и из мобилы — раньше только из веба).

---

## 3. Фронтенд (Flutter, `C:\projects\padel_app`)

### Создание турнира
- **`lib/screens/admin/admin_create_tournament_screen.dart`** — карточка типа
  «Round Robin» (без спец-полей, как Король корта — только корты/участники).

### Списки турниров
- **`lib/screens/admin/admin_tournaments_screen.dart`** — тег типа обёрнут в `Flexible`
  + ellipsis (длинное название не ломало строку — был overflow).

### Админ-проведение
- **`lib/services/admin_service.dart`** — `saveRoundRobinScore` (эндпоинт счёта).
- **`lib/screens/admin/admin_tournament_detail_screen.dart`**:
  - ветка `isRoundRobin` в вводе счёта (+ запрет ничьи)
  - **`_buildRoundRobinLeaderboard`** — таблица по веб-параметрам (# · Игрок · В · П · З
    · ПР · ±), дизайн как у общей таблицы
  - сворачивание завершённых раундов (активный «идёт» раскрыт, остальные свёрнуты),
    состояние в `_rrRoundExpanded` — **только для round_robin**.

### Live-экран игрока
- **`lib/utils/tournament_navigation.dart`** — `openTournamentLiveByType`: `round_robin`
  маршрутизируется на **`TournamentLiveKingOfCourtScreen`** (структура live идентична).
- **`lib/screens/tournament_live_kingofcourt_screen.dart`** — переиспользуется для RR.
  При `format == 'round_robin'` таблица показывает **В · П · З · ПР · ±** вместо
  KoC-шных РП · % · Очки (геттер `_isRoundRobin`). Заголовок берётся из `format_name`.
- **`lib/screens/home_screen.dart`** — карточка «Live турнир» на главной: ветка
  round_robin → live-экран Король корта (раньше падала в `else` → деталка).
- **`lib/screens/player_profile_screen.dart`** — тап по RR-турниру в истории чужого
  профиля → live-экран Король корта (раньше падал в `default` → `TournamentResultsScreen`,
  который RR не рисует).

### Пуши
- **`lib/services/push_notification_service.dart`** — subtype
  `round_robin_round_generated` → live-экран Король корта (тап по пушу о генерации раунда).

---

## 4. Ключевые потоки (куда смотреть)

| Поток | Бэкенд | Фронтенд |
|---|---|---|
| Создание (веб) | `TournamentController::store` + create.blade | — |
| Создание (мобила) | `MobileAdminTournamentController::store` | `admin_create_tournament_screen` |
| Проведение (веб) | `RoundRobinController` + show.blade | — |
| Проведение (мобила) | `MobileAdminTournamentDetailController` (start/matches/score/nextRound/finish) | `admin_tournament_detail_screen` + `admin_service` |
| Live игроком | `MobileTournamentController::liveRoundRobin` | `tournament_live_kingofcourt_screen` (через `tournament_navigation`) |
| Место в своей истории | `MobileTournamentController::getUserPlace` | архив (type-agnostic) |
| Место в чужом профиле | `MobileRatingController::getTournamentPlace` | `player_profile_screen` |
| Пуш о раунде | `*::notify*RoundGenerated` | `push_notification_service` |

⚠️ **Две отдельные реализации места** — `getUserPlace` (своё/архив) и
`getTournamentPlace` (чужой профиль из рейтинга). Если правишь логику места — правь обе.

---

## 5. Коммиты

### Бэкенд (`goldkazyna/padel`)
```
73c7a20 фундамент (миграция, модели, RoundRobinService, Tournament)
ba847b7 веб-проведение (RoundRobinController, роуты, диспетчеры, вью, форма)
8d79fd9 fix 500 на странице турнира (сервис резолвить внутри show)
62c9656 mobile API создания — round_robin в enum
708e5b9 короткая метка типа «Round Robin» в тегах
30f6103 mobile проведение (MobileAdminTournamentDetailController + роут счёта)
7a0513b live-просмотр (liveRoundRobin) + место в истории (getUserPlace)
cbecc1e пуш о генерации раунда из мобилы (KOC + RR), единые обёртки notify*
d384a3e место RR в истории чужого профиля (getTournamentPlace)
d0f8d44 нерейтинговый RR в истории чужого профиля (roundRobinPlayers в whereHas)
```

### Фронтенд (`goldkazyna/padell_app`)
```
0189a28 карточка типа Round Robin в мобильном создании
8e5ef61 тег типа не переполняет строку (Flexible + ellipsis)
d0ab8c7 мобильное проведение (saveRoundRobinScore + ветка isRoundRobin)
af24f3c таблица в админке по веб-параметрам (В·П·З·ПР·±)
fe50447 сворачивание завершённых раундов
e0787cf live-экран для игроков (маршрут на экран Король корта)
9800982 таблица на live-экране по админ-параметрам (В·П·З·ПР·±)
bb6dae8 тап по «Live турнир» на главной → live-экран
1d1b4cf пуш о генерации раунда → live-экран
4021d80 тап по RR-турниру в чужом профиле → live-экран
```

---

## 6. Деплой

**Бэкенд (прод):**
```bash
cd ~/padel
git pull origin main
# миграция (один раз, при первом деплое RR):
php artisan migrate --path=database/migrations/2026_06_11_000003_create_round_robin_tables.php --force
php artisan optimize:clear
```
На проде колонка `verified_only` уже есть, поэтому `round_robin_schedule … after
verified_only` отрабатывает корректно.

**Фронтенд:** пересборка APK (`flutter build apk --release`) — по явной просьбе.

---

## 7. Как протестировать (полный цикл)

1. Создать турнир тип Round Robin, макс. участников 8 (или 12, кратно 4).
2. Набрать 8 игроков (в админке кнопка «+Тест игроки»), «Начать турнир».
3. Вводить счёт по тапу (ничью не примет). Когда раунд доигран — «Следующий раунд».
4. После любого доигранного раунда — «Завершить турнир».
5. Проверки на мобиле игроком: главная → «Live турнир» (тап → корт/счёт/таблица);
   пуш о раунде (тап → live); рейтинг → чужой профиль → история с местом (тап → live).

Таблица везде одинаковая: **В · П · З · ПР · ±** (победы, поражения, забито геймов,
пропущено, разница).

---

## 8. Известные нюансы / возможные доработки

- **Спектаторские результаты завершённого RR** идут через `live()` (как у KoC), а НЕ
  через `results()`/`getLeaderboard()` — эти методы round_robin НЕ поддерживают
  (намеренно, по образцу Король корта). Если понадобится отдельный results-экран — надо
  будет добавить round_robin в `getLeaderboard`/`getPlayerBasedMatches`/`initPlayerRatings`.
- **8-й раунд и далее** — расписание зацикливается (второй круг, появятся повторы пар).
  Заложено по спеке; UI-предупреждения «начинается второй круг» нет.
- **Сворачивание раундов** сделано только для round_robin (у Американо раунды без
  статуса «идёт» свернулись бы все). Для Король корта — можно добавить по аналогии.
- **Live-экран для игроков** — это переиспользованный экран Король корта. Если захотят
  отдельный экран/дизайн именно для RR — это отдельная работа.
- **`americano_flex`** на главной (карточка «Live турнир») и в чужом профиле тоже
  местами падает в общий путь — не связано с RR, но рядом.
