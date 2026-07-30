# Games Mobile — F4 (Лобби/детали игры: GameDetailScreen) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`).

**Goal:** Экран деталей игры: инфо + список участников + ссылка-приглашение (view), и полный набор действий лобби (принять/отклонить/заявка/выйти/одобрить-отклонить кандидата/пригласить/старт/отмена старта/поделиться-ссылкой). Счёт/финал — F5.

**Architecture:** Заменяем заглушку `game_detail_screen.dart` (StatefulWidget). Данные+действия — `GameProvider` (F1). Образец — `challenge_detail_screen.dart`.

**Tech Stack:** Flutter, provider, AppTheme, AppLocalizations (ru/en/kk), showAppAlert, AppBackButton.

## Модель статусов/действий (state machine кнопок)
`game.myStatus` (invited/candidate/accepted/…), `game.isParticipant`, `game.isCreator (== is_creator)`, `game.status` (open/full/in_progress/finished/…):
- `myStatus == 'invited'` → **Принять** / **Отклонить**.
- не участник, `status == open`, есть свободные позиции → **Подать заявку** (apply).
- `myStatus == 'candidate'` → бейдж «Заявка отправлена» (без кнопки).
- участник (accepted), не организатор, статус не finished → **Выйти**.
- организатор:
  - есть кандидаты (players со статусом candidate) → у каждого инлайн **✓ одобрить** / **✕ отклонить**.
  - есть accepted (кроме себя) → у каждого **удалить**.
  - **Пригласить** (телефон-поиск → invite по user_id).
  - `status == full` → **Начать игру** (start); `status == in_progress` && !score_locked → **Отменить старт** (start/cancel).
  - **Поделиться ссылкой** (share): показать `share_token`/активность, **обновить** (rotate) / **отозвать** (revoke).

## Global Constraints
- Все строки — `AppLocalizations` `game*` (ru/en/kk) + gen-l10n. Хардкод запрещён.
- Цвета — `AppTheme.accent`/`orange`/`const Color(0xFF7C3AED)`. Границы `const Color(0xFF2A3330)`. Иконки `Icons.*`. Алерты — `showAppAlert`. Назад — `AppBackButton`.
- Все действия через провайдер, результат `({success,message})` → при !success `showAppAlert(msg, isError:true)`; при success провайдер уже обновил `_currentGame` (перерисовка через Consumer). Выход/успешные — можно `showAppAlert` с текстом.
- `flutter analyze` 0 issues. НЕ пушить. Кастомные кнопки (GestureDetector+Container).

---

### Task 1: GameDetailScreen — отображение (детали + участники + ссылка)

**Files:**
- Rewrite: `lib/screens/game_detail_screen.dart` (заглушку → view со стейтом загрузки)
- Create: `lib/widgets/games/game_players_list.dart` (список участников)
- Modify: 3 arb

**Interfaces:**
- Consumes: `GameProvider` (`loadDetails(id)`, `currentGame`, `isLoadingDetail`, `clearCurrentGame`), модели Game/GamePlayer.
- Produces:
  - `GameDetailScreen` (StatefulWidget, `{required int gameId}`): `initState` → postFrame `loadDetails(gameId)`; `dispose` → `clearCurrentGame()` (как challenge). `Consumer<GameProvider>` с ветками loading / not-found / loaded, каждая с header (`AppBackButton` + `gameDetailTitle`).
  - Loaded (SingleChildScrollView + RefreshIndicator(loadDetails)):
    1. Статус-бейдж (цвет по статусу: open=accent, full=orange, in_progress=`0xFF7C3AED`, finished=textSecondary, cancelled=error) + `game.statusName`.
    2. Инфо-карточка: дата/время (`game.dateFormatted`/`timeFormatted`), клуб, формат (`game.formatName`), тип (`game.typeName`), диапазон уровня (`game.levelText`), цена (если есть), описание (если есть).
    3. `GamePlayersList(game: game)` — участники.
    4. Ссылка-приглашение (только организатор): секция с `game.shareToken`/`game.shareActive` — здесь только отображение (кнопки rotate/revoke — Task 2).
    (Кнопки действий — Task 2, добавятся ниже по дереву.)
  - `GamePlayersList` (StatelessWidget `{required Game game}`): карточка со списком слотов 1..capacity. Для занятой позиции — строка: аватар (инлайн network+инициалы), имя (`fullName`), уровень/рейтинг (`RatingFormatter`), бейдж статуса (accepted=accent, candidate=orange «заявка», invited=textSecondary «приглашён»), пометка «вы» если `isMe`. Свободная позиция — «свободно». (Инлайн-кнопки одобрения/удаления/приглашения — Task 2 добавит через колбэки; в Task 1 виджет только отображает; предусмотреть опциональные колбэки `onApprove/onReject/onRemove/onInviteSlot`, по умолчанию null → кнопки не показываются.)

- [ ] **Step 1: Реализовать** — переписать `game_detail_screen.dart` (view), создать `game_players_list.dart`; l10n-ключи (см. ниже) в 3 arb + gen-l10n. Прочитать `challenge_detail_screen.dart` как образец веток загрузки/статус-бейджа/инфо-карточки.
- [ ] **Step 2: Проверка** — `flutter analyze lib/screens/game_detail_screen.dart lib/widgets/games/game_players_list.dart` → No issues.
- [ ] **Step 3: Commit**
```bash
git add lib/screens/game_detail_screen.dart lib/widgets/games/game_players_list.dart lib/l10n/app_ru.arb lib/l10n/app_en.arb lib/l10n/app_kk.arb lib/l10n/app_localizations*.dart
git commit -m "feat(games): экран деталей — инфо и участники (F4)"
```

**l10n-ключи Task 1 (RU; +EN+KK):** `gameStatusLabel`, `gamePlayersTitle`("Участники"), `gameSlotFree`("Свободно"), `gamePlayerYou`("вы"), `gameStatusAccepted`("В составе"), `gameStatusCandidate`("Заявка"), `gameStatusInvited`("Приглашён"), `gameShareTitle`("Ссылка-приглашение"), `gameShareActive`("активна"), `gameShareInactive`("неактивна"), `gamePriceLabel`("Цена"), `gameOrganizerLabel`("Организатор"). (Переиспользовать существующие gameFormat*/gameType* из F2/F3.)

---

### Task 2: Действия лобби (кнопки + телефон-поиск + инлайн-модерация)

**Files:**
- Modify: `lib/screens/game_detail_screen.dart` (`_buildActions`, invite bottom-sheet, share-кнопки)
- Modify: `lib/widgets/games/game_players_list.dart` (прокинуть колбэки одобрить/отклонить/удалить/пригласить-слот)
- Modify: 3 arb

**Interfaces:**
- Consumes: `GameProvider` действия — `accept/decline/apply/leave/approve/reject/removePlayer/invite/start/startCancel/shareRotate/shareRevoke/searchPartner` (все возвращают `({success,message})`, `searchPartner` — список).
- Produces:
  - `_buildActions(Game game)` внизу loaded-дерева — state machine из раздела выше; каждая кнопка вызывает соответствующий метод провайдера, при !success → `showAppAlert(msg, isError:true)`; для `leave`/успешного выхода — после успеха `Navigator.pop`. Кнопки — кастомные, дизейбл+спиннер при `provider.isActionLoading`.
  - Invite bottom-sheet: `showModalBottomSheet` (AppTheme.card) с полем телефона (digits, debounce как в challenge — можно проще: кнопка «найти»), список из `searchPartner(phone)` (элементы — Map с id/name/level), тап → `invite(game.id, userId)` → закрыть шит, showAppAlert.
  - Инлайн в `GamePlayersList`: если текущий пользователь организатор и передан колбэк — у candidate-строк «✓/✕» (approve/reject по `player.id`), у accepted-строк (кроме self) «удалить» (removePlayer по `player.id`), у свободного слота «Пригласить» (открывает тот же шит). `player.id` = user id? ВНИМАНИЕ: бэкенд approve/reject/remove принимают `{player}` = **GamePlayer.id**, а в модели `GamePlayer.id` — это user id (маппинг из formatGame отдаёт `id => user->id`). Нужно проверить: эндпоинты `applications/{player}` и `players/{player}` ждут GamePlayer.id (первичный ключ строки), НО formatGame отдаёт `id` = user_id, не gamePlayer.id. → В Task 2 использовать `player.id` как то, что отдаёт API; если сервер ждёт gamePlayer.id, а фронт шлёт user_id — работать не будет. **РЕШЕНИЕ:** approve/reject/remove в этом слайсе передают `player.id` (то, что есть). Если при интеграции 404 — согласовать с бэком (возможно, потребуется отдавать player_row_id в formatGame). Пометить как риск в отчёте.
  - Share-кнопки (организатор): «обновить ссылку» (shareRotate) / «отозвать» (shareRevoke); показать/скопировать `share_token` (копирование — `Clipboard.setData`).

- [ ] **Step 1: Реализовать** — добавить действия. l10n-ключи (ниже) в 3 arb + gen-l10n. Образец кнопок/шита — `challenge_detail_screen.dart` + invite-шит из `create_challenge_screen.dart`.
- [ ] **Step 2: Проверка** — `flutter analyze lib/screens/game_detail_screen.dart lib/widgets/games/game_players_list.dart` → No issues.
- [ ] **Step 3: Commit**
```bash
git add lib/screens/game_detail_screen.dart lib/widgets/games/game_players_list.dart lib/l10n/app_ru.arb lib/l10n/app_en.arb lib/l10n/app_kk.arb lib/l10n/app_localizations*.dart
git commit -m "feat(games): действия лобби — вступление/модерация/старт/ссылка (F4)"
```

**l10n-ключи Task 2 (RU; +EN+KK):** `gameActionAccept`("Принять"), `gameActionDecline`("Отклонить"), `gameActionApply`("Подать заявку"), `gameApplied`("Заявка отправлена"), `gameActionLeave`("Выйти"), `gameActionStart`("Начать игру"), `gameActionStartCancel`("Отменить старт"), `gameActionInvite`("Пригласить"), `gameActionApprove`("Одобрить"), `gameActionReject`("Отклонить"), `gameActionRemove`("Удалить"), `gameShareRotate`("Обновить ссылку"), `gameShareRevoke`("Отозвать"), `gameShareCopied`("Ссылка скопирована"), `gameInviteSearchHint`("Телефон игрока"), `gameInviteSearchBtn`("Найти"), `gameInviteEmpty`("Никого не найдено"), `gameLeaveConfirm`("Выйти из игры?").

---

## Порядок выполнения
Task 1 (view) → 2 (действия).

## Не входит
F5 счёт/раунды/финал/подтверждение/рейтинг; F6 инбокс; передача прав и журнал — отдельной уборкой позже.
