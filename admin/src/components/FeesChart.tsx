import { useState } from "react";
import { formatMoney } from "../money";

export interface DailyFee {
  day: number;
  amountMinor: number;
}

interface Props {
  data: DailyFee[];
  daysInMonth: number;
}

const CHART_HEIGHT = 220;
const PADDING_LEFT = 56;
const PADDING_BOTTOM = 24;
const PADDING_TOP = 16;
const MAX_BAR_WIDTH = 24;
const BAR_GAP = 2;

// «Красивый» потолок шкалы: 1·10^n / 2·10^n / 5·10^n, ближайшее не меньше max.
function niceCeiling(max: number): number {
  if (max <= 0) return 100;
  const exp = Math.floor(Math.log10(max));
  const base = Math.pow(10, exp);
  for (const step of [1, 2, 5, 10]) {
    const candidate = step * base;
    if (candidate >= max) return candidate;
  }
  return 10 * base;
}

// Однорядный столбчатый график: комиссии мерчанта по дням месяца. Одна
// серия — без легенды, заголовок карточки уже называет, что это.
export function FeesChart({ data, daysInMonth }: Props) {
  const [hoverDay, setHoverDay] = useState<number | null>(null);

  const byDay = new Map(data.map((d) => [d.day, d.amountMinor]));
  const maxValue = Math.max(0, ...data.map((d) => d.amountMinor));
  const yMax = niceCeiling(maxValue || 100);

  const width = Math.max(daysInMonth * (MAX_BAR_WIDTH + BAR_GAP), 480);
  const plotWidth = width - PADDING_LEFT;
  const plotHeight = CHART_HEIGHT - PADDING_TOP - PADDING_BOTTOM;
  const barSlot = plotWidth / daysInMonth;
  const barWidth = Math.min(MAX_BAR_WIDTH, barSlot - BAR_GAP);

  const ticks = [0, yMax / 2, yMax];
  const labelEvery = daysInMonth > 20 ? 5 : daysInMonth > 10 ? 2 : 1;

  function yFor(value: number): number {
    return PADDING_TOP + plotHeight - (value / yMax) * plotHeight;
  }

  const hovered = hoverDay !== null ? byDay.get(hoverDay) ?? 0 : null;

  return (
    <div className="fees-chart">
      <svg
        viewBox={`0 0 ${width} ${CHART_HEIGHT}`}
        width="100%"
        height={CHART_HEIGHT}
        role="img"
        aria-label="Aýlar boýunça günlük komissiýa"
      >
        {ticks.map((tick, i) => (
          <g key={i}>
            <line
              x1={PADDING_LEFT}
              x2={width}
              y1={yFor(tick)}
              y2={yFor(tick)}
              stroke="var(--border)"
              strokeWidth={1}
            />
            <text
              x={PADDING_LEFT - 8}
              y={yFor(tick)}
              textAnchor="end"
              dominantBaseline="middle"
              className="chart-axis-label"
            >
              {formatMoney(tick)}
            </text>
          </g>
        ))}

        {Array.from({ length: daysInMonth }, (_, i) => i + 1).map((day) => {
          const value = byDay.get(day) ?? 0;
          const barHeight = (value / yMax) * plotHeight;
          const x = PADDING_LEFT + (day - 1) * barSlot + (barSlot - barWidth) / 2;
          const y = yFor(value);
          const isHovered = hoverDay === day;

          return (
            <g key={day}>
              <rect
                x={x}
                y={y}
                width={barWidth}
                height={Math.max(barHeight, value > 0 ? 2 : 0)}
                rx={4}
                fill={isHovered ? "var(--accent-hover)" : "var(--accent)"}
                tabIndex={value > 0 ? 0 : -1}
                onPointerEnter={() => setHoverDay(day)}
                onPointerLeave={() => setHoverDay((d) => (d === day ? null : d))}
                onFocus={() => setHoverDay(day)}
                onBlur={() => setHoverDay((d) => (d === day ? null : d))}
              />
              {(day === 1 || day % labelEvery === 0 || day === daysInMonth) && (
                <text
                  x={x + barWidth / 2}
                  y={CHART_HEIGHT - PADDING_BOTTOM + 16}
                  textAnchor="middle"
                  className="chart-axis-label"
                >
                  {day}
                </text>
              )}
            </g>
          );
        })}
      </svg>
      {hoverDay !== null && hovered !== null && (
        <div className="chart-tooltip-static">
          {hoverDay}-sana: <strong>{formatMoney(hovered)} TMT</strong>
        </div>
      )}
    </div>
  );
}
