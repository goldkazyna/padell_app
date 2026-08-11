// Tournament list data — mock

const TOURNAMENTS = [
  // April 18
  { id: 1, date: '2026-04-18', dateLabel: '18 апр', dayOfWeek: 'Сб', time: '16:30',
    name: 'L2-L3 Mix- Суббота', format: 'Американо', formatColor: 'blue',
    club: 'ADD Padel Almaty', clubCity: 'Алматы', clubLogo: 'almaty',
    players: 16, playersMax: 16, price: 18000, levelMin: 2.0, levelMax: 3.75, status: 'full' },
  { id: 2, date: '2026-04-18', dateLabel: '18 апр', dayOfWeek: 'Сб', time: '19:00',
    name: 'L2 - Суббота', format: 'Американо', formatColor: 'blue',
    club: 'ADD Padel Almaty', clubCity: 'Алматы', clubLogo: 'almaty',
    players: 16, playersMax: 16, price: 18000, levelMin: 2.0, levelMax: 2.75, status: 'full' },
  { id: 7, date: '2026-04-18', dateLabel: '18 апр', dayOfWeek: 'Сб', time: '17:00',
    name: 'L2.25+ Суббота', format: 'Американо', formatColor: 'blue',
    club: 'ADD Padel Astana', clubCity: 'Астана', clubLogo: 'astana',
    players: 6, playersMax: 8, price: 18000, levelMin: 2.25, levelMax: 2.5, status: 'open' },
  { id: 8, date: '2026-04-18', dateLabel: '18 апр', dayOfWeek: 'Сб', time: '19:00',
    name: 'L2.75+ Суббота', format: 'Американо', formatColor: 'blue',
    club: 'ADD Padel Astana', clubCity: 'Астана', clubLogo: 'astana',
    players: 5, playersMax: 8, price: 18000, levelMin: 2.75, levelMax: 3.25, status: 'open' },

  // April 19
  { id: 3, date: '2026-04-19', dateLabel: '19 апр', dayOfWeek: 'Вс', time: '11:00',
    name: 'Женский -Воскресенье', format: 'Американо', formatColor: 'blue',
    club: 'ADD Padel Almaty', clubCity: 'Алматы', clubLogo: 'almaty',
    players: 16, playersMax: 16, price: 18000, levelMin: 1.25, levelMax: 3.5, status: 'full', tag: 'Женский' },
  { id: 4, date: '2026-04-19', dateLabel: '19 апр', dayOfWeek: 'Вс', time: '14:00',
    name: 'L2.75-L3.50', format: 'Американо', formatColor: 'blue',
    club: 'ADD Padel Almaty', clubCity: 'Алматы', clubLogo: 'almaty',
    players: 16, playersMax: 16, price: 18000, levelMin: 2.75, levelMax: 3.5, status: 'full' },
  { id: 5, date: '2026-04-19', dateLabel: '19 апр', dayOfWeek: 'Вс', time: '16:30',
    name: 'L1-L2 (1.5-2.50) - Воскресенье', format: 'Американо', formatColor: 'blue',
    club: 'ADD Padel Almaty', clubCity: 'Алматы', clubLogo: 'almaty',
    players: 16, playersMax: 16, price: 18000, levelMin: 1.5, levelMax: 2.5, status: 'full' },
  { id: 6, date: '2026-04-19', dateLabel: '19 апр', dayOfWeek: 'Вс', time: '19:00',
    name: 'L2-L3 Парный- Воскресенье', format: 'Групповой + Плей-офф', formatColor: 'purple',
    club: 'ADD Padel Almaty', clubCity: 'Алматы', clubLogo: 'almaty',
    players: 14, playersMax: 16, price: 36000, levelMin: 2.0, levelMax: 3.75, status: 'open', highlight: true },
  { id: 11, date: '2026-04-19', dateLabel: '19 апр', dayOfWeek: 'Вс', time: '21:30',
    name: 'L3-L3.75 Премиум- Воскресенье', format: 'Американо', formatColor: 'blue',
    club: 'ADD Padel Almaty', clubCity: 'Алматы', clubLogo: 'almaty',
    players: 16, playersMax: 16, price: 22000, levelMin: 3.0, levelMax: 3.75, status: 'full' },

  // April 20
  { id: 9, date: '2026-04-20', dateLabel: '20 апр', dayOfWeek: 'Пн', time: '19:00',
    name: 'L3+ Вечер', format: 'Американо', formatColor: 'blue',
    club: 'ADD Padel Almaty', clubCity: 'Алматы', clubLogo: 'almaty',
    players: 4, playersMax: 8, price: 20000, levelMin: 3.0, levelMax: 4.0, status: 'open' },
  { id: 10, date: '2026-04-20', dateLabel: '20 апр', dayOfWeek: 'Пн', time: '20:00',
    name: 'L4+ Мастерс', format: 'Групповой', formatColor: 'purple',
    club: 'ADD Padel Almaty', clubCity: 'Алматы', clubLogo: 'almaty',
    players: 2, playersMax: 8, price: 25000, levelMin: 4.0, levelMax: 5.0, status: 'open' },
];

const MY_LEVEL = 3.75;

// Club logo tile
const ClubLogo = ({ club, size = 28 }) => {
  const letter = club === 'almaty' ? 'A' : 'ASTANA';
  const bg = club === 'almaty' ? '#1e3a8a' : '#fff';
  const fg = club === 'almaty' ? '#8ab4ff' : '#3a3a3a';
  return (
    <div style={{ width: size, height: size, borderRadius: 7, background: bg, color: fg,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: club === 'almaty' ? size * 0.5 : size * 0.22,
                  fontWeight: 700, letterSpacing: 0.2, flexShrink: 0 }}>
      {club === 'almaty' ? 'A' : 'ASTANA'}
    </div>
  );
};

// Level range bar — visual spectrum with player dot
const LevelBar = ({ min, max, myLevel = MY_LEVEL, width = '100%', inRange }) => {
  const scaleMin = 1.0, scaleMax = 5.0;
  const rangePct = (v) => ((v - scaleMin) / (scaleMax - scaleMin)) * 100;
  const myPct = rangePct(myLevel);
  const minPct = rangePct(min);
  const maxPct = rangePct(max);
  return (
    <div style={{ position: 'relative', height: 6, borderRadius: 3, background: 'rgba(255,255,255,0.05)', width }}>
      <div style={{ position: 'absolute', left: `${minPct}%`, width: `${maxPct - minPct}%`,
                    top: 0, bottom: 0, borderRadius: 3,
                    background: inRange ? '#22c47a' : 'rgba(74,139,245,0.5)' }}/>
      <div style={{ position: 'absolute', left: `calc(${myPct}% - 5px)`, top: -2, width: 10, height: 10,
                    borderRadius: '50%', background: inRange ? '#22c47a' : '#f3f3f5',
                    border: '2px solid #131317', boxSizing: 'border-box' }}/>
    </div>
  );
};

function isInLevelRange(t, level = MY_LEVEL) {
  return level >= t.levelMin && level <= t.levelMax;
}

function formatPrice(p) {
  return (p / 1000).toFixed(0) + 'к ₸';
}

const FORMAT_COLORS = {
  blue:   { bg: 'rgba(74,139,245,0.15)',   fg: '#7aa8f8' },
  purple: { bg: 'rgba(168,156,245,0.15)',  fg: '#b3a7f8' },
  orange: { bg: 'rgba(240,132,70,0.15)',   fg: '#f5a37a' },
};

Object.assign(window, { TOURNAMENTS, MY_LEVEL, ClubLogo, LevelBar, isInLevelRange, formatPrice, FORMAT_COLORS });
