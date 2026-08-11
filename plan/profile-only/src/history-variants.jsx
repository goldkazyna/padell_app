// 4 variants of Tournament History for V1 Stat-led

const h = {
  card: '#1c1c21', cardRaised: '#23232a',
  border: 'rgba(255,255,255,0.06)', divider: 'rgba(255,255,255,0.05)',
  text: '#f3f3f5', muted: '#a2a2ab', dim: '#6a6a73',
  green: '#22c47a', greenSoft: 'rgba(34,196,122,0.14)',
  red: '#f0554d', redSoft: 'rgba(240,85,77,0.12)',
  blue: '#4a8bf5', amber: '#eab34e',
};

function HistoryHeader() {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10, padding: '0 4px' }}>
      <div style={{ fontSize: 15, fontWeight: 600, color: h.text, letterSpacing: -0.2 }}>История турниров</div>
      <div style={{ fontSize: 13, color: h.green, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 2, cursor: 'pointer' }}>
        Все <IconChevronRight size={15} color={h.green}/>
      </div>
    </div>
  );
}

// ——— H1 Cards ———
function History_H1() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
      {TOURNAMENT_HISTORY.slice(0, 4).map(t => {
        const pos = t.delta >= 0;
        return (
          <div key={t.id} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px',
                background: h.card, border: `1px solid ${h.border}`, borderRadius: 12,
                position: 'relative', overflow: 'hidden' }}>
            <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: 3,
                          background: pos ? h.green : h.red }}/>
            <div style={{ width: 34, height: 34, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              {t.medal === 'trophy' ? <IconTrophyFilled size={18} color={h.muted}/> : <Medal place={t.place} size={24}/>}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 14, fontWeight: 500, color: h.text,
                            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{t.name}</div>
              <div style={{ fontSize: 11, color: h.dim, marginTop: 2 }}>{t.date}</div>
            </div>
            <div style={{ fontSize: 13, fontWeight: 700, fontVariantNumeric: 'tabular-nums',
                          color: pos ? h.green : h.red,
                          background: pos ? h.greenSoft : h.redSoft,
                          padding: '4px 9px', borderRadius: 7 }}>
              {pos ? '+' : ''}{t.delta}
            </div>
          </div>
        );
      })}
    </div>
  );
}

// ——— H2 Timeline ———
function History_H2() {
  return (
    <div style={{ position: 'relative', paddingLeft: 68 }}>
      <div style={{ position: 'absolute', left: 54, top: 12, bottom: 12, width: 1, background: h.divider }}/>
      {TOURNAMENT_HISTORY.slice(0, 4).map(t => {
        const pos = t.delta >= 0;
        return (
          <div key={t.id} style={{ position: 'relative', display: 'flex', alignItems: 'center', gap: 12,
                                   padding: '10px 14px', marginBottom: 6,
                                   background: h.card, border: `1px solid ${h.border}`, borderRadius: 12 }}>
            {/* delta on the left, absolute */}
            <div style={{ position: 'absolute', left: -68, top: '50%', transform: 'translateY(-50%)',
                          width: 42, textAlign: 'right' }}>
              <div style={{ fontSize: 15, fontWeight: 700, color: pos ? h.green : h.red,
                            fontVariantNumeric: 'tabular-nums', letterSpacing: -0.3 }}>
                {pos ? '+' : ''}{t.delta}
              </div>
            </div>
            {/* dot */}
            <div style={{ position: 'absolute', left: -15, top: 'calc(50% - 4px)', width: 9, height: 9,
                          borderRadius: '50%', background: pos ? h.green : h.red,
                          boxShadow: `0 0 0 3px #131317, 0 0 0 4px ${pos ? h.green : h.red}33` }}/>
            <div style={{ width: 30, height: 30, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              {t.medal === 'trophy' ? <IconTrophyFilled size={16} color={h.muted}/> : <Medal place={t.place} size={22}/>}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 13, fontWeight: 500, color: h.text,
                            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{t.name}</div>
              <div style={{ fontSize: 11, color: h.dim, marginTop: 1 }}>{t.date}</div>
            </div>
          </div>
        );
      })}
    </div>
  );
}

// ——— H3 Chart + list ———
function History_H3() {
  const p = PROFILE_PAGE;
  return (
    <>
      <div style={{ background: h.card, border: `1px solid ${h.border}`, borderRadius: 14,
                    padding: '14px 16px', marginBottom: 8 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginBottom: 10 }}>
          <div>
            <div style={{ fontSize: 10, letterSpacing: 1.3, color: h.dim, textTransform: 'uppercase', fontWeight: 600 }}>
              Динамика за 9 турниров
            </div>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginTop: 4 }}>
              <div style={{ fontSize: 20, fontWeight: 700, color: h.text, letterSpacing: -0.5 }}>{p.rating}</div>
              <div style={{ fontSize: 12, fontWeight: 600, color: h.green }}>+155</div>
            </div>
          </div>
          <Sparkline points={p.ratingTrend} color={h.green} width={120} height={40}/>
        </div>
      </div>
      <div style={{ background: h.card, border: `1px solid ${h.border}`, borderRadius: 14, overflow: 'hidden' }}>
        {TOURNAMENT_HISTORY.slice(0, 4).map((t, i, arr) => {
          const pos = t.delta >= 0;
          return (
            <div key={t.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '11px 14px',
                                      borderBottom: i === arr.length - 1 ? 'none' : `1px solid ${h.divider}` }}>
              <div style={{ width: 28, height: 28, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                {t.medal === 'trophy' ? <IconTrophyFilled size={16} color={h.muted}/> : <Medal place={t.place} size={20}/>}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13, fontWeight: 500, color: h.text,
                              overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{t.name}</div>
                <div style={{ fontSize: 10, color: h.dim, marginTop: 1 }}>{t.date}</div>
              </div>
              <div style={{ fontSize: 12, fontWeight: 700, fontVariantNumeric: 'tabular-nums',
                            color: pos ? h.green : h.red }}>
                {pos ? '+' : ''}{t.delta}
              </div>
            </div>
          );
        })}
      </div>
    </>
  );
}

// ——— H4 Stats-first ———
function History_H4() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      {TOURNAMENT_HISTORY.slice(0, 4).map(t => {
        const pos = t.delta >= 0;
        return (
          <div key={t.id} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '10px 14px',
                background: h.card, border: `1px solid ${h.border}`, borderRadius: 12 }}>
            {/* big delta block left */}
            <div style={{ width: 58, textAlign: 'center', padding: '6px 0',
                          background: pos ? h.greenSoft : h.redSoft, borderRadius: 9 }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 2 }}>
                <svg width="10" height="10" viewBox="0 0 12 12" fill="none"
                     style={{ transform: pos ? 'none' : 'rotate(180deg)' }}>
                  <path d="M6 2 L10 8 L2 8 Z" fill={pos ? h.green : h.red}/>
                </svg>
                <div style={{ fontSize: 14, fontWeight: 700, color: pos ? h.green : h.red,
                              fontVariantNumeric: 'tabular-nums', letterSpacing: -0.3 }}>
                  {Math.abs(t.delta)}
                </div>
              </div>
              <div style={{ fontSize: 8, color: h.dim, textTransform: 'uppercase',
                            letterSpacing: 1, fontWeight: 600, marginTop: 1 }}>
                очков
              </div>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 13, fontWeight: 500, color: h.text,
                            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{t.name}</div>
              <div style={{ fontSize: 11, color: h.dim, marginTop: 1 }}>{t.date}</div>
            </div>
            <div style={{ width: 28, height: 28, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              {t.medal === 'trophy' ? <IconTrophyFilled size={16} color={h.muted}/> : <Medal place={t.place} size={22}/>}
            </div>
          </div>
        );
      })}
    </div>
  );
}

function S1_History_V2() {
  return (
    <div style={{ padding: '22px 16px 0' }}>
      <HistoryHeader/>
      <History_H4/>
    </div>
  );
}

Object.assign(window, { S1_History_V2 });
