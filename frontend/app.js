// ============================================
// Smart Urban Mobility Analytics
// app.js — API calls, data binding, and charts
// Day 20
// ============================================

const API_BASE = "http://127.0.0.1:5000";

// ============================================
// CHART COLOR THEME
// ============================================
const COLORS = {
  teal:         "#4f98a3",
  tealLight:    "rgba(79, 152, 163, 0.15)",
  tealMid:      "rgba(79, 152, 163, 0.6)",
  tealFill:     "rgba(79, 152, 163, 0.12)",
  green:        "#6daa45",
  greenLight:   "rgba(109, 170, 69, 0.6)",
  gridLine:     "rgba(255, 255, 255, 0.05)",
  textMuted:    "#797876",
  textFaint:    "#5a5957",
  white:        "#cdccca"
};

// ============================================
// UTILITY FUNCTIONS
// ============================================
function formatNumber(num) {
  if (num === null || num === undefined) return "—";
  return Number(num).toLocaleString("en-US");
}

function formatDecimal(num) {
  if (num === null || num === undefined) return "—";
  return Number(num).toFixed(2);
}

function formatPercent(num) {
  if (num === null || num === undefined) return "—";
  return Number(num).toFixed(2) + "%";
}

function setText(id, value) {
  const el = document.getElementById(id);
  if (el) el.textContent = value;
}

// Shared Chart.js default options
function getChartDefaults() {
  return {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: "#1c1b19",
        borderColor: "#393836",
        borderWidth: 1,
        titleColor: "#cdccca",
        bodyColor: "#797876",
        padding: 10,
        cornerRadius: 6
      }
    },
    scales: {
      x: {
        grid: { color: COLORS.gridLine },
        ticks: { color: COLORS.textMuted, font: { size: 11 } }
      },
      y: {
        grid: { color: COLORS.gridLine },
        ticks: {
          color: COLORS.textMuted,
          font: { size: 11 },
          callback: (val) => formatNumber(val)
        }
      }
    }
  };
}


// ============================================
// FETCH KPIs
// ============================================
async function loadKPIs() {
  try {
    const response = await fetch(`${API_BASE}/api/kpis`);
    const data = await response.json();
    setText("kpi-total-trips",    formatNumber(data.total_trips));
    setText("kpi-avg-distance",   formatDecimal(data.avg_distance_km));
    setText("kpi-avg-passengers", formatDecimal(data.avg_passengers));
  } catch (error) {
    console.error("Failed to load KPIs:", error);
    setText("kpi-total-trips",    "Error");
    setText("kpi-avg-distance",   "Error");
    setText("kpi-avg-passengers", "Error");
  }
}


// ============================================
// FETCH WEEKDAY SUMMARY + PEAK DAY + BAR CHART
// ============================================
async function loadWeekdaySummary() {
  try {
    const response = await fetch(`${API_BASE}/api/weekday-summary`);
    const data = await response.json();

    // Peak day KPI
    const peakDay = data.reduce((max, row) =>
      row.total_trips > max.total_trips ? row : max
    );
    setText("kpi-peak-day", peakDay.day_of_week);

    // Bar chart — Trips by Day of Week
    const labels = data.map(row => row.day_of_week.slice(0, 3));
    const values = data.map(row => row.total_trips);
    const bgColors = data.map(row =>
      row.day_of_week === peakDay.day_of_week
        ? COLORS.teal
        : COLORS.tealMid
    );

    const ctx = document.getElementById("chart-daily");
    if (!ctx) return;

    new Chart(ctx, {
      type: "bar",
      data: {
        labels,
        datasets: [{
          data: values,
          backgroundColor: bgColors,
          borderRadius: 6,
          borderSkipped: false
        }]
      },
      options: {
        ...getChartDefaults(),
        plugins: {
          ...getChartDefaults().plugins,
          tooltip: {
            ...getChartDefaults().plugins.tooltip,
            callbacks: {
              label: (ctx) => ` ${formatNumber(ctx.raw)} trips`
            }
          }
        }
      }
    });

  } catch (error) {
    console.error("Failed to load weekday summary:", error);
    setText("kpi-peak-day", "Error");
  }
}


// ============================================
// FETCH HOURLY SUMMARY + LINE CHART
// ============================================
async function loadHourlySummary() {
  try {
    const response = await fetch(`${API_BASE}/api/hourly-summary`);
    const data = await response.json();

    // Format hour labels: 0 → "12 AM", 13 → "1 PM"
    const labels = data.map(row => {
      const h = row.hour_of_day;
      if (h === 0)  return "12 AM";
      if (h < 12)   return `${h} AM`;
      if (h === 12) return "12 PM";
      return `${h - 12} PM`;
    });

    const values = data.map(row => row.total_trips);

    const ctx = document.getElementById("chart-hourly");
    if (!ctx) return;

    new Chart(ctx, {
      type: "line",
      data: {
        labels,
        datasets: [{
          data: values,
          borderColor: COLORS.teal,
          backgroundColor: COLORS.tealFill,
          borderWidth: 2.5,
          pointRadius: 3,
          pointHoverRadius: 6,
          pointBackgroundColor: COLORS.teal,
          pointBorderColor: "#1c1b19",
          pointBorderWidth: 2,
          fill: true,
          tension: 0.4
        }]
      },
      options: {
        ...getChartDefaults(),
        plugins: {
          ...getChartDefaults().plugins,
          tooltip: {
            ...getChartDefaults().plugins.tooltip,
            callbacks: {
              title: (items) => `Hour: ${labels[items[0].dataIndex]}`,
              label: (ctx) => ` ${formatNumber(ctx.raw)} trips`
            }
          }
        },
        scales: {
          ...getChartDefaults().scales,
          x: {
            ...getChartDefaults().scales.x,
            ticks: {
              color: COLORS.textMuted,
              font: { size: 10 },
              maxTicksLimit: 12
            }
          }
        }
      }
    });

  } catch (error) {
    console.error("Failed to load hourly summary:", error);
  }
}


// ============================================
// FETCH DISTANCE SUMMARY + BAR CHART
// ============================================
async function loadDistanceSummary() {
  try {
    const response = await fetch(`${API_BASE}/api/distance-summary`);
    const data = await response.json();

    const labels = data.map(row => row.distance_bucket);
    const values = data.map(row => row.total_trips);
    const bgColors = [COLORS.teal, COLORS.tealMid, COLORS.tealLight];
    const borderColors = [COLORS.teal, COLORS.teal, COLORS.teal];

    const ctx = document.getElementById("chart-distance");
    if (!ctx) return;

    new Chart(ctx, {
      type: "bar",
      data: {
        labels,
        datasets: [{
          data: values,
          backgroundColor: bgColors,
          borderColor: borderColors,
          borderWidth: 1,
          borderRadius: 6,
          borderSkipped: false
        }]
      },
      options: {
        ...getChartDefaults(),
        plugins: {
          ...getChartDefaults().plugins,
          tooltip: {
            ...getChartDefaults().plugins.tooltip,
            callbacks: {
              label: (ctx) => ` ${formatNumber(ctx.raw)} trips`
            }
          }
        }
      }
    });

  } catch (error) {
    console.error("Failed to load distance summary:", error);
  }
}


// ============================================
// FETCH WEEKEND SUMMARY — TABLE
// ============================================
async function loadWeekendSummary() {
  try {
    const response = await fetch(`${API_BASE}/api/weekend-summary`);
    const data = await response.json();

    data.forEach(row => {
      if (row.day_type === "Weekday") {
        setText("wd-total-trips",    formatNumber(row.total_trips));
        setText("wd-avg-distance",   formatDecimal(row.avg_distance_km));
        setText("wd-avg-passengers", formatDecimal(row.avg_passengers));
        setText("wd-group-trips",    formatNumber(row.group_trips));
        setText("wd-group-pct",      formatPercent(row.group_trip_pct));
      }
      if (row.day_type === "Weekend") {
        setText("we-total-trips",    formatNumber(row.total_trips));
        setText("we-avg-distance",   formatDecimal(row.avg_distance_km));
        setText("we-avg-passengers", formatDecimal(row.avg_passengers));
        setText("we-group-trips",    formatNumber(row.group_trips));
        setText("we-group-pct",      formatPercent(row.group_trip_pct));
      }
    });

  } catch (error) {
    console.error("Failed to load weekend summary:", error);
  }
}


// ============================================
// FETCH VENDOR SUMMARY — STAT CARDS
// ============================================
async function loadVendorSummary() {
  try {
    const response = await fetch(`${API_BASE}/api/vendor-summary`);
    const data = await response.json();

    data.forEach(row => {
      if (row.vendor_id === 1) {
        setText("v1-trips",      formatNumber(row.total_trips));
        setText("v1-distance",   formatDecimal(row.avg_distance_km) + " km");
        setText("v1-passengers", formatDecimal(row.avg_passengers));
      }
      if (row.vendor_id === 2) {
        setText("v2-trips",      formatNumber(row.total_trips));
        setText("v2-distance",   formatDecimal(row.avg_distance_km) + " km");
        setText("v2-passengers", formatDecimal(row.avg_passengers));
      }
    });

  } catch (error) {
    console.error("Failed to load vendor summary:", error);
  }
}


// ============================================
// THEME TOGGLE
// ============================================
function initThemeToggle() {
  const toggle = document.querySelector("[data-theme-toggle]");
  const html = document.documentElement;
  if (!toggle) return;

  toggle.addEventListener("click", () => {
    const current = html.getAttribute("data-theme");
    const next = current === "dark" ? "light" : "dark";
    html.setAttribute("data-theme", next);

    toggle.innerHTML = next === "dark"
      ? `<svg width="18" height="18" viewBox="0 0 24 24" fill="none"
           stroke="currentColor" stroke-width="2">
           <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
         </svg>`
      : `<svg width="18" height="18" viewBox="0 0 24 24" fill="none"
           stroke="currentColor" stroke-width="2">
           <circle cx="12" cy="12" r="5"/>
           <path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36
                    18.36l1.42 1.42M1 12h2M21 12h2M4.22
                    19.78l1.42-1.42M18.36 5.64l1.42-1.42"/>
         </svg>`;
  });
}


// ============================================
// INIT — Run everything when page loads
// ============================================
document.addEventListener("DOMContentLoaded", () => {
  initThemeToggle();
  loadKPIs();
  loadHourlySummary();
  loadWeekdaySummary();
  loadDistanceSummary();
  loadWeekendSummary();
  loadVendorSummary();
});