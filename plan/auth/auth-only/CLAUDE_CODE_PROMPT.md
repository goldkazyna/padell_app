You are a senior frontend engineer. Implement the **Вход (Auth / Sign-in)** screen for the padel mobile app (React Native or React web — follow the project's existing stack).

# Context

The old auth screen had only one method — Telegram — as a big primary blue button, with Email/phone as a secondary. We're expanding auth to 4 social providers (**Telegram, WhatsApp, Google, Apple**) + Email/phone. Critically: **all 4 social providers are equal** — no one is a visual "primary". Email stays as a secondary fallback below a divider, matching the original pattern.

All design tokens, structure, and data contracts are spec'd in `README.md`. Use that as the source of truth. A working prototype lives in `auth.html` + `src/auth-v2.jsx` + `src/auth-assets.jsx` — reference it for exact spacing, colors, typography ratios, and brand-icon SVG paths.

# Your task

Build the screen end-to-end, matching the prototype pixel-ratios and using the existing app's component library / design tokens where present. Do NOT copy colors verbatim if the project already has a token system — map to existing tokens that closest match the hex values in README.md. Preserve all navigation destinations currently wired for Telegram and Email, add stubs for the 3 new providers.

# Screen structure (top → bottom)

1. **Back button** — 38×38, `--card` bg + `--border`, left-arrow icon, triggers `router.back()`

2. **Header** (26px gap)
   - Title "Вход" — 22px, weight 700, letter-spacing -0.4
   - Subtitle "Выберите удобный способ" — 13px, `--text-muted`

3. **Social providers stack** (22px gap, 8px inner gap between rows) — 4 equal-weight buttons in column, **in this order**:
   1. Telegram — blue tint (`rgba(34,158,217,0.06)` bg + `rgba(34,158,217,0.18)` border)
   2. WhatsApp — green tint (`rgba(37,211,102,0.06)` + `rgba(37,211,102,0.18)`)
   3. Google — neutral tint (`rgba(255,255,255,0.04)` + `rgba(255,255,255,0.12)`)
   4. Apple — neutral tint (same as Google)

   Each row: `[24px brand-icon] [label "Telegram" / "WhatsApp" / etc, font-weight 600, flex:1] [chevron-right 14px, alpha 25%]`. Padding `13px 16px`, border-radius `14px`.

   ⚠️ **Telegram must NOT be visually distinguished beyond the subtle blue tint.** No shadow, no scale, no "Рекомендуем" badge, no larger size. The user explicitly rejected a Telegram-primary treatment.

4. **Divider "или"** — two 1px hairlines with centered text "или" (12px, weight 500, `--text-dim`). `18px` margin-top from social stack, `14px` margin-bottom.

5. **Email button** — separate transparent button (no fill, just `--border`), centered content: `[22px mail-icon] Войти через Email или телефон`. Border-radius `14px`, same padding as social rows.

6. **Flex spacer** pushes everything below to the bottom of the viewport.

7. **Consent** — single row: 18×18 rounded-5px checkbox (default `true`, filled `--green` when checked) + 11px caption text:
   `Продолжая, я принимаю <ссылка на соглашение> и <ссылка на обработку данных>`.
   Links underlined `--green` with underline-offset 2px. The two legal documents from the old screen are merged into one consent row — same legal weight, less visual clutter.

8. **Footer** — "Developed by Dudnikov Denis", 10px, `--text-dim`, opacity 0.6, centered.

9. **Ambient glow** — decorative `radial-gradient(circle, rgba(34,196,122,0.08) 0%, transparent 70%)` at top-right (`top: -30px, right: -40px, width: 220px, height: 220px`), `pointer-events: none`, sits under all content.

# Brand icons

Use the inline SVG paths from `src/auth-assets.jsx` — they're verified brand-accurate:
- Telegram: `#229ED9` circle + white paper-plane glyph
- WhatsApp: `#25D366` circle + white phone-chat glyph
- Google: white circle + official 4-color Google "G"
- Apple: `#f3f3f5` circle + `#0a0a0d` apple silhouette (cut-leaf style)
- Email: neutral `#2a2a31` circle + outline envelope, stroke color `--text-muted`

If the project uses an existing icon library (Lucide, Feather, HeroIcons), replace **only** the email envelope — brand marks must stay as the trademark SVG.

# Data shape / props

```ts
type AuthScreenProps = {
  onProvider: (id: 'telegram' | 'whatsapp' | 'google' | 'apple' | 'email') => void;
  onBack: () => void;
  onOpenTerms: () => void;
  onOpenPrivacy: () => void;
};
```

Internal state: `agreed: boolean` (default `true`).

# Components to build/reuse

- `<AuthScreen>` — top-level
- `<AuthRow provider onPress>` — one social provider row, takes `{ id, label, icon, tint }`
- `<EmailButton onPress>` — separate styled button for email
- `<Divider label="или" />` — horizontal rule with centered caption
- `<Consent agreed onToggle onOpenTerms onOpenPrivacy />`

# Constraints

- All 4 social buttons are **visually equal weight**. No primary/secondary hierarchy within the social group. This is explicit product direction — do not "improve" by highlighting Telegram.
- Telegram stays first in the list (historically primary method, users know to look for it).
- Email is **below the divider**, never in the same stack as socials.
- Horizontal screen padding `20px`. No full-bleed elements.
- Min hit-target 44px on all interactive elements.
- Ambient glow must stay subtle (≤8% alpha). No gradients on buttons.
- All copy is Russian — do not localize keys into English in UI strings.

# Interaction

- Tap on any social button → launch corresponding OAuth/SDK flow (`onProvider(id)`)
- Tap on Email button → navigate to email/phone entry screen (`onProvider('email')`)
- Tap on back → `onBack()` / `router.back()`
- Tap on consent link → open respective document (web-view or modal)
- If `agreed === false` and user taps any provider button → inline error "Примите условия для продолжения" under the checkbox, do NOT launch the flow

# Button states

- **Default** — as in prototype
- **Pressed** — `transform: scale(0.98)`, `opacity: 0.9`, 120ms transition
- **Loading** (during OAuth callback) — replace chevron with 16px spinner, disable entire screen (`pointer-events: none`, opacity 0.7 on non-loading rows)
- **Disabled** (provider unavailable) — `opacity: 0.4`, cursor `not-allowed`

# Accessibility

- Every button is a semantic `<button>` (or `Pressable` on RN) with `aria-label` / `accessibilityLabel` matching the visible label
- Checkbox is `role="checkbox"` + `aria-checked`
- Consent links are real `<a>` with `target="_blank"` + `rel="noopener noreferrer"` on web; on RN open in in-app browser
- Focus order: back → 4 providers → email → checkbox → terms link → privacy link
- Visible focus ring (2px `--green` outline, 2px offset) on keyboard navigation

# Acceptance checklist

- [ ] 4 social buttons rendered in order Telegram → WhatsApp → Google → Apple
- [ ] No single social button is visually emphasized over the others (no larger size, no "primary" color fill, no badge)
- [ ] Telegram has blue tint, WhatsApp green tint, Google + Apple neutral tint — all at the specified low alphas
- [ ] Brand icons use the exact SVG paths from `src/auth-assets.jsx` (trademark-accurate)
- [ ] "или" divider separates social block from Email button
- [ ] Email button is transparent bg with `--border`, centered content, full-width
- [ ] Consent is ONE row with both links inline (not two separate checkbox rows)
- [ ] Ambient glow present at top-right, ≤8% alpha
- [ ] `agreed=false` blocks all provider taps with inline error
- [ ] Min hit target 44px everywhere
- [ ] Works at 360px screen width without overflow
- [ ] Analytics: `auth_screen_view`, `auth_provider_tap` with `{ provider: 'telegram' | ... }`, `auth_consent_toggle` with `{ agreed: bool }`

When done, ship a PR with a screenshot of the new screen alongside the prototype (`auth.html` rendered in a 360×760 phone frame).
