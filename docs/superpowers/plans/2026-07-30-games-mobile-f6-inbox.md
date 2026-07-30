# Games Mobile — F6 (Инбокс приглашений: GameInvitationsScreen) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`).

**Goal:** Экран «Приглашения в игры»: список pending-приглашений текущего пользователя с быстрым принять/отклонить и переходом в детали. Вход — иконка в шапке `GamesScreen`.

**Architecture:** Новый `GameInvitationsScreen` читает `GameProvider.loadInvitations()` (F1) + действия `accept/decline`. Одна задача.

**Tech Stack:** Flutter, provider, AppTheme, AppLocalizations (ru/en/kk), showAppAlert, AppBackButton.

## Global Constraints
- Все строки — `AppLocalizations` `game*` (ru/en/kk)+gen-l10n. Цвета accent/orange/`0xFF7C3AED`; границы `0xFF2A3330`; иконки `Icons.*`; алерты `showAppAlert`; назад `AppBackButton`.
- `flutter analyze` 0 issues. НЕ пушить.

---

### Task 1: GameInvitationsScreen + вход из GamesScreen

**Files:**
- Create: `lib/screens/game_invitations_screen.dart`
- Modify: `lib/screens/games_screen.dart` (иконка-инбокс в шапке → переход)
- Modify: 3 arb

**Interfaces:**
- Consumes: `GameProvider` (`loadInvitations({status})`, getter `invitations` (List<GameInvitationItem>), `isLoadingDetail`? — использовать отдельный флаг если есть, иначе локальный; `accept(id)`, `decline(id)`), модели `GameInvitationItem` (invitationId, status, expiresAt, inviterId, inviterName, game:Game).
- Produces:
  - `GameInvitationsScreen` (StatefulWidget): `initState` postFrame → `context.read<GameProvider>().loadInvitations()`. Scaffold(AppTheme.background) → SafeArea → header (`AppBackButton` + `gameInvitationsTitle`) → `Consumer<GameProvider>`: спиннер при загрузке; пусто → `gameInvitationsEmpty`; иначе `RefreshIndicator(loadInvitations)` + `ListView.separated` карточек.
  - Карточка приглашения (Container card, border `0xFF2A3330`): кто пригласил (`gameInvitedBy` с `inviterName`), краткие данные игры (клуб `item.game.club?.name`, дата/время `item.game.dateFormatted`/`timeFormatted`, формат `item.game.formatName`), кнопки **Принять** (`accept(item.game.id)`)/**Отклонить** (`decline(item.game.id)`) и тап по карточке → `Navigator.push(GameDetailScreen(gameId: item.game.id))`. После успешного accept/decline — `loadInvitations()` перезагрузить; при !success — `showAppAlert(msg, isError:true)`.
  - В `games_screen.dart`: в шапку (рядом с заголовком, справа) добавить круглую иконку `Icons.mail_outline` (стиль как AppBackButton 34×34) → `Navigator.push(context, MaterialPageRoute(builder: (_) => const GameInvitationsScreen()))`.

- [ ] **Step 1: Реализовать** — создать экран; добавить иконку входа в `games_screen.dart`; l10n-ключи (ниже) в 3 arb + gen-l10n. Образец списка/refresh — `games_screen.dart`/`challenges_screen.dart`.
- [ ] **Step 2: Проверка** — `flutter analyze lib/screens/game_invitations_screen.dart lib/screens/games_screen.dart` → No issues.
- [ ] **Step 3: Commit**
```bash
git add lib/screens/game_invitations_screen.dart lib/screens/games_screen.dart lib/l10n/app_ru.arb lib/l10n/app_en.arb lib/l10n/app_kk.arb lib/l10n/app_localizations*.dart
git commit -m "feat(games): инбокс приглашений (F6)"
```

**l10n (RU;+EN+KK):** `gameInvitationsTitle`("Приглашения"), `gameInvitationsEmpty`("Нет приглашений"), `gameInvitedBy`("Пригласил: {name}") [ICU name:String]. (Переиспользовать `gameActionAccept`/`gameActionDecline`/`gameFormat*` из прошлых слайсов.)

---

## Порядок выполнения
Одна задача.

## Не входит
Передача прав и журнал действий — отдельной уборкой позже (бэкенд готов, UI опционален).
