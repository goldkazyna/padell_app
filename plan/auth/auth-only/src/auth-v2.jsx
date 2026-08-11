// V2 — Tinted cards. Telegram/WhatsApp/Google/Apple равнозначными карточками,
// Email вынесен отдельно снизу с разделителем «или» — как в оригинале.

const av2 = {
  bg: '#131317', card: '#1c1c21', border: 'rgba(255,255,255,0.08)',
  text: '#f3f3f5', muted: '#a2a2ab', dim: '#6a6a73',
  green: '#22c47a',
};

// Top 4 social providers + email below
const SOCIAL = PROVIDERS.filter(p => p.id !== 'email');
const EMAIL_PROVIDER = PROVIDERS.find(p => p.id === 'email');

// Subtle brand tint bg per provider — same padding/typography, just tinted background
const TINTS = {
  telegram: { bg: 'rgba(34,158,217,0.06)',  border: 'rgba(34,158,217,0.18)' },
  whatsapp: { bg: 'rgba(37,211,102,0.06)',  border: 'rgba(37,211,102,0.18)' },
  google:   { bg: 'rgba(255,255,255,0.04)', border: 'rgba(255,255,255,0.12)' },
  apple:    { bg: 'rgba(255,255,255,0.04)', border: 'rgba(255,255,255,0.12)' },
};

function AuthRow_V2({ provider }) {
  const Icon = provider.icon;
  const tint = TINTS[provider.id];
  return (
    <button style={{ padding: '13px 16px', borderRadius: 14, background: tint.bg,
                     border: `1px solid ${tint.border}`, color: av2.text,
                     fontSize: 14, fontWeight: 500, cursor: 'pointer',
                     display: 'flex', alignItems: 'center', gap: 12, fontFamily: 'inherit', textAlign: 'left' }}>
      <Icon size={24}/>
      <span style={{ flex: 1, fontWeight: 600 }}>{provider.label}</span>
      <IconChev/>
    </button>
  );
}

function EmailButton_V2() {
  const Icon = EMAIL_PROVIDER.icon;
  return (
    <button style={{ padding: '13px 16px', borderRadius: 14, background: 'transparent',
                     border: `1px solid ${av2.border}`, color: av2.text,
                     fontSize: 14, fontWeight: 600, cursor: 'pointer',
                     display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
                     fontFamily: 'inherit' }}>
      <Icon size={22}/>
      Войти через Email или телефон
    </button>
  );
}

function AuthScreen_V2() {
  const [agreed, setAgreed] = React.useState(true);
  return (
    <div style={{ background: av2.bg, color: av2.text, display: 'flex', flexDirection: 'column',
                  height: '100%', fontFamily: 'system-ui, -apple-system, sans-serif', padding: '8px 20px 14px',
                  position: 'relative', overflow: 'hidden' }}>
      {/* Mild ambient glow */}
      <div style={{ position: 'absolute', top: -30, right: -40, width: 220, height: 220,
                    background: 'radial-gradient(circle, rgba(34,196,122,0.08) 0%, transparent 70%)',
                    pointerEvents: 'none' }}/>

      <div style={{ paddingTop: 8, position: 'relative' }}>
        <button style={{ width: 38, height: 38, borderRadius: 12, background: av2.card, border: `1px solid ${av2.border}`,
                        display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <IconArrowBack/>
        </button>
      </div>

      <div style={{ marginTop: 36, position: 'relative' }}>
        <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.4 }}>Вход</div>
        <div style={{ fontSize: 13, color: av2.muted, marginTop: 4 }}>Выберите удобный способ</div>
      </div>

      {/* 4 social providers */}
      <div style={{ marginTop: 22, display: 'flex', flexDirection: 'column', gap: 8, position: 'relative' }}>
        {SOCIAL.map(p => <AuthRow_V2 key={p.id} provider={p}/>)}
      </div>

      {/* или */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, margin: '18px 0 14px',
                    color: av2.dim, position: 'relative' }}>
        <div style={{ flex: 1, height: 1, background: av2.border }}/>
        <div style={{ fontSize: 12, fontWeight: 500 }}>или</div>
        <div style={{ flex: 1, height: 1, background: av2.border }}/>
      </div>

      {/* Email отдельно */}
      <div style={{ position: 'relative' }}>
        <EmailButton_V2/>
      </div>

      <div style={{ flex: 1 }}/>

      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10, marginBottom: 12, position: 'relative' }}>
        <div onClick={() => setAgreed(!agreed)}
             style={{ width: 18, height: 18, borderRadius: 5, background: agreed ? av2.green : 'transparent',
                      border: `1.5px solid ${agreed ? av2.green : 'rgba(255,255,255,0.2)'}`,
                      display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                      marginTop: 1, cursor: 'pointer' }}>
          {agreed && <IconCheck/>}
        </div>
        <div style={{ fontSize: 11, color: av2.muted, lineHeight: 1.5 }}>
          Продолжая, я принимаю <span style={{ color: av2.green, textDecoration: 'underline', textUnderlineOffset: 2 }}>Пользовательское соглашение</span> и <span style={{ color: av2.green, textDecoration: 'underline', textUnderlineOffset: 2 }}>согласие на обработку данных</span>
        </div>
      </div>
      <div style={{ fontSize: 10, color: av2.dim, textAlign: 'center', opacity: 0.6 }}>
        Developed by Dudnikov Denis
      </div>
    </div>
  );
}

Object.assign(window, { AuthScreen_V2 });
