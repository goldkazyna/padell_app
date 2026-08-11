You are a senior frontend engineer. Implement the **Profile** tab for the padel mobile app (React Native or React web — follow the project's existing stack).

# Context

We're refreshing the existing Profile screen without scaring users — same information, better hierarchy, tighter layout, premium hero card. The old design had: a flat green hero, a separate row of 4 stat cards, a simple history list, and a wasteful 2×3 grid of huge square settings tiles. The new design unifies stats into a single premium hero, makes history scannable via bold delta chips, and collapses settings into a dense list.

All design tokens and structure are spec'd in `README.md`. Use that as the source of truth. A working prototype lives in `settings.html` + `src/settings-v1.jsx` — reference it for exact spacing, colors, typography ratios.

# Your task

Build the screen end-to-end, matching the prototype pixel-ratios and using the existing app's component library / design tokens where present. Do NOT copy colors verbatim if the project already has a token system — map to existing tokens that closest match the hex values in README.md.

# Screen structure (top → bottom)

1. **Hero card** — green gradient (`linear-gradient(140deg, #1e3a2b 0%, #1a241e 40%, #1a1a1f 100%)`), decorative radial glow top-right
   - Row 1: avatar 58px · name + PRO pill · edit icon-button
   - Row 2: "РЕЙТИНГ" caps-label · 38px number · #rank · sparkline (last 9 ratings) on the right
   - Row 3: level progress bar ("Уровень X → Y" + "progress / target" + 3px-tall bar)
   - Bottom strip (inside hero, dark overlay 20% + border-top): 4 equal-spaced stats — Матчей · Побед · Винрейт (green) · Пораж. (muted)

2. **История турниров** — section header "История турниров" + "Все →" link. Each row:
   - Left: 58px delta block with green-soft or red-soft background, triangle-arrow icon (▲ up for +, ▼ down for −) + absolute value of delta + "очков" caps
   - Middle: tournament name (single line, ellipsis) + date
   - Right: medal SVG (place 1/2/3 with ribbon) or trophy icon
   - 4 items visible, tap opens tournament detail

3. **Настройки** — caps-label, single card with 4 rows (Dense list):
   - 28px icon in tinted colored square (green / blue / amber / purple)
   - Title "Настройки профиля" / "Мои бронирования" / "Уведомления" / "Язык"
   - Right-aligned value ("Имя, город, пол" / "Забронированные корты" / "Настройки уведомлений" / "Русский")
   - Chevron right at end
   - Dividers between rows (`rgba(255,255,255,0.05)`)

4. **Аккаунт** — caps-label, separate card for destructive actions:
   - Выйти — logout icon in red-soft, title in default text color
   - Удалить аккаунт — trash icon red, title red, sub "Безвозвратное удаление" muted

5. **Разработчик** — single compact row with code-icon + "Разработчик · Дудников Денис · @mdlabkz" + external-link icon

6. **Bottom tab bar** — 5 tabs (Главная, Турниры, Бронирование, Рейтинг, Профиль), Профиль is active

# Data shape

See README.md → "Данные" section for `Profile` and `TournamentHistoryItem` types. Wire to your existing API client / store; if endpoints don't exist yet, stub with the mock data from `src/data-profile-page.jsx`.

# Components to build/reuse

- `<ProfileHero>` — takes the Profile object
- `<Sparkline points color width height>` — inline SVG line + area gradient, last-point dot
- `<Medal place size>` — SVG with ribbon; place 1/2/3 → gold/silver/bronze disc, null → render `IconTrophyFilled`
- `<TournamentHistoryRow item>`
- `<SettingsRow icon title value tint onPress>`
- `<DangerRow icon title subtitle variant="logout" | "delete" onPress>`

# Constraints

- Keep the screen scrollable; hero is NOT sticky
- Preserve all existing navigation destinations — wiring should be 1:1 with the old screen
- Typography must use `tabular-nums` for all numbers (rating, deltas, counts, progress)
- Icons: 1.5px stroke, rounded caps/joins, 24×24 viewBox
- Destructive actions (Выйти, Удалить) MUST be visually separated from regular settings — same card is a no-go
- Validate in both light and dark themes if the app supports light (tokens above are dark; map green/red/amber accordingly)

# Acceptance checklist

- [ ] Hero matches gradient + layout in prototype
- [ ] Stats strip shows 4 values with semantic winrate color (≥60% green / 40-59% amber / <40% red)
- [ ] Sparkline renders cleanly at small sizes, last point visible
- [ ] Medal SVG renders place number with ribbon
- [ ] History row delta chip has correct arrow direction + color
- [ ] Settings rows are 48-52px tall (dense, not spacious)
- [ ] Destructive actions live in a separate card under "Аккаунт" label
- [ ] All numbers use `tabular-nums`
- [ ] No hardcoded widths that break on narrow phones (360px minimum)
- [ ] Analytics events on tap for every row (preserve whatever was tracked in the old screen)

When done, ship a PR with screenshots of the new screen next to the old one.
