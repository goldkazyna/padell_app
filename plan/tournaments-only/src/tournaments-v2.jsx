// V2 — Club-grouped, with hero "For you" cards and explicit club headers

const tv2 = {
  bg: '#131317', card: '#1c1c21', cardRaised: '#23232a',
  border: 'rgba(255,255,255,0.06)', divider: 'rgba(255,255,255,0.05)',
  text: '#f3f3f5', muted: '#a2a2ab', dim: '#6a6a73',
  green: '#22c47a', greenSoft: 'rgba(34,196,122,0.14)',
  blue: '#4a8bf5', red: '#f0554d', amber: '#eab34e',
};

// Bigger, richer club logo tile for headers
function ClubLogoBig({ club, size = 36 }) {
  if (club === 'almaty') {
    return (
      <div style={{ width: size, height: size, borderRadius: 9, background: '#1e3a8a',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontSize: size * 0.5, fontWeight: 800, color: '#8ab4ff', flexShrink: 0,
                    boxShadow: 'inset 0 -1px 0 rgba(0,0,0,0.2)' }}>A</div>
    );
  }
  return (
    <div style={{ width: size, height: size, borderRadius: 9, background: '#f3f3f5',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: size * 0.24, fontWeight: 800, color: '#2a2a2e', flexShrink: 0,
                  letterSpacing: 0.3, boxShadow: 'inset 0 -1px 0 rgba(0,0,0,0.15)' }}>ASTANA</div>
  );
}

function T_V2_HeroCard({ t }) {
  const fmt = FORMAT_COLORS[t.formatColor];
  const spotsLeft = t.playersMax - t.players;
  const full = t.status === 'full';
  return (
    <div style={{ background: full
                    ? 'linear-gradient(150deg, #25201d 0%, #221c1c 40%, #1c1c21 100%)'
                    : 'linear-gradient(150deg, #1d3025 0%, #1c2820 40%, #1c1c21 100%)',
                  border: `1px solid ${full ? 'rgba(240,85,77,0.18)' : tv2.border}`,
                  borderRadius: 16, padding: 14, position: 'relative', overflow: 'hidden' }}>
      {/* Diagonal stripe overlay when full */}
      {full && (
        <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none',
                      background: 'repeating-linear-gradient(135deg, transparent 0 10px, rgba(255,255,255,0.015) 10px 11px)' }}/>
      )}
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 10, marginBottom: 10, position: 'relative' }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 6, flexWrap: 'wrap' }}>
            <span style={{ fontSize: 10, color: fmt.fg, background: fmt.bg,
                           padding: '2px 7px', borderRadius: 4, fontWeight: 600 }}>{t.format}</span>
            <span style={{ fontSize: 10, color: tv2.green, background: tv2.greenSoft,
                           padding: '2px 7px', borderRadius: 4, fontWeight: 600 }}>Ваш уровень</span>
            {full && (
              <span style={{ fontSize: 10, color: tv2.red, background: 'rgba(240,85,77,0.14)',
                             padding: '2px 7px', borderRadius: 4, fontWeight: 700,
                             textTransform: 'uppercase', letterSpacing: 0.5 }}>Заполнен</span>
            )}
          </div>
          <div style={{ fontSize: 15, fontWeight: 700, color: full ? tv2.muted : tv2.text, letterSpacing: -0.2 }}>
            {t.name}
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 3 }}>
            <span style={{ fontSize: 11, color: tv2.muted,
                           overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {t.club} · {t.clubCity}
            </span>
            <span style={{ color: tv2.dim, fontSize: 11 }}>·</span>
            <span style={{ fontSize: 11, color: full ? tv2.muted : tv2.text, fontWeight: 600,
                           fontVariantNumeric: 'tabular-nums', flexShrink: 0 }}>
              {formatPrice(t.price)}
            </span>
          </div>
        </div>
        {!full && (
          <button style={{ padding: '8px 14px', borderRadius: 10, background: tv2.green, color: '#0a0a0d',
                          border: 'none', fontSize: 12, fontWeight: 700, cursor: 'pointer',
                          fontFamily: 'inherit', flexShrink: 0 }}>
            Записаться
          </button>
        )}
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 12, color: tv2.muted, marginBottom: 10, position: 'relative' }}>
        <span style={{ color: full ? tv2.muted : tv2.text, fontWeight: 600 }}>{t.dateLabel}</span>
        <span style={{ color: tv2.dim }}>·</span>
        <span style={{ color: full ? tv2.muted : tv2.text, fontWeight: 600, fontVariantNumeric: 'tabular-nums' }}>{t.time}</span>
        <span style={{ color: tv2.dim }}>·</span>
        <span>{t.dayOfWeek}</span>
      </div>
      <div style={{ marginBottom: 8, position: 'relative', opacity: full ? 0.6 : 1 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 10, color: tv2.dim, marginBottom: 5,
                      fontVariantNumeric: 'tabular-nums' }}>
          <span>Уровень {t.levelMin.toFixed(2)}</span>
          <span style={{ color: tv2.green, fontWeight: 600 }}>Вы: {MY_LEVEL}</span>
          <span>{t.levelMax.toFixed(2)}</span>
        </div>
        <LevelBar min={t.levelMin} max={t.levelMax} inRange={true}/>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 10, position: 'relative' }}>
        <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 6 }}>
          <div style={{ flex: 1, height: 4, borderRadius: 2, background: 'rgba(255,255,255,0.05)', overflow: 'hidden' }}>
            <div style={{ height: '100%', width: `${(t.players / t.playersMax) * 100}%`,
                          background: full ? tv2.red : spotsLeft <= 2 ? tv2.amber : tv2.green }}/>
          </div>
          <div style={{ fontSize: 11, color: tv2.muted, fontVariantNumeric: 'tabular-nums' }}>
            {full
              ? <><span style={{ color: tv2.red, fontWeight: 600 }}>{t.players}/{t.playersMax}</span> мест нет</>
              : <><span style={{ color: tv2.text, fontWeight: 600 }}>{spotsLeft}</span> мест</>
            }
          </div>
        </div>
        {!full && (
          <div style={{ fontSize: 12, color: tv2.text, fontWeight: 600, fontVariantNumeric: 'tabular-nums' }}>
            {formatPrice(t.price)}
          </div>
        )}
      </div>
    </div>
  );
}

// Row for club-grouped section — compact, strong hierarchy, clear "full" treatment
function T_V2_ClubRow({ t }) {
  const inRange = isInLevelRange(t);
  const full = t.status === 'full';
  const fmt = FORMAT_COLORS[t.formatColor];
  const spotsLeft = t.playersMax - t.players;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 14px',
                  position: 'relative' }}>
      {/* diagonal stripe overlay if full */}
      {full && (
        <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none',
                      background: 'repeating-linear-gradient(135deg, transparent 0 8px, rgba(255,255,255,0.015) 8px 9px)' }}/>
      )}
      {/* Date/time block */}
      <div style={{ width: 44, textAlign: 'center', flexShrink: 0, opacity: full ? 0.5 : 1 }}>
        <div style={{ fontSize: 10, color: tv2.dim, textTransform: 'uppercase', letterSpacing: 0.5, fontWeight: 700 }}>
          {t.dayOfWeek}
        </div>
        <div style={{ fontSize: 16, fontWeight: 700, color: tv2.text, fontVariantNumeric: 'tabular-nums', marginTop: 1, letterSpacing: -0.3 }}>
          {t.time}
        </div>
      </div>

      {/* Middle content */}
      <div style={{ flex: 1, minWidth: 0, opacity: full ? 0.55 : 1 }}>
        {/* Name — prominent title */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <div style={{ fontSize: 14, fontWeight: 700, color: tv2.text, letterSpacing: -0.15,
                        overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
                        textDecoration: full ? 'line-through' : 'none',
                        textDecorationColor: 'rgba(240,85,77,0.5)',
                        textDecorationThickness: '1.5px' }}>
            {t.name}
          </div>
          {inRange && !full && <div style={{ width: 6, height: 6, borderRadius: '50%', background: tv2.green, flexShrink: 0 }}/>}
        </div>
        {/* Subtitle — format, level range, date */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 4, fontSize: 11, color: tv2.muted }}>
          <span style={{ fontSize: 10, color: fmt.fg, background: fmt.bg,
                         padding: '1px 6px', borderRadius: 3, fontWeight: 600 }}>{t.format}</span>
          <span style={{ color: tv2.dim, fontVariantNumeric: 'tabular-nums' }}>
            L{t.levelMin.toFixed(2)}–{t.levelMax.toFixed(2)}
          </span>
          <span style={{ color: tv2.dim }}>·</span>
          <span style={{ color: tv2.dim }}>{t.dateLabel}</span>
        </div>
      </div>

      {/* Right side: status chip */}
      <div style={{ textAlign: 'right', flexShrink: 0 }}>
        {full ? (
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 5,
                        fontSize: 10, color: tv2.red, background: 'rgba(240,85,77,0.12)',
                        padding: '4px 8px', borderRadius: 5, fontWeight: 700,
                        textTransform: 'uppercase', letterSpacing: 0.5 }}>
            <svg width="9" height="9" viewBox="0 0 10 10" fill="none">
              <circle cx="5" cy="5" r="4" stroke="currentColor" strokeWidth="1.5"/>
              <path d="M3 3l4 4M7 3l-4 4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
            </svg>
            Заполнен
          </div>
        ) : (
          <div>
            <div style={{ fontSize: 13, color: spotsLeft <= 2 ? tv2.amber : tv2.green, fontWeight: 700, fontVariantNumeric: 'tabular-nums' }}>
              {t.players}/{t.playersMax}
            </div>
            <div style={{ fontSize: 10, color: tv2.dim, marginTop: 1, fontVariantNumeric: 'tabular-nums' }}>
              {formatPrice(t.price)}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function ClubSectionHeader({ clubName, city, clubLogo, openCount, totalCount }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '4px 2px 12px' }}>
      <ClubLogoBig club={clubLogo} size={38}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15, fontWeight: 700, color: tv2.text, letterSpacing: -0.2,
                      overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
          {clubName}
        </div>
        <div style={{ fontSize: 11, color: tv2.muted, marginTop: 2 }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 3 }}>
            <svg width="10" height="10" viewBox="0 0 10 10" fill="none">
              <path d="M5 1a3 3 0 0 0-3 3c0 2.5 3 5 3 5s3-2.5 3-5a3 3 0 0 0-3-3z" stroke="currentColor" strokeWidth="1"/>
              <circle cx="5" cy="4" r="1" fill="currentColor"/>
            </svg>
            {city}
          </span>
        </div>
      </div>
      <div style={{ textAlign: 'right' }}>
        <div style={{ fontSize: 12, color: tv2.green, fontWeight: 700, fontVariantNumeric: 'tabular-nums' }}>
          {openCount} <span style={{ color: tv2.muted, fontWeight: 500 }}>/ {totalCount}</span>
        </div>
        <div style={{ fontSize: 10, color: tv2.dim, marginTop: 1, letterSpacing: 0.3 }}>открыто</div>
      </div>
    </div>
  );
}

function ScreenTournaments_V2() {
  // For you = tournaments in your level range (both open and full)
  const forYou = TOURNAMENTS.filter(t => isInLevelRange(t));
  // Sort so open ones come first within "For you"
  forYou.sort((a, b) => {
    if (a.status !== b.status) return a.status === 'open' ? -1 : 1;
    return 0;
  });

  // Remaining = tournaments outside your level range
  const remaining = TOURNAMENTS.filter(t => !forYou.includes(t));
  const byClub = {};
  remaining.forEach(t => { (byClub[t.clubLogo] = byClub[t.clubLogo] || []).push(t); });
  const clubOrder = Object.keys(byClub).sort((a, b) => {
    // clubs with open tournaments first
    const aOpen = byClub[a].some(t => t.status === 'open');
    const bOpen = byClub[b].some(t => t.status === 'open');
    if (aOpen !== bOpen) return aOpen ? -1 : 1;
    return 0;
  });

  return (
    <div style={{ background: tv2.bg, color: tv2.text, display: 'flex', flexDirection: 'column', height: '100%',
                  fontFamily: 'system-ui, -apple-system, sans-serif' }}>
      <div style={{ padding: '12px 16px 8px' }}>
        <div style={{ fontSize: 26, fontWeight: 700, letterSpacing: -0.5, color: tv2.text }}>Турниры</div>
      </div>
      <div style={{ display: 'flex', gap: 20, padding: '0 16px', borderBottom: `1px solid ${tv2.border}` }}>
        {['Открытые', 'Мои', 'Архив'].map((t, i) => (
          <div key={t} style={{ padding: '10px 0', fontSize: 14, fontWeight: i === 0 ? 700 : 500,
                                color: i === 0 ? tv2.green : tv2.muted,
                                borderBottom: i === 0 ? `2px solid ${tv2.green}` : '2px solid transparent',
                                marginBottom: -1 }}>{t}</div>
        ))}
      </div>
      {/* Filter pills */}
      <div style={{ display: 'flex', gap: 6, padding: '12px 16px', overflowX: 'auto' }}>
        {['Все', 'Уровень', 'Формат', 'Дата', 'Клуб'].map((f, i) => (
          <div key={f} style={{ padding: '6px 12px', fontSize: 12, fontWeight: 600,
                                background: i === 0 ? tv2.greenSoft : 'rgba(255,255,255,0.04)',
                                color: i === 0 ? tv2.green : tv2.muted,
                                borderRadius: 16, whiteSpace: 'nowrap', cursor: 'pointer' }}>{f}</div>
        ))}
      </div>
      <div style={{ flex: 1, overflowY: 'auto' }}>
        {/* For you — grouped by club */}
        {forYou.length > 0 && (() => {
          const forYouByClub = {};
          forYou.forEach(t => { (forYouByClub[t.clubLogo] = forYouByClub[t.clubLogo] || []).push(t); });
          const fyClubs = Object.keys(forYouByClub);
          return (
            <div style={{ padding: '8px 16px 0' }}>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginBottom: 12 }}>
                <div style={{ fontSize: 15, fontWeight: 700, color: tv2.text }}>Для вас</div>
                <div style={{ fontSize: 11, color: tv2.green, background: tv2.greenSoft,
                              padding: '2px 6px', borderRadius: 4, fontWeight: 600 }}>Уровень {MY_LEVEL}</div>
                <div style={{ fontSize: 11, color: tv2.dim, marginLeft: 'auto' }}>{forYou.length}</div>
              </div>
              {fyClubs.map((clubKey, i) => {
                const items = forYouByClub[clubKey];
                return (
                  <div key={clubKey} style={{ marginTop: i === 0 ? 0 : 18 }}>
                    {/* Club sub-header */}
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10, padding: '0 2px' }}>
                      <ClubLogoBig club={clubKey} size={30}/>
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ fontSize: 13, fontWeight: 700, color: tv2.text, letterSpacing: -0.1 }}>
                          {items[0].club}
                        </div>
                        <div style={{ fontSize: 10, color: tv2.dim, marginTop: 1 }}>{items[0].clubCity}</div>
                      </div>
                      <div style={{ fontSize: 11, color: tv2.green, fontWeight: 700, fontVariantNumeric: 'tabular-nums' }}>
                        {items.length}
                      </div>
                    </div>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                      {items.map(t => <T_V2_HeroCard key={t.id} t={t}/>)}
                    </div>
                  </div>
                );
              })}
            </div>
          );
        })()}

        {/* Separator between "For you" and rest */}
        {forYou.length > 0 && clubOrder.length > 0 && (
          <div style={{ margin: '28px 16px 0', padding: '16px 0 4px', position: 'relative' }}>
            <div style={{ height: 1, background: 'linear-gradient(90deg, transparent, rgba(255,255,255,0.08) 20%, rgba(255,255,255,0.08) 80%, transparent)' }}/>
            <div style={{ position: 'absolute', top: 7, left: '50%', transform: 'translateX(-50%)',
                          background: tv2.bg, padding: '0 14px',
                          fontSize: 10, color: tv2.dim, fontWeight: 700, letterSpacing: 1.2, textTransform: 'uppercase',
                          whiteSpace: 'nowrap' }}>
              Остальные турниры
            </div>
          </div>
        )}

        {/* By club */}
        <div style={{ background: forYou.length > 0 ? 'rgba(0,0,0,0.18)' : 'transparent',
                      paddingBottom: 20, paddingTop: forYou.length > 0 ? 4 : 0,
                      borderTop: forYou.length > 0 ? `1px solid ${tv2.border}` : 'none',
                      marginTop: forYou.length > 0 ? 8 : 0 }}>
          {clubOrder.map((clubKey, clubIdx) => {
            const items = byClub[clubKey];
            const openCount = items.filter(t => t.status === 'open').length;
            const clubName = items[0].club;
            const city = items[0].clubCity;
            const sorted = [...items].sort((a, b) => {
              if (a.status !== b.status) return a.status === 'open' ? -1 : 1;
              return a.date.localeCompare(b.date) || a.time.localeCompare(b.time);
            });
            return (
              <div key={clubKey} style={{ padding: clubIdx === 0 ? '18px 16px 0' : '18px 16px 0' }}>
                <ClubSectionHeader clubName={clubName} city={city} clubLogo={clubKey}
                                   openCount={openCount} totalCount={items.length}/>
                <div style={{ background: tv2.card, border: `1px solid ${tv2.border}`, borderRadius: 14, overflow: 'hidden' }}>
                  {sorted.map((t, i) => (
                    <div key={t.id} style={{ borderBottom: i === sorted.length - 1 ? 'none' : `1px solid ${tv2.divider}` }}>
                      <T_V2_ClubRow t={t}/>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      </div>
      <div style={{ background: tv2.bg, borderTop: `1px solid ${tv2.border}`, display: 'flex', padding: '8px 4px 12px' }}>
        {[
          { label: 'Главная', Icon: IconHome },
          { label: 'Турниры', Icon: IconTrophy, active: true },
          { label: 'Бронирование', Icon: IconCalendar },
          { label: 'Рейтинг', Icon: IconChart },
          { label: 'Профиль', Icon: IconUser },
        ].map((it, i) => (
          <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, position: 'relative' }}>
            {it.active && <div style={{ position: 'absolute', top: -8, width: 20, height: 2, borderRadius: 2, background: tv2.green }}/>}
            <it.Icon size={22} color={it.active ? tv2.green : tv2.dim} active={it.active}/>
            <div style={{ fontSize: 11, color: it.active ? tv2.green : tv2.dim, fontWeight: it.active ? 600 : 400 }}>{it.label}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, { ScreenTournaments_V2 });
