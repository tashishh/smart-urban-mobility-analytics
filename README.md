# Smart Urban Mobility Analytics Dashboard

A full-stack data analytics project analyzing NYC taxi trip patterns to uncover peak hours, busy days, distance trends, and route demand.

## Project Goal
Build an end-to-end analytics system: raw data → Python cleaning → MySQL database → Flask API → interactive web dashboard → AWS deployment.

## Dataset
- **Source:** NYC Taxi Trip Duration (Kaggle)
- **Size:** ~625,000 taxi trips
- **Key fields:** pickup datetime, GPS coordinates, passenger count, vendor ID

## Tech Stack
| Layer | Technology |
|-------|-----------|
| Data Cleaning & EDA | Python (Pandas, Matplotlib) |
| Database | MySQL |
| Backend API | Flask (Python) |
| Frontend Dashboard | HTML, CSS, JavaScript, Chart.js |
| Cloud Hosting | AWS S3 |
| Version Control | GitHub |

## Project Structure

smart-urban-mobility-analytics/
├── data/  
│ ├── raw/ # Original dataset (not tracked in Git)
│ └── cleaned/ # Cleaned and engineered CSV files
├── analysis/ # Python notebooks and EDA scripts
├── sql/ # Schema, queries, and views
├── backend/ # Flask API application
├── frontend/ # Dashboard HTML/CSS/JS
├── aws/ # Deployment notes
├── screenshots/ # Project screenshots
└── docs/ # Planning notes and documentation


## Status
- [x] Day 1 - Project setup and dataset understanding
- [x] Day 2 - GitHub repository initialized
- [ ] Day 3 - Raw data inspection
- [ ] Day 4 - Data cleaning
- [ ] Day 5 - Feature engineering
- [ ] Day 6 - Exploratory analysis
- [ ] Day 7 - Visual charts
- [ ] Day 8-12 - SQL layer
- [ ] Day 13 - GitHub polish
- [ ] Day 14-17 - Flask backend
- [ ] Day 18-20 - Frontend dashboard
- [ ] Day 21-22 - AWS deployment and final handoff

## Author
Ashish Thapa