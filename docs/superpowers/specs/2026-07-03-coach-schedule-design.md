# Расписание тренера в приложении — дизайн

**Дата:** 2026-07-03
**Статус:** утверждён, к реализации
**Область:** Flutter `padel_app` + Laravel `padel`

## Цель
Тренер (роль `coach`) видит своё расписание в приложении — как в вебе
`https://padel-p.kz/coach/schedule`. Только просмотр. Вход — блок «Тренер» на
главной (рядом с «Управление клубом»), кнопка «Расписание».

## Решения
- **Только просмотр** (редактирование — у админа клуба, как сейчас).
- **Один клуб** у тренера (сервер берёт первый `ClubCoach`).
- В занятом слоте показываем **корт + имя клиента + время**.

## Бэкенд
Новый эндпоинт `GET /api/mobile/coach/schedule?date=YYYY-MM-DD` (auth:sanctum,
только `role == 'coach'`). Логика повторяет `Coach\DashboardController::index`
(через `ClubCoach::daySchedule($date)`).

Ответ:
```jsonc
{
  "coach": { "name": "…", "club_name": "ADD Padel" },
  "date": "2026-07-03",
  "busy_hours": 2.0,
  "slots": [
    { "time": "10:00", "status": "free" },
    { "time": "11:00", "status": "booked",
      "booking": { "court": "Корт 1", "client": "Иван П.", "start": "11:00", "end": "12:00" } },
    { "time": "12:00", "status": "blocked" }
  ],
  "week": [
    { "date": "2026-06-30", "day_name": "пн", "day_num": "30",
      "is_today": false, "is_selected": false, "hours": 3.0 }
  ]
}
```
- Нет `ClubCoach` у пользователя → 403.
- Новый `MobileCoachController::schedule` + роут в группе auth.

## Фронтенд
- `User.isCoach` геттер (`role == 'coach'`).
- Блок «Тренер» на главной (только при `user.isCoach`) с кнопкой «Расписание».
- `models/coach_schedule.dart` — `CoachDaySchedule`, `CoachSlot`, `CoachSlotBooking`, `CoachWeekDay`.
- `services/coach_service.dart` — `getSchedule(date)`.
- `screens/coach_schedule_screen.dart`:
  - шапка (кнопка назад + имя клуба), «Занято сегодня: N ч»;
  - недельная навигация — 7 дней-чипов с бейджем часов;
  - таймлайн дня — часовые слоты: время + статус (Свободно/Занято/Заблокировано),
    занятый показывает корт + клиента; стиль слотов из расписания кортов.
- l10n RU/EN/KK для новых строк.

## Вне области (этап 1)
Редактирование/блокировка слотов тренером, несколько клубов, смена пароля.
