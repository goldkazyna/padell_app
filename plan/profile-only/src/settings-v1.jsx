// V1 Stat-led — repolished hero, compact history, list-style settings

const s1 = {
  bg: '#131317', card: '#1c1c21', cardRaised: '#23232a',
  border: 'rgba(255,255,255,0.06)', divider: 'rgba(255,255,255,0.05)',
  text: '#f3f3f5', muted: '#a2a2ab', dim: '#6a6a73',
  green: '#22c47a', greenSoft: 'rgba(34,196,122,0.14)',
  blue: '#4a8bf5', orange: '#f08446', red: '#f0554d', amber: '#eab34e',
};

function S1_Hero() {
  const p = PROFILE_PAGE;
  return (
    <div style={{ padding: '10px 16px 0' }}>
      <div style={{ position: 'relative', borderRadius: 20, overflow: 'hidden',
                    background: 'linear-gradient(140deg, #1e3a2b 0%, #1a241e 40%, #1a1a1f 100%)',
                    border: `1px solid ${s1.border}` }}>
        {/* decorative ring */}
        <div style={{ position: 'absolute', top: -60, right: -60, width: 180, height: 180, borderRadius: '50%',
                      background: 'radial-gradient(circle, rgba(34,196,122,0.12) 0%, transparent 60%)' }}/>
        <div style={{ position: 'relative', padding: '18px 18px 0' }}>
          {/* Row 1 */}
          <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
            <div style={{ width: 58, height: 58, borderRadius: 16,
                          background: 'linear-gradient(135deg, #2a4a36, #1c2b22)',
                          display: 'flex', alignItems: 'center', justifyContent: 'center',
                          fontSize: 19, fontWeight: 700, color: s1.green }}>ДЯ</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <div style={{ fontSize: 16, fontWeight: 600, color: s1.text, letterSpacing: -0.2 }}>{p.name}</div>
                <div style={{ fontSize: 9, fontWeight: 700, color: s1.green, background: s1.greenSoft,
                              padding: '2px 6px', borderRadius: 5, letterSpacing: 0.5 }}>PRO</div>
              </div>
              <div style={{ fontSize: 11, color: s1.muted, marginTop: 2 }}>{p.phone}</div>
            </div>
            <button style={{ width: 36, height: 36, borderRadius: 10, background: 'rgba(255,255,255,0.06)',
                             border: `1px solid ${s1.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center',
                             cursor: 'pointer' }}>
              <IconEdit size={16} color={s1.text}/>
            </button>
          </div>
          {/* Big rating */}
          <div style={{ marginTop: 16, display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between' }}>
            <div>
              <div style={{ fontSize: 10, letterSpacing: 1.4, color: s1.dim, textTransform: 'uppercase', fontWeight: 600 }}>Рейтинг</div>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginTop: 4 }}>
                <div style={{ fontSize: 38, fontWeight: 700, color: s1.text, lineHeight: 1, letterSpacing: -1.3 }}>{p.rating}</div>
                <div style={{ fontSize: 12, color: s1.muted }}>#{p.ratingRank}</div>
              </div>
            </div>
            <Sparkline points={p.ratingTrend} color={s1.green} width={110} height={38}/>
          </div>
          {/* Level progress */}
          <div style={{ marginTop: 14 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
              <div style={{ fontSize: 10, color: s1.muted, letterSpacing: 0.3 }}>Уровень {p.level} → {p.nextLevel}</div>
              <div style={{ fontSize: 10, color: s1.dim, fontVariantNumeric: 'tabular-nums' }}>{p.levelProgress} / {p.levelTarget}</div>
            </div>
            <div style={{ height: 3, borderRadius: 2, background: 'rgba(255,255,255,0.05)', overflow: 'hidden' }}>
              <div style={{ height: '100%', width: `${(p.levelProgress / p.levelTarget) * 100}%`, background: s1.green }}/>
            </div>
          </div>
        </div>
        {/* Stats strip inside hero */}
        <div style={{ marginTop: 16, padding: '14px 18px', borderTop: `1px solid ${s1.border}`,
                      background: 'rgba(0,0,0,0.2)', display: 'flex', justifyContent: 'space-between' }}>
          {[
            { v: p.matches, l: 'Матчей' },
            { v: p.wins, l: 'Побед' },
            { v: p.winrate + '%', l: 'Винрейт', color: s1.green },
            { v: p.matches - p.wins, l: 'Пораж.', color: s1.muted },
          ].map((st, i) => (
            <div key={i} style={{ textAlign: 'center' }}>
              <div style={{ fontSize: 17, fontWeight: 700, color: st.color || s1.text, letterSpacing: -0.3 }}>{st.v}</div>
              <div style={{ fontSize: 10, letterSpacing: 1, color: s1.dim, textTransform: 'uppercase', fontWeight: 600, marginTop: 2 }}>{st.l}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function S1_Stats() {
  const p = PROFILE_PAGE;
  const items = [
    { label: 'Рейтинг', value: p.rating, color: s1.green },
    { label: 'Матчей',  value: p.matches },
    { label: 'Побед',   value: p.wins },
    { label: 'Винрейт', value: p.winrate + '%', color: p.winrate >= 60 ? s1.green : s1.amber },
  ];
  return (
    <div style={{ padding: '14px 16px 0' }}>
      <div style={{ display: 'flex', gap: 8 }}>
        {items.map((it, i) => (
          <div key={i} style={{ flex: 1, background: s1.card, border: `1px solid ${s1.border}`,
                                borderRadius: 12, padding: '10px 8px', textAlign: 'center' }}>
            <div style={{ fontSize: 18, fontWeight: 700, color: it.color || s1.text,
                          letterSpacing: -0.5, fontVariantNumeric: 'tabular-nums' }}>{it.value}</div>
            <div style={{ fontSize: 10, letterSpacing: 1.2, color: s1.dim,
                          textTransform: 'uppercase', fontWeight: 600, marginTop: 4 }}>{it.label}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function S1_History() {
  return (
    <div style={{ padding: '22px 16px 0' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10, padding: '0 4px' }}>
        <div style={{ fontSize: 15, fontWeight: 600, color: s1.text, letterSpacing: -0.2 }}>История турниров</div>
        <div style={{ fontSize: 13, color: s1.green, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 2 }}>
          Все <IconChevronRight size={15} color={s1.green}/>
        </div>
      </div>
      <div style={{ background: s1.card, border: `1px solid ${s1.border}`, borderRadius: 14, overflow: 'hidden' }}>
        {TOURNAMENT_HISTORY.slice(0, 4).map((t, i, arr) => {
          const pos = t.delta >= 0;
          return (
            <div key={t.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px',
                                      borderBottom: i === arr.length - 1 ? 'none' : `1px solid ${s1.divider}` }}>
              <div style={{ width: 34, height: 34, borderRadius: 10, background: 'rgba(255,255,255,0.03)',
                            display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                {t.medal === 'trophy' ? <IconTrophyFilled size={18} color={s1.muted}/> : <Medal place={t.place} size={22}/>}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14, fontWeight: 500, color: s1.text,
                              overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{t.name}</div>
                <div style={{ fontSize: 11, color: s1.dim, marginTop: 2 }}>{t.date}</div>
              </div>
              <div style={{ fontSize: 13, fontWeight: 700, fontVariantNumeric: 'tabular-nums',
                            color: pos ? s1.green : s1.red, minWidth: 38, textAlign: 'right' }}>
                {pos ? '+' : ''}{t.delta}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function S1_SettingsList() {
  const groups = [
    [
      { icon: <IconUserSmall size={17}/>, title: 'Настройки профиля', sub: 'Имя, город, пол', tint: s1.green },
      { icon: <IconBookmark size={17}/>, title: 'Мои бронирования', sub: 'Забронированные корты', tint: s1.blue },
      { icon: <IconBellSmall size={17}/>, title: 'Уведомления', sub: 'Настройки уведомлений', tint: s1.amber },
      { icon: <IconGlobe size={17}/>, title: 'Язык', sub: 'Русский', tint: '#a89cf5' },
    ],
  ];
  return (
    <div style={{ padding: '22px 16px 0' }}>
      <div style={{ fontSize: 11, letterSpacing: 1.4, color: s1.dim, textTransform: 'uppercase',
                    fontWeight: 600, margin: '0 4px 8px' }}>Настройки</div>
      <div style={{ background: s1.card, border: `1px solid ${s1.border}`, borderRadius: 14, overflow: 'hidden' }}>
        {groups[0].map((g, i, arr) => (
          <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px',
                                borderBottom: i === arr.length - 1 ? 'none' : `1px solid ${s1.divider}` }}>
            <div style={{ width: 34, height: 34, borderRadius: 10,
                          background: `${g.tint}22`, color: g.tint,
                          display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              {g.icon}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 14, fontWeight: 500, color: s1.text }}>{g.title}</div>
              <div style={{ fontSize: 11, color: s1.dim, marginTop: 1 }}>{g.sub}</div>
            </div>
            <IconChevronRight size={16} color={s1.dim}/>
          </div>
        ))}
      </div>
    </div>
  );
}

function S1_Danger() {
  return (
    <div style={{ padding: '16px 16px 0' }}>
      <div style={{ fontSize: 11, letterSpacing: 1.4, color: s1.dim, textTransform: 'uppercase',
                    fontWeight: 600, margin: '0 4px 8px' }}>Аккаунт</div>
      <div style={{ background: s1.card, border: `1px solid ${s1.border}`, borderRadius: 14, overflow: 'hidden' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px',
                      borderBottom: `1px solid ${s1.divider}` }}>
          <div style={{ width: 34, height: 34, borderRadius: 10, background: 'rgba(240,85,77,0.1)', color: s1.red,
                        display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <IconLogout size={17}/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, fontWeight: 500, color: s1.text }}>Выйти</div>
            <div style={{ fontSize: 11, color: s1.dim, marginTop: 1 }}>Выйти из аккаунта</div>
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px' }}>
          <div style={{ width: 34, height: 34, borderRadius: 10, background: 'rgba(240,85,77,0.1)', color: s1.red,
                        display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <IconTrash size={17}/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, fontWeight: 500, color: s1.red }}>Удалить аккаунт</div>
            <div style={{ fontSize: 11, color: s1.dim, marginTop: 1 }}>Безвозвратное удаление</div>
          </div>
        </div>
      </div>
    </div>
  );
}

function S1_Dev() {
  return (
    <div style={{ padding: '16px 16px 0', display: 'flex', alignItems: 'center', gap: 10 }}>
      <div style={{ width: 30, height: 30, borderRadius: 8, background: 'rgba(74,139,245,0.12)', color: s1.blue,
                    display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <IconCode size={16}/>
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 12, color: s1.muted }}>Разработчик</div>
        <div style={{ fontSize: 11, color: s1.dim }}>Дудников Денис · @mdlabkz</div>
      </div>
      <IconExternal size={14} color={s1.dim}/>
    </div>
  );
}

function S1_Nav() {
  const items = [
    { label: 'Главная', Icon: IconHome },
    { label: 'Турниры', Icon: IconTrophy },
    { label: 'Бронирование', Icon: IconCalendar },
    { label: 'Рейтинг', Icon: IconChart },
    { label: 'Профиль', Icon: IconUser, active: true },
  ];
  return (
    <div style={{ background: s1.bg, borderTop: `1px solid ${s1.border}`, display: 'flex', padding: '8px 4px 12px' }}>
      {items.map((it, i) => (
        <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, position: 'relative' }}>
          {it.active && <div style={{ position: 'absolute', top: -8, width: 20, height: 2, borderRadius: 2, background: s1.green }}/>}
          <it.Icon size={22} color={it.active ? s1.green : s1.dim} active={it.active}/>
          <div style={{ fontSize: 11, color: it.active ? s1.green : s1.dim, fontWeight: it.active ? 600 : 400 }}>{it.label}</div>
        </div>
      ))}
    </div>
  );
}

function ScreenS1() {
  return (
    <div style={{ background: s1.bg, color: s1.text, display: 'flex', flexDirection: 'column', height: '100%',
                  fontFamily: 'system-ui, -apple-system, sans-serif' }}>
      <div style={{ flex: 1, overflowY: 'auto', paddingBottom: 20 }}>
        <S1_Hero/>
        <S1_History_V2/>
        <S1_SettingsList_V2/>
        <S1_Danger/>
        <S1_Dev/>
      </div>
      <S1_Nav/>
    </div>
  );
}

Object.assign(window, { ScreenS1 });
