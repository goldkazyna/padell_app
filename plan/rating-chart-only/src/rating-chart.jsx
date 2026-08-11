// Rating-history chart card — 3 variants
// V1 = Sparkline + last 15 matches (KEEPER from previous iteration)
// V2 = Tournament-by-tournament impact list
// V3 = Step chart with annotated peaks

const rc = {
  bg: '#131317', card: '#1c1c21',
  border: 'rgba(255,255,255,0.08)', text: '#f3f3f5',
  muted: '#a2a2ab', dim: '#6a6a73',
  green: '#22c47a', greenDark: '#1a9e62',
  greenSoft: 'rgba(34,196,122,0.14)', greenBorder: 'rgba(34,196,122,0.32)',
  red: '#ef4444', redSoft: 'rgba(239,68,68,0.10)',
};

const DATA = [
  { m: 'Июн', v: 3420, d: -45 },
  { m: 'Июл', v: 3510, d: +90 },
  { m: 'Авг', v: 3480, d: -30 },
  { m: 'Сен', v: 3580, d: +100 },
  { m: 'Окт', v: 3640, d: +60 },
  { m: 'Ноя', v: 3720, d: +80 },
  { m: 'Дек', v: 3680, d: -40 },
  { m: 'Янв', v: 3750, d: +70 },
  { m: 'Фев', v: 3820, d: +70 },
  { m: 'Мар', v: 3790, d: -30 },
  { m: 'Апр', v: 3855, d: +65 },
  { m: 'Май', v: 3890, d: +35 },
];

// =========================================================================
// V1 — Sparkline + last 15 matches (KEEPER)
// =========================================================================
function RatingChart_V1() {
  const W = 320, H = 96;
  const PAD = { l: 8, r: 8, t: 18, b: 4 };
  const min = 3300, max = 4000;
  const xs = i => PAD.l + (i / (DATA.length - 1)) * (W - PAD.l - PAD.r);
  const ys = v => PAD.t + (1 - (v - min) / (max - min)) * (H - PAD.t - PAD.b);
  const ptsArr = DATA.map((d, i) => [xs(i), ys(d.v)]);
  const path = (() => {
    let p = `M${ptsArr[0][0]},${ptsArr[0][1]}`;
    for (let i = 0; i < ptsArr.length - 1; i++) {
      const p0 = ptsArr[i-1] || ptsArr[i], p1 = ptsArr[i], p2 = ptsArr[i+1], p3 = ptsArr[i+2] || p2;
      const cp1x = p1[0] + (p2[0]-p0[0])/6, cp1y = p1[1] + (p2[1]-p0[1])/6;
      const cp2x = p2[0] - (p3[0]-p1[0])/6, cp2y = p2[1] - (p3[1]-p1[1])/6;
      p += ` C${cp1x.toFixed(1)},${cp1y.toFixed(1)} ${cp2x.toFixed(1)},${cp2y.toFixed(1)} ${p2[0].toFixed(1)},${p2[1].toFixed(1)}`;
    }
    return p;
  })();
  const areaPath = path + ` L${ptsArr[ptsArr.length-1][0]},${H-PAD.b} L${ptsArr[0][0]},${H-PAD.b} Z`;
  const [selected, setSelected] = React.useState(DATA.length - 1);
  const sel = DATA[selected];
  const [sx, sy] = ptsArr[selected];
  const RECENT = [
    { w: true,  d: +18 }, { w: true,  d: +22 }, { w: false, d: -15 },
    { w: true,  d: +12 }, { w: true,  d: +25 }, { w: true,  d: +19 },
    { w: false, d: -20 }, { w: false, d: -12 }, { w: true,  d: +28 },
    { w: true,  d: +14 }, { w: true,  d: +21 }, { w: false, d: -18 },
    { w: true,  d: +24 }, { w: true,  d: +16 }, { w: true,  d: +35 },
  ];
  return (
    <div style={{ background: rc.card, border: `1px solid ${rc.border}`, borderRadius: 16,
                   padding: 16, fontFamily: 'system-ui, sans-serif' }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: 4 }}>
        <div>
          <div style={{ fontSize: 11, color: rc.dim, fontWeight: 700, letterSpacing: 1.2, textTransform: 'uppercase' }}>
            Динамика рейтинга
          </div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginTop: 4 }}>
            <div style={{ fontSize: 26, fontWeight: 800, color: rc.text, letterSpacing: -0.5, lineHeight: 1, fontVariantNumeric: 'tabular-nums' }}>
              {sel.v.toLocaleString('ru')}
            </div>
            <div style={{ fontSize: 13, fontWeight: 800, color: sel.d >= 0 ? rc.green : rc.red }}>
              {sel.d >= 0 ? '↗ +' : '↘ '}{sel.d}
            </div>
          </div>
        </div>
      </div>
      <svg width="100%" height={H} viewBox={`0 0 ${W} ${H}`} preserveAspectRatio="none" style={{ display: 'block', marginTop: 8, overflow: 'visible' }}>
        <defs>
          <linearGradient id="g1-fill" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0%" stopColor={rc.green} stopOpacity="0.30"/>
            <stop offset="100%" stopColor={rc.green} stopOpacity="0"/>
          </linearGradient>
        </defs>
        <path d={areaPath} fill="url(#g1-fill)"/>
        <path d={path} fill="none" stroke={rc.green} strokeWidth="2" strokeLinejoin="round" strokeLinecap="round"/>
        {/* Vertical guide for selected point */}
        <line x1={sx} x2={sx} y1={sy} y2={H-PAD.b} stroke="rgba(34,196,122,0.3)" strokeDasharray="2 3"/>
        {/* All clickable dots */}
        {ptsArr.map(([x, y], i) => {
          const isSel = i === selected;
          return (
            <g key={i} style={{ cursor: 'pointer' }} onClick={() => setSelected(i)}>
              {/* Bigger transparent hit area */}
              <circle cx={x} cy={y} r="14" fill="transparent"/>
              {isSel && <circle cx={x} cy={y} r="9" fill={rc.green} opacity="0.18"/>}
              <circle cx={x} cy={y} r={isSel ? 4.5 : 3} fill={rc.green}
                      stroke={rc.card} strokeWidth={isSel ? 2.5 : 2}/>
            </g>
          );
        })}
      </svg>
      <div style={{ marginTop: 14, paddingTop: 14, borderTop: `1px solid ${rc.border}` }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
          <div style={{ fontSize: 11, color: rc.dim, fontWeight: 700, letterSpacing: 1.2, textTransform: 'uppercase' }}>Последние 15 матчей</div>
          <div style={{ fontSize: 11, color: rc.muted, fontWeight: 700 }}>11 П · 4 П</div>
        </div>
        <div style={{ display: 'flex', gap: 3 }}>
          {RECENT.map((m, i) => (
            <div key={i} style={{ flex: 1, height: 26, borderRadius: 4,
                                    background: m.w ? rc.green : rc.red,
                                    opacity: m.w ? (0.45 + Math.min(m.d, 30)/60) : (0.55 + Math.min(Math.abs(m.d), 30)/60),
                                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                                    fontSize: 9, fontWeight: 800,
                                    color: m.w ? '#06281a' : '#fff' }}>
              {m.w ? 'П' : 'П'}
            </div>
          ))}
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6,
                        fontSize: 9, color: rc.dim, fontWeight: 600 }}>
          <span>15 матчей назад</span>
          <span>сейчас</span>
        </div>
      </div>
    </div>
  );
}

// =========================================================================
// V2 — Tournament-by-tournament impact (last 8 tournaments)
// Список турниров с дельтой и итоговым рейтингом + мини-индикатор тренда
// =========================================================================
const TOURNAMENTS = [
  { name: 'L2.5+ Суббота', date: '10 мая', delta: +35, after: 3890 },
  { name: 'L3.0 Воскресенье', date: '04 мая', delta: +22, after: 3855 },
  { name: 'L2.5+ Парный', date: '27 апр', delta: +43, after: 3833 },
  { name: 'L3.0 Микст', date: '20 апр', delta: -28, after: 3790 },
  { name: 'L2.5+ Суббота', date: '13 апр', delta: +28, after: 3818 },
  { name: 'L3.0+ Премиум', date: '06 апр', delta: +12, after: 3790 },
  { name: 'L2.5+ Воскресенье', date: '30 мар', delta: -15, after: 3778 },
  { name: 'L3.0 Турнир', date: '23 мар', delta: +33, after: 3793 },
];

function RatingChart_V2() {
  const ratingNow = 3890;
  const monthDelta = TOURNAMENTS.slice(0, 4).reduce((s, t) => s + t.delta, 0);
  return (
    <div style={{ background: rc.card, border: `1px solid ${rc.border}`, borderRadius: 16,
                   padding: 16, fontFamily: 'system-ui, sans-serif' }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: 14 }}>
        <div>
          <div style={{ fontSize: 11, color: rc.dim, fontWeight: 700, letterSpacing: 1.2, textTransform: 'uppercase' }}>Динамика рейтинга</div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginTop: 4 }}>
            <div style={{ fontSize: 26, fontWeight: 800, color: rc.text, letterSpacing: -0.5, lineHeight: 1 }}>{ratingNow.toLocaleString('ru')}</div>
            <div style={{ padding: '3px 8px', background: rc.greenSoft, border: `1px solid ${rc.greenBorder}`, borderRadius: 6,
                            fontSize: 11, fontWeight: 800, color: rc.green }}>+{monthDelta} за месяц</div>
          </div>
        </div>
      </div>
      {/* Tournament list */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
        {TOURNAMENTS.slice(0, 6).map((t, i, arr) => {
          const isPos = t.delta >= 0;
          const barWidth = Math.min(Math.abs(t.delta) / 50, 1) * 100;
          return (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12,
                                    padding: '10px 0',
                                    borderBottom: i < arr.length - 1 ? `1px solid ${rc.border}` : 'none' }}>
              {/* Delta block */}
              <div style={{ minWidth: 56, textAlign: 'right',
                              fontSize: 14, fontWeight: 800, fontVariantNumeric: 'tabular-nums',
                              color: isPos ? rc.green : rc.red }}>
                {isPos ? '+' : ''}{t.delta}
              </div>
              {/* Bar visualization */}
              <div style={{ flex: 1, position: 'relative', height: 6,
                              background: 'rgba(255,255,255,0.04)', borderRadius: 3, overflow: 'hidden' }}>
                <div style={{ position: 'absolute', top: 0, bottom: 0,
                                left: isPos ? '50%' : `${50 - barWidth/2}%`,
                                width: `${barWidth/2}%`,
                                background: isPos
                                  ? `linear-gradient(90deg, ${rc.greenDark}, ${rc.green})`
                                  : `linear-gradient(270deg, #b91c1c, ${rc.red})`,
                                borderRadius: 3 }}/>
                <div style={{ position: 'absolute', left: '50%', top: -1, bottom: -1, width: 1,
                                background: 'rgba(255,255,255,0.12)' }}/>
              </div>
              {/* Tournament info */}
              <div style={{ minWidth: 0, flex: '0 0 130px' }}>
                <div style={{ fontSize: 12, fontWeight: 700, color: rc.text, letterSpacing: -0.1,
                                overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{t.name}</div>
                <div style={{ fontSize: 10, color: rc.dim, fontWeight: 600, marginTop: 1 }}>{t.date} · стало {t.after}</div>
              </div>
            </div>
          );
        })}
      </div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
                      marginTop: 12, fontSize: 12, color: rc.green, fontWeight: 700 }}>
        Все турниры <span style={{ fontSize: 14 }}>→</span>
      </div>
    </div>
  );
}

// =========================================================================
// V3 — Step chart with annotated peaks/lows
// Кривая роста с маркерами «лучший месяц / худший месяц» + over-year stats
// =========================================================================
function RatingChart_V3() {
  const W = 320, H = 180;
  const PAD = { l: 14, r: 14, t: 36, b: 32 };
  const min = 3300, max = 4000;
  const xs = i => PAD.l + (i / (DATA.length - 1)) * (W - PAD.l - PAD.r);
  const ys = v => PAD.t + (1 - (v - min) / (max - min)) * (H - PAD.t - PAD.b);
  const ptsArr = DATA.map((d, i) => [xs(i), ys(d.v)]);
  // smooth curve
  const path = (() => {
    let p = `M${ptsArr[0][0]},${ptsArr[0][1]}`;
    for (let i = 0; i < ptsArr.length - 1; i++) {
      const p0 = ptsArr[i-1] || ptsArr[i], p1 = ptsArr[i], p2 = ptsArr[i+1], p3 = ptsArr[i+2] || p2;
      const cp1x = p1[0] + (p2[0]-p0[0])/6, cp1y = p1[1] + (p2[1]-p0[1])/6;
      const cp2x = p2[0] - (p3[0]-p1[0])/6, cp2y = p2[1] - (p3[1]-p1[1])/6;
      p += ` C${cp1x.toFixed(1)},${cp1y.toFixed(1)} ${cp2x.toFixed(1)},${cp2y.toFixed(1)} ${p2[0].toFixed(1)},${p2[1].toFixed(1)}`;
    }
    return p;
  })();
  const areaPath = path + ` L${ptsArr[ptsArr.length-1][0]},${H-PAD.b} L${ptsArr[0][0]},${H-PAD.b} Z`;
  // Find best and worst month
  const bestIdx = DATA.reduce((bi, d, i) => d.d > DATA[bi].d ? i : bi, 0);
  const worstIdx = DATA.reduce((wi, d, i) => d.d < DATA[wi].d ? i : wi, 0);
  const lastIdx = DATA.length - 1;
  const totalDelta = DATA[lastIdx].v - DATA[0].v;
  return (
    <div style={{ background: rc.card, border: `1px solid ${rc.border}`, borderRadius: 16,
                   padding: 16, fontFamily: 'system-ui, sans-serif' }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: 10 }}>
        <div>
          <div style={{ fontSize: 11, color: rc.dim, fontWeight: 700, letterSpacing: 1.2, textTransform: 'uppercase' }}>История рейтинга</div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginTop: 4 }}>
            <div style={{ fontSize: 26, fontWeight: 800, color: rc.text, letterSpacing: -0.5, lineHeight: 1 }}>3 890</div>
            <div style={{ padding: '3px 8px', background: rc.greenSoft, border: `1px solid ${rc.greenBorder}`, borderRadius: 6,
                            fontSize: 11, fontWeight: 800, color: rc.green }}>+{totalDelta} за год</div>
          </div>
        </div>
      </div>
      {/* Chart */}
      <svg width="100%" height={H} viewBox={`0 0 ${W} ${H}`} preserveAspectRatio="none" style={{ display: 'block', overflow: 'visible' }}>
        <defs>
          <linearGradient id="g3-fill" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0%" stopColor={rc.green} stopOpacity="0.30"/>
            <stop offset="100%" stopColor={rc.green} stopOpacity="0"/>
          </linearGradient>
        </defs>
        {/* y grid */}
        {[3400, 3600, 3800].map(v => (
          <line key={v} x1={PAD.l} x2={W-PAD.r} y1={ys(v)} y2={ys(v)}
                  stroke="rgba(255,255,255,0.04)" strokeDasharray="2 4"/>
        ))}
        <path d={areaPath} fill="url(#g3-fill)"/>
        <path d={path} fill="none" stroke={rc.green} strokeWidth="2.4" strokeLinejoin="round" strokeLinecap="round"/>
        {/* dots */}
        {ptsArr.map(([x, y], i) => (
          <circle key={i} cx={x} cy={y} r={i === lastIdx ? 4.5 : 2.5}
                    fill={i === lastIdx ? rc.green : 'rgba(34,196,122,0.6)'}
                    stroke={i === lastIdx ? rc.card : 'none'} strokeWidth="2"/>
        ))}
        {/* Best month annotation */}
        {(() => {
          const [bx, by] = ptsArr[bestIdx];
          return (
            <g>
              <line x1={bx} x2={bx} y1={by-6} y2={by-22} stroke={rc.green} strokeWidth="1" strokeDasharray="2 2"/>
              <rect x={bx-26} y={by-38} width="52" height="16" rx="8" fill={rc.green}/>
              <text x={bx} y={by-27} textAnchor="middle" fontSize="10" fontWeight="800" fill="#06281a">↑ +{DATA[bestIdx].d}</text>
            </g>
          );
        })()}
        {/* Worst month annotation */}
        {(() => {
          const [wx, wy] = ptsArr[worstIdx];
          return (
            <g>
              <line x1={wx} x2={wx} y1={wy+6} y2={wy+22} stroke={rc.red} strokeWidth="1" strokeDasharray="2 2"/>
              <rect x={wx-22} y={wy+22} width="44" height="16" rx="8" fill={rc.red}/>
              <text x={wx} y={wy+33} textAnchor="middle" fontSize="10" fontWeight="800" fill="#fff">↓ {DATA[worstIdx].d}</text>
            </g>
          );
        })()}
        {/* month labels */}
        {DATA.map((d, i) => (
          (i % 2 === 0 || i === lastIdx) ? (
            <text key={i} x={xs(i)} y={H-12} textAnchor="middle" fontSize="10" fontWeight="700"
                    fill={i === lastIdx ? rc.green : rc.dim}>{d.m}</text>
          ) : null
        ))}
      </svg>
      {/* Stats row */}
      <div style={{ marginTop: 6, display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8,
                      padding: '10px 0 0', borderTop: `1px solid ${rc.border}` }}>
        <div>
          <div style={{ fontSize: 10, color: rc.dim, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase' }}>Лучший</div>
          <div style={{ fontSize: 13, fontWeight: 800, color: rc.green, marginTop: 2 }}>+{DATA[bestIdx].d}</div>
          <div style={{ fontSize: 10, color: rc.muted, fontWeight: 600 }}>{DATA[bestIdx].m}</div>
        </div>
        <div>
          <div style={{ fontSize: 10, color: rc.dim, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase' }}>Худший</div>
          <div style={{ fontSize: 13, fontWeight: 800, color: rc.red, marginTop: 2 }}>{DATA[worstIdx].d}</div>
          <div style={{ fontSize: 10, color: rc.muted, fontWeight: 600 }}>{DATA[worstIdx].m}</div>
        </div>
        <div>
          <div style={{ fontSize: 10, color: rc.dim, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase' }}>В среднем</div>
          <div style={{ fontSize: 13, fontWeight: 800, color: rc.text, marginTop: 2 }}>+{Math.round(totalDelta / 12)}</div>
          <div style={{ fontSize: 10, color: rc.muted, fontWeight: 600 }}>в месяц</div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { RatingChart_V1, RatingChart_V2, RatingChart_V3 });
