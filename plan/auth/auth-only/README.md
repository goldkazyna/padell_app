# Padel App — Экран входа (V2 Tinted)

Спецификация для разработчика. Экран **Вход** (авторизация).

---

## Что меняется vs. оригинал

| Было | Стало |
|---|---|
| Только вход через Telegram (основная крупная синяя кнопка) | 4 равнозначных способа соц-входа: **Telegram · WhatsApp · Google · Apple** одинаковыми карточками в столбик, ни один не выделен визуально как primary |
| Вход через Email/телефон — вторая кнопка того же уровня | Email/телефон вынесен **отдельно** снизу через разделитель «или» — это fallback-способ, не в одном списке с соц-провайдерами |
| Hero с логотипом или без, крупный заголовок | Компактный заголовок «Вход» (22px) + подзаголовок «Выберите удобный способ». Экран остаётся воздушным, но не кричит. |
| Два отдельных чекбокса (Пользовательское соглашение + Согласие на обработку данных) внизу | Один чекбокс-строка с обеими ссылками сразу в тексте — меньше визуального шума, та же юридическая семантика |
| Никакой атмосферы | Мягкий ambient glow (зелёный радиал 8%) в правом верхнем углу — едва заметная подсветка, не отвлекает |

---

## Design tokens (те же что в Профиле / Турнирах)

### Цвета

```css
/* Фон и поверхности */
--bg:              #131317;   /* основной фон экрана */
--card:            #1c1c21;   /* нейтральная карточка (back-button) */
--border:          rgba(255, 255, 255, 0.08);

/* Текст */
--text:            #f3f3f5;
--text-muted:      #a2a2ab;
--text-dim:        #6a6a73;

/* Акцент */
--green:           #22c47a;  /* чекбокс активный + подчёркивания ссылок */

/* Brand tints провайдеров — очень тонкие, 6% fill + 18% border */
--telegram-tint-bg:      rgba(34, 158, 217, 0.06);
--telegram-tint-border:  rgba(34, 158, 217, 0.18);
--whatsapp-tint-bg:      rgba(37, 211, 102, 0.06);
--whatsapp-tint-border:  rgba(37, 211, 102, 0.18);
--neutral-tint-bg:       rgba(255, 255, 255, 0.04);  /* Google, Apple */
--neutral-tint-border:   rgba(255, 255, 255, 0.12);

/* Ambient glow */
/* top-right radial: rgba(34,196,122,0.08) → transparent */
```

### Brand цвета иконок (оригинальные)

| Провайдер | Круг | Иконка |
|---|---|---|
| Telegram | `#229ED9` | белая `paper-plane` |
| WhatsApp | `#25D366` | белая `phone-chat` |
| Google | `#fff` | оригинал 4 цвета (Google G mark) |
| Apple | `#f3f3f5` | `#0a0a0d` apple silhouette |
| Email | `#2a2a31` (neutral) | contour конверт 1.6px stroke, цвет `--text-muted` |

### Типографика

```
font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif
```

| Элемент | Размер | Вес | letter-spacing |
|---|---|---|---|
| Заголовок «Вход» | 22 | 700 | -0.4 |
| Подзаголовок | 13 | 400 | 0 |
| Лейбл провайдера | 14 | 600 | 0 |
| «или» разделитель | 12 | 500 | 0 |
| Текст чекбокса | 11 | 400 | 0, `line-height: 1.5` |
| Footer (Developed by) | 10 | 400 | 0, `opacity: 0.6` |

### Скругления и отступы

| Элемент | Value |
|---|---|
| Кнопка провайдера | `border-radius: 14px`, `padding: 13px 16px` |
| Back-button | `width: 38px`, `height: 38px`, `border-radius: 12px` |
| Чекбокс | `width: 18px`, `height: 18px`, `border-radius: 5px` |
| Горизонтальный padding экрана | `20px` |
| Gap между кнопками провайдеров | `8px` |
| Gap между блоком провайдеров и «или» | `18px` сверху, `14px` снизу |

---

## Структура экрана сверху вниз

1. **Back-button** (38×38, top-left) — `<- arrow`, `--card` фон + `--border`

2. **Header block** (26px отступ от кнопки назад)
   - Заголовок: `Вход` — 22px, 700
   - Подзаголовок: `Выберите удобный способ` — 13px, `--text-muted`

3. **Блок соц-провайдеров** (22px gap) — 4 кнопки-карточки в столбик:
   1. **Telegram** — синий tint (`--telegram-tint-*`)
   2. **WhatsApp** — зелёный tint (`--whatsapp-tint-*`)
   3. **Google** — нейтральный tint (`--neutral-tint-*`)
   4. **Apple** — нейтральный tint (`--neutral-tint-*`)

   Каждая кнопка: `[brand-icon 24px] [label, flex:1] [chevron right 14px, 25% alpha]`

4. **Разделитель «или»** (18px margin-top, 14px margin-bottom) — два `1px` hairline с центрированным текстом `или`

5. **Email fallback** — одна отдельная кнопка (transparent bg, `--border`), центрированный контент:
   `[mail-icon 22px] Войти через Email или телефон`

6. **Spacer `flex: 1`** — прижимает чекбокс и футер вниз

7. **Consent** (12px margin-bottom)
   - Чекбокс 18×18 + текст: `Продолжая, я принимаю <Пользовательское соглашение> и <согласие на обработку данных>` — ссылки подчёркнуты `--green` с offset 2px

8. **Footer** — `Developed by Dudnikov Denis`, 10px, `--text-dim`, `opacity: 0.6`, по центру

---

## Компоненты

### `<AuthScreen>`
Корневой экран. Принимает:
```ts
type AuthScreenProps = {
  onProvider: (id: 'telegram' | 'whatsapp' | 'google' | 'apple' | 'email') => void;
  onBack: () => void;
  onOpenTerms: () => void;
  onOpenPrivacy: () => void;
};
```

### `<AuthRow provider>`
Одна строка-кнопка провайдера. Принимает объект:
```ts
type Provider = {
  id: 'telegram' | 'whatsapp' | 'google' | 'apple';
  label: string;
  icon: ComponentType<{ size?: number }>;
  tint: { bg: string; border: string };
};
```

### `<EmailButton>`
Отдельная кнопка Email/телефона — transparent bg, центрированный контент.

### Brand icons
Все 22×22 или 24×24 viewBox, inline SVG:
- `BrandTelegram`, `BrandWhatsApp`, `BrandGoogle`, `BrandApple` — с брендовыми цветами
- `BrandEmail` — параметризован `bg` + `fg`, по умолчанию `#2a2a31` + `--text-muted`

### Utility icons
- `IconArrowBack` (24×24, stroke 2px)
- `IconCheck` (12×12, stroke 2.5px, для чекбокса)
- `IconChev` (16×16, параметризован `color`)

---

## Поведение / интеракции

| Action | Result |
|---|---|
| Tap на любую из 4 соц-кнопок | Запустить OAuth/SDK-флоу соответствующего провайдера, `onProvider(id)` |
| Tap на Email-кнопку | Перейти на экран ввода email/телефона |
| Tap на back-button | `router.back()` / `onBack()` |
| Tap на ссылку «Пользовательское соглашение» | Открыть документ (web-view или модалка) |
| Tap на ссылку «согласие на обработку данных» | Открыть документ |
| Tap на чекбокс | Toggle `agreed` (по умолчанию `true`, визуально заполненный зелёным) |
| Если `agreed === false` при tap на любую кнопку провайдера | Показать inline-error под чекбоксом, не запускать флоу |

---

## Состояния кнопок (TBD при имплементации)

- **Default** — как на макете
- **Pressed** — `transform: scale(0.98)` + `opacity: 0.9`
- **Loading** (во время OAuth) — заменить chevron на spinner, disable весь экран с `pointer-events: none`
- **Disabled** (если провайдер временно недоступен) — `opacity: 0.4`

---

## Accessibility

- Все кнопки — semantic `<button>` с `aria-label` (например `"Войти через Telegram"`)
- Чекбокс — `role="checkbox"` + `aria-checked` + `aria-label="Согласие с условиями"`
- Ссылки внутри consent-текста — реальные `<a>`, открываются в `target="_blank"` с `rel="noopener"`
- Min hit-target 44px — текущие кнопки 46px высотой, ок

---

## Файлы прототипа

- `auth.html` — корневой HTML
- `src/auth-assets.jsx` — brand-иконки, utility-иконки, список провайдеров `PROVIDERS`
- `src/auth-v2.jsx` — `AuthScreen_V2` + `AuthRow_V2` + `EmailButton_V2` + tint-карта

Открыть прототип: `auth.html` в браузере (или VS Code Live Server).
