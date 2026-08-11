// Soon + Telegram news — 3 variants
const sn = {
  bg: '#131317', card: '#1c1c21', cardRaised: '#23232a',
  border: 'rgba(255,255,255,0.08)', text: '#f3f3f5', muted: '#a2a2ab', dim: '#6a6a73',
  green: '#22c47a', greenDark: '#1a9e62',
  greenSoft: 'rgba(34,196,122,0.14)', greenBorder: 'rgba(34,196,122,0.32)',
  blue: '#4f87ff', blueSoft: 'rgba(79,135,255,0.10)',
};

const SnTg = ({s=14, c='#22c47a'}) => (
  <svg width={s} height={s} viewBox="0 0 24 24" fill={c}>
    <path d="M22 2L2 11l6 2 2 7 4-5 6 5 2-18z"/>
  </svg>
);
const SnArrow = ({c='#06281a',s=14}) => (
  <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
);
const SnCal = ({c='#22c47a',s=14}) => (
  <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
);
const SnExt = ({c='#22c47a',s=12}) => (
  <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
);

const TOURNAMENTS = [
  { date: '09 мая', dow: 'Сб', time: '11:00', title: 'L2.5+ Суббота', club: 'ADD Padel Astana', logo: '#fbbf24', logoText: 'ADD', format: 'Американо', price: '18 000 ₸', level: '2.5–2.75', filled: 7, max: 8 },
  { date: '10 мая', dow: 'Вс', time: '14:00', title: 'L3.0 Воскресенье', club: 'ADD Padel Almaty', logo: '#22c47a', logoText: 'ADD', format: 'Американо', price: '20 000 ₸', level: '3.0–3.5', filled: 5, max: 8 },
  { date: '11 мая', dow: 'Пн', time: '19:00', title: 'L1.5+ Вечерний', club: 'PadelHouse', logo: '#4f87ff', logoText: 'PH', format: 'Лига', price: '12 000 ₸', level: '1.5–2.0', filled: 3, max: 8 },
  { date: '14 мая', dow: 'Чт', time: '20:00', title: 'L4.0 Премиум', club: 'ADD Padel Astana', logo: '#fbbf24', logoText: 'ADD', format: 'Американо', price: '25 000 ₸', level: '4.0–4.5', filled: 6, max: 8 },
];

// =========================================================================
// V1 — Compact horizontal cards + slim Telegram footer
// =========================================================================
function Soon_V1() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
      <div style={{ padding: '0 16px', display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
        <div style={{ fontSize: 18, fontWeight: 800, color: sn.text, letterSpacing: -0.3 }}>Скоро</div>
        <button style={{ background: 'transparent', border: 'none', color: sn.green, fontSize: 13, fontWeight: 700, cursor: 'pointer', fontFamily: 'inherit' }}>Все турниры →</button>
      </div>
      <div style={{ overflowX: 'auto', display: 'flex', gap: 10, padding: '0 16px', scrollbarWidth: 'none' }}>
        {TOURNAMENTS.map((t, i) => (
          <div key={i} style={{ minWidth: 230, background: sn.card, border: `1px solid ${sn.border}`, borderRadius: 14, padding: 14,
                                  display: 'flex', flexDirection: 'column', gap: 10 }}>
            {/* top row: date + fill */}
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <SnCal s={12} c={sn.green}/>
                <div style={{ fontSize: 12, fontWeight: 700, color: sn.green }}>{t.date} · {t.time}</div>
              </div>
              <div style={{ fontSize: 11, color: sn.muted, fontWeight: 700 }}>{t.filled}/{t.max}</div>
            </div>
            {/* logo + title */}
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <div style={{ width: 36, height: 36, borderRadius: 8, background: t.logo, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 10, fontWeight: 800, color: '#000', flexShrink: 0 }}>{t.logoText}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14, fontWeight: 800, color: sn.text, letterSpacing: -0.2, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{t.title}</div>
                <div style={{ fontSize: 11, color: sn.muted, marginTop: 2, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{t.club}</div>
              </div>
            </div>
            {/* progress bar */}
            <div style={{ height: 4, background: 'rgba(255,255,255,0.05)', borderRadius: 2, overflow: 'hidden' }}>
              <div style={{ width: `${t.filled/t.max*100}%`, height: '100%',
                              background: t.filled/t.max >= 0.875 ? '#ef4444' : `linear-gradient(90deg, ${sn.green}, ${sn.greenDark})` }}/>
            </div>
            {/* meta + cta */}
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div style={{ fontSize: 11, color: sn.muted, fontWeight: 600 }}>{t.format} · L{t.level}</div>
              <div style={{ fontSize: 13, fontWeight: 800, color: sn.text }}>{t.price}</div>
            </div>
            <button style={{ marginTop: 2, padding: '10px 0', borderRadius: 10, background: sn.greenSoft, color: sn.green, border: `1px solid ${sn.greenBorder}`, fontWeight: 800, fontSize: 13, cursor: 'pointer', fontFamily: 'inherit' }}>Записаться</button>
          </div>
        ))}
      </div>
      {/* Telegram footer slim */}
      <div style={{ padding: '0 16px' }}>
        <button style={{ width: '100%', padding: '12px 14px', background: sn.card, border: `1px solid ${sn.border}`, borderRadius: 12, display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer', fontFamily: 'inherit' }}>
          <div style={{ width: 28, height: 28, borderRadius: 8, background: sn.greenSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <SnTg s={14} c={sn.green}/>
          </div>
          <div style={{ flex: 1, textAlign: 'left' }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: sn.text }}>Новости приложения</div>
            <div style={{ fontSize: 11, color: sn.muted, marginTop: 1 }}>Telegram-канал</div>
          </div>
          <SnExt s={12} c={sn.dim}/>
        </button>
      </div>
    </div>
  );
}

// =========================================================================
// V2 — Calendar strip (horizontal days with dots) + small list below
// =========================================================================
function Soon_V2() {
  // Generate next 14 days
  const today = new Date(2026, 4, 9); // 09 May
  const days = Array.from({length: 14}, (_, i) => {
    const d = new Date(today);
    d.setDate(today.getDate() + i);
    const dows = ['Вс','Пн','Вт','Ср','Чт','Пт','Сб'];
    const dateStr = `${String(d.getDate()).padStart(2,'0')} ${['янв','фев','мар','апр','мая','июн','июл','авг','сен','окт','ноя','дек'][d.getMonth()]}`;
    const tournamentsHere = TOURNAMENTS.filter(t => t.date === dateStr);
    return {
      day: d.getDate(), dow: dows[d.getDay()],
      isToday: i === 0,
      tournaments: tournamentsHere,
    };
  });
  const selectedIdx = 0;
  const selectedDay = days[selectedIdx];
  const upcomingShown = TOURNAMENTS.slice(0, 3);
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      <div style={{ padding: '0 16px', display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
        <div style={{ fontSize: 18, fontWeight: 800, color: sn.text, letterSpacing: -0.3 }}>Скоро</div>
        <button style={{ background: 'transparent', border: 'none', color: sn.green, fontSize: 13, fontWeight: 700, cursor: 'pointer', fontFamily: 'inherit' }}>Календарь →</button>
      </div>
      {/* Calendar strip */}
      <div style={{ overflowX: 'auto', display: 'flex', gap: 6, padding: '0 16px', scrollbarWidth: 'none' }}>
        {days.map((d, i) => {
          const has = d.tournaments.length > 0;
          const sel = i === selectedIdx;
          return (
            <button key={i} style={{ minWidth: 48, padding: '10px 8px', borderRadius: 12,
                                       background: sel ? sn.greenSoft : sn.card,
                                       border: `1px solid ${sel ? sn.greenBorder : sn.border}`,
                                       display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
                                       cursor: 'pointer', fontFamily: 'inherit' }}>
              <div style={{ fontSize: 10, fontWeight: 700, color: sel ? sn.green : sn.dim, letterSpacing: 0.6, textTransform: 'uppercase' }}>{d.dow}</div>
              <div style={{ fontSize: 18, fontWeight: 800, color: sel ? sn.green : sn.text, letterSpacing: -0.3 }}>{d.day}</div>
              <div style={{ height: 5, display: 'flex', gap: 2 }}>
                {has
                  ? d.tournaments.map((_, j) => <div key={j} style={{ width: 4, height: 4, borderRadius: '50%', background: sn.green }}/>)
                  : <div style={{ width: 4, height: 4, borderRadius: '50%', background: 'rgba(255,255,255,0.08)' }}/>}
              </div>
            </button>
          );
        })}
      </div>
      {/* List for selected day */}
      <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {upcomingShown.map((t, i) => (
          <div key={i} style={{ background: sn.card, border: `1px solid ${sn.border}`, borderRadius: 12,
                                  padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ width: 38, height: 38, borderRadius: 8, background: t.logo, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 800, color: '#000', flexShrink: 0 }}>{t.logoText}</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 3 }}>
                <div style={{ fontSize: 11, fontWeight: 700, color: sn.green }}>{t.time}</div>
                <div style={{ width: 3, height: 3, borderRadius: '50%', background: sn.dim }}/>
                <div style={{ fontSize: 11, color: sn.muted, fontWeight: 600 }}>{t.format} · L{t.level}</div>
              </div>
              <div style={{ fontSize: 14, fontWeight: 800, color: sn.text, letterSpacing: -0.2, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{t.title}</div>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 4 }}>
              <div style={{ fontSize: 13, fontWeight: 800, color: sn.text }}>{t.price}</div>
              <div style={{ fontSize: 10, color: t.filled/t.max >= 0.875 ? '#ef4444' : sn.muted, fontWeight: 700 }}>{t.filled}/{t.max} мест</div>
            </div>
          </div>
        ))}
      </div>
      {/* Telegram inline link (super slim) */}
      <div style={{ padding: '6px 16px 0' }}>
        <button style={{ width: '100%', padding: '12px 14px', background: 'transparent', border: `1px dashed ${sn.border}`, borderRadius: 10, display: 'flex', alignItems: 'center', gap: 10, cursor: 'pointer', fontFamily: 'inherit', justifyContent: 'center' }}>
          <SnTg s={13} c={sn.green}/>
          <span style={{ fontSize: 12, color: sn.muted, fontWeight: 600 }}>Подписаться на новости в Telegram</span>
        </button>
      </div>
    </div>
  );
}

// =========================================================================
// V3 — Hero card + mini list rows + Telegram inline as last row
// =========================================================================
function Soon_V3() {
  const hero = TOURNAMENTS[0];
  const rest = TOURNAMENTS.slice(1, 4);
  const heroFillPct = hero.filled / hero.max * 100;
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      <div style={{ padding: '0 16px', display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
        <div style={{ fontSize: 18, fontWeight: 800, color: sn.text, letterSpacing: -0.3 }}>Скоро</div>
        <button style={{ background: 'transparent', border: 'none', color: sn.green, fontSize: 13, fontWeight: 700, cursor: 'pointer', fontFamily: 'inherit' }}>Все ({TOURNAMENTS.length}) →</button>
      </div>
      {/* Hero card */}
      <div style={{ padding: '0 16px' }}>
        <div style={{ background: 'linear-gradient(180deg, #1d2a23 0%, #161e1a 100%)',
                        border: `1px solid ${sn.greenBorder}`, borderRadius: 16, padding: 16,
                        boxShadow: '0 0 0 4px rgba(34,196,122,0.04)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
            <div style={{ width: 44, height: 44, borderRadius: 10, background: hero.logo, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 12, fontWeight: 800, color: '#000', flexShrink: 0 }}>{hero.logoText}</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 3 }}>
                <div style={{ padding: '2px 8px', borderRadius: 6, background: sn.greenSoft, fontSize: 10, fontWeight: 800, color: sn.green, letterSpacing: 0.6 }}>{hero.dow.toUpperCase()} · {hero.date.toUpperCase()}</div>
                <div style={{ fontSize: 11, fontWeight: 700, color: sn.green }}>{hero.time}</div>
              </div>
              <div style={{ fontSize: 16, fontWeight: 800, color: sn.text, letterSpacing: -0.2 }}>{hero.title}</div>
              <div style={{ fontSize: 12, color: sn.muted, marginTop: 1 }}>{hero.club}</div>
            </div>
          </div>
          {/* meta row */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12, flexWrap: 'wrap' }}>
            <div style={{ padding: '4px 10px', background: 'rgba(255,255,255,0.05)', borderRadius: 6, fontSize: 11, fontWeight: 700, color: sn.text }}>{hero.format}</div>
            <div style={{ padding: '4px 10px', background: 'rgba(255,255,255,0.05)', borderRadius: 6, fontSize: 11, fontWeight: 700, color: sn.text }}>L {hero.level}</div>
            <div style={{ flex: 1 }}/>
            <div style={{ fontSize: 14, fontWeight: 800, color: sn.text }}>{hero.price}</div>
          </div>
          {/* progress + cta */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 4 }}>
                <div style={{ fontSize: 11, color: heroFillPct >= 87.5 ? '#ef4444' : sn.muted, fontWeight: 700 }}>
                  {heroFillPct >= 87.5 ? `Осталось ${hero.max - hero.filled} место` : `${hero.filled} из ${hero.max} мест`}
                </div>
              </div>
              <div style={{ height: 4, background: 'rgba(255,255,255,0.05)', borderRadius: 2, overflow: 'hidden' }}>
                <div style={{ width: `${heroFillPct}%`, height: '100%',
                                background: heroFillPct >= 87.5 ? '#ef4444' : `linear-gradient(90deg, ${sn.green}, ${sn.greenDark})` }}/>
              </div>
            </div>
            <button style={{ padding: '10px 18px', borderRadius: 10,
                              background: `linear-gradient(135deg, ${sn.green}, ${sn.greenDark})`,
                              border: 'none', color: '#06281a', fontSize: 13, fontWeight: 800,
                              cursor: 'pointer', fontFamily: 'inherit', display: 'flex', alignItems: 'center', gap: 6,
                              boxShadow: '0 6px 16px rgba(34,196,122,0.25)' }}>
              Записаться <SnArrow s={12}/>
            </button>
          </div>
        </div>
      </div>
      {/* Mini rows for the rest */}
      <div style={{ padding: '0 16px' }}>
        <div style={{ background: sn.card, border: `1px solid ${sn.border}`, borderRadius: 12, overflow: 'hidden' }}>
          {rest.map((t, i, arr) => (
            <button key={i} style={{ width: '100%', padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 12, background: 'transparent', border: 'none', borderBottom: i < arr.length - 1 ? `1px solid ${sn.border}` : 'none', cursor: 'pointer', fontFamily: 'inherit', textAlign: 'left' }}>
              {/* date stack */}
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', minWidth: 36 }}>
                <div style={{ fontSize: 10, fontWeight: 700, color: sn.dim, letterSpacing: 0.6, textTransform: 'uppercase' }}>{t.dow}</div>
                <div style={{ fontSize: 17, fontWeight: 800, color: sn.text, letterSpacing: -0.3, lineHeight: 1 }}>{t.date.split(' ')[0]}</div>
              </div>
              <div style={{ width: 1, alignSelf: 'stretch', background: sn.border }}/>
              <div style={{ width: 26, height: 26, borderRadius: 6, background: t.logo, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 9, fontWeight: 800, color: '#000', flexShrink: 0 }}>{t.logoText}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13, fontWeight: 800, color: sn.text, letterSpacing: -0.1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{t.title}</div>
                <div style={{ fontSize: 11, color: sn.muted, marginTop: 1 }}>{t.time} · L{t.level} · {t.price}</div>
              </div>
              <div style={{ fontSize: 11, color: t.filled/t.max >= 0.875 ? '#ef4444' : sn.muted, fontWeight: 700 }}>{t.filled}/{t.max}</div>
            </button>
          ))}
        </div>
      </div>
      {/* Telegram inline row, same vocabulary as list above */}
      <div style={{ padding: '0 16px' }}>
        <button style={{ width: '100%', padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 12, background: sn.card, border: `1px solid ${sn.border}`, borderRadius: 12, cursor: 'pointer', fontFamily: 'inherit', textAlign: 'left' }}>
          <div style={{ width: 32, height: 32, borderRadius: 8, background: sn.greenSoft, border: `1px solid ${sn.greenBorder}`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
            <SnTg s={15} c={sn.green}/>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 13, fontWeight: 800, color: sn.text }}>Новости приложения</div>
            <div style={{ fontSize: 11, color: sn.muted, marginTop: 1 }}>Свежие апдейты в Telegram</div>
          </div>
          <SnExt s={13} c={sn.muted}/>
        </button>
      </div>
    </div>
  );
}

// Phone shell that reproduces enough of the home screen to give context
function PhoneShell({ children, label }) {
  return (
    <div style={{ background: sn.bg, height: 760, color: sn.text, fontFamily: 'system-ui, sans-serif',
                   display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      {/* Status bar */}
      <div style={{ height: 28 }}/>
      {/* Above context: the existing hero with two color blocks (CTA cards) */}
      <div style={{ padding: '8px 16px 0' }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: sn.dim, letterSpacing: 1, textTransform: 'uppercase', marginBottom: 8 }}>↑ выше: «Активный турнир» + 2 цв. CTA</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 18, opacity: 0.55 }}>
          <div style={{ aspectRatio: '2/1', borderRadius: 12, background: '#2855c4' }}/>
          <div style={{ aspectRatio: '2/1', borderRadius: 12, background: '#c26a2a' }}/>
        </div>
      </div>
      <div style={{ flex: 1, overflow: 'auto', paddingBottom: 12 }}>
        {children}
      </div>
      {/* Tab bar dummy */}
      <div style={{ height: 56, borderTop: `1px solid ${sn.border}`, background: '#16161a',
                      display: 'flex', alignItems: 'center', justifyContent: 'space-around',
                      fontSize: 10, color: sn.dim, fontWeight: 700 }}>
        <span style={{color: sn.green}}>Главная</span><span>Турниры</span><span>Бронь</span><span>Рейтинг</span><span>Профиль</span>
      </div>
    </div>
  );
}

Object.assign(window, { Soon_V1, Soon_V2, Soon_V3, PhoneShell });
