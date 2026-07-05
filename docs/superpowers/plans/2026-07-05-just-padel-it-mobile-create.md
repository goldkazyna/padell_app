# Just Padel It в приложении — под-проект A (создание) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Дать администратору создавать турнир типа `just_padel_it` прямо из мобильного приложения (solo и с фиксированными парами).

**Architecture:** Две независимые части. (1) Мобильный бэкенд `MobileAdminTournamentController` (Laravel `C:\projects\padel`) принимает тип `just_padel_it` и флаг `is_paired`. (2) Мобильная форма создания `admin_create_tournament_screen.dart` (Flutter `C:\projects\padel_app`) получает карточку типа, переключатель «Пары» и визуальный контрол «Тип подсчёта». Вся серверная логика формата (движок, бонусы, таблица) уже написана и запушена — здесь только приём типа при создании; проведение — отдельный под-проект B.

**Tech Stack:** Laravel (PHP, PHPUnit), Flutter/Dart, Sanctum-аутентификация мобильного API.

## Global Constraints

- Два разных репозитория: бэкенд `C:\projects\padel`, приложение `C:\projects\padel_app`. Задачи не смешивать между репозиториями.
- **Бэкенд (`padel`) коммитим и пушим сразу** после правки (правило проекта).
- **Приложение (`padel_app`) НЕ пушим** — пользователь собирает локально `flutter run`. Коммит в app-задаче делаем, push не делаем.
- Значение типа турнира ровно `just_padel_it` (snake_case) — везде одинаково.
- Мобильный эндпоинт создания для клуба: `POST /api/mobile/admin/clubs/{club}/tournaments`; ответ `assertOk()` + `success: true`.
- Enum `tournaments.type` уже содержит `just_padel_it` (миграция веб-части) — новых миграций нет.
- Строки в app-форме: админ-экраны допускают хардкод RU (правило проекта) — локализация не требуется.
- Контрол «Тип подсчёта» в v1 значение НЕ отправляет (бэкенд-дефолт «по очкам»).

---

### Task 1: Бэкенд — приём типа `just_padel_it` и `is_paired` при создании

**Repo:** `C:\projects\padel`

**Files:**
- Modify: `app/Http/Controllers/Api/MobileAdminTournamentController.php` (правило типа в `tournamentValidationRules()` ~строка 246; блок маппинга `is_paired` в `finalizeTournamentCreate()` ~строки 327-338)
- Test: `tests/Feature/MobileAdminJustPadelItCreateTest.php` (создать)

**Interfaces:**
- Consumes: существующий эндпоинт `POST /api/mobile/admin/clubs/{club}/tournaments` → `store()` → `tournamentValidationRules()` + `finalizeTournamentCreate()`.
- Produces: после задачи мобильный create принимает `type: just_padel_it` (solo и paired), сохраняет `Tournament` с `type='just_padel_it'` и корректным `is_paired`. Под-проект B на это опирается.

- [ ] **Step 1: Написать падающий тест**

Создать `tests/Feature/MobileAdminJustPadelItCreateTest.php`:

```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Club;
use App\Models\Tournament;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class MobileAdminJustPadelItCreateTest extends TestCase
{
    use RefreshDatabase;

    private function actingAdminWithClub(): Club
    {
        $club = Club::create(['name' => 'C', 'address' => 'A', 'city' => 'Алматы']);
        $admin = User::factory()->create(['role' => 'club_admin']);
        $admin->adminClubs()->attach($club->id);
        Sanctum::actingAs($admin);
        return $club;
    }

    public function test_admin_creates_solo_just_padel_it_via_mobile(): void
    {
        $club = $this->actingAdminWithClub();

        $this->postJson("/api/mobile/admin/clubs/{$club->id}/tournaments", [
            'type' => 'just_padel_it',
            'name' => 'JPI турнир',
            'start_date' => now()->addDay()->toIso8601String(),
            'min_level' => 1.0,
            'max_level' => 5.0,
            'max_participants' => 12,
            'status' => 'open',
            'courts_count' => 3,
        ])
            ->assertOk()
            ->assertJsonPath('success', true);

        $t = Tournament::where('type', 'just_padel_it')->first();
        $this->assertNotNull($t);
        $this->assertFalse((bool) $t->is_paired);
    }

    public function test_admin_creates_paired_just_padel_it_via_mobile(): void
    {
        $club = $this->actingAdminWithClub();

        $this->postJson("/api/mobile/admin/clubs/{$club->id}/tournaments", [
            'type' => 'just_padel_it',
            'name' => 'JPI пары',
            'start_date' => now()->addDay()->toIso8601String(),
            'min_level' => 1.0,
            'max_level' => 5.0,
            'max_participants' => 12,
            'status' => 'open',
            'courts_count' => 3,
            'is_paired' => true,
        ])
            ->assertOk()
            ->assertJsonPath('success', true);

        $t = Tournament::where('type', 'just_padel_it')->first();
        $this->assertNotNull($t);
        $this->assertTrue((bool) $t->is_paired);
    }
}
```

- [ ] **Step 2: Запустить тест — убедиться, что падает**

Run: `php artisan test --filter=MobileAdminJustPadelItCreateTest`
Expected: FAIL. `test_admin_creates_solo...` падает на валидации (422, т.к. `just_padel_it` нет в `in:`), либо `success` не `true`. `test_admin_creates_paired...` — на `assertTrue($t->is_paired)` (маппинг ставит `false`).

- [ ] **Step 3: Добавить тип в правило валидации**

В `app/Http/Controllers/Api/MobileAdminTournamentController.php`, метод `tournamentValidationRules()`, заменить строку правила типа:

```php
            'type' => 'required|in:king_of_court,americano,americano_flex,bali_koc,team,round_robin',
```

на:

```php
            'type' => 'required|in:king_of_court,americano,americano_flex,bali_koc,team,round_robin,just_padel_it',
```

- [ ] **Step 4: Добавить ветку `is_paired` для JPI**

В том же файле, метод `finalizeTournamentCreate()`, блок маппинга `is_paired`. Найти:

```php
        } elseif ($type === 'king_of_court' && $request->boolean('is_paired')) {
            $validated['is_paired'] = true;
        } else {
            $validated['is_paired'] = false;
        }
```

Заменить на (вставить ветку JPI перед `else`):

```php
        } elseif ($type === 'king_of_court' && $request->boolean('is_paired')) {
            $validated['is_paired'] = true;
        } elseif ($type === 'just_padel_it' && $request->boolean('is_paired')) {
            $validated['is_paired'] = true;
        } else {
            $validated['is_paired'] = false;
        }
```

- [ ] **Step 5: Запустить тест — убедиться, что проходит**

Run: `php artisan test --filter=MobileAdminJustPadelItCreateTest`
Expected: PASS (2 passed).

- [ ] **Step 6: Прогнать смежные тесты создания на регрессии**

Run: `php artisan test --filter=MobileAdminAmericanoFlexTest`
Expected: PASS (существующее поведение flex/KoC не задето).

- [ ] **Step 7: Коммит и пуш**

```bash
git add app/Http/Controllers/Api/MobileAdminTournamentController.php tests/Feature/MobileAdminJustPadelItCreateTest.php
git commit -m "feat(mobile-api): приём типа just_padel_it при создании турнира"
git push
```

---

### Task 2: Приложение — тип JPI в форме создания

**Repo:** `C:\projects\padel_app`

**Files:**
- Modify: `lib/screens/admin/admin_create_tournament_screen.dart`
  - тело запроса `is_paired` (рядом с веткой KoC ~строка 300)
  - блок после поля цены с `_pairedToggle()` (~строки 494-497)
  - список карточек типов (билдер `card(...)` ~строки 671-760)
  - новый метод-виджет `_scoreTypeControl()` (рядом с `_pairedToggle()` ~строка 1818)

**Interfaces:**
- Consumes: бэкенд из Task 1 принимает `type: just_padel_it` и `is_paired`. Существующее состояние `String _type`, `bool _flexIsPaired`, виджеты `card({required String value, required String title, required String subtitle, required IconData icon})`, `_pairedToggle()`, `_label(String)`, токены `AppTheme.accent/cardRaised/border/textPrimary/textDim/textSecondary`.
- Produces: пользовательская фича — админ выбирает «Just Padel It», задаёт пары, видит «Тип подсчёта», создаёт турнир.

- [ ] **Step 1: Добавить карточку типа `just_padel_it`**

В `_type`-комментарии (строка 49) дополнить перечисление типов, добавив `/ just_padel_it` в конец комментария (косметика, чтобы список типов был полон).

В списке карточек типов (внутри `Row` билдера `card(...)`), сразу после карточки `king_of_court` добавить:

```dart
            card(
              value: 'just_padel_it',
              title: 'Just Padel It',
              subtitle: 'Движение по кортам + бонусы',
              icon: Icons.local_fire_department_outlined,
            ),
```

- [ ] **Step 2: Показать «Пары» и «Тип подсчёта» для JPI**

Найти блок после поля цены (строки 494-497):

```dart
            if (_type == 'americano_flex' || _type == 'king_of_court') ...[
              const SizedBox(height: 12),
              _pairedToggle(),
            ],
```

Заменить на:

```dart
            if (_type == 'americano_flex' ||
                _type == 'king_of_court' ||
                _type == 'just_padel_it') ...[
              const SizedBox(height: 12),
              _pairedToggle(),
            ],
            if (_type == 'just_padel_it') ...[
              const SizedBox(height: 12),
              _scoreTypeControl(),
            ],
```

- [ ] **Step 3: Отправлять `is_paired` для paired JPI**

Найти ветку KoC в сборке тела запроса (~строка 300):

```dart
    if (_type == 'king_of_court' && _flexIsPaired) {
      // Король корта с фиксированными парами: пары админ создаёт после набора.
      body['is_paired'] = true;
    }
```

Сразу после неё добавить:

```dart
    if (_type == 'just_padel_it' && _flexIsPaired) {
      // Just Padel It с фиксированными парами: пары создаются на этапе проведения.
      body['is_paired'] = true;
    }
```

- [ ] **Step 4: Добавить метод-виджет `_scoreTypeControl()`**

Сразу перед методом `Widget _pairedToggle() {` (строка 1818) вставить:

```dart
  // Тип подсчёта результата. v1: активна только «По очкам»; «По сетам» — заглушка.
  // Значение не отправляется — бэкенд по умолчанию считает по очкам.
  Widget _scoreTypeControl() {
    Widget pill({
      required String text,
      required bool active,
      required bool enabled,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? AppTheme.accent.withOpacity(0.15)
                : AppTheme.cardRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? AppTheme.accent : AppTheme.border,
              width: active ? 1.4 : 1,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: enabled
                  ? (active ? AppTheme.accent : AppTheme.textPrimary)
                  : AppTheme.textDim,
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Тип подсчёта'),
        Row(
          children: [
            pill(text: 'По очкам', active: true, enabled: true),
            const SizedBox(width: 10),
            pill(text: 'По сетам · скоро', active: false, enabled: false),
          ],
        ),
      ],
    );
  }
```

- [ ] **Step 5: Статический анализ**

Run: `flutter analyze lib/screens/admin/admin_create_tournament_screen.dart`
Expected: без новых ошибок/варнингов по этому файлу (`No issues found!` либо только уже существовавшие info-уровня по проекту — новых от правок быть не должно).

- [ ] **Step 6: Ручная проверка (smoke)**

Собрать и проверить вручную (`flutter run`, целевое устройство телефона):
1. В форме создания появилась карточка «Just Padel It»; при выборе она подсвечивается как активная.
2. При выбранном JPI виден переключатель «Парный» и контрол «Тип подсчёта» с активной «По очкам» и задизейбленной «По сетам · скоро».
3. Поле «Количество раундов» НЕ показывается (оно только для «Американо»).
4. Создание solo (переключатель выкл) проходит, турнир появляется в списке.
5. Создание paired (переключатель вкл) проходит; на бэке `is_paired=true` (проверяется веб-интерфейсом клуба / БД).

Отметить результаты пунктов в отчёте. (Автотестов виджета для этого экрана в проекте нет — как и для остальных типов.)

- [ ] **Step 7: Коммит (без push — правило проекта)**

```bash
git add lib/screens/admin/admin_create_tournament_screen.dart
git commit -m "feat(admin): тип Just Padel It в форме создания турнира"
```

---

## Notes для исполнителя

- Task 1 и Task 2 — в разных репозиториях. Не смешивать пути и коммиты.
- Task 1 пушится (`git push`), Task 2 — только коммит, без push.
- Поле «Кол-во раундов» для JPI трогать НЕ нужно: оно рендерится и уходит в тело только в ветке `if (_type == 'americano')`, поэтому для JPI отсутствует автоматически.
- Контрол «Тип подсчёта» — чисто визуальный, без состояния и без отправки на сервер (YAGNI: «По сетам» появится в отдельной итерации, когда режим реально заработает).
