# Padel App — Экран профиля (V1)

Спецификация для разработчика. Обновлённый экран **Профиль** (вкладка в табе).

---

## Что изменилось vs. оригинал

| Было | Стало |
|---|---|
| Зелёный hero-блок «имя + рейтинг + редактировать» с 4 метриками под ним отдельной полосой | Единая премиум-карточка с PRO-бейджем, огромным рейтингом, sparkline динамики, прогрессом уровня и встроенной строкой статов (матчей/побед/винрейт/пораж.) |
| История турниров — простой список | Каждая запись — карточка с большим левым блоком дельты (иконка ▲/▼ + число очков), название и медаль справа. Чтение дельты на порядок быстрее. |
| Настройки в сетке 2×3 из больших квадратов — много воздуха, деструктив на том же уровне | Плотный list-style по 4 пункта в одной карточке (иконка 28px в цветной tint-подложке, название справа, подзаголовок-значение, chevron). Деструктив **отдельной** карточкой внизу с красной акцентной палитрой. |
| Винрейт без семантического цвета | Винрейт окрашивается зелёным при ≥60%, amber при 40-59%, красным при <40% |
| Разработчик-блок крупной карточкой | Минимальная строка внизу |

---

## Design tokens (утверждены)

### Цвета

```css
/* Фон и поверхности */
--bg:              #131317;   /* основной фон (чуть теплее чёрного) */
--card:            #1c1c21;   /* карточки */
--card-raised:     #23232a;
--border:          rgba(255, 255, 255, 0.06);
--divider:         rgba(255, 255, 255, 0.05);

/* Текст */
--text:            #f3f3f5;
--text-muted:      #a2a2ab;
--text-dim:        #6a6a73;

/* Акценты */
--green:           #22c47a;
--green-soft:      rgba(34, 196, 122, 0.14);
--blue:            #4a8bf5;
--orange:          #f08446;
--red:             #f0554d;
--red-soft:        rgba(240, 85, 77, 0.12);
--amber:           #eab34e;
--purple:          #a89cf5;   /* tint для иконки «Язык» */
```

### Hero gradient

```css
background: linear-gradient(140deg, #1e3a2b 0%, #1a241e 40%, #1a1a1f 100%);
```

Декоративное зелёное свечение в правом верхнем углу:
```css
position: absolute; top: -60px; right: -60px; width: 180px; height: 180px;
border-radius: 50%;
background: radial-gradient(circle, rgba(34,196,122,0.12) 0%, transparent 60%);
```

### Типографика

```
font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif
```

| Элемент | Размер | Вес | letter-spacing |
|---|---|---|---|
| Имя пользователя | 16 | 600 | -0.2 |
| Рейтинг (крупный) | 38 | 700 | -1.3 |
| Заголовки секций | 15 | 600 | -0.2 |
| Caps-лейблы (Рейтинг, Настройки) | 10-11 | 600 | +1.4, TEXT-TRANSFORM: uppercase |
| Title строки списка | 14 | 500 | 0 |
| Subtitle / значение | 11-12 | 400 | 0 |
| Delta в истории | 14 | 700 | -0.3, `font-variant-numeric: tabular-nums` |

### Скругления и отступы

| Элемент | Value |
|---|---|
| Hero card | `border-radius: 20px` |
| Обычные карточки | `border-radius: 14px` |
| Кнопки / tint-иконки | `border-radius: 10px` |
| Внутренние отступы карточек | `16-18px` |
| Горизонтальный отступ экрана | `16px` |
| Gap между секциями | `22px` (от предыдущей секции до caps-label) |

---

## Структура экрана сверху вниз

1. **Hero card** (зелёный градиент)
   - Аватар 58×58 (fallback — инициалы)
   - Имя + PRO бейдж
   - Телефон
   - Кнопка редактирования (36×36, иконка edit)
   - Caps «РЕЙТИНГ» + число 38px + `#63`
   - Sparkline 110×38 справа от рейтинга
   - Прогресс уровня: `Уровень 3.75 → 4.00` + `3775 / 4000` + полоска 3px
   - Stats strip (внутри hero, отделена `border-top` + затемнением фона 0.2): Матчей · Побед · Винрейт (зелёный) · Пораж. (muted)

2. **История турниров** (22px gap сверху)
   - Header: title + «Все →» ссылка зелёным
   - Список из 4 записей-карточек
   - Каждая запись: `[дельта-блок 58px с иконкой тренда и числом · название · дата] [медаль 22-24px]`
   - Дельта-блок: фон `--green-soft` или `--red-soft`, текст зелёный/красный; стрелка ▲ для + и ▼ для −

3. **Настройки** (22px gap, caps-label)
   - Одна карточка, 4 строки
   - Строка: иконка 28×28 в цветной tint-подложке + title + sub (значение) + chevron
   - Порядок и tint:
     - Настройки профиля — green
     - Мои бронирования — blue
     - Уведомления — amber
     - Язык — purple

4. **Аккаунт** (отдельная секция, caps-label)
   - Две строки в карточке, красная акцентная палитра для иконок
   - Выйти — иконка в `--red-soft`
   - Удалить аккаунт — заголовок красный, подзаголовок «Безвозвратное удаление»

5. **Разработчик** (нижний блок)
   - Маленькая строка с иконкой кода + имя/handle + external-link

6. **Нижний таб-бар** (5 вкладок: Главная, Турниры, Бронирование, Рейтинг, Профиль)
   - Активная вкладка — зелёная иконка и лейбл + индикатор-таблетка 20×2 сверху

---

## Компоненты

### `Medal({ place, size })`
SVG медали с ленточкой. Цвет диска:
- 1 → `#e9c46a` (золото)
- 2 → `#c7c9cf` (серебро)
- 3 → `#cd8a4b` (бронза)

### `Sparkline({ points, color, width, height })`
Линия + area-fill градиент от `color@0.3` до `color@0`, последняя точка — заполненный кружок 2.5px.

### `IconTrophyFilled`, `IconEdit`, `IconGlobe`, `IconBookmark`, `IconBellSmall`, `IconLogout`, `IconTrash`, `IconCode`, `IconExternal`, `IconChevronRight`, `IconUserSmall`, `IconHome`, `IconTrophy`, `IconCalendar`, `IconChart`, `IconUser`
24×24 viewBox, `stroke-width: 1.5`, `stroke-linecap: round`, `stroke-linejoin: round`.

---

## Данные

```ts
type Profile = {
  name: string;
  phone: string;
  avatarUrl: string | null;
  initials: string;       // fallback когда нет фото
  isPro: boolean;
  rating: number;          // 3775
  ratingRank: number;      // 63
  level: number;           // 3.75
  nextLevel: number;       // 4.00
  levelProgress: number;   // 3775
  levelTarget: number;     // 4000
  matches: number;
  wins: number;
  winrate: number;         // 66
  ratingTrend: number[];   // история для sparkline, ~9 точек
};

type TournamentHistoryItem = {
  id: string;
  name: string;         // "L3 🔥парный"
  date: string;         // "12 апреля"
  delta: number;        // +24 / -46
  place: 1 | 2 | 3 | null;
  medal: 'gold' | 'silver' | 'bronze' | 'trophy';
};
```

---

## Интеракции

- Кнопка редактирования в hero → экран `/profile/edit`
- Клик по карточке истории → экран турнира
- «Все →» → экран полной истории
- Клик по строке настройки → соответствующий экран
- Выйти → confirm-диалог, затем logout
- Удалить аккаунт → двойной confirm с вводом фразы

---

## Файлы прототипа

- `settings.html` — корневой HTML
- `src/settings-v1.jsx` — layout экрана (Hero, History wrapper, SettingsList wrapper, Danger, Dev, Nav)
- `src/history-variants.jsx` — компонент `History_H4` (финальный)
- `src/settings-group-variants.jsx` — компонент `Settings_G1` (финальный Dense list)
- `src/data-profile-page.jsx` — моковые данные + иконки
- `src/icons.jsx`, `src/icons-profile.jsx` — разделяемые иконки
- `src/sparkline.jsx` — sparkline компонент
