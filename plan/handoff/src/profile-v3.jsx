// V3 — Card preview at top + sectioned cards with dense inline rows

const pv3 = {
  bg: '#131317',
  card: '#1c1c21',
  cardRaised: '#23232a',
  border: 'rgba(255,255,255,0.06)',
  divider: 'rgba(255,255,255,0.05)',
  text: '#f3f3f5',
  muted: '#a2a2ab',
  dim: '#6a6a73',
  green: '#22c47a',
  greenSoft: 'rgba(34,196,122,0.14)',
  red: '#f0554d',
  amber: '#eab34e',
};

function P3_Header() {
  return (
    <div style={{ padding: '14px 16px 10px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        <div style={{ width: 34, height: 34, borderRadius: '50%', background: pv3.card,
                      border: `1px solid ${pv3.border}`,
                      display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <IconArrowLeft size={18} color={pv3.text}/>
        </div>
        <div style={{ fontSize: 17, fontWeight: 600, color: pv3.text, letterSpacing: -0.2 }}>Настройки профиля</div>
      </div>
      <div style={{ background: pv3.greenSoft, color: pv3.green, padding: '7px 14px', borderRadius: 10,
                    fontSize: 13, fontWeight: 600 }}>Сохранить</div>
    </div>
  );
}

// Hero: big profile card with avatar, name, stats-esque meta, progress
function P3_Hero({ pct }) {
  return (
    <div style={{ padding: '6px 16px 0' }}>
      <div style={{ background: 'linear-gradient(180deg, #1f1f26 0%, #1a1a20 100%)',
                    border: `1px solid ${pv3.border}`, borderRadius: 18, padding: '18px 18px 16px' }}>
        <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
          <div style={{ position: 'relative', width: 64, height: 64 }}>
            <div style={{ width: 64, height: 64, borderRadius: 18, background: pv3.green,
                          display: 'flex', alignItems: 'center', justifyContent: 'center',
                          fontSize: 22, fontWeight: 700, color: '#fff' }}>АК</div>
            <div style={{ position: 'absolute', right: -3, bottom: -3, width: 24, height: 24, borderRadius: 12,
                          background: pv3.cardRaised, border: `2px solid #1b1b21`,
                          display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <IconCamera size={12} color={pv3.text}/>
            </div>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 17, fontWeight: 600, color: pv3.text, letterSpacing: -0.3 }}>Андрей Кузнецов</div>
            <div style={{ fontSize: 12, color: pv3.muted, marginTop: 3 }}>Алматы · Уровень 1.00</div>
            <div style={{ display: 'flex', gap: 4, marginTop: 6 }}>
              <div style={{ padding: '2px 7px', borderRadius: 6, background: pv3.greenSoft,
                            color: pv3.green, fontSize: 11, fontWeight: 600 }}>Правша</div>
              <div style={{ padding: '2px 7px', borderRadius: 6, background: 'rgba(255,255,255,0.04)',
                            color: pv3.muted, fontSize: 11, fontWeight: 500 }}>#675 в рейтинге</div>
            </div>
          </div>
        </div>
        {/* progress */}
        <div style={{ marginTop: 14, padding: '10px 12px', background: 'rgba(255,255,255,0.03)',
                      borderRadius: 10 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 6 }}>
            <div style={{ fontSize: 12, color: pv3.muted }}>Профиль заполнен</div>
            <div style={{ fontSize: 13, fontWeight: 700, color: pv3.green }}>{pct}%</div>
          </div>
          <div style={{ height: 4, borderRadius: 2, background: 'rgba(255,255,255,0.05)', overflow: 'hidden' }}>
            <div style={{ height: '100%', width: `${pct}%`, background: pv3.green, borderRadius: 2 }}/>
          </div>
          <div style={{ fontSize: 11, color: pv3.dim, marginTop: 6 }}>
            Заполните возраст и позицию на корте, чтобы находить пары
          </div>
        </div>
      </div>
    </div>
  );
}

function P3_SectionTitle({ children, optional }) {
  return (
    <div style={{ margin: '18px 20px 8px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
      <div style={{ fontSize: 11, letterSpacing: 1.4, color: pv3.dim, textTransform: 'uppercase', fontWeight: 600 }}>
        {children}
      </div>
      {optional && (
        <div style={{ fontSize: 10, color: pv3.dim, background: 'rgba(255,255,255,0.03)',
                      padding: '2px 7px', borderRadius: 5, fontWeight: 500 }}>Опционально</div>
      )}
    </div>
  );
}

function P3_Row({ icon, label, value, placeholder, lock, chevron, last, required, incomplete }) {
  const empty = !value;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px',
                  borderBottom: last ? 'none' : `1px solid ${pv3.divider}` }}>
      <div style={{ width: 34, height: 34, borderRadius: 10, background: 'rgba(255,255,255,0.04)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center', color: pv3.muted, flexShrink: 0 }}>
        {icon}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 11, color: pv3.dim, marginBottom: 1, display: 'flex', gap: 5, alignItems: 'center' }}>
          {label}
          {incomplete && <span style={{ color: pv3.amber, fontSize: 11 }}>• Не заполнено</span>}
        </div>
        <div style={{ fontSize: 14, fontWeight: 500, color: empty ? pv3.dim : pv3.text,
                      overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
          {value || placeholder}
        </div>
      </div>
      {lock && <IconLock size={15} color={pv3.dim}/>}
      {chevron && <IconChevronRight size={16} color={pv3.dim}/>}
    </div>
  );
}

function P3_Card({ children }) {
  return (
    <div style={{ margin: '0 16px', background: pv3.card, border: `1px solid ${pv3.border}`,
                  borderRadius: 14, overflow: 'hidden' }}>{children}</div>
  );
}

function P3_ChipPicker({ icon, label, options, value }) {
  return (
    <div style={{ padding: '12px 14px', borderTop: `1px solid ${pv3.divider}`,
                  display: 'flex', alignItems: 'center', gap: 12 }}>
      <div style={{ width: 34, height: 34, borderRadius: 10, background: 'rgba(255,255,255,0.04)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center', color: pv3.muted, flexShrink: 0 }}>
        {icon}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 11, color: pv3.dim, marginBottom: 6 }}>{label}</div>
        <div style={{ display: 'flex', gap: 5, flexWrap: 'wrap' }}>
          {options.map(o => {
            const active = o === value;
            return (
              <div key={o} style={{ padding: '5px 12px', borderRadius: 999,
                                    background: active ? pv3.green : 'rgba(255,255,255,0.04)',
                                    border: `1px solid ${active ? pv3.green : pv3.border}`,
                                    fontSize: 12, fontWeight: active ? 600 : 400,
                                    color: active ? '#fff' : pv3.muted }}>{o}</div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

function ScreenP3() {
  const pct = computeCompletion(PROFILE);
  return (
    <div style={{ background: pv3.bg, color: pv3.text, display: 'flex', flexDirection: 'column', height: '100%',
                  fontFamily: 'system-ui, -apple-system, sans-serif' }}>
      <div style={{ flex: 1, overflowY: 'auto', paddingBottom: 30 }}>
        <P3_Header/>
        <P3_Hero pct={pct}/>

        <P3_SectionTitle>Контакты</P3_SectionTitle>
        <P3_Card>
          <P3_Row icon={<IconUserSmall size={17}/>} label="Имя" value="Андрей Кузнецов"/>
          <P3_Row icon={<IconPhone size={17}/>} label="Телефон" value="+7 777 422 12 12" lock/>
          <P3_Row icon={<IconMapPin size={17}/>} label="Город" value="Алматы" chevron last/>
        </P3_Card>

        <P3_SectionTitle optional>О вас</P3_SectionTitle>
        <P3_Card>
          <P3_Row icon={<IconCake size={17}/>} label="Возраст" placeholder="Укажите возраст" chevron incomplete/>
          <P3_ChipPicker icon={<IconGender size={17}/>} label="Пол"
                         options={['Мужской', 'Женский']} value="Мужской"/>
        </P3_Card>

        <P3_SectionTitle>Игровой стиль</P3_SectionTitle>
        <P3_Card>
          <P3_ChipPicker icon={<IconHand size={17}/>} label="Ведущая рука"
                         options={['Правша', 'Левша']} value="Правша"/>
          <P3_ChipPicker icon={<IconCourt size={17}/>} label="Позиция на корте"
                         options={['Справа', 'Слева', 'Любая']}/>
        </P3_Card>

        <div style={{ padding: '20px 16px 0' }}>
          <div style={{ background: pv3.green, color: '#fff', textAlign: 'center',
                        padding: '14px 0', borderRadius: 12, fontSize: 15, fontWeight: 600 }}>
            Сохранить изменения
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { ScreenP3 });
