from flask import Flask, jsonify
from flask_cors import CORS
from db import get_connection

app = Flask(__name__)
CORS(app)


# -----------------------------------------------
# Home route — confirms Flask is running
# -----------------------------------------------
@app.route("/")
def home():
    return jsonify({
        "message": "Smart Urban Mobility API is running",
        "status": "ok"
    })


# -----------------------------------------------
# DB test route — confirms MySQL connection works
# -----------------------------------------------
@app.route("/api/test")
def test_db():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM trips")
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        return jsonify({
            "message": "Database connection successful",
            "total_trips": result[0]
        })
    except Exception as e:
        return jsonify({
            "message": "Database connection failed",
            "error": str(e)
        }), 500


# -----------------------------------------------
# Endpoint 1: /api/kpis
# High-level summary numbers for KPI cards
# -----------------------------------------------
@app.route("/api/kpis")
def kpis():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT
                COUNT(*)                        AS total_trips,
                ROUND(AVG(trip_distance_km), 2) AS avg_distance_km,
                ROUND(AVG(passenger_count), 2)  AS avg_passengers,
                COUNT(DISTINCT vendor_id)       AS total_vendors
            FROM trips
        """)
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# -----------------------------------------------
# Endpoint 2: /api/hourly-summary
# Trips per hour with peak category label
# -----------------------------------------------
@app.route("/api/hourly-summary")
def hourly_summary():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM hourly_summary")
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(results)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# -----------------------------------------------
# Endpoint 3: /api/weekday-summary
# Trips per day of week with weekend flag
# -----------------------------------------------
@app.route("/api/weekday-summary")
def weekday_summary():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM weekday_summary")
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(results)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# -----------------------------------------------
# Endpoint 4: /api/distance-summary
# Trips by Short / Medium / Long bucket
# -----------------------------------------------
@app.route("/api/distance-summary")
def distance_summary():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM distance_summary")
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(results)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# -----------------------------------------------
# Endpoint 5: /api/vendor-summary
# Vendor 1 vs Vendor 2 breakdown
# -----------------------------------------------
@app.route("/api/vendor-summary")
def vendor_summary():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM vendor_summary")
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(results)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# -----------------------------------------------
# Endpoint 6: /api/weekend-summary
# Weekday vs Weekend KPI comparison
# -----------------------------------------------
@app.route("/api/weekend-summary")
def weekend_summary():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM weekend_summary")
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(results)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True)