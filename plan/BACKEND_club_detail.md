# Задача бэкендеру: карточка клуба

## Что нужно

Мобильное приложение получило новый экран «Карточка клуба» (открывается из вкладки «Турниры» по иконке ⓘ рядом с названием клуба). Фронт готов, ждёт API.

## Endpoint

```
GET /api/mobile/clubs/{id}
```

- **Auth:** Bearer-токен (как у остальных мобильных ручек, например `/tournaments/{id}`)
- **Method:** GET
- **Path param:** `id` — ID клуба

## Ответ (200 OK)

```json
{
  "id": 1,
  "name": "Padel Club Almaty",
  "address": "ул. Абая 100",
  "city": "Алматы",
  "logo": "https://padel-p.kz/storage/clubs/1/logo.png",
  "description": "Современный падел-клуб в центре города. 4 корта, раздевалки, кафе, парковка.",
  "phone": "+7 777 123 45 67",
  "courts_count": 4,
  "min_price": 5000
}
```

### Обязательные поля
- `id` — int
- `name` — string

### Опциональные (могут быть null)
- `address` — string
- `city` — string
- `logo` — URL картинки
- `description` — **НОВОЕ ПОЛЕ** — текст описания клуба (мультилайн)
- `phone` — string
- `courts_count` — int
- `min_price` — number

Фронт принимает любой из форматов обёртки — плоский JSON, `{"data": {...}}` или `{"club": {...}}`.

## Миграция БД

Скорее всего в таблице `clubs` нет колонки `description`. Нужно добавить:

```php
Schema::table('clubs', function (Blueprint $table) {
    $table->text('description')->nullable()->after('city');
});
```

И дать возможность заполнять `description` в админке (Filament/Nova/что используется).

## Ответы при ошибках

- `404 Not Found` — если клуба с таким id нет
- `401 Unauthorized` — если токен невалиден

## Как проверить

```bash
curl -H "Authorization: Bearer <token>" https://padel-p.kz/api/mobile/clubs/1
```

Должен вернуться JSON как выше.

## Где на фронте это используется

- `lib/services/club_service.dart` — вызывает endpoint
- `lib/screens/club_detail_screen.dart` — показывает карточку
- `lib/models/club.dart` — парсит ответ

Блоки «Описание», «Телефон» на экране скрываются автоматически если соответствующие поля пустые — можно выкатывать поэтапно.
