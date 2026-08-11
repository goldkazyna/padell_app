# Just Padel It — Implementation Plan (web)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Новый веб-тип турнира `just_padel_it` — полная изоляция от «Короля корта»: свои таблицы, модели, сервис, контроллер, view; движение как в KoC + бонусы за корт, посев по рейтингу с ручной правкой, итоговая таблица (очки → победы).

**Architecture:** Копируем подсистему King of Court (модели/сервис/контроллер/view) в новые файлы `JustPadelIt*` / `justpadelit`, переименовываем, затем вносим дельты: бонусные очки в начислении, посев по рейтингу + экран посева, сортировка таблицы по очкам→победам, тип в форме создания + «Тип подсчёта» (сеты неактивны). «Король корта» НЕ трогаем.

**Tech Stack:** Laravel (репозиторий `C:\projects\padel`), Blade, MySQL. PHPUnit для юнит-тестов чистой логики.

## Global Constraints
- Все правки в репозитории **`C:\projects\padel`** (веб/бэкенд). Приложение (`padel_app`) НЕ трогаем — приложение в этой фиче не участвует.
- **«Король корта» не изменяется** — только копируем из него. Ни один файл `KingOfCourt*` / `kingofcourt` / `king_of_court` не редактируем (кроме добавления нового типа в общие точки: `Tournament.php`, `TournamentController.php`, `TournamentResetService.php`, `create.blade.php`, `routes/web.php`).
- **Бэкенд коммитить и пушить сразу** после каждой задачи (правило проекта): `git push origin main`.
- Тип-строка: `just_padel_it`. Классы: `JustPadelIt*`. Таблицы/вьюхи/роуты: `just_padel_it_*` / `justpadelit` / `club.justpadelit.*`. Человекочитаемое имя: **`Just Padel It`**.
- Полный enum `tournaments.type` сейчас: `'classic','americano','mexicano','team','king_of_court','bali_koc','americano_flex','round_robin'` — новая миграция ДОЛЖНА включать их все + `'just_padel_it'`, `DEFAULT 'classic'`.
- Бонусы: победа на корте **1 → +3**, **2 → +2**, остальные → **+1**, обоим победителям.
- Итоговая таблица: сортировка **очки ↓ → победы ↓**.
- Проверка синтаксиса каждой правки: `php -l <file>`. Проверка роутов: `php artisan route:list --path=justpadelit`. Юнит-тесты: `php artisan test --filter=<name>`.

## Соглашение о переименовании (для всех «copy»-задач)
При копировании файла King of Court применять построчную замену:
- `KingOfCourt` → `JustPadelIt`
- `kingOfCourt` → `justPadelIt`
- `kingofcourt` → `justpadelit`
- `king_of_court` → `just_padel_it`
- `koc` → `jpi`
- `Король корта` → `Just Padel It`

---

## File Structure (создаётся в `C:\projects\padel`)
- `database/migrations/2026_07_05_000001_create_just_padel_it_tables.php` — таблицы players/rounds/matches/pairs.
- `database/migrations/2026_07_05_000002_add_just_padel_it_to_tournaments_type_enum.php` — enum типа.
- `app/Models/JustPadelItPlayer.php`, `JustPadelItRound.php`, `JustPadelItMatch.php`, `JustPadelItPair.php`.
- `app/Services/JustPadelItService.php`.
- `app/Http/Controllers/Club/JustPadelItController.php`.
- `resources/views/club/tournaments/justpadelit/show.blade.php`, `pairs.blade.php`, `seeding.blade.php`, `partials/_header.blade.php`, `_leaderboard.blade.php`, `_rounds.blade.php`.
- **Правки:** `app/Models/Tournament.php`, `app/Http/Controllers/Club/TournamentController.php`, `app/Services/TournamentResetService.php`, `resources/views/club/tournaments/create.blade.php`, `routes/web.php`.

---

## Task 1: Миграции — таблицы и enum типа

**Files:**
- Create: `database/migrations/2026_07_05_000001_create_just_padel_it_tables.php`
- Create: `database/migrations/2026_07_05_000002_add_just_padel_it_to_tournaments_type_enum.php`

**Interfaces:**
- Produces таблицы: `just_padel_it_players`, `just_padel_it_rounds`, `just_padel_it_matches`, `just_padel_it_pairs`; enum-значение `just_padel_it`.

- [ ] **Step 1: Скопировать миграцию таблиц KoC и переименовать**

Скопировать `database/migrations/2026_04_26_000001_create_kingofcourt_tables.php` → `database/migrations/2026_07_05_000001_create_just_padel_it_tables.php`, применить соглашение о переименовании (таблицы `kingofcourt_*` → `just_padel_it_*`, FK-колонка `kingofcourt_round_id` → `just_padel_it_round_id`, имена индексов `koc_*` → `jpi_*`). Итог — те же 3 таблицы:
- `just_padel_it_players`: `id, tournament_id (FK tournaments cascade), user_id (FK users cascade), total_points int default 0, wins int default 0, losses int default 0, points_for int default 0, points_against int default 0, rating_before int nullable, rating_after int nullable, timestamps, unique[tournament_id,user_id]`.
- `just_padel_it_rounds`: `id, tournament_id (FK cascade), round_number int, status enum['pending','in_progress','completed'] default 'pending', timestamps, unique[tournament_id,round_number], index[tournament_id,status]`.
- `just_padel_it_matches`: `id, just_padel_it_round_id (FK just_padel_it_rounds cascade), court_number int, team1_player1_id/team1_player2_id/team2_player1_id/team2_player2_id (each FK users cascade), team1_score int nullable, team2_score int nullable, status enum['pending','in_progress','completed'] default 'pending', timestamps, index just_padel_it_round_id named 'jpi_matches_round_idx'`.

И скопировать `database/migrations/2026_06_27_000001_create_kingofcourt_pairs_table.php` содержимое таблицы `kingofcourt_pairs` → добавить в ту же миграцию таблицу `just_padel_it_pairs`: `id, tournament_id (FK cascade), player1_id/player2_id (FK users cascade), timestamps, index tournament_id named 'jpi_pairs_tournament_idx'`. `down()` — dropIfExists всех 4 таблиц.

- [ ] **Step 2: Миграция enum типа**

`database/migrations/2026_07_05_000002_add_just_padel_it_to_tournaments_type_enum.php` — по образцу `2026_05_19_000001_add_americano_flex_to_tournaments_type.php`:
```php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (Schema::getConnection()->getDriverName() === 'sqlite') return;
        DB::statement("ALTER TABLE tournaments MODIFY COLUMN type ENUM('classic','americano','mexicano','team','king_of_court','bali_koc','americano_flex','round_robin','just_padel_it') DEFAULT 'classic'");
    }
    public function down(): void
    {
        if (Schema::getConnection()->getDriverName() === 'sqlite') return;
        DB::statement("ALTER TABLE tournaments MODIFY COLUMN type ENUM('classic','americano','mexicano','team','king_of_court','bali_koc','americano_flex','round_robin') DEFAULT 'classic'");
    }
};
```

- [ ] **Step 3: Синтаксис + прогон миграций**

Run: `php -l database/migrations/2026_07_05_000001_create_just_padel_it_tables.php && php -l database/migrations/2026_07_05_000002_add_just_padel_it_to_tournaments_type_enum.php`
Expected: No syntax errors.
Run (если локальная БД поднята): `php artisan migrate --path=database/migrations/2026_07_05_000001_create_just_padel_it_tables.php --path=database/migrations/2026_07_05_000002_add_just_padel_it_to_tournaments_type_enum.php`
Expected: миграции применились. (Если БД недоступна — пропустить прогон, деплой мигрирует на проде через `--path=`.)

- [ ] **Step 4: Commit + push**
```bash
git add database/migrations/2026_07_05_000001_create_just_padel_it_tables.php database/migrations/2026_07_05_000002_add_just_padel_it_to_tournaments_type_enum.php
git commit -m "feat(jpi): миграции — таблицы just_padel_it + тип в enum"
git push origin main
```

---

## Task 2: Модели JustPadelIt*

**Files:**
- Create: `app/Models/JustPadelItPlayer.php`, `JustPadelItRound.php`, `JustPadelItMatch.php`, `JustPadelItPair.php`

**Interfaces:**
- Produces: `JustPadelItPlayer` (fillable: tournament_id,user_id,total_points,wins,losses,points_for,points_against,rating_before,rating_after; relations tournament(), user()); `JustPadelItRound` (fillable tournament_id,round_number,status; relations tournament(), matches() hasMany JustPadelItMatch FK 'just_padel_it_round_id' orderBy court_number; helpers isCompleted/isPending/isInProgress); `JustPadelItMatch` (fillable just_padel_it_round_id,court_number,team1_player1_id,team1_player2_id,team2_player1_id,team2_player2_id,team1_score,team2_score,status; relations round() belongsTo JustPadelItRound FK 'just_padel_it_round_id', team1Player1()/team1Player2()/team2Player1()/team2Player2() belongsTo User; helpers isCompleted(): bool, getPlayersAttribute(): array, getWinningTeamAttribute(): ?int); `JustPadelItPair` (fillable tournament_id,player1_id,player2_id; relations tournament(),player1(),player2(); getDisplayNameAttribute()).

- [ ] **Step 1: Скопировать 4 модели KoC и переименовать**

Скопировать `app/Models/KingOfCourtPlayer.php`, `KingOfCourtRound.php`, `KingOfCourtMatch.php`, `KingOfCourtPair.php` → `app/Models/JustPadelItPlayer.php`, `JustPadelItRound.php`, `JustPadelItMatch.php`, `JustPadelItPair.php`, применив соглашение о переименовании. Проверить внутри:
- В `JustPadelItRound`: `matches()` использует FK `'just_padel_it_round_id'` и класс `JustPadelItMatch`.
- В `JustPadelItMatch`: `round()` использует FK `'just_padel_it_round_id'` и класс `JustPadelItRound`; таблица — по умолчанию `just_padel_it_matches` (проверить `$table`, если задан явно — переименовать).
- Таблицы: если в моделях задан `protected $table`, убедиться что теперь `just_padel_it_players/rounds/matches/pairs`.

- [ ] **Step 2: Синтаксис**

Run: `php -l app/Models/JustPadelItPlayer.php && php -l app/Models/JustPadelItRound.php && php -l app/Models/JustPadelItMatch.php && php -l app/Models/JustPadelItPair.php`
Expected: No syntax errors.

- [ ] **Step 3: Commit + push**
```bash
git add app/Models/JustPadelItPlayer.php app/Models/JustPadelItRound.php app/Models/JustPadelItMatch.php app/Models/JustPadelItPair.php
git commit -m "feat(jpi): модели JustPadelIt (копии KoC)"
git push origin main
```

---

## Task 3: Регистрация типа в модели Tournament

**Files:**
- Modify: `app/Models/Tournament.php`

**Interfaces:**
- Consumes: модели из Task 2.
- Produces: `Tournament::isJustPadelIt(): bool`, `isPairedJustPadelIt(): bool`, relations `justPadelItPlayers()/justPadelItRounds()/justPadelItPairs()`, метка типа `Just Padel It`, ветка в `firstRoundCompleted()`.

- [ ] **Step 1: Метка типа**

В `getTypeNameAttribute()` (`match($this->type)`) добавить ветку рядом с `'king_of_court' => 'Король корта',`:
```php
			'just_padel_it' => 'Just Padel It',
```

- [ ] **Step 2: Хелперы типа + связи + paired**

Рядом с `isKingOfCourt()` и его связями добавить:
```php
	public function isJustPadelIt(): bool
	{
		return $this->type === 'just_padel_it';
	}

	public function isPairedJustPadelIt(): bool
	{
		return $this->isJustPadelIt() && (bool) $this->is_paired;
	}

	public function justPadelItPlayers()
	{
		return $this->hasMany(\App\Models\JustPadelItPlayer::class);
	}

	public function justPadelItRounds()
	{
		return $this->hasMany(\App\Models\JustPadelItRound::class)->orderBy('round_number');
	}

	public function justPadelItPairs()
	{
		return $this->hasMany(\App\Models\JustPadelItPair::class);
	}
```

- [ ] **Step 3: firstRoundCompleted()**

В `firstRoundCompleted()` (`match ($this->type)`) добавить кейс рядом с `'king_of_court'`:
```php
			'just_padel_it' => \App\Models\JustPadelItRound::query()
				->where('tournament_id', $this->id)
				->where('round_number', 1)->where('status', 'completed')->exists(),
```

- [ ] **Step 4: Синтаксис + commit**

Run: `php -l app/Models/Tournament.php`
Expected: No syntax errors.
```bash
git add app/Models/Tournament.php
git commit -m "feat(jpi): регистрация типа just_padel_it в модели Tournament"
git push origin main
```

---

## Task 4: Чистые хелперы бонусов и сортировки (юнит-тесты)

**Files:**
- Create: `app/Services/JustPadelItScoring.php`
- Test: `tests/Unit/JustPadelItScoringTest.php`

**Interfaces:**
- Produces: `JustPadelItScoring::courtBonus(int $courtNumber): int`; `JustPadelItScoring::sortStandings(array $rows): array` (сортировка по `total_points` ↓ → `wins` ↓; каждая строка — массив с ключами `total_points`, `wins`).

- [ ] **Step 1: Тест бонусов и сортировки (падающий)**

`tests/Unit/JustPadelItScoringTest.php`:
```php
<?php
namespace Tests\Unit;
use App\Services\JustPadelItScoring;
use PHPUnit\Framework\TestCase;

class JustPadelItScoringTest extends TestCase
{
    public function test_court_bonus(): void
    {
        $this->assertSame(3, JustPadelItScoring::courtBonus(1));
        $this->assertSame(2, JustPadelItScoring::courtBonus(2));
        $this->assertSame(1, JustPadelItScoring::courtBonus(3));
        $this->assertSame(1, JustPadelItScoring::courtBonus(5));
    }

    public function test_sort_standings_points_then_wins(): void
    {
        $rows = [
            ['name' => 'B', 'total_points' => 130, 'wins' => 8],
            ['name' => 'A', 'total_points' => 130, 'wins' => 9],
            ['name' => 'C', 'total_points' => 140, 'wins' => 1],
        ];
        $sorted = JustPadelItScoring::sortStandings($rows);
        $this->assertSame(['C', 'A', 'B'], array_column($sorted, 'name'));
    }
}
```

- [ ] **Step 2: Запустить — убедиться, что падает**

Run: `php artisan test --filter=JustPadelItScoringTest`
Expected: FAIL — класс `App\Services\JustPadelItScoring` не найден.

- [ ] **Step 3: Реализация**

`app/Services/JustPadelItScoring.php`:
```php
<?php
namespace App\Services;

class JustPadelItScoring
{
    /** Бонус победителям по номеру корта: 1→+3, 2→+2, остальные→+1. */
    public static function courtBonus(int $courtNumber): int
    {
        return match ($courtNumber) {
            1 => 3,
            2 => 2,
            default => 1,
        };
    }

    /** Сортировка итоговой таблицы: очки ↓, при равенстве — победы ↓. */
    public static function sortStandings(array $rows): array
    {
        usort($rows, function ($a, $b) {
            $ap = $a['total_points'] ?? 0;
            $bp = $b['total_points'] ?? 0;
            if ($ap !== $bp) return $bp <=> $ap;
            return ($b['wins'] ?? 0) <=> ($a['wins'] ?? 0);
        });
        return $rows;
    }
}
```

- [ ] **Step 4: Запустить — проходит**

Run: `php artisan test --filter=JustPadelItScoringTest`
Expected: PASS (2 теста).

- [ ] **Step 5: Commit + push**
```bash
git add app/Services/JustPadelItScoring.php tests/Unit/JustPadelItScoringTest.php
git commit -m "feat(jpi): хелперы courtBonus/sortStandings + юнит-тесты"
git push origin main
```

---

## Task 5: Сервис JustPadelItService (копия KoC + дельты)

**Files:**
- Create: `app/Services/JustPadelItService.php`

**Interfaces:**
- Consumes: модели Task 2, `JustPadelItScoring` (Task 4), trait `App\Traits\RatingCalculator`.
- Produces (публичные методы, сигнатуры как в KoC): `previewRatingChanges(Tournament): array`, `createPairs(Tournament, array): array`, `arePairsCreated(Tournament): bool`, `startTournament(Tournament, ?array $order = null): bool`, `saveMatchResult(JustPadelItMatch, int, int): void`, `canGenerateNextRound(Tournament): bool`, `generateNextRound(Tournament): bool`, `canFinishTournament(Tournament): bool`, `finishTournament(Tournament): bool`, `calculateEloForMatch(JustPadelItMatch, array&): void`, `getPairStandings(Tournament): array`.

- [ ] **Step 1: Скопировать сервис KoC и переименовать**

Скопировать `app/Services/KingOfCourtService.php` → `app/Services/JustPadelItService.php`, применить соглашение о переименовании (класс `JustPadelItService`, все модели `JustPadelItPlayer/Round/Match/Pair`, вызовы `$tournament->isJustPadelIt()/isPairedJustPadelIt()/justPadelItPairs()/justPadelItPlayers()`). Добавить `use App\Services\JustPadelItScoring;` в начало.

- [ ] **Step 2: Дельта — посев по рейтингу + опциональный порядок в `startTournament`**

В `startTournament(Tournament $tournament, ?array $order = null): bool` заменить логику формирования порядка участников/пар (там где KoC делает `->shuffle()`):

Solo-режим — вместо `$participants->shuffle()->values()`:
```php
        // Посев: явный порядок (из экрана посева) или по рейтингу (сильные → корт 1).
        if ($order && count($order)) {
            $byId = $participants->keyBy('id');
            $ordered = collect($order)->map(fn ($id) => $byId->get($id))->filter()->values();
            // добавить забытых (если порядок неполный)
            foreach ($participants as $p) {
                if (!$ordered->contains('id', $p->id)) $ordered->push($p);
            }
            $participants = $ordered->values();
        } else {
            $participants = $participants->sortByDesc('rating')->values();
        }
```
Paired-режим — вместо `$pairs->shuffle()`: сортировать пары по сумме рейтинга игроков ↓:
```php
        $pairs = $pairs->sortByDesc(function ($pair) {
            return (int) ($pair->player1->rating ?? 0) + (int) ($pair->player2->rating ?? 0);
        })->values();
```
(`$order` для paired-режима в v1 не используем — пары уже фиксированы; сортировка по рейтингу.)

- [ ] **Step 3: Дельта — бонусы в `applyMatchStats`**

В `applyMatchStats(...)` (начисление статистики) после определения победившей команды добавить бонус победителям. Найти место, где для победителей делается `increment('wins')` и `increment('total_points', ...)`, и для КАЖДОГО из двух победителей добавить бонус:
```php
        $bonus = JustPadelItScoring::courtBonus((int) $match->court_number);
        // ... в ветке победителей, для каждого игрока победившей команды:
        $playerRow->increment('total_points', $bonus);
```
Убедиться, что бонус начисляется ТОЛЬКО победителям (в ветке win), обоим игрокам победившей пары, ПОМИМО уже начисляемого счёта команды.

- [ ] **Step 4: Дельта — откат бонусов в `rollbackMatchStats`**

В `rollbackMatchStats(...)` симметрично вычесть бонус у победителей:
```php
        $bonus = JustPadelItScoring::courtBonus((int) $match->court_number);
        // ... в ветке победителей, для каждого игрока победившей команды:
        $playerRow->decrement('total_points', $bonus);
```

- [ ] **Step 5: Дельта — сортировка `getPairStandings`**

В `getPairStandings(...)` заменить финальную сортировку строк на `JustPadelItScoring::sortStandings(...)` (очки → победы). Убедиться, что каждая строка содержит ключи `total_points` и `wins` (они уже есть в KoC-версии). Заменить блок `usort/sort` на:
```php
        return JustPadelItScoring::sortStandings($rows);
```

- [ ] **Step 6: Синтаксис**

Run: `php -l app/Services/JustPadelItService.php`
Expected: No syntax errors.

- [ ] **Step 7: Commit + push**
```bash
git add app/Services/JustPadelItService.php
git commit -m "feat(jpi): JustPadelItService — посев по рейтингу, бонусы, сортировка таблицы"
git push origin main
```

---

## Task 6: Контроллер JustPadelItController (+ экран посева)

**Files:**
- Create: `app/Http/Controllers/Club/JustPadelItController.php`

**Interfaces:**
- Consumes: `JustPadelItService` (Task 5), `JustPadelItMatch`.
- Produces методы: `show(Tournament)`, `pairs(Tournament)`, `storePairs(Request, Tournament, JustPadelItService)`, `saveScore(Request, JustPadelItMatch, JustPadelItService)`, `updateScore(Request, JustPadelItMatch, JustPadelItService)`, `generateNextRound(Tournament, JustPadelItService)`, `seeding(Tournament)`, `start(Request, Tournament, JustPadelItService)`.

- [ ] **Step 1: Скопировать контроллер KoC и переименовать**

Скопировать `app/Http/Controllers/Club/KingOfCourtController.php` → `app/Http/Controllers/Club/JustPadelItController.php`, применить соглашение о переименовании (класс, `JustPadelItService`, `JustPadelItMatch`, связи `justPadelItPlayers/justPadelItRounds`, `isPairedJustPadelIt()`, `getPairStandings`, view-путь `club.tournaments.justpadelit.show`, route-имена `club.justpadelit.*`, push-хелперы переименовать `notifyJpiRoundGenerated` и текст оставить общий). В `show()` — рендерить `club.tournaments.justpadelit.show`.

- [ ] **Step 2: Добавить экран посева `seeding()` и `start()`**

Добавить в контроллер методы:
```php
    /** Экран посева перед стартом: авто-раскладка по кортам по рейтингу, редактируемая. */
    public function seeding(Tournament $tournament)
    {
        abort_unless($tournament->isJustPadelIt(), 404);
        if ($tournament->status !== 'open') {
            return redirect()->route('club.tournaments.show', $tournament);
        }
        // Парный режим сначала требует созданных пар.
        if ($tournament->isPairedJustPadelIt() && !$tournament->justPadelItPairs()->exists()) {
            return redirect()->route('club.justpadelit.pairs', $tournament)
                ->with('error', 'Сначала создайте пары');
        }
        $participants = $tournament->participants()
            ->wherePivot('status', 'registered')
            ->orderByDesc('rating')->get();
        $courtsCount = (int) ($participants->count() / 4);
        return view('club.tournaments.justpadelit.seeding', compact('tournament', 'participants', 'courtsCount'));
    }

    /** Старт с учётом порядка посева (order[] — id участников по кортам). */
    public function start(Request $request, Tournament $tournament, JustPadelItService $service)
    {
        abort_unless($tournament->isJustPadelIt(), 404);
        $order = $request->input('order', []);
        $order = is_array($order) ? array_map('intval', $order) : [];
        if ($service->startTournament($tournament, $order ?: null)) {
            return redirect()->route('club.tournaments.show', $tournament)
                ->with('success', 'Турнир начат');
        }
        return redirect()->route('club.tournaments.show', $tournament)
            ->with('error', 'Не удалось начать турнир (проверьте число игроков и пары)');
    }
```

- [ ] **Step 3: Синтаксис**

Run: `php -l app/Http/Controllers/Club/JustPadelItController.php`
Expected: No syntax errors.

- [ ] **Step 4: Commit + push**
```bash
git add app/Http/Controllers/Club/JustPadelItController.php
git commit -m "feat(jpi): JustPadelItController — проведение + экран посева"
git push origin main
```

---

## Task 7: Роуты + диспетчеризация в TournamentController + reset

**Files:**
- Modify: `routes/web.php`
- Modify: `app/Http/Controllers/Club/TournamentController.php`
- Modify: `app/Services/TournamentResetService.php`

**Interfaces:**
- Consumes: `JustPadelItController`, `JustPadelItService`.
- Produces роуты `club.justpadelit.{show,pairs,storePairs,saveScore,updateScore,nextRound,seeding,start}`; диспетчеризацию `show/start/finish` для `just_padel_it`; reset-ветку.

- [ ] **Step 1: Импорт + роуты**

В начале `routes/web.php` рядом с `use App\Http\Controllers\Club\KingOfCourtController;` добавить:
```php
use App\Http\Controllers\Club\JustPadelItController;
```
В группе `club.` (рядом с блоком KoC-роутов) добавить:
```php
        Route::get('/justpadelit/{tournament}/pairs', [JustPadelItController::class, 'pairs'])->name('justpadelit.pairs');
        Route::post('/justpadelit/{tournament}/pairs', [JustPadelItController::class, 'storePairs'])->name('justpadelit.storePairs');
        Route::get('/justpadelit/{tournament}/seeding', [JustPadelItController::class, 'seeding'])->name('justpadelit.seeding');
        Route::post('/justpadelit/{tournament}/start', [JustPadelItController::class, 'start'])->name('justpadelit.start');
        Route::post('/justpadelit/match/{match}/score', [JustPadelItController::class, 'saveScore'])->name('justpadelit.saveScore');
        Route::put('/justpadelit/match/{match}/score', [JustPadelItController::class, 'updateScore'])->name('justpadelit.updateScore');
        Route::post('/justpadelit/tournament/{tournament}/next-round', [JustPadelItController::class, 'generateNextRound'])->name('justpadelit.nextRound');
```
> `{match}` биндится к модели `JustPadelItMatch` — убедиться, что route-model-binding резолвит правильную модель (Laravel по имени параметра `match` не знает тип; в KoC используется явный тип в сигнатуре метода `saveScore(Request $r, KingOfCourtMatch $match, ...)` — implicit binding по typehint). В `JustPadelItController::saveScore/updateScore` typehint уже `JustPadelItMatch` (из Task 6) — binding сработает.

- [ ] **Step 2: Диспетчеризация в TournamentController::store (валидация типа + is_paired)**

В `store()`: в правило `'type' => 'required|in:...'` добавить `just_padel_it`. В спец-блоке `is_paired` (где KoC берёт из чекбокса) расширить условие, чтобы `just_padel_it` тоже брал `is_paired` из запроса:
```php
        // было: if ($type === 'king_of_court') { $isPaired = $request->boolean('is_paired'); }
        if (in_array($type, ['king_of_court', 'just_padel_it'], true)) {
            $isPaired = $request->boolean('is_paired');
        }
```
(точную форму спец-блока адаптировать под существующий код строк 138–145.)

- [ ] **Step 3: Диспетчеризация show/start/finish**

`show()` — рядом с веткой KoC:
```php
        if ($tournament->isJustPadelIt()) {
            return app(\App\Http\Controllers\Club\JustPadelItController::class)->show($tournament);
        }
```
`start()` — добавить ветку (перед общим стартом), направляющую на экран посева (старт идёт через JustPadelItController::start):
```php
        elseif ($tournament->isJustPadelIt()) {
            if ($tournament->isPairedJustPadelIt() && !$tournament->justPadelItPairs()->exists()) {
                return redirect()->route('club.justpadelit.pairs', $tournament)->with('error', 'Сначала создайте пары');
            }
            return redirect()->route('club.justpadelit.seeding', $tournament);
        }
```
`finish()` — добавить ветку по образцу KoC:
```php
        elseif ($tournament->isJustPadelIt()) {
            $service = app(\App\Services\JustPadelItService::class);
            if (!$service->canFinishTournament($tournament)) {
                return back()->with('error', 'Доиграйте текущий раунд');
            }
            $service->finishTournament($tournament);
            return redirect()->route('club.tournaments.show', $tournament)->with('success', 'Турнир завершён');
        }
```
(адаптировать под точные сигнатуры/возвраты существующих методов start/finish.)

- [ ] **Step 4: TournamentResetService**

В `reset()` добавить кейс `just_padel_it`, удаляющий новые таблицы (по образцу KoC-кейса):
```php
            case 'just_padel_it':
                \App\Models\JustPadelItMatch::whereHas('round', fn ($q) => $q->where('tournament_id', $tournament->id))->delete();
                \App\Models\JustPadelItRound::where('tournament_id', $tournament->id)->delete();
                \App\Models\JustPadelItPair::where('tournament_id', $tournament->id)->delete();
                \App\Models\JustPadelItPlayer::where('tournament_id', $tournament->id)->delete();
                break;
```
(сверить с тем, как реализован KoC-кейс — повторить его форму.)

- [ ] **Step 5: Синтаксис + роуты**

Run: `php -l routes/web.php && php -l app/Http/Controllers/Club/TournamentController.php && php -l app/Services/TournamentResetService.php`
Expected: No syntax errors.
Run: `php artisan route:list --path=justpadelit`
Expected: 7 роутов `club.justpadelit.*` перечислены.

- [ ] **Step 6: Commit + push**
```bash
git add routes/web.php app/Http/Controllers/Club/TournamentController.php app/Services/TournamentResetService.php
git commit -m "feat(jpi): роуты + диспетчеризация show/start/finish + reset"
git push origin main
```

---

## Task 8: View — проведение (копия KoC) + адаптация таблицы

**Files:**
- Create: `resources/views/club/tournaments/justpadelit/show.blade.php`, `pairs.blade.php`, `partials/_header.blade.php`, `_leaderboard.blade.php`, `_rounds.blade.php`

**Interfaces:**
- Consumes: `club.justpadelit.*` роуты, `getPairStandings`.

- [ ] **Step 1: Скопировать директорию view KoC и переименовать**

Скопировать `resources/views/club/tournaments/kingofcourt/` → `resources/views/club/tournaments/justpadelit/` (файлы `show.blade.php`, `pairs.blade.php`, `partials/_header.blade.php`, `_leaderboard.blade.php`, `_rounds.blade.php`). Применить соглашение о переименовании во ВСЕХ файлах:
- includes `kingofcourt.partials._*` → `justpadelit.partials._*`;
- route-имена `club.kingofcourt.*` → `club.justpadelit.*`;
- сервис-вызовы в blade `\App\Services\KingOfCourtService::` → `\App\Services\JustPadelItService::` (методы `canGenerateNextRound`, `canFinishTournament`);
- связи `$tournament->kingOfCourtPlayers` → `$tournament->justPadelItPlayers`;
- JS-функции `toggleKocRound` → `toggleJpiRound`, id модалок `kocScoreModal`/`kocEditScoreModal` → `jpiScoreModal`/`jpiEditScoreModal`;
- подпись «Король корта» → «Just Padel It».

- [ ] **Step 2: _header — кнопка «Начать» → экран посева**

В `partials/_header.blade.php` кнопку «Начать турнир» (форма на `club.tournaments.start`) для JPI заменить на ссылку на экран посева:
```blade
<a href="{{ route('club.justpadelit.seeding', $tournament) }}" class="btn-primary-custom">Посев и старт</a>
```
(для парного режима сохранить существующую ветку «Создать пары» → `club.justpadelit.pairs`, затем «Посев и старт».)

- [ ] **Step 3: _leaderboard — сортировка и колонки под очки+победы**

В `partials/_leaderboard.blade.php` (solo-вариант, где сортировка инлайн в blade) заменить инлайн-`uasort` на использование сервиса — собрать строки в массив и отсортировать:
```php
@php
    $rows = $tournament->justPadelItPlayers->map(fn ($p) => [
        'player' => $p, 'total_points' => $p->total_points, 'wins' => $p->wins,
        'losses' => $p->losses, 'points_for' => $p->points_for, 'points_against' => $p->points_against,
    ])->values()->all();
    $rows = \App\Services\JustPadelItScoring::sortStandings($rows);
@endphp
```
и отрисовывать `$rows` (доступ к игроку `$row['player']`). Колонки оставить, но акцент на **Очки** и **Победы**. Парный вариант уже сортируется через `getPairStandings` (Task 5, Step 5) — там правки не нужны.

- [ ] **Step 4: Синтаксис (компиляция blade)**

Run: `php artisan view:cache 2>&1 | tail -3 && php artisan view:clear`
Expected: `Blade templates cached successfully.` (без ошибок компиляции).

- [ ] **Step 5: Commit + push**
```bash
git add resources/views/club/tournaments/justpadelit/
git commit -m "feat(jpi): view проведения (копия KoC) + таблица очки→победы"
git push origin main
```

---

## Task 9: View — экран посева (seeding)

**Files:**
- Create: `resources/views/club/tournaments/justpadelit/seeding.blade.php`

**Interfaces:**
- Consumes: `seeding()` контроллера (передаёт `$tournament`, `$participants` (по рейтингу ↓), `$courtsCount`), POST `club.justpadelit.start` с полем `order[]`.

- [ ] **Step 1: Экран посева**

`resources/views/club/tournaments/justpadelit/seeding.blade.php` — форма, показывающая корты 1..N с 4 слотами каждый, предзаполненные по рейтингу (первые 4 → корт 1 и т.д.), каждый слот — `<select name="order[]">` со всеми участниками; JS отключает уже выбранных в других слотах (как в `pairs.blade.php`, функция `refreshDisabledOptions`). Кнопка «Начать турнир» сабмитит форму POST на `club.justpadelit.start`. По образцу `resources/views/club/tournaments/kingofcourt/pairs.blade.php` (структура селектов + дизейбл занятых + `extends layouts.app`). Порядок `order[]` идёт слот за слотом (корт1 слот1..4, корт2 слот1..4, ...), что и есть порядок посева для `startTournament`.
```blade
@extends('layouts.app')
@section('content')
<div class="container">
  <h4 class="mb-3">Посев — {{ $tournament->name }}</h4>
  <p class="text-secondary">Игроки распределены по рейтингу (сильные — корт 1). Можно поменять вручную.</p>
  <form method="POST" action="{{ route('club.justpadelit.start', $tournament) }}" id="seedForm">
    @csrf
    @for($c = 0; $c < $courtsCount; $c++)
      <div class="card mb-3"><div class="card-body">
        <div class="fw-bold mb-2">Корт {{ $c + 1 }}</div>
        <div class="row">
          @for($s = 0; $s < 4; $s++)
            @php $idx = $c * 4 + $s; @endphp
            <div class="col-md-3 mb-2">
              <select name="order[]" class="form-select seed-select">
                @foreach($participants as $p)
                  <option value="{{ $p->id }}" {{ $participants[$idx]->id === $p->id ? 'selected' : '' }}>
                    {{ $p->name }} ({{ $p->rating }})
                  </option>
                @endforeach
              </select>
            </div>
          @endfor
        </div>
      </div></div>
    @endfor
    <button type="submit" class="btn-primary-custom">Начать турнир</button>
    <a href="{{ route('club.tournaments.show', $tournament) }}" class="btn-outline-custom">Отмена</a>
  </form>
</div>
<script>
function refreshDisabledOptions() {
  const selects = Array.from(document.querySelectorAll('.seed-select'));
  const chosen = selects.map(s => s.value);
  selects.forEach(sel => {
    Array.from(sel.options).forEach(o => {
      o.disabled = chosen.includes(o.value) && sel.value !== o.value;
    });
  });
}
document.querySelectorAll('.seed-select').forEach(s => s.addEventListener('change', refreshDisabledOptions));
refreshDisabledOptions();
</script>
@endsection
```
> Замечание: экран посева в v1 — для solo-режима (индивидуальный посев по кортам). В парном режиме `startTournament` сортирует пары по рейтингу автоматически; для парного `seeding()` можно вести сразу на старт (порядок пар не редактируем в v1) — это допустимо, т.к. §5 про ручную правку в первую очередь про игроков. Если участников не кратно 4 — кнопка старта всё равно сабмитит, а `startTournament` вернёт false с сообщением (guard по числу игроков).

- [ ] **Step 2: Компиляция blade**

Run: `php artisan view:cache 2>&1 | tail -3 && php artisan view:clear`
Expected: без ошибок.

- [ ] **Step 3: Commit + push**
```bash
git add resources/views/club/tournaments/justpadelit/seeding.blade.php
git commit -m "feat(jpi): экран посева (ручная правка кортов по рейтингу)"
git push origin main
```

---

## Task 10: Форма создания — тип + настройки (Пары, Тип подсчёта)

**Files:**
- Modify: `resources/views/club/tournaments/create.blade.php`

**Interfaces:**
- Consumes: `store()` (валидация типа из Task 7).
- Produces: опцию типа `just_padel_it`, блок настроек `#justPadelItFields` (чекбокс `is_paired` + селектор «Тип подсчёта» с неактивными сетами), JS-переключение.

- [ ] **Step 1: Опция типа**

В `<select>` типов (рядом со строкой `<option value="king_of_court" ...>`) добавить:
```blade
									<option value="just_padel_it" {{ old('type') === 'just_padel_it' ? 'selected' : '' }}>Just Padel It</option>
```

- [ ] **Step 2: Блок настроек**

Рядом с блоком `#kingOfCourtFields` добавить `#justPadelItFields` (скрыт по умолчанию):
```blade
						<div id="justPadelItFields" style="display: none;">
							<div class="alert-success-custom mb-4">
								<i class="bi bi-info-circle me-2"></i>
								<strong>Just Padel It:</strong> Победители переходят на корт выше, проигравшие — ниже. За победу начисляются бонусы: корт 1 → +3, корт 2 → +2, остальные → +1. Число игроков — кратно 4, минимум 8.
							</div>
							<div class="mb-3">
								<div class="form-check">
									<input type="checkbox" class="form-check-input" name="is_paired" value="1" id="jpiFixedPairs"
										   {{ old('is_paired') ? 'checked' : '' }}>
									<label class="form-check-label" for="jpiFixedPairs">
										Фиксированные пары <small class="text-muted">(партнёр на весь турнир). Снимите — случайные пары со сменой партнёров.</small>
									</label>
								</div>
							</div>
							<div class="mb-3">
								<label class="form-label">Тип подсчёта</label>
								<div class="form-check">
									<input type="radio" class="form-check-input" name="jpi_score_type" id="jpiScorePoints" value="points" checked>
									<label class="form-check-label" for="jpiScorePoints">По очкам</label>
								</div>
								<div class="form-check">
									<input type="radio" class="form-check-input" id="jpiScoreSets" value="sets" disabled>
									<label class="form-check-label text-muted" for="jpiScoreSets">По сетам <small>(скоро)</small></label>
								</div>
							</div>
						</div>
```
> «Тип подсчёта» — косметический (в v1 только «По очкам»); значение на сервер не отправляем и не храним (сеты не реализованы). Кнопка «По сетам» — `disabled`.

- [ ] **Step 3: JS-переключение**

В `toggleTypeFields()`:
- получить элемент: `const justPadelItFields = document.getElementById('justPadelItFields');`
- в блоке скрытия всех — добавить `if (justPadelItFields) justPadelItFields.style.display = 'none';`
- добавить ветку показа:
```javascript
    else if (type === 'just_padel_it' && justPadelItFields) {
        justPadelItFields.style.display = 'block';
    }
```

- [ ] **Step 4: Компиляция + проверка**

Run: `php artisan view:cache 2>&1 | tail -3 && php artisan view:clear`
Expected: без ошибок.
Ручная проверка: открыть форму создания, выбрать тип «Just Padel It» → появляется блок с чекбоксом «Фиксированные пары» и «Тип подсчёта» (сеты неактивны).

- [ ] **Step 5: Commit + push**
```bash
git add resources/views/club/tournaments/create.blade.php
git commit -m "feat(jpi): тип Just Padel It в форме создания + настройки (пары, тип подсчёта)"
git push origin main
```

---

## Task 11: Финальная проверка (ручной прогон на проде/локали)

- [ ] **Step 1: Все юнит-тесты**

Run: `php artisan test --filter=JustPadelItScoringTest`
Expected: PASS.

- [ ] **Step 2: Роуты и синтаксис**

Run: `php artisan route:list --path=justpadelit` — 7 роутов.
Run: `php artisan view:cache && php artisan view:clear` — без ошибок.

- [ ] **Step 3: Сквозной сценарий (после деплоя + миграций)**

Прогнать вручную на клубе:
1. Создать турнир тип «Just Padel It», 8 тест-игроков, режим «случайные пары».
2. «Посев и старт» → увидеть раскладку по рейтингу (сильные на корте 1), при желании поменять → «Начать турнир».
3. Ввести счёт матчей раунда (без ничьих). Проверить бонусы: победитель на корте 1 получает +3 к очкам (свой счёт + 3).
4. «Следующий раунд» — победители вверх, проигравшие вниз.
5. Итоговая таблица: сортировка по очкам, при равенстве очков выше тот, у кого больше побед.
6. «Завершить турнир».
7. Повторить с «фиксированными парами»: сначала «Создать пары», затем старт; посев пар по сумме рейтинга.
8. Проверить: пока не введён ни один счёт — состав можно менять (участники до старта); после старта/счёта — таблица зафиксирована (замены посреди турнира нет — по дизайну v1).

- [ ] **Step 4: Финальный commit при правках**
```bash
git add -A && git commit -m "test(jpi): финальная проверка сценариев Just Padel It" && git push origin main
```

---

## Замечания по дизайну (для ревьюеров)
- **Замена игрока (§8)** — в v1 отдельной фичи нет: состав правится штатно до старта; после первого счёта ростер зафиксирован (турнир `in_progress`). Полноценная замена посреди турнира — вне v1.
- **Тип подсчёта по сетам** — вне v1 (кнопка неактивна).
- **Приложение (live-экран)** — вне v1 (только веб).
- **Число очков в матче / число раундов** — не настраиваются (по решению).
