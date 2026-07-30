# Games Mobile — F5 (Счёт, финал, подтверждение, рейтинг) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`).

**Goal:** Ввод счёта по раундам (sets/points/американо), завершение с подтверждением участниками, итог с личным ранжированием Американо и изменением рейтинга (ELO). Всё внутри `GameDetailScreen`.

**Architecture:** Виджет `GameRoundsSection` (раунды+ввод) + результат-секция в `game_detail_screen.dart`. Данные/действия — `GameProvider` (addRound/updateRound/deleteRound/regenerate/finish/confirmScore).

**Tech Stack:** Flutter, provider, AppTheme, AppLocalizations (ru/en/kk), showAppAlert.

## Модель отображения по статусу
- `in_progress && !scoreLocked` → **фаза счёта**: показать раунды; организатору — редактируемо.
  - Американо: раунды авто-сгенерированы при старте. Организатор правит счёт каждого раунда (inline); кнопка **Перегенерировать** (если ни один раунд не сыгран).
  - Sets/Points: организатор **Добавить раунд** (выбор команды A из 4 принятых + счёт) → addRound; правка/удаление раунда.
  - Организатору кнопка **Завершить** (если ≥1 сыгранный раунд) — реализуется в Task 2.
- `in_progress && scoreLocked` → **фаза подтверждения** (Task 2): раунды read-only + статус подтверждения + кнопка «Подтверждаю счёт».
- `finished` → **итог** (Task 2): раунды read-only + таблица ранжирования Американо (если americano) + изменение рейтинга (ELO) на игрока.

## Раунд (модель GameRound): `pairA/pairB` (List<int> user_id), `scoreA/scoreB` (int?), `isPlayed`.
Игрока по user_id находить в `game.players` (по `id`).

## Global Constraints
- Все строки — `AppLocalizations` `game*` (ru/en/kk)+gen-l10n. Хардкод запрещён.
- Числа счёта слать как **int** (int.tryParse). Цвета — `AppTheme.accent`/`orange`/`0xFF7C3AED`; границы `0xFF2A3330`. Иконки `Icons.*`. Алерты `showAppAlert`.
- `flutter analyze` 0 issues. НЕ пушить.

---

### Task 1: GameRoundsSection — отображение и ввод счёта

**Files:**
- Create: `lib/widgets/games/game_rounds_section.dart`
- Modify: `lib/screens/game_detail_screen.dart` (вставить секцию при статусе in_progress/finished/scoreLocked)
- Modify: 3 arb

**Interfaces:**
- Consumes: `GameProvider` (`addRound(id,body)`, `updateRound(id,roundId,body)`, `deleteRound(id,roundId)`, `regenerate(id)`, `isActionLoading`), модели Game/GameRound/GamePlayer.
- Produces:
  - `class GameRoundsSection extends StatelessWidget { final Game game; const GameRoundsSection({super.key, required this.game}); }`. Внутри — `context.read<GameProvider>()` для действий; редактируемость = `game.isCreator && game.isInProgress && !game.scoreLocked`.
  - Отображение каждого раунда (карточка `0xFF2A3330`): «Раунд {n}», строка команды A (имена игроков pairA через `game.players`), счёт, строка команды B; выигравшая сторона — лёгкий accent-тон. Заголовок секции `gameRoundsTitle`.
  - Редактируемо:
    - Американо: у каждого раунда два числовых поля (score_a/score_b) + кнопка «Сохранить» → `updateRound(game.id, round.id, {'score_a': a, 'score_b': b})` (пары не шлём — сервер сохраняет существующие). Кнопка секции **Перегенерировать** (`gameRegenerate`) видна если `game.isAmericano` и ни один раунд не `isPlayed` → `regenerate(game.id)`.
    - Sets/Points: кнопка **Добавить раунд** (`gameAddRound`) → `showModalBottomSheet`: выбрать 2 игроков в команду A (тап по чипам 4 принятых игроков; остальные 2 → команда B, показать превью), поля score_a/score_b → `addRound(game.id, {'pair_a': [idA1,idA2], 'pair_b': [idB1,idB2], 'score_a': a, 'score_b': b})`. У каждого раунда — иконка удаления → `deleteRound(game.id, round.id)`.
    - Ошибка любого действия → `showAppAlert(result.message, isError:true)`.
  - В `game_detail_screen.dart`: вставить `GameRoundsSection(game: game)` в loaded-дерево когда `game.isInProgress || game.isFinished || game.scoreLocked` (между участниками и кнопками действий).

- [ ] **Step 1: Реализовать** — создать виджет; интегрировать; l10n-ключи (ниже) в 3 arb + gen-l10n.
- [ ] **Step 2: Проверка** — `flutter analyze lib/widgets/games/game_rounds_section.dart lib/screens/game_detail_screen.dart` → No issues.
- [ ] **Step 3: Commit**
```bash
git add lib/widgets/games/game_rounds_section.dart lib/screens/game_detail_screen.dart lib/l10n/app_ru.arb lib/l10n/app_en.arb lib/l10n/app_kk.arb lib/l10n/app_localizations*.dart
git commit -m "feat(games): раунды и ввод счёта (F5)"
```

**l10n Task 1 (RU;+EN+KK):** `gameRoundsTitle`("Счёт по раундам"), `gameRoundNo`("Раунд {n}") [ICU n:int], `gameTeamA`("Команда A"), `gameTeamB`("Команда B"), `gameAddRound`("Добавить раунд"), `gameRegenerate`("Перегенерировать"), `gameRoundSave`("Сохранить"), `gameRoundScoreA`("Счёт A"), `gameRoundScoreB`("Счёт B"), `gamePickTeamA`("Выберите команду A (2 игрока)"), `gameRoundDeleteConfirm`("Удалить раунд?").

---

### Task 2: Финал, подтверждение счёта, итог (ранжирование + ELO)

**Files:**
- Modify: `lib/screens/game_detail_screen.dart` (кнопка Завершить + фаза подтверждения + итог)
- Create: `lib/widgets/games/game_result_section.dart` (итог: ранжирование + ELO)
- Modify: 3 arb

**Interfaces:**
- Consumes: `GameProvider` (`finish(id)`, `confirmScore(id)`), модели Game (rounds, players, americanoRanking, myScoreConfirmed, scoreLocked), GamePlayer (scoreConfirmed, ratingChange), GameRankingRow (userId, points, wins, diff, place).
- Produces:
  - Кнопка **Завершить** (`gameActionFinish`) в `_buildActions`: видна если `game.isCreator && game.isInProgress && !game.scoreLocked && game.rounds.any((r)=>r.isPlayed)` → confirm dialog → `finish(game.id)`.
  - Фаза подтверждения (`game.isInProgress && game.scoreLocked`): секция `gameConfirmTitle` — список принятых игроков с галочкой `scoreConfirmed` (accent ✓ / серый), и кнопка **Подтверждаю счёт** (`gameConfirmBtn`) если `game.myStatus=='accepted' && !game.myScoreConfirmed` → `confirmScore(game.id)`.
  - `GameResultSection(game)` — при `game.isFinished`: если `game.isAmericano && game.americanoRanking.isNotEmpty` → таблица мест (место, имя по userId из players, очки, победы, разница); плюс для всех форматов — список игроков с `ratingChange` (если != null): «+N»/«−N» зелёным/красным (`gameRatingChange`). Вставить в дерево при `isFinished`.
  - Ошибки → `showAppAlert`.

- [ ] **Step 1: Реализовать** — добавить финал/подтверждение/итог; l10n-ключи (ниже) в 3 arb + gen-l10n.
- [ ] **Step 2: Проверка** — `flutter analyze lib/screens/game_detail_screen.dart lib/widgets/games/game_result_section.dart` → No issues.
- [ ] **Step 3: Commit**
```bash
git add lib/screens/game_detail_screen.dart lib/widgets/games/game_result_section.dart lib/l10n/app_ru.arb lib/l10n/app_en.arb lib/l10n/app_kk.arb lib/l10n/app_localizations*.dart
git commit -m "feat(games): финал, подтверждение счёта, итог с рейтингом (F5)"
```

**l10n Task 2 (RU;+EN+KK):** `gameActionFinish`("Завершить"), `gameFinishConfirm`("Завершить игру и зафиксировать счёт?"), `gameConfirmTitle`("Подтверждение счёта"), `gameConfirmBtn`("Подтверждаю счёт"), `gameConfirmed`("подтвердил"), `gameNotConfirmed`("ожидает"), `gameResultTitle`("Итог"), `gameRankingTitle`("Ранжирование"), `gameRankPlace`("Место"), `gameRankPoints`("Очки"), `gameRankWins`("Победы"), `gameRatingChange`("Рейтинг"), `gameResultPlace`("{place} место") [ICU place:int].

---

## Порядок выполнения
Task 1 (раунды+счёт) → 2 (финал+подтверждение+итог).

## Не входит
F6 инбокс приглашений; передача прав/журнал — уборкой позже.
