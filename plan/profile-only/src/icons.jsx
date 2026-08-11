// Stroke 1.5 line icons — minimal, modern
// All accept {size, color, fill} and default to currentColor

const Icon = ({ size = 24, color = 'currentColor', fill = 'none', strokeWidth = 1.5, children, style }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill}
       stroke={color} strokeWidth={strokeWidth}
       strokeLinecap="round" strokeLinejoin="round"
       style={{ display: 'block', flexShrink: 0, ...style }}>
    {children}
  </svg>
);

const IconBell = (p) => (
  <Icon {...p}>
    <path d="M6 8a6 6 0 0112 0c0 7 3 9 3 9H3s3-2 3-9"/>
    <path d="M10.3 21a1.94 1.94 0 003.4 0"/>
  </Icon>
);

const IconTrendUp = (p) => (
  <Icon {...p}>
    <path d="M3 17l6-6 4 4 7-8"/>
    <path d="M14 7h6v6"/>
  </Icon>
);

const IconLevel = (p) => (
  <Icon {...p}>
    <rect x="4"  y="13" width="4" height="8" rx="1"/>
    <rect x="10" y="8"  width="4" height="13" rx="1"/>
    <rect x="16" y="3"  width="4" height="18" rx="1"/>
  </Icon>
);

const IconMedal = (p) => (
  <Icon {...p}>
    <path d="M7.21 3l4.79 8 4.79-8"/>
    <path d="M8 3h8"/>
    <circle cx="12" cy="15" r="6"/>
    <path d="M12 12v3l2 1.5"/>
  </Icon>
);

const IconRacket = (p) => (
  <Icon {...p}>
    <ellipse cx="10" cy="10" rx="7" ry="7"/>
    <path d="M5.5 10h9M10 5.5v9M6.5 6.5l7 7M13.5 6.5l-7 7"/>
    <path d="M15 15l5 5"/>
    <path d="M13.6 16.4l2.8-2.8"/>
  </Icon>
);

const IconCalendarCheck = (p) => (
  <Icon {...p}>
    <rect x="3" y="5" width="18" height="16" rx="2"/>
    <path d="M8 3v4M16 3v4M3 10h18"/>
    <path d="M9 15l2 2 4-4"/>
  </Icon>
);

const IconBuildings = (p) => (
  <Icon {...p}>
    <path d="M4 21V7l6-3v17"/>
    <path d="M10 10h8a2 2 0 012 2v9"/>
    <path d="M14 14h2M14 17h2M7 10h0M7 13h0M7 16h0"/>
  </Icon>
);

const IconPlus = (p) => (
  <Icon {...p}>
    <path d="M12 5v14M5 12h14"/>
  </Icon>
);

const IconChevronRight = (p) => (
  <Icon {...p}>
    <path d="M9 6l6 6-6 6"/>
  </Icon>
);

const IconHome = ({ active, ...p }) => (
  <Icon {...p} fill={active ? 'currentColor' : 'none'}>
    <path d="M3 11l9-7 9 7v9a2 2 0 01-2 2h-4v-7h-6v7H5a2 2 0 01-2-2v-9z"/>
  </Icon>
);

const IconTrophy = ({ active, ...p }) => (
  <Icon {...p} fill={active ? 'currentColor' : 'none'}>
    <path d="M8 4h8v5a4 4 0 01-8 0V4z"/>
    <path d="M8 6H5a2 2 0 000 4h1M16 6h3a2 2 0 010 4h-1"/>
    <path d="M10 14h4l-.5 3h-3L10 14zM9 20h6"/>
  </Icon>
);

const IconCalendar = ({ active, ...p }) => (
  <Icon {...p} fill={active ? 'currentColor' : 'none'}>
    <rect x="3" y="5" width="18" height="16" rx="2"/>
    <path d="M8 3v4M16 3v4M3 10h18"/>
  </Icon>
);

const IconChart = ({ active, ...p }) => (
  <Icon {...p} fill={active ? 'currentColor' : 'none'}>
    <rect x="3" y="12" width="5" height="9" rx="1"/>
    <rect x="9.5" y="7" width="5" height="14" rx="1"/>
    <rect x="16" y="3" width="5" height="18" rx="1"/>
  </Icon>
);

const IconUser = ({ active, ...p }) => (
  <Icon {...p} fill={active ? 'currentColor' : 'none'}>
    <circle cx="12" cy="8" r="4"/>
    <path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8"/>
  </Icon>
);

Object.assign(window, {
  IconBell, IconTrendUp, IconLevel, IconMedal, IconRacket,
  IconCalendarCheck, IconBuildings, IconPlus, IconChevronRight,
  IconHome, IconTrophy, IconCalendar, IconChart, IconUser,
});
