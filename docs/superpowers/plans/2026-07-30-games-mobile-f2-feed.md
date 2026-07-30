# Games Mobile — F2 (Лента игр: GamesScreen) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`).

**Goal:** Экран «Игры» с вкладками «Открытые» и «Мои», карточкой игры, входом из home services-grid, и переходом на детали. Зеркало `challenges_screen.dart`.

**Architecture:** `GamesScreen` (StatefulWidget) читает `GameProvider` (F1). Карточка — `GameCard`. Минимальные заглушки `CreateGameScreen`/`GameDetailScreen` (наполнят F3/F4), чтобы навигация и `flutter analyze` работали.

**Tech Stack:** Flutter, provider, AppTheme, AppLocalizations (ru/en/kk), showAppAlert, AppBackButton.

## Global Constraints
- Все строки — через `AppLocalizations` с префиксом `game*` (добавлять ключ во ВСЕ три arb: `lib/l10n/app_ru.arb`, `app_en.arb`, `app_kk.arb`), затем `flutter gen-l10n`. Хардкод пользовательских строк запрещён.
- Цвета — только `AppTheme.accent`/`orange`/насыщенный `const Color(0xFF7C3AED)`; бледный `AppTheme.purple` не использовать. Границы карточек — `const Color(0xFF2A3330)` width 0.5.
- Иконки — только `Icons.*` (моно). Назад — `AppBackButton`. Ошибки/алерты — `showAppAlert`.
- `flutter analyze` — 0 issues на изменённых файлах. НЕ пушить.

---

### Task 1: Заглушки экранов + виджет GameCard

**Files:**
- Create: `lib/screens/game_detail_screen.dart` (заглушка)
- Create: `lib/screens/create_game_screen.dart` (заглушка)
- Create: `lib/widgets/games/game_card.dart`
- Modify: `lib/l10n/app_ru.arb`, `app_en.arb`, `app_kk.arb` (ключи для карточки)

**Interfaces:**
- Produces:
  - `class GameDetailScreen extends StatelessWidget { final int gameId; const GameDetailScreen({super.key, required this.gameId}); }` — заглушка: `Scaffold(backgroundColor: AppTheme.background)` + header (`AppBackButton` + заголовок `AppLocalizations...gameDetailTitle`) + центр `Text(gameSoon)` («Скоро»). F4 наполнит.
  - `class CreateGameScreen extends StatelessWidget { const CreateGameScreen({super.key}); }` — аналогичная заглушка с заголовком `gameCreateTitle`.
  - `class GameCard extends StatelessWidget { final Game game; final VoidCallback onTap; }` — карточка списка по образцу `lib/widgets/challenges/challenge_card.dart`: имя клуба или `gameTitleFallback`, бейдж типа (rated=accent «gameTypeRated» / friendly=orange «gameTypeFriendly»), бейдж формата (sets/points/americano → `gameFormatSets/Points/Americano`, цвет `const Color(0xFF7C3AED)`), мета-строки (клуб/адрес, дата-время, уровень через `game.levelText`), ряд слотов (`game.capacity` кружков: занятые = инициалы/аватар из `game.players` со статусом accepted по позиции, свободные = `Icons.add` в пунктирном контейнере), правый action-чип: «gameJoinSlot» (accent) если есть свободные позиции и не участник, иначе «gameDetails» (outline). Тап по карточке → `onTap`.

- [ ] **Step 1: Реализовать** — создать заглушки и `GameCard` (прочитать `challenge_card.dart` как образец). Добавить l10n-ключи во все три arb: `gameDetailTitle`, `gameCreateTitle`, `gameSoon`, `gameTitleFallback`, `gameTypeRated`, `gameTypeFriendly`, `gameFormatSets`, `gameFormatPoints`, `gameFormatAmericano`, `gameJoinSlot`, `gameDetails` (RU + перевод EN + KK). Запустить `flutter gen-l10n`.
- [ ] **Step 2: Проверка** — `flutter analyze lib/screens/game_detail_screen.dart lib/screens/create_game_screen.dart lib/widgets/games/game_card.dart` → No issues.
- [ ] **Step 3: Commit**
```bash
git add lib/screens/game_detail_screen.dart lib/screens/create_game_screen.dart lib/widgets/games/game_card.dart lib/l10n/app_ru.arb lib/l10n/app_en.arb lib/l10n/app_kk.arb lib/l10n/app_localizations*.dart
git commit -m "feat(games): заглушки экранов + карточка игры (F2)"
```

---

### Task 2: GamesScreen (вкладки Открытые/Мои) + вход из services-grid

**Files:**
- Create: `lib/screens/games_screen.dart`
- Modify: `lib/widgets/home/services_block.dart` (перенаправить `serviceGames` → `GamesScreen`, `serviceCreateGame` → `CreateGameScreen`)
- Modify: `lib/l10n/app_ru.arb`, `app_en.arb`, `app_kk.arb` (ключи экрана)

**Interfaces:**
- Consumes: `GameProvider` (F1), `GameCard` + `GameDetailScreen` + `CreateGameScreen` (Task 1).
- Produces:
  - `class GamesScreen extends StatefulWidget` — по образцу `challenges_screen.dart`: `initState` → `addPostFrameCallback` → `context.read<GameProvider>().loadFeed(); loadMyGames();`. Layout: `Scaffold(AppTheme.background)` → `SafeArea` → header (`AppBackButton` + `gameScreenTitle`) → `DefaultTabController(length:2)` кастомный `TabBar` (indicator `AppTheme.accent`) вкладки `gameOpenTab`/`gameMyTab` → `Expanded(TabBarView([_OpenTab, _MyTab]))`. Кастомный FAB (GestureDetector+Container 56×56, accent, `Icons.add`) → `Navigator.push(... CreateGameScreen())`.
  - Каждая вкладка — `Consumer<GameProvider>`: спиннер (`CircularProgressIndicator(color: AppTheme.accent)`) при загрузке; пустой текст (`gameEmptyOpen`/`gameEmptyMy`) если список пуст; иначе `RefreshIndicator` + `ListView.separated` из `GameCard(game: g, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GameDetailScreen(gameId: g.id))))`. Pull-to-refresh дёргает соответствующий `load*`.
  - В `services_block.dart`: заменить в тайле `serviceGames` навигацию `ChallengesScreen()` → `GamesScreen()`, а `serviceCreateGame` `CreateChallengeScreen()` → `CreateGameScreen()` (сохранить `ensureProfileComplete(context)` guard и импортировать новые экраны).

- [ ] **Step 1: Реализовать** — создать `games_screen.dart`; добавить l10n-ключи `gameScreenTitle`, `gameOpenTab`, `gameMyTab`, `gameEmptyOpen`, `gameEmptyMy` во все три arb; `flutter gen-l10n`; перенаправить тайлы в `services_block.dart`.
- [ ] **Step 2: Проверка** — `flutter analyze lib/screens/games_screen.dart lib/widgets/home/services_block.dart` → No issues.
- [ ] **Step 3: Commit**
```bash
git add lib/screens/games_screen.dart lib/widgets/home/services_block.dart lib/l10n/app_ru.arb lib/l10n/app_en.arb lib/l10n/app_kk.arb lib/l10n/app_localizations*.dart
git commit -m "feat(games): экран ленты игр + вход из услуг (F2)"
```

---

## Порядок выполнения
Task 1 (заглушки+карточка) → 2 (экран+вход).

## Не входит
F3 создание; F4 детали/лобби; F5 счёт/финал; F6 инбокс.
