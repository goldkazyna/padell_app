// Sparkline — shared across settings variants

function Sparkline({ points, color, width = 60, height = 22 }) {
  const min = Math.min(...points), max = Math.max(...points);
  const n = points.length;
  const sx = (i) => (i / (n - 1)) * width;
  const sy = (v) => height - ((v - min) / (max - min || 1)) * height;
  const d = points.map((v, i) => `${i ? 'L' : 'M'}${sx(i).toFixed(1)} ${sy(v).toFixed(1)}`).join(' ');
  const lastX = sx(n - 1), lastY = sy(points[n - 1]);
  // area fill path
  const areaD = d + ` L${width} ${height} L0 ${height} Z`;
  return (
    <svg width={width} height={height} style={{ overflow: 'visible' }}>
      <defs>
        <linearGradient id={`sg-${color.replace('#','')}`} x1="0" x2="0" y1="0" y2="1">
          <stop offset="0%" stopColor={color} stopOpacity="0.3"/>
          <stop offset="100%" stopColor={color} stopOpacity="0"/>
        </linearGradient>
      </defs>
      <path d={areaD} fill={`url(#sg-${color.replace('#','')})`}/>
      <path d={d} stroke={color} strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
      <circle cx={lastX} cy={lastY} r="2.5" fill={color}/>
    </svg>
  );
}

Object.assign(window, { Sparkline });
