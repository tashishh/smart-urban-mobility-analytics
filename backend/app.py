from flask import Flask, jsonify
from flask_cors import CORS
from db import get_connection

app = Flask(__name__)
CORS(app)

# -----------------------------------------------
# Test route — confirms Flask is running
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


if __name__ == "__main__":
    app.run(debug=True)