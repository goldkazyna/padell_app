// Compact settings variants for V1

const sv = {
  card: '#1c1c21', cardRaised: '#23232a',
  border: 'rgba(255,255,255,0.06)', divider: 'rgba(255,255,255,0.05)',
  text: '#f3f3f5', muted: '#a2a2ab', dim: '#6a6a73',
  green: '#22c47a', greenSoft: 'rgba(34,196,122,0.14)',
  blue: '#4a8bf5', amber: '#eab34e', red: '#f0554d', purple: '#a89cf5',
};

const SETTING_ITEMS = [
  { icon: <IconUserSmall size={17}/>, title: 'Настройки профиля', sub: 'Имя, город, пол', tint: sv.green, shortLabel: 'Профиль' },
  { icon: <IconBookmark size={17}/>,  title: 'Мои бронирования',  sub: 'Забронированные корты', tint: sv.blue, shortLabel: 'Брони' },
  { icon: <IconBellSmall size={17}/>, title: 'Уведомления',        sub: 'Настройки уведомлений', tint: sv.amber, shortLabel: 'Уведом.' },
  { icon: <IconGlobe size={17}/>,     title: 'Язык',               sub: 'Русский', tint: sv.purple, shortLabel: 'Язык' },
];

function SettingsHeader({ variant, setVariant }) {
  const pills = [
    { id: 'g1', label: 'Dense' },
    { id: 'g2', label: 'Inline' },
    { id: 'g3', label: 'Icons' },
    { id: 'g4', label: 'Chips' },
  ];
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10, padding: '0 4px' }}>
      <div style={{ fontSize: 11, letterSpacing: 1.4, color: sv.dim, textTransform: 'uppercase', fontWeight: 600 }}>Настройки</div>
      <div style={{ display: 'flex', gap: 3, background: 'rgba(255,255,255,0.04)', padding: 3, borderRadius: 8 }}>
        {pills.map(p => (
          <button key={p.id} onClick={() => setVariant(p.id)}
            style={{ padding: '4px 8px', fontSize: 10, borderRadius: 6, border: 'none', cursor: 'pointer',
                     background: variant === p.id ? sv.green : 'transparent',
                     color: variant === p.id ? '#0a0a0d' : sv.muted,
                     fontWeight: variant === p.id ? 700 : 500, fontFamily: 'inherit', letterSpacing: 0.3 }}>
            {p.label}
          </button>
        ))}
      </div>
    </div>
  );
}

// G1 Dense list — super-compact rows, single line, no subtitle
function Settings_G1() {
  return (
    <div style={{ background: sv.card, border: `1px solid ${sv.border}`, borderRadius: 14, overflow: 'hidden' }}>
      {SETTING_ITEMS.map((it, i, arr) => (
        <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '11px 14px',
                              borderBottom: i === arr.length - 1 ? 'none' : `1px solid ${sv.divider}`,
                              cursor: 'pointer' }}>
          <div style={{ width: 28, height: 28, borderRadius: 8,
                        background: `${it.tint}22`, color: it.tint,
                        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
            {React.cloneElement(it.icon, { size: 15 })}
          </div>
          <div style={{ flex: 1, fontSize: 14, color: sv.text }}>{it.title}</div>
          {it.sub && <div style={{ fontSize: 12, color: sv.dim }}>{it.sub}</div>}
          <IconChevronRight size={14} color={sv.dim}/>
        </div>
      ))}
    </div>
  );
}

// G2 Inline — title + value inline, ultra-minimal
function Settings_G2() {
  return (
    <div style={{ background: sv.card, border: `1px solid ${sv.border}`, borderRadius: 14, overflow: 'hidden' }}>
      {SETTING_ITEMS.map((it, i, arr) => (
        <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px',
                              borderBottom: i === arr.length - 1 ? 'none' : `1px solid ${sv.divider}`,
                              cursor: 'pointer' }}>
          <div style={{ color: it.tint, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
            {React.cloneElement(it.icon, { size: 17 })}
          </div>
          <div style={{ flex: 1, fontSize: 14, color: sv.text, fontWeight: 500 }}>{it.title}</div>
          <div style={{ fontSize: 12, color: sv.muted }}>{it.sub}</div>
          <IconChevronRight size={14} color={sv.dim}/>
        </div>
      ))}
    </div>
  );
}

// G3 Icon row — 4-in-a-row compact buttons, label below icon
function Settings_G3() {
  return (
    <div style={{ background: sv.card, border: `1px solid ${sv.border}`, borderRadius: 14,
                  display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', overflow: 'hidden' }}>
      {SETTING_ITEMS.map((it, i) => (
        <div key={i} style={{ padding: '14px 6px', display: 'flex', flexDirection: 'column',
                              alignItems: 'center', gap: 7, cursor: 'pointer',
                              borderRight: i < 3 ? `1px solid ${sv.divider}` : 'none' }}>
          <div style={{ width: 34, height: 34, borderRadius: 10,
                        background: `${it.tint}22`, color: it.tint,
                        display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            {React.cloneElement(it.icon, { size: 16 })}
          </div>
          <div style={{ fontSize: 11, color: sv.text, fontWeight: 500, textAlign: 'center' }}>{it.shortLabel}</div>
        </div>
      ))}
    </div>
  );
}

// G4 Chips — pill-shaped rows, super flat
function Settings_G4() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      {SETTING_ITEMS.map((it, i) => (
        <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 14px',
                              background: sv.card, border: `1px solid ${sv.border}`, borderRadius: 10,
                              cursor: 'pointer' }}>
          <div style={{ color: it.tint, flexShrink: 0, display: 'flex' }}>
            {React.cloneElement(it.icon, { size: 16 })}
          </div>
          <div style={{ flex: 1, fontSize: 13, color: sv.text }}>{it.title}</div>
          <div style={{ fontSize: 11, color: sv.dim }}>{it.sub}</div>
        </div>
      ))}
    </div>
  );
}

function S1_SettingsList_V2() {
  return (
    <div style={{ padding: '22px 16px 0' }}>
      <div style={{ fontSize: 11, letterSpacing: 1.4, color: sv.dim, textTransform: 'uppercase',
                    fontWeight: 600, margin: '0 4px 10px' }}>Настройки</div>
      <Settings_G1/>
    </div>
  );
}

Object.assign(window, { S1_SettingsList_V2 });
