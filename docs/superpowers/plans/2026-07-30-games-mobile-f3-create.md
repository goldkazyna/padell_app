# Games Mobile — F3 (Экран создания игры: CreateGameScreen) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`).

**Goal:** Полноценная форма создания игры (клуб/дата-время/длительность/тип/приватность/формат+параметры/диапазон рейтинга/цена/описание) → POST, переход в детали созданной игры.

**Architecture:** Заменяем заглушку `lib/screens/create_game_screen.dart` реальной формой (StatefulWidget) по образцу `create_challenge_screen.dart`. Данные — `GameProvider.createGame(data)` (F1).

**Tech Stack:** Flutter, provider, AppTheme, AppLocalizations (ru/en/kk), showAppAlert, AppBackButton, showDatePicker/showTimePicker.

## Контракт POST /games (бэкенд)
Обязательные: `club_id`(exists), `starts_at`(ISO, > now), `ends_at`(ISO, > starts_at), `type`(rated|friendly), `visibility`(public|private), `format`(sets|points|americano).
Опциональные: `court_id`, `format_meta`(Map), `rating_min`/`rating_max`(1..5.75, max ≥ min), `price`(int ≥0), `description`(≤1000).
**format_meta по формату (числа — строго int!):**
- `sets`: опц. `{tiebreak: bool}`.
- `points`: `{points_mode: 'first_to'|'total'}` обяз.; для `first_to` — `points_target`(int≥1); опц. `points_cap`(int≥1).
- `americano`: `{sub: 'by_sets'|'by_tiebreak'|'by_points', target: int≥1}` обяз.
`capacity` не шлём (бэк ставит 4).

## Global Constraints
- Все строки — `AppLocalizations` `game*` (ru/en/kk) + `flutter gen-l10n`. Хардкод запрещён.
- Цвета — только `AppTheme.accent`/`orange`/`const Color(0xFF7C3AED)`. Границы — `const Color(0xFF2A3330)`. Иконки — `Icons.*`. Алерты — `showAppAlert`. Назад — `AppBackButton`.
- Числа format_meta слать как `int` (не строки): `int.tryParse(...)`.
- `flutter analyze` — 0 issues. НЕ пушить. Кнопки — кастомные `GestureDetector`+`Container` как в create_challenge_screen.

---

### Task 1: Форма CreateGameScreen

**Files:**
- Rewrite: `lib/screens/create_game_screen.dart` (заглушку → форму)
- Modify: `lib/l10n/app_ru.arb`, `app_en.arb`, `app_kk.arb`

**Interfaces:**
- Consumes: `GameProvider` (`loadClubs()`, `clubs`, `createGame(Map) → ({bool success, String message, Game? game})`), `AuthProvider` (для guard уже есть), `GameClub`.
- Produces: `class CreateGameScreen extends StatefulWidget { const CreateGameScreen({super.key}); }` — форма со стейтом и сабмитом.

**Состояние формы:**
- `GameClub? _club` (dropdown из `provider.clubs`; грузить в initState через `loadClubs()`).
- `DateTime? _date`, `TimeOfDay? _time` (showDatePicker/showTimePicker, тема `ColorScheme.dark(primary: AppTheme.accent, surface: AppTheme.card)` как в challenge).
- `int _durationMin = 90` (чипы 60/90/120).
- `String _type = 'rated'` (сегмент rated/friendly).
- `String _visibility = 'public'` (сегмент public/private).
- `String _format = 'sets'` (селектор sets/points/americano).
- format_meta стейт: `bool _tiebreak = false` (sets); `String _pointsMode = 'first_to'`, `int? _pointsTarget`, `int? _pointsCap` (points); `String _amSub = 'by_points'`, `int? _amTarget` (americano). Числовые — через `TextEditingController` + `int.tryParse`.
- `double? _ratingMin`, `_ratingMax` (опц. dropdown уровней из списка `[1.0,1.25,…,5.75]`; допускается «не задано»).
- `int? _price` (опц. TextField, digits), `String _description` (опц. TextField multiline, maxLength 1000).
- `bool _isCreating`.

**Сабмит `_create()`:**
1. Валидация на клиенте: клуб/дата/время заданы; для points при first_to — target задан; для americano — sub+target заданы. Иначе `showAppAlert(context, <локализованная ошибка>)`.
2. `starts_at = DateTime(_date.year,…,_time.hour,_time.minute)`; `ends_at = starts_at.add(Duration(minutes: _durationMin))`.
3. Собрать `format_meta`: sets → `{if _tiebreak} {'tiebreak': true}` (или null если false — можно слать `{'tiebreak': _tiebreak}`); points → `{'points_mode': _pointsMode, if first_to 'points_target': _pointsTarget, if _pointsCap!=null 'points_cap': _pointsCap}`; americano → `{'sub': _amSub, 'target': _amTarget}`.
4. `data = {'club_id': _club!.id, 'starts_at': starts.toIso8601String(), 'ends_at': ends.toIso8601String(), 'type': _type, 'visibility': _visibility, 'format': _format, if formatMeta!=null 'format_meta': formatMeta, if _ratingMin!=null 'rating_min': _ratingMin, if _ratingMax!=null 'rating_max': _ratingMax, if _price!=null 'price': _price, if desc nonEmpty 'description': _description}`.
5. `setState _isCreating=true`; `final r = await context.read<GameProvider>().createGame(data)`; если `r.success && r.game!=null` → `Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameDetailScreen(gameId: r.game!.id)))`; иначе `showAppAlert(context, r.message, isError: true)`. `_isCreating=false`.

**Layout:** `Scaffold(AppTheme.background)` → `SafeArea` → header (`AppBackButton` + `gameCreateTitle`) → `Expanded(SingleChildScrollView(...секции...))` → нижняя кастомная кнопка «gameCreateSubmit» (accent, dim+спиннер при `_isCreating`). Каждая секция — подпись + контрол в `Container`(card, radius 12, border `0xFF2A3330`). Сегменты/чипы — как в приложении (выбранный = accent-заливка/бордер).

- [ ] **Step 1: Реализовать** — переписать `create_game_screen.dart` (импортировать `game_detail_screen.dart` для перехода; прочитать `create_challenge_screen.dart` как образец пикеров/дропдаунов/кнопки/боттом-шита). Добавить l10n-ключи (ниже) во все три arb + `flutter gen-l10n`.
- [ ] **Step 2: Проверка** — `flutter analyze lib/screens/create_game_screen.dart` → No issues.
- [ ] **Step 3: Commit**
```bash
git add lib/screens/create_game_screen.dart lib/l10n/app_ru.arb lib/l10n/app_en.arb lib/l10n/app_kk.arb lib/l10n/app_localizations*.dart
git commit -m "feat(games): экран создания игры (F3)"
```

**l10n-ключи (RU; добавить EN+KK):** `gameCreateSubmit`("Создать"), `gameFieldClub`("Клуб"), `gameFieldDate`("Дата"), `gameFieldTime`("Время"), `gameFieldDuration`("Длительность"), `gameFieldType`("Тип"), `gameFieldVisibility`("Видимость"), `gameVisibilityPublic`("Открытая"), `gameVisibilityPrivate`("Приватная"), `gameFieldFormat`("Формат"), `gameFieldTiebreak`("Тай-брейк"), `gamePointsMode`("Режim очков"), `gamePointsFirstTo`("До N очков"), `gamePointsTotal`("На сумму"), `gamePointsTarget`("Очков до победы"), `gamePointsCap`("Лимит очков"), `gameAmSub`("Подформат"), `gameAmBySets`("По сетам"), `gameAmByTiebreak`("По тай-брейку"), `gameAmByPoints`("По очкам"), `gameAmTarget`("Значение"), `gameFieldRatingRange`("Диапазон уровня"), `gameRatingAny`("Любой"), `gameFieldPrice`("Цена, ₸"), `gameFieldDescription`("Описание"), `gameCreateValidationError`("Заполните обязательные поля"), `gameDurationMin`("{min} мин") [ICU placeholder min:int].

---

## Порядок выполнения
Одна задача (цельная форма).

## Не входит
F4 детали/лобби; F5 счёт/финал; F6 инбокс.
