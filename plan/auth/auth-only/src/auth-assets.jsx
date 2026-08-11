// Auth screen — shared brand icons, logo, helpers

// Brand icons as inline SVG — correct brand colors, no text
const BrandTelegram = ({ size = 22 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
    <circle cx="12" cy="12" r="12" fill="#229ED9"/>
    <path d="M5.5 11.8l11.8-4.6c.6-.2 1.1.2.9.9l-2 9.5c-.2.7-.6.9-1.2.6l-3.3-2.4-1.6 1.5c-.2.2-.3.3-.6.3l.2-3.3 6-5.4c.3-.2-.1-.4-.4-.2l-7.4 4.6-3.2-1c-.7-.2-.7-.7.1-1z" fill="#fff"/>
  </svg>
);

const BrandWhatsApp = ({ size = 22 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
    <circle cx="12" cy="12" r="12" fill="#25D366"/>
    <path d="M16.7 14.3c-.3-.1-1.6-.8-1.8-.9-.2-.1-.4-.1-.6.1-.2.3-.7.9-.8 1-.2.2-.3.2-.6.1-.3-.1-1.2-.5-2.3-1.4-.9-.8-1.4-1.7-1.6-2-.2-.3 0-.4.1-.5l.4-.5c.1-.2.2-.3.3-.5 0-.2 0-.4-.1-.5-.1-.1-.6-1.4-.8-1.9-.2-.5-.4-.4-.6-.4h-.5c-.2 0-.5.1-.7.3-.2.3-.9.9-.9 2.1 0 1.2.9 2.4 1 2.6.1.2 1.8 2.7 4.4 3.8.6.3 1.1.4 1.5.5.6.2 1.2.2 1.7.1.5-.1 1.6-.7 1.8-1.3.2-.6.2-1.2.2-1.3-.1-.2-.3-.2-.6-.3z" fill="#fff"/>
  </svg>
);

const BrandGoogle = ({ size = 22 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24">
    <rect width="24" height="24" rx="12" fill="#fff"/>
    <g transform="translate(3,3) scale(0.75)">
      <path d="M22.5 12.2c0-.7-.1-1.4-.2-2.1H12v4h5.9c-.3 1.4-1 2.5-2.2 3.3v2.7h3.5c2-1.9 3.3-4.7 3.3-7.9z" fill="#4285F4"/>
      <path d="M12 23c2.9 0 5.4-1 7.2-2.6l-3.5-2.7c-1 .7-2.2 1.1-3.7 1.1-2.8 0-5.2-1.9-6.1-4.5H2.3v2.8C4.1 20.7 7.8 23 12 23z" fill="#34A853"/>
      <path d="M5.9 14.3c-.2-.7-.4-1.4-.4-2.3s.1-1.6.4-2.3V6.9H2.3C1.5 8.5 1 10.2 1 12s.5 3.5 1.3 5.1l3.6-2.8z" fill="#FBBC05"/>
      <path d="M12 5.4c1.6 0 3 .5 4.1 1.6l3.1-3.1C17.4 2.1 14.9 1 12 1 7.8 1 4.1 3.3 2.3 6.9l3.6 2.8C6.8 7.3 9.2 5.4 12 5.4z" fill="#EA4335"/>
    </g>
  </svg>
);

const BrandApple = ({ size = 22 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24">
    <circle cx="12" cy="12" r="12" fill="#f3f3f5"/>
    <path d="M16.3 13.1c0-1.8 1.5-2.7 1.6-2.7-.9-1.2-2.2-1.4-2.7-1.4-1.1-.1-2.2.7-2.8.7-.6 0-1.5-.7-2.5-.6-1.3 0-2.4.7-3.1 1.9-1.3 2.3-.3 5.7.9 7.5.6.9 1.4 1.9 2.3 1.8.9 0 1.3-.6 2.3-.6s1.4.6 2.4.6c1 0 1.6-.9 2.2-1.8.7-.9 1-1.8 1-1.9-.1 0-1.9-.7-1.9-2.9zM14.5 7.8c.5-.6.8-1.4.8-2.2-.7 0-1.6.4-2.1 1-.4.5-.9 1.4-.8 2.2.8.1 1.6-.4 2.1-1z" fill="#0a0a0d"/>
  </svg>
);

const BrandEmail = ({ size = 22, bg = '#2a2a31', fg = '#a2a2ab' }) => (
  <svg width={size} height={size} viewBox="0 0 24 24">
    <circle cx="12" cy="12" r="12" fill={bg}/>
    <rect x="6" y="8" width="12" height="9" rx="1.5" fill="none" stroke={fg} strokeWidth="1.6"/>
    <path d="M6.5 9l5.5 4 5.5-4" fill="none" stroke={fg} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
  </svg>
);

const IconArrowBack = ({ size = 20 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="#f3f3f5" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M19 12H5M12 19l-7-7 7-7"/>
  </svg>
);

const IconCheck = ({ size = 11 }) => (
  <svg width={size} height={size} viewBox="0 0 12 12" fill="none" stroke="#0a0a0d" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
    <path d="M2 6l3 3 5-6"/>
  </svg>
);

const IconChev = ({ size = 14, color = 'rgba(255,255,255,0.25)' }) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path d="M6 4l4 4-4 4" stroke={color} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
  </svg>
);

const PROVIDERS = [
  { id: 'telegram', label: 'Telegram', icon: BrandTelegram },
  { id: 'whatsapp', label: 'WhatsApp', icon: BrandWhatsApp },
  { id: 'google',   label: 'Google',   icon: BrandGoogle },
  { id: 'apple',    label: 'Apple',    icon: BrandApple },
  { id: 'email',    label: 'Email или телефон', icon: BrandEmail },
];

Object.assign(window, { BrandTelegram, BrandWhatsApp, BrandGoogle, BrandApple, BrandEmail,
                        IconArrowBack, IconCheck, IconChev, PROVIDERS });
