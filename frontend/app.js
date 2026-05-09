// ============================================
// Smart Urban Mobility Analytics
// app.js — API calls and dashboard data binding
// Day 19
// ============================================

const API_BASE = "http://127.0.0.1:5000";

// ============================================
// UTILITY FUNCTIONS
// ============================================

// Format numbers with commas: 601662 → "601,662"
function formatNumber(num) {
  if (num === null || num === undefined) return "—";
  return Number(num).toLocaleString("en-US");
}

// Format decimals to 2 places: 2.091 → "2.09"
function formatDecimal(num) {
  if (num === null || num === undefined) return "—";
  return Number(num).toFixed(2);
}

// Format percentage: 25.26 → "25.26%"
function formatPercent(num) {
  if (num === null || num === undefined) return "—";
  return Number(num).toFixed(2) + "%";
}

// Set text content of an element by ID
function setText(id, value) {
  const el = document.getElementById(id);
  if (el) el.textContent = value;
}


// ============================================
// FETCH KPIs
// Endpoint: /api/kpis
// Fills: Total Trips, Avg Distance, Avg Passengers
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
// FETCH WEEKDAY SUMMARY
// Endpoint: /api/weekday-summary
// Fills: Peak Day KPI card
// ============================================
async function loadWeekdaySummary() {
  try {
    const response = await fetch(`${API_BASE}/api/weekday-summary`);
    const data = await response.json();

    // Find the day with the most trips
    const peakDay = data.reduce((max, row) =>
      row.total_trips > max.total_trips ? row : max
    );

    setText("kpi-peak-day", peakDay.day_of_week);

  } catch (error) {
    console.error("Failed to load weekday summary:", error);
    setText("kpi-peak-day", "Error");
  }
}


// ============================================
// FETCH WEEKEND SUMMARY
// Endpoint: /api/weekend-summary
// Fills: Weekday vs Weekend comparison table
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
// FETCH VENDOR SUMMARY
// Endpoint: /api/vendor-summary
// Fills: Vendor 1 and Vendor 2 stat cards
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
// Switches between dark and light mode
// ============================================
function initThemeToggle() {
  const toggle = document.querySelector("[data-theme-toggle]");
  const html = document.documentElement;

  if (!toggle) return;

  toggle.addEventListener("click", () => {
    const current = html.getAttribute("data-theme");
    const next = current === "dark" ? "light" : "dark";
    html.setAttribute("data-theme", next);

    // Update toggle icon
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
  loadWeekdaySummary();
  loadWeekendSummary();
  loadVendorSummary();
});