// Shared profile-page data + extra icons

const PROFILE_PAGE = {
  avatar: null,          // null → initials
  initials: 'ДЯ',
  name: 'Денис Яманов',
  phone: '+7 771 507 57 57',
  rating: 3775,
  ratingRank: 63,
  level: 3.75,
  nextLevel: 4.00,
  levelProgress: 3775,
  levelTarget: 4000,
  matches: 258,
  wins: 171,
  winrate: 66,
  ratingTrend: [3620, 3640, 3605, 3660, 3690, 3680, 3720, 3750, 3775],
};

const TOURNAMENT_HISTORY = [
  { id: 1, place: 2, name: 'L3 🔥парный',       date: '12 апреля', delta: +24, medal: 'silver' },
  { id: 2, place: null, name: 'PRO L3.75-L4.75', date: '12 апреля', delta: -46, medal: 'trophy' },
  { id: 3, place: 3, name: 'L3 Парный- Воскресенье', date: '29 марта', delta: +7, medal: 'bronze' },
  { id: 4, place: 2, name: 'L2-L3 Mix- Суббота',     date: '28 марта', delta: -29, medal: 'silver' },
  { id: 5, place: 2, name: 'L2-L3 Mix- Вторник',     date: '24 марта', delta: +8, medal: 'silver' },
];

// SVG helpers — medal
const Medal = ({ place, size = 28 }) => {
  const color = place === 1 ? '#e9c46a' : place === 2 ? '#c7c9cf' : '#cd8a4b';
  return (
    <svg width={size} height={size} viewBox="0 0 32 32" style={{ display: 'block' }}>
      {/* ribbon */}
      <path d="M10 2 L13 14 L16 10 L19 14 L22 2 Z" fill="#c94b3a" opacity="0.65"/>
      <path d="M11 2 L14 12 L16 10 L18 12 L21 2 Z" fill="#2e62b6" opacity="0.65"/>
      <circle cx="16" cy="20" r="9" fill={color} stroke={place === 3 ? '#a46735' : '#9a9ca2'} strokeWidth="0.5"/>
      <text x="16" y="23" textAnchor="middle" fontSize="9" fontWeight="700" fill={place === 3 ? '#5a3b22' : '#4a4c52'}>{place}</text>
    </svg>
  );
};

const IconTrophyFilled = ({ size = 20, color = '#9a9aa3' }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
    <path d="M8 4h8v5a4 4 0 01-8 0V4z"/>
    <path d="M8 6H5a2 2 0 000 4h1M16 6h3a2 2 0 010 4h-1"/>
    <path d="M10 14h4l-.5 3h-3L10 14zM9 20h6"/>
  </svg>
);

const IconGlobe = (p) => (
  <Icon {...p}>
    <circle cx="12" cy="12" r="9"/>
    <path d="M3 12h18M12 3a14 14 0 010 18M12 3a14 14 0 000 18"/>
  </Icon>
);

const IconGear = (p) => (
  <Icon {...p}>
    <circle cx="12" cy="12" r="3"/>
    <path d="M19.4 15a1.7 1.7 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.7 1.7 0 00-1.8-.3 1.7 1.7 0 00-1 1.5V21a2 2 0 01-4 0v-.1a1.7 1.7 0 00-1.1-1.5 1.7 1.7 0 00-1.8.3l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.7 1.7 0 00.3-1.8 1.7 1.7 0 00-1.5-1H3a2 2 0 010-4h.1a1.7 1.7 0 001.5-1.1 1.7 1.7 0 00-.3-1.8l-.1-.1a2 2 0 112.8-2.8l.1.1a1.7 1.7 0 001.8.3H9a1.7 1.7 0 001-1.5V3a2 2 0 014 0v.1a1.7 1.7 0 001 1.5 1.7 1.7 0 001.8-.3l.1-.1a2 2 0 112.8 2.8l-.1.1a1.7 1.7 0 00-.3 1.8V9a1.7 1.7 0 001.5 1H21a2 2 0 010 4h-.1a1.7 1.7 0 00-1.5 1z"/>
  </Icon>
);

const IconBookmark = (p) => (
  <Icon {...p}>
    <path d="M19 21l-7-5-7 5V5a2 2 0 012-2h10a2 2 0 012 2z"/>
  </Icon>
);

const IconBellSmall = (p) => (
  <Icon {...p}>
    <path d="M6 8a6 6 0 0112 0c0 7 3 9 3 9H3s3-2 3-9"/>
    <path d="M10.3 21a1.94 1.94 0 003.4 0"/>
  </Icon>
);

const IconLogout = (p) => (
  <Icon {...p}>
    <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
    <path d="M16 17l5-5-5-5"/>
    <path d="M21 12H9"/>
  </Icon>
);

const IconTrash = (p) => (
  <Icon {...p}>
    <path d="M3 6h18"/>
    <path d="M8 6V4a2 2 0 012-2h4a2 2 0 012 2v2"/>
    <path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/>
    <path d="M10 11v6M14 11v6"/>
  </Icon>
);

const IconCode = (p) => (
  <Icon {...p}>
    <path d="M16 18l6-6-6-6M8 6l-6 6 6 6"/>
  </Icon>
);

const IconEdit = (p) => (
  <Icon {...p}>
    <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/>
    <path d="M18.5 2.5a2.1 2.1 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/>
  </Icon>
);

const IconExternal = (p) => (
  <Icon {...p}>
    <path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/>
    <path d="M15 3h6v6"/>
    <path d="M10 14L21 3"/>
  </Icon>
);

const IconFire = (p) => (
  <Icon {...p}>
    <path d="M12 22s-6-4-6-10a6 6 0 016-6 6 6 0 016 6c0 6-6 10-6 10z"/>
    <path d="M12 18a3 3 0 003-3c0-2-3-5-3-5s-3 3-3 5a3 3 0 003 3z"/>
  </Icon>
);

Object.assign(window, {
  PROFILE_PAGE, TOURNAMENT_HISTORY, Medal,
  IconTrophyFilled, IconGlobe, IconGear, IconBookmark, IconBellSmall,
  IconLogout, IconTrash, IconCode, IconEdit, IconExternal, IconFire,
});
