You are a senior frontend engineer. Implement the **Tournaments list screen** (tab «Открытые») for the padel mobile app.

# Context

The old screen dumped a flat list of cards with weak hierarchy — users couldn't tell at a glance which tournaments matched their level, which club hosted each one, and which were still open. The new design splits the screen into two clearly separated zones:

1. **«Для вас»** (top) — premium hero cards for tournaments in the player's skill range. Grouped by club with explicit logo+name sub-headers so nobody signs up at the wrong venue.
2. **«Остальные турниры»** (below an explicit divider, on a slightly darker background) — compact rows grouped by club with a big club header (logo 38px + name + city + "open / total" counter).

Design tokens and structure are fully spec'd in `README.md`. A working prototype is in `tournaments.html` + `src/tournaments-v2.jsx`. Use README as source of truth; reference the prototype for exact spacing/type ratios.

# Your task

Build the screen pixel-matched to the prototype, wired to the app's real tournament list API. Reuse the app's existing design-token system where possible — map the hex values in README.md to the nearest existing tokens rather than hardcoding.

# Screen breakdown (top → bottom)

1. **Title** «Турниры» — 26px/700
2. **Tab bar**: Открытые (active, green underline) · Мои · Архив
3. **Filter pills** horizontal scroll: Все (active) · Уровень · Формат · Дата · Клуб — each opens a filter sheet
4. **Section «Для вас»**
   - Section header: title + chip «Уровень {user.level}» + right-aligned count
   - Grouped by `clubLogo`; each group has a small club sub-header (logo 30px + name + city + count)
   - Hero cards inside each group
5. **Separator** — "ОСТАЛЬНЫЕ ТУРНИРЫ" label centered on gradient hairline
6. **Section «Остальные турниры»**
   - Slightly darker background (`rgba(0,0,0,0.18)` overlay)
   - Grouped by `clubLogo`; each group has a **large** club header (logo 38px + name + city + "открыто N / всего M")
   - Rows inside a card
7. **Bottom tab bar** — 5 tabs, Турниры active

# Hero card (For you)

**Open tournament:**
- Green gradient background
- Top row: [format chip] [«Ваш уровень» chip] + title + (club · city · price) + **«Записаться»** button (green, top-right)
- Date · time · day-of-week
- Level bar: min – player position – max with colored fill
- Footer: players progress bar (green/amber based on spots left) + spots-left label (no price — it's up top now)

**Full tournament:**
- Red-warm gradient, red-tinted border
- Diagonal stripe overlay
- Extra chip: **ЗАПОЛНЕН** (red, uppercase)
- Title color dimmed
- **NO «Записаться» button** (right column empty)
- **NO price in footer** (price lives next to club name at top)
- Progress bar red, "16/16 мест нет" red
- Card is still tappable (opens detail / waitlist)

# Row (Rest)

- Left: dayOfWeek caps + time (tabular-nums)
- Middle: name (strikethrough with red dotted underline if full) + green dot if inRange + subtitle (format chip · level range · date)
- Right:
  - if open: `players/max` (green if plenty, amber if ≤2 spots left) + price below (tabular-nums)
  - if full: red chip with crossmark icon **ЗАПОЛНЕН**
- Full row: diagonal stripe overlay on background, opacity 0.55

# Filtering / sorting logic

```ts
const forYou = tournaments
  .filter(t => isInLevelRange(t, user.level))
  .sort((a, b) => {
    if (a.status !== b.status) return a.status === 'open' ? -1 : 1;
    return a.date.localeCompare(b.date) || a.time.localeCompare(b.time);
  });

const rest = tournaments.filter(t => !forYou.includes(t));
const byClub = groupBy(rest, t => t.clubLogo);
// Sort clubs: those with any open tournament first
```

Inside each club group: open first (by date then time), then full.

# Components to build/reuse

- `<TournamentsScreen>` — top-level
- `<ForYouSection data={forYou} userLevel />`
- `<RestByClubSection data={rest} />`
- `<ClubSectionHeader logo name city openCount totalCount />` (big, used in Rest)
- `<ClubSubHeader logo name city count />` (small, used inside For-you)
- `<HeroTournamentCard t />`
- `<TournamentRow t />`
- `<ClubLogo slug size />` — maps `'almaty' | 'astana' | …` → styled logo tile. Swap with real club logo assets when available.
- `<LevelBar min max playerLevel inRange />` — SVG/div with colored range + player dot
- `<FilterPills />`, `<TopTabs />`, `<BottomTabBar />`

# Data

See README.md → "Данные" for the `Tournament` type. Wire to your existing API client. If endpoints aren't there yet, mock with `src/data-tournaments.jsx`.

# Constraints

- All numbers — `font-variant-numeric: tabular-nums` (times, scores, prices, levels)
- Club logos must be REAL club logos when provided by the client — the prototype's "A" / "ASTANA" tiles are placeholders
- Rows and hero cards are tappable (navigate to tournament detail)
- Full tournaments have NO «Записаться» button and NO price duplicate in the footer — price lives next to the club name at the top instead
- Dividers between rows inside a club card: `rgba(255,255,255,0.05)`, no divider below the last row

# Acceptance checklist

- [ ] Two-zone layout with explicit labeled separator between them
- [ ] «Для вас» grouped by club with sub-header (logo + name + city + count)
- [ ] «Остальные турниры» grouped by club with big header (logo 38px + «N / M открыто»)
- [ ] Hero cards: different gradient + border + stripes for full vs open
- [ ] Full hero card has NO записаться button, price moved up next to club name
- [ ] Rows: strikethrough name for full, green dot for inRange, amber counter for ≤2 spots
- [ ] Level bar renders player position dot correctly when out of range (white) vs in range (green)
- [ ] All tap targets ≥44px
- [ ] Filter pills horizontal-scroll without clipping
- [ ] Works on 360px-wide screens (no horizontal overflow)

Ship a PR with side-by-side screenshots: old vs new.
