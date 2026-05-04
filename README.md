# 🚕 Smart Urban Mobility Analytics Dashboard

A full-stack data analytics project analyzing **601,662 NYC taxi trips** to uncover
peak hours, busy days, distance trends, and passenger behavior.

**Live Repository:** https://github.com/tashishh/smart-urban-mobility-analytics

---

## Project Goal

Build a complete end-to-end analytics system:
Raw Data → Python Cleaning → MySQL Database → Flask API → Web Dashboard → AWS Deployment


The project analyzes real NYC taxi trip data to answer business questions like:
- When is taxi demand highest during the day?
- Which days of the week are busiest?
- Do weekday and weekend riders behave differently?
- What proportion of trips are short vs long distance?
- How do the two vendors compare?

---

## Dataset

| Property | Detail |
|---|---|
| Source | [NYC Taxi Trip Duration — Kaggle](https://www.kaggle.com/c/nyc-taxi-trip-duration/data?select=test.zip) |
| Raw file | `data/raw/test.csv` |
| Raw rows | 625,134 trips |
| Cleaned rows | 601,662 trips (after removing invalid records) |
| Columns (raw) | 9 |
| Columns (final) | 14 (includes 5 engineered features) |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Data Cleaning & EDA | Python — Pandas, Matplotlib |
| Database | MySQL 8.0 |
| Backend API | Flask (Python) |
| Frontend Dashboard | HTML, CSS, JavaScript, Chart.js |
| Cloud Hosting | AWS S3 |
| Version Control | GitHub |

---

## Project Structure

smart-urban-mobility-analytics/
├── data/
│ ├── raw/ # Original dataset (not tracked in Git)
│ └── cleaned/ # taxi_cleaned.csv — ready for SQL import
├── analysis/ # Python EDA scripts and notebooks
├── sql/
│ ├── schema.sql # Table design and data types
│ ├── data_load.sql # LOAD DATA INFILE import script
│ ├── basic_queries.sql # Day 10 foundational SQL queries
│ ├── analytics_queries.sql # Day 11 business-focused SQL analytics
│ └── views.sql # Day 12 reusable summary views
├── backend/ # Flask API (coming Day 15–17)
├── frontend/ # Dashboard HTML/CSS/JS (coming Day 18–20)
├── aws/ # Deployment notes (coming Day 21)
├── screenshots/ # Chart and output screenshots
└── docs/
├── project_overview.txt # Project goal and tools
├── column_notes.txt # Column descriptions and meanings
├── cleaning_notes.txt # Data quality issues found and fixed
└── analysis_insights.txt # Key findings from EDA


---

## Dataset Columns

| Column | Type | Description |
|---|---|---|
| id | VARCHAR | Unique trip identifier (e.g. id2875421) |
| vendor_id | TINYINT | Taxi company — 1 = CMT, 2 = VeriFone |
| pickup_datetime | DATETIME | Date and time of passenger pickup |
| passenger_count | TINYINT | Number of passengers (1–5) |
| pickup_longitude | DECIMAL | GPS longitude of pickup location |
| pickup_latitude | DECIMAL | GPS latitude of pickup location |
| dropoff_longitude | DECIMAL | GPS longitude of dropoff location |
| dropoff_latitude | DECIMAL | GPS latitude of dropoff location |
| store_and_fwd_flag | TINYINT | 0 = sent live, 1 = stored on tablet first |
| trip_distance_km | DECIMAL | Distance calculated from GPS (Haversine formula) |
| hour_of_day | TINYINT | Hour extracted from pickup_datetime (0–23) |
| day_of_week | VARCHAR | Day name (Monday–Sunday) |
| is_weekend | TINYINT | 1 = Saturday or Sunday, 0 = weekday |
| distance_bucket | VARCHAR | Short (0–2 km) / Medium (2–10 km) / Long (10+ km) |

---

## Data Cleaning Summary

Four data quality issues were found and fixed before analysis:

| Issue | What Was Found | Fix Applied |
|---|---|---|
| Datetime stored as text | `pickup_datetime` had dtype `object` | `pd.to_datetime()` conversion |
| GPS coordinates outside NYC | Longitude as far as -121.93, latitude as low as 37.39 | Filtered to official NYC bounds (NYC.gov) |
| Impossible passenger counts | Values of 0 and up to 9 found | Kept only rows where count is 1–5 (NYC TLC rules) |
| store_and_fwd_flag as text | Stored as 'Y'/'N' strings | Converted to 1/0 integer for SQL storage |

Additionally, **2,413 zero-distance trips** (immediate cancellations) were removed
during feature engineering, bringing the final dataset to **601,662 rows**.

---

## Key Findings from Analysis

### Hourly Demand
![Hourly Trip Demand](screenshots/chart1_hourly_demand.png)

- **Peak hour:** 6 PM (18:00) → 37,535 trips — the evening rush is the single busiest hour
- **Quietest hour:** 5 AM → only 6,200 trips
- Demand drops steadily from midnight to 5 AM, then climbs sharply from 6 AM onward

### Daily Demand
![Daily Trip Volume](screenshots/chart2_daily_demand.png)

- **Busiest day:** Friday → 92,727 trips (19.7% more than Monday)
- Trip volume builds through the week and peaks Thursday–Saturday
- Monday is the quietest weekday at 77,456 trips

### Weekday vs Weekend Behavior
![Weekday vs Weekend](screenshots/chart5_weekday_weekend.png)

- Weekdays carry 430,697 trips total vs 170,965 on weekends
- Per-day demand is nearly identical (~86,000 trips/day each)
- Weekend trips are slightly longer (3.50 km vs 3.40 km avg)
- Weekend riders travel in groups more often — 30.24% group rides vs 25.26% on weekdays

### Distance Distribution
![Distance Buckets](screenshots/chart3_distance_buckets.png)

- **Short (0–2 km):** 286,389 trips — 47.6% of all trips
- **Medium (2–10 km):** 279,029 trips — 46.4% of all trips
- **Long (10+ km):** 36,244 trips — 6.0% (airport runs, max trip 41.55 km)
- Median trip distance is just **2.09 km** — NYC taxi use is dominated by short rides

### Passenger Count
![Passenger Count](screenshots/chart4_passenger_count.png)

- **73.3%** of all trips carry exactly 1 passenger — solo rides dominate
- 2-passenger trips are the second most common at 14.9%
- Only 6% of trips carry 3 or more passengers

---

## SQL Layer

### Database
- **Database:** `urban_mobility`
- **Table:** `trips` — 601,662 rows, 14 columns
- **Imported using:** MySQL command line with `LOAD DATA LOCAL INFILE`

### SQL Files

| File | Purpose |
|---|---|
| `schema.sql` | Table definition with correct data types |
| `data_load.sql` | CSV import script |
| `basic_queries.sql` | Counts, averages, groupings — Day 10 |
| `analytics_queries.sql` | Peak-hour analysis, vendor comparison, window functions — Day 11 |
| `views.sql` | 5 reusable summary views for Flask API — Day 12 |

### Reusable Views (Ready for API)

| View | What It Returns |
|---|---|
| `hourly_summary` | Trips per hour with Peak/Shoulder/Off-Peak label |
| `weekday_summary` | Trips per day with weekday/weekend flag |
| `distance_summary` | Trips by Short/Medium/Long bucket |
| `vendor_summary` | Vendor 1 vs Vendor 2 breakdown |
| `weekend_summary` | Weekday vs Weekend KPI comparison |

---

## Key SQL Insights (Day 11)

- **Thursday 7–9 PM** is the single busiest 3-hour window in the dataset
- **Per-day trip demand is equal** on weekdays and weekends (~86,000 trips/day)
- **Shoulder hours carry 50%** of all trips — peak is intense but brief (7 hours)
- **Weekday = Short-dominant; Weekend = Medium-dominant** — a clear behavioral shift
- **Both vendors serve identical trip type distributions** — no specialization
- **Sunday midnight** is the only day where the busiest hour is after 11 PM

---

## Progress

- [x] Day 1 — Project setup and dataset understanding
- [x] Day 2 — GitHub repository initialized
- [x] Day 3 — Raw data inspection and issue log
- [x] Day 4 — Data cleaning and column standardization
- [x] Day 5 — Feature engineering (distance, time, buckets)
- [x] Day 6 — Exploratory data analysis (EDA)
- [x] Day 7 — Visual charts (5 charts created)
- [x] Day 8 — SQL database design and schema
- [x] Day 9 — Data import and validation (601,662 rows)
- [x] Day 10 — Basic SQL queries
- [x] Day 11 — Business-focused SQL analytics
- [x] Day 12 — Reusable SQL views
- [ ] Day 13 — GitHub README polish ← current
- [ ] Day 14 — Backend planning
- [ ] Day 15 — Flask setup and database connection
- [ ] Day 16 — Analytics API endpoints
- [ ] Day 17 — Complete backend and error handling
- [ ] Day 18 — Frontend layout design
- [ ] Day 19 — Connect frontend to API
- [ ] Day 20 — Charts and interactive filter
- [ ] Day 21 — AWS S3 deployment
- [ ] Day 22 — Final testing and handoff

---

## Author

**Ashish Thapa**
GitHub: [@tashishh](https://github.com/tashishh)