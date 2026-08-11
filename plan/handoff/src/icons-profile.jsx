// Profile-specific icons (stroke 1.5)

const IconArrowLeft = (p) => (
  <Icon {...p}>
    <path d="M19 12H5M12 19l-7-7 7-7"/>
  </Icon>
);

const IconCamera = (p) => (
  <Icon {...p}>
    <path d="M4 7h3l2-3h6l2 3h3a2 2 0 012 2v9a2 2 0 01-2 2H4a2 2 0 01-2-2V9a2 2 0 012-2z"/>
    <circle cx="12" cy="13" r="4"/>
  </Icon>
);

const IconLock = (p) => (
  <Icon {...p}>
    <rect x="5" y="11" width="14" height="10" rx="2"/>
    <path d="M8 11V7a4 4 0 018 0v4"/>
  </Icon>
);

const IconMapPin = (p) => (
  <Icon {...p}>
    <path d="M12 21s-7-6.5-7-12a7 7 0 0114 0c0 5.5-7 12-7 12z"/>
    <circle cx="12" cy="9" r="2.5"/>
  </Icon>
);

const IconUserSmall = (p) => (
  <Icon {...p}>
    <circle cx="12" cy="8" r="4"/>
    <path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8"/>
  </Icon>
);

const IconPhone = (p) => (
  <Icon {...p}>
    <path d="M22 16.9v3a2 2 0 01-2.2 2 19.8 19.8 0 01-8.6-3.1 19.5 19.5 0 01-6-6 19.8 19.8 0 01-3.1-8.7A2 2 0 014.1 2h3a2 2 0 012 1.7c.1.9.3 1.8.6 2.7a2 2 0 01-.5 2.1L8 9.6a16 16 0 006 6l1.1-1.1a2 2 0 012.1-.5c.9.3 1.8.5 2.7.6a2 2 0 011.7 2z"/>
  </Icon>
);

const IconGender = (p) => (
  <Icon {...p}>
    <circle cx="10" cy="14" r="6"/>
    <path d="M14.5 9.5L20 4M20 4h-5M20 4v5"/>
  </Icon>
);

const IconCake = (p) => (
  <Icon {...p}>
    <path d="M4 21v-7a2 2 0 012-2h12a2 2 0 012 2v7"/>
    <path d="M3 21h18"/>
    <path d="M4 16c2 0 2-2 4-2s2 2 4 2 2-2 4-2 2 2 4 2"/>
    <path d="M12 3v4M10 5l2-2 2 2"/>
  </Icon>
);

const IconHand = (p) => (
  <Icon {...p}>
    <path d="M7 11V5a2 2 0 114 0v4"/>
    <path d="M11 9V4a2 2 0 114 0v5"/>
    <path d="M15 9V6a2 2 0 114 0v8a7 7 0 01-7 7H9a5 5 0 01-5-5c0-1 0-2 1-3l2-2"/>
  </Icon>
);

const IconCourt = (p) => (
  <Icon {...p}>
    <rect x="3" y="6" width="18" height="12" rx="1"/>
    <path d="M12 6v12M3 12h18"/>
    <path d="M7 10v4M17 10v4"/>
  </Icon>
);

const IconCheck = (p) => (
  <Icon {...p}>
    <path d="M20 6L9 17l-5-5"/>
  </Icon>
);

const IconSparkle = (p) => (
  <Icon {...p}>
    <path d="M12 3l2 5 5 2-5 2-2 5-2-5-5-2 5-2 2-5z"/>
  </Icon>
);

Object.assign(window, {
  IconArrowLeft, IconCamera, IconLock, IconMapPin, IconUserSmall, IconPhone,
  IconGender, IconCake, IconHand, IconCourt, IconCheck, IconSparkle,
});
