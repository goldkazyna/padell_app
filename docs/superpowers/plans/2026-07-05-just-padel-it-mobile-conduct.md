# Just Padel It в приложении — под-проект B (проведение + live) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Дать администратору проводить турнир `just_padel_it` из приложения (посев/пары → старт → счёт → раунды → таблица → финиш), а игрокам/зрителям — смотреть live-экран.

**Architecture:** JPI построен на движке «Король корта», а `JustPadelItService` — метод-в-метод копия `KingOfCourtService`. Поэтому B = зеркалирование интеграции KoC: в мобильных контроллерах добавляем ветки/методы `just_padel_it`, вызывающие `JustPadelItService`; в приложении копируем KoC-экраны/сервис-методы под JPI-эндпоинты. «Король корта» не изменяется — только добавляется JPI рядом.

**Tech Stack:** Laravel (PHP, PHPUnit, Sanctum), Flutter/Dart, provider.

## Global Constraints

- Два репозитория: бэкенд `C:\projects\padel`, приложение `C:\projects\padel_app`. Не смешивать пути/коммиты.
- **Бэкенд (`padel`) коммитим и пушим сразу** после задачи. **Приложение (`padel_app`) — только коммит, без push** (юзер собирает локально).
- Тип везде ровно `just_padel_it` (snake_case).
- «Король корта» (методы/маршруты/таблицы/экраны KoC) **не изменять** — только добавлять JPI-аналоги рядом.
- Ничьи в матче запрещены — победитель обязателен (как в KoC/JPI-сервисе).
- `JustPadelItService` уже существует, публичные методы: `arePairsCreated(Tournament):bool`, `startTournament(Tournament, ?array $order):bool`, `createPairs(Tournament, array):array`, `saveMatchResult(JustPadelItMatch, int, int):void`, `canGenerateNextRound(Tournament):bool`, `generateNextRound(Tournament):bool`, `canFinishTournament(Tournament):bool`, `finishTournament(Tournament):bool`, `getPairStandings(Tournament):array`.
- Модель матча — `App\Models\JustPadelItMatch`; раунды — `$tournament->justPadelItRounds()`; связь имён — по образцу `kingOfCourt*` в модели `Tournament`.
- Строки админ-экранов приложения — можно хардкод RU. Live-экран (пользовательский) — строки через AppLocalizations (переиспользовать ключи KoC-live).
- **Способ копирования:** где задача говорит «копия KoC-метода X» — открыть указанный образец, скопировать дословно, применить перечисленные замены. Не изобретать новую структуру.

---

### Task 1: Бэкенд — `start()` JPI-ветка + `jpiSeeding` эндпоинт

**Repo:** `C:\projects\padel`
Снимает текущий блокер «Неизвестный тип турнира» при старте JPI.

**Files:**
- Modify: `app/Http/Controllers/Api/MobileAdminTournamentDetailController.php` (метод `start()` ~строки 135-190; добавить метод `jpiSeeding()`)
- Modify: `routes/api.php` (рядом с KoC-маршрутами ~строки 172-182)
- Test: `tests/Feature/MobileAdminJustPadelItConductTest.php` (создать)

**Interfaces:**
- Consumes: `JustPadelItService` (см. Global Constraints).
- Produces: старт JPI работает (solo авто-посев или с `order[]`; парный требует пары). GET `/admin/tournaments/{t}/justpadelit/seeding` → `{ participants:[{id,name,rating}], courts_count }`.

- [ ] **Step 1: Написать падающий тест**

Создать `tests/Feature/MobileAdminJustPadelItConductTest.php`:

```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Club;
use App\Models\Tournament;
use App\Models\TournamentParticipant;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class MobileAdminJustPadelItConductTest extends TestCase
{
    use RefreshDatabase;

    /** @return array{0:Club,1:User,2:Tournament} */
    private function makeTournament(bool $paired = false, int $players = 8, int $courts = 2): array
    {
        $club = Club::create(['name' => 'C', 'address' => 'A', 'city' => 'Алматы']);
        $admin = User::factory()->create(['role' => 'club_admin']);
        $admin->adminClubs()->attach($club->id);

        $t = Tournament::factory()->create([
            'club_id' => $club->id,
            'type' => 'just_padel_it',
            'status' => 'open',
            'max_participants' => $players,
            'courts_count' => $courts,
            'is_paired' => $paired,
        ]);
        for ($i = 1; $i <= $players; $i++) {
            $u = User::factory()->create(['rating' => 1000 + $i * 100]);
            TournamentParticipant::create([
                'tournament_id' => $t->id,
                'user_id' => $u->id,
                'status' => 'registered',
            ]);
        }
        return [$club, $admin, $t];
    }

    public function test_solo_start_creates_first_round(): void
    {
        [$club, $admin, $t] = $this->makeTournament(false, 8, 2);
        Sanctum::actingAs($admin);

        $this->postJson("/api/mobile/admin/tournaments/{$t->id}/start")
            ->assertOk()
            ->assertJsonPath('success', true);

        $t->refresh();
        $this->assertSame('active', $t->status);
        $this->assertSame(1, $t->justPadelItRounds()->count());
    }

    public function test_seeding_endpoint_returns_participants_sorted_by_rating(): void
    {
        [$club, $admin, $t] = $this->makeTournament(false, 8, 2);
        Sanctum::actingAs($admin);

        $res = $this->getJson("/api/mobile/admin/tournaments/{$t->id}/justpadelit/seeding")
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('courts_count', 2);

        $ratings = array_column($res->json('participants'), 'rating');
        $sorted = $ratings;
        rsort($sorted);
        $this->assertSame($sorted, $ratings, 'participants must be sorted by rating desc');
    }

    public function test_paired_start_without_pairs_requires_pairs(): void
    {
        [$club, $admin, $t] = $this->makeTournament(true, 8, 2);
        Sanctum::actingAs($admin);

        $this->postJson("/api/mobile/admin/tournaments/{$t->id}/start")
            ->assertStatus(422)
            ->assertJsonPath('pairs_required', true);
    }
}
```

- [ ] **Step 2: Запустить — убедиться что падает**

Run: `php artisan test --filter=MobileAdminJustPadelItConductTest`
Expected: FAIL (старт → 422 «Неизвестный тип турнира»; seeding-роут 404).

- [ ] **Step 3: Добавить JPI-ветку в `start()`**

В `MobileAdminTournamentDetailController::start()` добавить в сигнатуру инъекцию сервиса (рядом с остальными):

```php
        RoundRobinService $roundRobin,
        \App\Services\JustPadelItService $jpi
    ): JsonResponse {
```

В цепочке `if/elseif` (перед `else { ... 'Неизвестный тип турнира' }`) вставить ветку — образец: соседняя ветка `isKingOfCourt` (~строки 165-173):

```php
        } elseif ($tournament->isJustPadelIt()) {
            if ($tournament->isPairedJustPadelIt() && !$jpi->arePairsCreated($tournament)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Сначала создайте пары',
                    'pairs_required' => true,
                ], 422);
            }
            $order = $request->input('order');
            $order = is_array($order) ? array_map('intval', $order) : null;
            $ok = $jpi->startTournament($tournament, $order ?: null);
```

(Проверить, что модель `Tournament` имеет `isJustPadelIt()` и `isPairedJustPadelIt()` — они добавлены в веб-части. Если `isPairedJustPadelIt()` нет — использовать `$tournament->is_paired`.)

- [ ] **Step 4: Добавить метод `jpiSeeding()`**

В тот же контроллер добавить метод (участники по рейтингу ↓ + число кортов):

```php
    public function jpiSeeding(Request $request, Tournament $tournament): JsonResponse
    {
        if (!$this->canManageTournament($request->user(), $tournament)) {
            return $this->forbidden();
        }
        if (!$tournament->isJustPadelIt()) {
            return response()->json(['success' => false, 'message' => 'Не тот тип турнира'], 422);
        }

        $participants = $tournament->participants()
            ->where('tournament_participants.status', 'registered')
            ->with('user')
            ->get()
            ->map(fn($p) => [
                'id' => $p->user_id,
                'name' => $p->user->name,
                'rating' => (int) ($p->user->rating ?? 0),
            ])
            ->sortByDesc('rating')
            ->values();

        return response()->json([
            'success' => true,
            'participants' => $participants,
            'courts_count' => (int) ($tournament->courts_count ?? 1),
        ]);
    }
```

(Сверить способ выборки участников с тем, как это делает `jpiPairs`/`kocPairs` в этом же контроллере — использовать тот же паттерн отношения `participants()` и поля `user->name`/`user->rating`. Если статус-скоуп отличается — привести к образцу KoC.)

- [ ] **Step 5: Добавить маршруты**

В `routes/api.php` рядом с KoC-маршрутами (после строки 182) добавить:

```php
        Route::get('/admin/tournaments/{tournament}/justpadelit/seeding', [MobileAdminTournamentDetailController::class, 'jpiSeeding']);
```

- [ ] **Step 6: Запустить тест — PASS**

Run: `php artisan test --filter=MobileAdminJustPadelItConductTest`
Expected: PASS (3 passed).

- [ ] **Step 7: Регрессия KoC-старта**

Run: `php artisan test --filter=KingOfCourt`
Expected: PASS (KoC не задет).

- [ ] **Step 8: Коммит и пуш**

```bash
git add app/Http/Controllers/Api/MobileAdminTournamentDetailController.php routes/api.php tests/Feature/MobileAdminJustPadelItConductTest.php
git commit -m "feat(mobile-api): JPI старт + эндпоинт посева"
git push
```

---

### Task 2: Бэкенд — `buildJustPadelItMatches()` + ветка в `matches()`

**Repo:** `C:\projects\padel`
Ядро отображения проведения (раунды/матчи/таблица) для админ-экрана.

**Files:**
- Modify: `app/Http/Controllers/Api/MobileAdminTournamentDetailController.php` (метод `matches()` ~строка 1347; добавить приватный `buildJustPadelItMatches()`)
- Test: `tests/Feature/MobileAdminJustPadelItConductTest.php` (дополнить)

**Interfaces:**
- Consumes: результат старта из Task 1.
- Produces: `GET /admin/tournaments/{t}/matches` для JPI отдаёт ту же структуру, что KoC (`buildKingOfCourtMatches`): раунды, матчи, таблица (`getPairStandings`).

- [ ] **Step 1: Найти образец**

Открыть `buildKingOfCourtMatches($tournament)` (grep по имени в контроллере) и ветку `isKingOfCourt()` в `matches()` (~строка 1357). Это образец для копирования.

- [ ] **Step 2: Дополнить тест**

Добавить в `MobileAdminJustPadelItConductTest` метод:

```php
    public function test_matches_endpoint_returns_rounds_and_standings_for_jpi(): void
    {
        [$club, $admin, $t] = $this->makeTournament(false, 8, 2);
        Sanctum::actingAs($admin);
        $this->postJson("/api/mobile/admin/tournaments/{$t->id}/start")->assertOk();

        $res = $this->getJson("/api/mobile/admin/tournaments/{$t->id}/matches")
            ->assertOk()
            ->assertJsonPath('type', 'just_padel_it');

        $this->assertNotEmpty($res->json('rounds'), 'must return rounds');
        $this->assertNotNull($res->json('standings'), 'must return standings');
    }
```

(Если у образца `buildKingOfCourtMatches` ключи называются иначе — напр. `leaderboard` вместо `standings` или `type` = `king_of_court` в другом месте — привести тест к фактическим ключам образца, но для JPI `type` должен быть `just_padel_it`.)

- [ ] **Step 3: Запустить — FAIL**

Run: `php artisan test --filter=test_matches_endpoint_returns_rounds_and_standings_for_jpi`
Expected: FAIL (matches() для JPI попадает в общий путь/ошибку — нет JPI-ветки).

- [ ] **Step 4: Добавить `buildJustPadelItMatches()`**

Скопировать метод `buildKingOfCourtMatches()` целиком под именем `buildJustPadelItMatches()`. Замены (все вхождения):
- имя метода → `buildJustPadelItMatches`
- `$tournament->kingOfCourtRounds()` → `$tournament->justPadelItRounds()`
- любые `KingOfCourt*` модели/связи → `JustPadelIt*`
- сервис `KingOfCourtService`/`$king` → `JustPadelItService`/`$jpi` (инъектировать/резолвить так же, как в образце)
- таблица: использовать `$jpi->getPairStandings($tournament)` (тот же вызов, что образец делает через KoC-сервис)
- значение ключа `type` в ответе → `'just_padel_it'`
Ничего кроме этих замен не менять — структура и ключи ответа идентичны KoC.

- [ ] **Step 5: Ветка в `matches()`**

В `matches()` рядом с `if ($tournament->isKingOfCourt()) { return response()->json($this->buildKingOfCourtMatches($tournament)); }` добавить:

```php
        if ($tournament->isJustPadelIt()) {
            return response()->json($this->buildJustPadelItMatches($tournament));
        }
```

- [ ] **Step 6: Запустить — PASS**

Run: `php artisan test --filter=MobileAdminJustPadelItConductTest`
Expected: PASS (4 passed).

- [ ] **Step 7: Коммит и пуш**

```bash
git add app/Http/Controllers/Api/MobileAdminTournamentDetailController.php tests/Feature/MobileAdminJustPadelItConductTest.php
git commit -m "feat(mobile-api): JPI matches — раунды/матчи/таблица"
git push
```

---

### Task 3: Бэкенд — `saveJustPadelItScore()` + маршрут счёта

**Repo:** `C:\projects\padel`

**Files:**
- Modify: `app/Http/Controllers/Api/MobileAdminTournamentDetailController.php` (образец `saveKingOfCourtScore()` ~строка 1907; добавить `saveJustPadelItScore()`)
- Modify: `routes/api.php`
- Test: `tests/Feature/MobileAdminJustPadelItConductTest.php` (дополнить)

**Interfaces:**
- Consumes: старт из Task 1, матчи из Task 2.
- Produces: `POST|PUT /admin/tournaments/{t}/justpadelit/matches/{match}/score` — сохраняет счёт, начисляет очки+бонус (`$jpi->saveMatchResult`).

- [ ] **Step 1: Дополнить тест**

```php
    public function test_save_score_awards_points_and_court_bonus(): void
    {
        [$club, $admin, $t] = $this->makeTournament(false, 8, 2);
        Sanctum::actingAs($admin);
        $this->postJson("/api/mobile/admin/tournaments/{$t->id}/start")->assertOk();

        $match = \App\Models\JustPadelItMatch::whereHas('round', function ($q) use ($t) {
            $q->where('tournament_id', $t->id);
        })->where('court_number', 1)->firstOrFail();

        $this->postJson(
            "/api/mobile/admin/tournaments/{$t->id}/justpadelit/matches/{$match->id}/score",
            ['team1_score' => 6, 'team2_score' => 2]
        )->assertOk()->assertJsonPath('success', true);

        $match->refresh();
        $this->assertSame('completed', $match->status);
        $this->assertSame(6, (int) $match->team1_score);
    }
```

(Если связь матча с раундом называется не `round` — привести `whereHas` к фактической связи модели `JustPadelItMatch`. Если поля счёта иные — привести к образцу.)

- [ ] **Step 2: Запустить — FAIL**

Run: `php artisan test --filter=test_save_score_awards_points_and_court_bonus`
Expected: FAIL (роут 404).

- [ ] **Step 3: Добавить `saveJustPadelItScore()`**

Скопировать `saveKingOfCourtScore()` под именем `saveJustPadelItScore()`. Замены:
- сигнатура: route-model binding `KingOfCourtMatch $match` → `\App\Models\JustPadelItMatch $match`; сервис `KingOfCourtService $service` → `\App\Services\JustPadelItService $service`
- вызов `$service->saveMatchResult($match, ...)` — остаётся (сигнатура совпадает)
- валидация счёта — без изменений (те же правила)
Логику/структуру ответа не менять.

- [ ] **Step 4: Маршрут**

В `routes/api.php` после seeding-маршрута добавить:

```php
        Route::match(['POST', 'PUT'], '/admin/tournaments/{tournament}/justpadelit/matches/{match}/score', [MobileAdminTournamentDetailController::class, 'saveJustPadelItScore']);
```

- [ ] **Step 5: Запустить — PASS**

Run: `php artisan test --filter=MobileAdminJustPadelItConductTest`
Expected: PASS (5 passed).

- [ ] **Step 6: Коммит и пуш**

```bash
git add app/Http/Controllers/Api/MobileAdminTournamentDetailController.php routes/api.php tests/Feature/MobileAdminJustPadelItConductTest.php
git commit -m "feat(mobile-api): JPI сохранение счёта матча"
git push
```

---

### Task 4: Бэкенд — `nextRound()` + `finish()` JPI-ветки

**Repo:** `C:\projects\padel`

**Files:**
- Modify: `app/Http/Controllers/Api/MobileAdminTournamentDetailController.php` (`nextRound()` KoC-ветка ~строки 2003-2026; `finish()` KoC-ветка ~строки 1854-1858)
- Test: `tests/Feature/MobileAdminJustPadelItConductTest.php` (дополнить)

**Interfaces:**
- Consumes: старт (Task 1), matches (Task 2), счёт (Task 3).
- Produces: `POST /admin/tournaments/{t}/next-round` и `finish` работают для JPI.

- [ ] **Step 1: Дополнить тест**

```php
    private function completeCurrentRound(Tournament $t, \App\Services\JustPadelItService $jpi): void
    {
        $round = $t->justPadelItRounds()->orderByDesc('round_number')->first();
        foreach ($round->matches as $m) {
            $jpi->saveMatchResult($m, 6, 2);
        }
    }

    public function test_next_round_generates_second_round(): void
    {
        [$club, $admin, $t] = $this->makeTournament(false, 8, 2);
        Sanctum::actingAs($admin);
        $jpi = app(\App\Services\JustPadelItService::class);
        $this->postJson("/api/mobile/admin/tournaments/{$t->id}/start")->assertOk();
        $t->refresh();
        $this->completeCurrentRound($t, $jpi);

        $this->postJson("/api/mobile/admin/tournaments/{$t->id}/next-round")->assertOk();

        $this->assertSame(2, $t->fresh()->justPadelItRounds()->count());
    }

    public function test_finish_completes_tournament(): void
    {
        [$club, $admin, $t] = $this->makeTournament(false, 8, 2);
        Sanctum::actingAs($admin);
        $jpi = app(\App\Services\JustPadelItService::class);
        $this->postJson("/api/mobile/admin/tournaments/{$t->id}/start")->assertOk();
        $t->refresh();
        $this->completeCurrentRound($t, $jpi);

        $this->postJson("/api/mobile/admin/tournaments/{$t->id}/finish")->assertOk();

        $this->assertSame('completed', $t->fresh()->status);
    }
```

(Связь `round->matches` и `justPadelItRounds()` — привести к фактическим именам модели, если отличаются.)

- [ ] **Step 2: Запустить — FAIL**

Run: `php artisan test --filter="test_next_round_generates_second_round|test_finish_completes_tournament"`
Expected: FAIL (нет JPI-веток → ошибка/неизвестный тип).

- [ ] **Step 3: `nextRound()` JPI-ветка**

По образцу KoC-ветки (2003-2026) добавить в `nextRound()`:

```php
        if ($tournament->isJustPadelIt()) {
            $jpi = app(\App\Services\JustPadelItService::class);
            if (!$jpi->canGenerateNextRound($tournament)) {
                return $this->error('Текущий раунд ещё не завершён');
            }
            if (!$jpi->generateNextRound($tournament)) {
                return $this->error('Не удалось сгенерировать следующий раунд');
            }
            $tournament->refresh();
            return response()->json($this->buildJustPadelItMatches($tournament));
        }
```

Примечание: персональный пуш о новом раунде (как `KingOfCourtController::notifyKocRoundGenerated` в KoC-ветке) в v1 **не добавляем** — у JPI отдельного notify нет; это осознанный пропуск (можно добавить позже).

- [ ] **Step 4: `finish()` JPI-ветка**

По образцу KoC-ветки (1854-1858) добавить в `finish()` (сервис `$jpi` уже может инъектироваться в сигнатуру метода — сверить, как инъектированы прочие сервисы в `finish()`; если инъекции нет, резолвить `app(JustPadelItService::class)`):

```php
        } elseif ($tournament->isJustPadelIt()) {
            if (!$jpi->canFinishTournament($tournament)) {
                return $this->error('Доиграйте текущий раунд');
            }
            $ok = $jpi->finishTournament($tournament);
```

- [ ] **Step 5: Запустить — PASS**

Run: `php artisan test --filter=MobileAdminJustPadelItConductTest`
Expected: PASS (7 passed).

- [ ] **Step 6: Коммит и пуш**

```bash
git add app/Http/Controllers/Api/MobileAdminTournamentDetailController.php tests/Feature/MobileAdminJustPadelItConductTest.php
git commit -m "feat(mobile-api): JPI следующий раунд + завершение"
git push
```

---

### Task 5: Бэкенд — `jpiPairs()` / `saveJpiPairs()` + маршруты

**Repo:** `C:\projects\padel`

**Files:**
- Modify: `app/Http/Controllers/Api/MobileAdminTournamentDetailController.php` (образцы `kocPairs()` ~2551, `saveKocPairs()` ~2593)
- Modify: `routes/api.php`
- Test: `tests/Feature/MobileAdminJustPadelItConductTest.php` (дополнить)

**Interfaces:**
- Consumes: `JustPadelItService::createPairs`.
- Produces: `GET /admin/tournaments/{t}/justpadelit/pairs` (участники + пары), `POST` (сохранить пары); после сохранения парный старт из Task 1 проходит.

- [ ] **Step 1: Дополнить тест**

```php
    public function test_paired_pairs_then_start(): void
    {
        [$club, $admin, $t] = $this->makeTournament(true, 8, 2);
        Sanctum::actingAs($admin);

        $ids = $t->participants()->pluck('user_id')->values()->all();
        $pairs = [[$ids[0], $ids[1]], [$ids[2], $ids[3]], [$ids[4], $ids[5]], [$ids[6], $ids[7]]];

        $this->postJson("/api/mobile/admin/tournaments/{$t->id}/justpadelit/pairs", ['pairs' => $pairs])
            ->assertOk()->assertJsonPath('success', true);

        $this->postJson("/api/mobile/admin/tournaments/{$t->id}/start")
            ->assertOk()->assertJsonPath('success', true);

        $this->assertSame('active', $t->fresh()->status);
    }
```

(Ключ тела (`pairs`) и структуру пар привести к образцу `saveKocPairs`. Выборку `participants()->pluck('user_id')` — к фактическому имени связи.)

- [ ] **Step 2: Запустить — FAIL**

Run: `php artisan test --filter=test_paired_pairs_then_start`
Expected: FAIL (роут пар 404).

- [ ] **Step 3: Добавить `jpiPairs()` и `saveJpiPairs()`**

Скопировать `kocPairs()` → `jpiPairs()` и `saveKocPairs()` → `saveJpiPairs()`. Замены:
- KoC-эндпоинт/связи → JPI (`kingOfCourt*` → `justPadelIt*`)
- сервис в `saveJpiPairs`: `KingOfCourtService $service` → `\App\Services\JustPadelItService $service`; вызов `$service->createPairs(...)` без изменений
- guard типа (если образец проверяет `isKingOfCourt`) → `isJustPadelIt`
Структуру ответа/тела не менять.

- [ ] **Step 4: Маршруты**

```php
        Route::get('/admin/tournaments/{tournament}/justpadelit/pairs', [MobileAdminTournamentDetailController::class, 'jpiPairs']);
        Route::post('/admin/tournaments/{tournament}/justpadelit/pairs', [MobileAdminTournamentDetailController::class, 'saveJpiPairs']);
```

- [ ] **Step 5: Запустить — PASS**

Run: `php artisan test --filter=MobileAdminJustPadelItConductTest`
Expected: PASS (8 passed).

- [ ] **Step 6: Коммит и пуш**

```bash
git add app/Http/Controllers/Api/MobileAdminTournamentDetailController.php routes/api.php tests/Feature/MobileAdminJustPadelItConductTest.php
git commit -m "feat(mobile-api): JPI пары (get/save)"
git push
```

---

### Task 6: Бэкенд — `liveJustPadelIt()` + диспетчер live (публичный)

**Repo:** `C:\projects\padel`

**Files:**
- Modify: `app/Http/Controllers/Api/MobileTournamentController.php` (`live()` диспетчер ~строка 2260-2289; образец `liveKingOfCourt()` ~строка 2979)
- Test: `tests/Feature/MobileJustPadelItLiveTest.php` (создать)

**Interfaces:**
- Consumes: старт/раунды JPI.
- Produces: `GET /tournaments/{id}/live` для JPI отдаёт структуру, идентичную KoC-live (питает live-экран приложения).

- [ ] **Step 1: Написать падающий тест**

Создать `tests/Feature/MobileJustPadelItLiveTest.php`:

```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Club;
use App\Models\Tournament;
use App\Models\TournamentParticipant;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class MobileJustPadelItLiveTest extends TestCase
{
    use RefreshDatabase;

    public function test_live_endpoint_returns_jpi_payload(): void
    {
        $club = Club::create(['name' => 'C', 'address' => 'A', 'city' => 'Алматы']);
        $admin = User::factory()->create(['role' => 'club_admin']);
        $admin->adminClubs()->attach($club->id);
        $t = Tournament::factory()->create([
            'club_id' => $club->id, 'type' => 'just_padel_it',
            'status' => 'open', 'max_participants' => 8, 'courts_count' => 2,
        ]);
        $players = [];
        for ($i = 1; $i <= 8; $i++) {
            $u = User::factory()->create(['rating' => 1000 + $i * 100]);
            $players[] = $u;
            TournamentParticipant::create(['tournament_id' => $t->id, 'user_id' => $u->id, 'status' => 'registered']);
        }
        app(\App\Services\JustPadelItService::class)->startTournament($t);

        Sanctum::actingAs($players[0]);
        $this->getJson("/api/mobile/tournaments/{$t->id}/live")
            ->assertOk()
            ->assertJsonPath('type', 'just_padel_it');
    }
}
```

(Ключ `type` в live-ответе привести к тому, что реально возвращает `liveKingOfCourt` — но для JPI значение `just_padel_it`. Если live не кладёт `type`, заменить проверку на наличие ключа `rounds`/`standings` по факту образца.)

- [ ] **Step 2: Запустить — FAIL**

Run: `php artisan test --filter=MobileJustPadelItLiveTest`
Expected: FAIL (JPI попадает в `else`/дефолт live — не тот payload).

- [ ] **Step 3: Диспетчер + метод**

В `live()` рядом с `return $this->liveKingOfCourt($tournament, $user);` добавить ветку:

```php
        if ($tournament->isJustPadelIt()) {
            return $this->liveJustPadelIt($tournament, $user);
        }
```

Скопировать `liveKingOfCourt()` → `liveJustPadelIt()`. Замены:
- `kingOfCourtRounds()`/`KingOfCourt*` → `justPadelItRounds()`/`JustPadelIt*`
- таблица через `JustPadelItService::getPairStandings` (если образец резолвит KoC-сервис — заменить на `app(JustPadelItService::class)`)
- значение `type` (если есть) → `'just_padel_it'`
Структуру/ключи не менять.

- [ ] **Step 4: Запустить — PASS**

Run: `php artisan test --filter=MobileJustPadelItLiveTest`
Expected: PASS.

- [ ] **Step 5: Коммит и пуш**

```bash
git add app/Http/Controllers/Api/MobileTournamentController.php tests/Feature/MobileJustPadelItLiveTest.php
git commit -m "feat(mobile-api): JPI live-эндпоинт"
git push
```

---

### Task 7: App — методы JPI в `AdminService`

**Repo:** `C:\projects\padel_app`

**Files:**
- Modify: `lib/services/admin_service.dart` (образцы `saveKocScore` ~612, `getKocPairs` ~711, `saveKocPairs` ~721; `startTournament` ~320)
- Test: нет (сервис-обёртки; проверяются `flutter analyze` + использованием в экранах Task 8-10)

**Interfaces:**
- Consumes: бэкенд-эндпоинты JPI (Tasks 1,3,5).
- Produces: `saveJpiScore(tournamentId, matchId, {team1Score, team2Score})`; `getJpiPairs(tournamentId) → Map`; `saveJpiPairs(tournamentId, List<List<int>>)`; `getJpiSeeding(tournamentId) → Map`; `startTournamentWithOrder(tournamentId, List<int> order) → AdminTournamentDetail`.

- [ ] **Step 1: Добавить методы**

В `lib/services/admin_service.dart` добавить (рядом с KoC-методами), по образцу `saveKocScore`/`getKocPairs`/`saveKocPairs`:

```dart
  /// Сохранить счёт матча Just Padel It. POST/PUT одинаковы — сервис
  /// идемпотентно переписывает счёт и статы.
  Future<void> saveJpiScore(
    int tournamentId,
    int matchId, {
    required int team1Score,
    required int team2Score,
  }) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/justpadelit/matches/$matchId/score',
      {'team1_score': team1Score, 'team2_score': team2Score},
      token,
    );
  }

  /// Участники + уже созданные пары JPI.
  Future<Map<String, dynamic>> getJpiPairs(int tournamentId) async {
    final token = await _storage.getToken();
    return _api.get('/admin/tournaments/$tournamentId/justpadelit/pairs', token);
  }

  /// Сохранить пары JPI. pairs — [[player1_id, player2_id], ...].
  Future<void> saveJpiPairs(int tournamentId, List<List<int>> pairs) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/justpadelit/pairs',
      {'pairs': pairs},
      token,
    );
  }

  /// Авто-посев (по рейтингу) + число кортов для экрана посева solo JPI.
  Future<Map<String, dynamic>> getJpiSeeding(int tournamentId) async {
    final token = await _storage.getToken();
    return _api.get('/admin/tournaments/$tournamentId/justpadelit/seeding', token);
  }
```

- [ ] **Step 2: Старт с порядком**

Найти существующий `startTournament(int id)` (~320) — он POST-ит на `/admin/tournaments/$id/start`. Добавить рядом вариант с порядком (по тому же образцу, добавив тело `order`):

```dart
  /// Старт JPI solo с ручным посевом: order — id игроков в порядке слотов
  /// (корт1 слот1..4, корт2 слот1..4, ...).
  Future<AdminTournamentDetail> startTournamentWithOrder(
    int id,
    List<int> order,
  ) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/tournaments/$id/start',
      {'order': order},
      token,
    );
    return AdminTournamentDetail.fromJson(response);
  }
```

(Сверить, что `startTournament` возвращает `AdminTournamentDetail.fromJson(response)` — повторить тот же разбор ответа. Если возвращает иначе — привести к образцу.)

- [ ] **Step 3: Анализ**

Run: `flutter analyze lib/services/admin_service.dart`
Expected: без новых ошибок/варнингов.

- [ ] **Step 4: Коммит (без push)**

```bash
git add lib/services/admin_service.dart
git commit -m "feat(admin): методы JPI в AdminService (счёт, пары, посев, старт с порядком)"
```

---

### Task 8: App — экран пар JPI + привязка в детали турнира

**Repo:** `C:\projects\padel_app`

**Files:**
- Create: `lib/screens/admin/admin_jpi_create_pairs_screen.dart` (копия `admin_koc_create_pairs_screen.dart`)
- Modify: `lib/screens/admin/admin_tournament_detail_screen.dart` (`_needPairs` ~строки 234-235; `_openCreatePairs` ~строки 243-247; импорт)
- Test: нет (UI; `flutter analyze` + ручная проверка)

**Interfaces:**
- Consumes: `AdminService.getJpiPairs`/`saveJpiPairs` (Task 7).
- Produces: `AdminJpiCreatePairsScreen(tournamentId, tournamentName)`; для парного JPI кнопка «Создать пары» открывает его.

- [ ] **Step 1: Создать экран**

Скопировать `lib/screens/admin/admin_koc_create_pairs_screen.dart` в `lib/screens/admin/admin_jpi_create_pairs_screen.dart`. Замены:
- имя класса `AdminKocCreatePairsScreen` → `AdminJpiCreatePairsScreen` (и его `State`)
- вызовы `AdminService.getKocPairs`/`saveKocPairs` → `getJpiPairs`/`saveJpiPairs`
- заголовки/тексты, если упоминают «Король корта» → «Just Padel It»
Остальную логику (выбор пар, валидация чётности) не менять.

- [ ] **Step 2: Привязать в детали турнира**

В `admin_tournament_detail_screen.dart`:

Импорт рядом с `import 'admin_koc_create_pairs_screen.dart';`:

```dart
import 'admin_jpi_create_pairs_screen.dart';
```

В `_needPairs` (после строки про `king_of_court`):

```dart
    if (t.type == 'just_padel_it' && t.isPaired && !t.jpiPairsCreated) return true;
```

(Если у модели `AdminTournamentDetail` нет геттера `jpiPairsCreated` — проверить, какое поле бэкенд отдаёт для «пары созданы» у JPI в `show()`/детали, и использовать его; при отсутствии — временно `!t.kocPairsCreated` НЕ использовать, а добавить парсинг флага `pairs_created` для JPI. Сверить с тем, что отдаёт бэкенд Task 5 `jpiPairs`/детальный payload.)

В `_openCreatePairs` (где выбирается экран по типу):

```dart
        builder: (_) => t.type == 'just_padel_it'
            ? AdminJpiCreatePairsScreen(tournamentId: t.id, tournamentName: t.name)
            : isKoc
                ? AdminKocCreatePairsScreen(tournamentId: t.id, tournamentName: t.name)
                : AdminBaliCreatePairsScreen(tournamentId: t.id, tournamentName: t.name),
```

(Привести к фактической форме существующего тернарного выбора экрана — добавить JPI-ветку первой, не ломая KoC/Bali.)

- [ ] **Step 3: Анализ**

Run: `flutter analyze lib/screens/admin/admin_jpi_create_pairs_screen.dart lib/screens/admin/admin_tournament_detail_screen.dart`
Expected: без новых ошибок/варнингов.

- [ ] **Step 4: Самопроверка (кода)**

Убедиться: для парного JPI (`is_paired && !pairsCreated`) кнопка ведёт на новый экран; выбор пар сохраняется через `saveJpiPairs`; KoC/Bali пути не задеты.

- [ ] **Step 5: Коммит (без push)**

```bash
git add lib/screens/admin/admin_jpi_create_pairs_screen.dart lib/screens/admin/admin_tournament_detail_screen.dart
git commit -m "feat(admin): экран создания пар JPI + привязка"
```

---

### Task 9: App — экран посева solo + проведение JPI в детали турнира

**Repo:** `C:\projects\padel_app`

**Files:**
- Create: `lib/screens/admin/admin_jpi_seeding_screen.dart`
- Modify: `lib/screens/admin/admin_tournament_detail_screen.dart` (`_start()` для solo JPI; ввод счёта; ветки таблицы/след. раунда/финиша, если тип-специфичны)
- Test: нет (UI; `flutter analyze` + ручная проверка)

**Interfaces:**
- Consumes: `AdminService.getJpiSeeding`, `startTournamentWithOrder`, `saveJpiScore`, `generateNextRound` (общий).
- Produces: solo-поток JPI (посев → старт → счёт → раунды → таблица → финиш) в приложении.

- [ ] **Step 1: Экран посева**

Создать `lib/screens/admin/admin_jpi_seeding_screen.dart` — экран с сигнатурой `AdminJpiSeedingScreen({required int tournamentId, required String tournamentName})`, возвращающий выбранный `List<int> order` (или сам вызывающий старт). Поведение (аналог веб-seeding):
- `initState` → `AdminService.getJpiSeeding(tournamentId)` → список участников (авто по рейтингу) + `courtsCount`.
- Рисовать `courtsCount` блоков «Корт N», в каждом 4 слота-дропдауна со всеми участниками; начальное заполнение — по порядку из ответа.
- Свап при выборе: если игрок выбран в слоте, а он уже стоит в другом слоте — поменять их местами (как веб `seed-select`).
- Кнопка «Начать турнир» → собрать `order` (id по слотам корт1[0..3], корт2[0..3], ...) → `AdminService.startTournamentWithOrder(tournamentId, order)` → `Navigator.pop(context, true)`.
- Стиль: `AppTheme` токены, `AppBackButton`, круглые кнопки навигации — как в соседних admin-экранах. Строки — хардкод RU (admin).

Используемые токены/виджеты брать из соседних экранов (`admin_koc_create_pairs_screen.dart` как референс структуры экрана: AppBar, загрузка, состояние ошибки, кнопка внизу).

- [ ] **Step 2: Solo-старт через посев**

В `admin_tournament_detail_screen.dart`, в обработчике старта `_start()` (или там, где для не-парных типов вызывается `startTournament`) добавить перед общим стартом ветку: если `t.type == 'just_padel_it' && !t.isPaired` — открыть экран посева и стартовать там:

```dart
    if (t.type == 'just_padel_it' && !t.isPaired) {
      final started = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => AdminJpiSeedingScreen(
            tournamentId: t.id,
            tournamentName: t.name,
          ),
        ),
      );
      if (started == true && mounted) {
        await _reload(); // обновить детали после старта
      }
      return;
    }
```

(Импортировать `admin_jpi_seeding_screen.dart`. `_reload()` — привести к фактическому методу перезагрузки деталей в экране.)

- [ ] **Step 3: Ввод счёта JPI**

Там, где экран сохраняет счёт матча по типу (диспетчер `saveXxxScore`), добавить ветку для `just_padel_it` → `AdminService.saveJpiScore(...)`. Найти существующий диспетчер счёта (по вызову `saveKocScore`) и добавить JPI-ветку рядом, с теми же аргументами.

- [ ] **Step 4: Таблица / след. раунд / финиш**

Проверить, что отображение матчей/таблицы и кнопки «Следующий раунд»/«Завершить» для JPI работают на данных `/matches` (Task 2) и общих методах (`generateNextRound`, finish). Если экран ветвит рендер по типу (KoC-специфичные виджеты) — добавить `just_padel_it` в те же условия, что `king_of_court` (JPI-данные структурно идентичны KoC). Если рендер тип-нейтрален — изменений не требуется.

- [ ] **Step 5: Анализ**

Run: `flutter analyze lib/screens/admin/admin_jpi_seeding_screen.dart lib/screens/admin/admin_tournament_detail_screen.dart`
Expected: без новых ошибок/варнингов.

- [ ] **Step 6: Самопроверка (кода)**

Solo JPI: старт открывает посев → редактирование → старт с order; счёт сохраняется через `saveJpiScore`; следующий раунд/таблица/финиш отображаются. KoC/прочие типы не задеты.

- [ ] **Step 7: Коммит (без push)**

```bash
git add lib/screens/admin/admin_jpi_seeding_screen.dart lib/screens/admin/admin_tournament_detail_screen.dart
git commit -m "feat(admin): посев solo JPI + проведение (счёт/раунды/таблица)"
```

---

### Task 10: App — live-экран JPI + навигация

**Repo:** `C:\projects\padel_app`

**Files:**
- Create: `lib/screens/tournament_live_justpadelit_screen.dart` (копия `tournament_live_kingofcourt_screen.dart`)
- Modify: `lib/utils/tournament_navigation.dart` (и/или место, где по типу открывается live-экран)
- Test: нет (UI; `flutter analyze` + ручная проверка)

**Interfaces:**
- Consumes: `GET /tournaments/{id}/live` JPI (Task 6).
- Produces: live-экран просмотра JPI для игроков/зрителей.

- [ ] **Step 1: Экран**

Скопировать `lib/screens/tournament_live_kingofcourt_screen.dart` → `lib/screens/tournament_live_justpadelit_screen.dart`. Замены:
- имя класса `TournamentLiveKingOfCourtScreen` → `TournamentLiveJustPadelItScreen` (+ `State`)
- эндпоинт остаётся `/tournaments/${widget.tournamentId}/live` (тот же — бэкенд сам отдаёт JPI-payload по типу)
- заголовки, если упоминают «Король корта» → «Just Padel It»
Строки — через AppLocalizations (переиспользовать существующие ключи KoC-live; новых не добавлять). Структуру не менять.

- [ ] **Step 2: Навигация**

Найти, где по типу турнира открывается live-экран (grep `TournamentLiveKingOfCourtScreen` в `lib/utils/tournament_navigation.dart` и экранах списка). Добавить ветку для `just_padel_it` → `TournamentLiveJustPadelItScreen` рядом с `king_of_court`-веткой, тем же способом (те же аргументы конструктора).

- [ ] **Step 3: Анализ**

Run: `flutter analyze lib/screens/tournament_live_justpadelit_screen.dart lib/utils/tournament_navigation.dart`
Expected: без новых ошибок/варнингов.

- [ ] **Step 4: Самопроверка (кода)**

Тап по активному JPI-турниру у игрока открывает `TournamentLiveJustPadelItScreen`; экран грузит `/live` и рисует раунды/таблицу. KoC-навигация не задета.

- [ ] **Step 5: Коммит (без push)**

```bash
git add lib/screens/tournament_live_justpadelit_screen.dart lib/utils/tournament_navigation.dart
git commit -m "feat: live-экран Just Padel It + навигация"
```

---

## Notes для исполнителя

- Порядок задач: 1-6 бэкенд (`padel`, коммит+push каждая), 7-10 app (`padel_app`, только коммит). Task 1 первым — снимает блокер со стартом.
- Где сказано «копия KoC-метода/экрана» — открыть образец по указанному адресу, скопировать дословно, применить только перечисленные замены. Структуру и ключи ответов/пейлоадов не менять — иначе разъедется совместимость app↔бэкенд.
- Модель `Tournament` и `AdminTournamentDetail`: перед использованием геттеров (`isJustPadelIt`, `isPairedJustPadelIt`, `jpiPairsCreated`) проверить их наличие; при отсутствии — использовать имеющиеся поля (`is_paired`, `type == 'just_padel_it'`, флаг `pairs_created` из payload) и не трогать KoC-геттеры.
- Если фактические имена связей/полей у JPI-моделей отличаются от предполагаемых в тестах — привести тест к факту образца (KoC), сохранив смысл проверки.
- App-экраны: строки admin — RU хардкод; live-экран — AppLocalizations (ключи KoC).
```
