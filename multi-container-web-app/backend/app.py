import os

import psycopg2

from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "database"),
        dbname=os.getenv("DB_NAME", "appdb"),
        user=os.getenv("DB_USER", "appuser"),
        password=os.getenv("DB_PASSWORD", "apppassword"),
    )

@app.route("/")
def home():
    return jsonify({
        "message": "Backend is running"
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    })

@app.route("/db-health")
def db_health():
    try:
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST", "database"),
            database=os.getenv("DB_NAME", "appdb"),
            user=os.getenv("DB_USER", "appuser"),
            password=os.getenv("DB_PASSWORD", "apppassword"),
        )

        conn.close()

        return jsonify({
            "database": "connected"
        })

    except Exception as e:
        return jsonify({
            "database": "disconnected",
            "error": str(e)
        }), 500

@app.route("/users", methods=["POST"])
def create_user():
    data = request.get_json()

    name = data.get("name")

    if not name:
        return jsonify({"error": "name is required"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute(
        "INSERT INTO users (name) VALUES (%s) RETURNING id, name",
        (name,)
    )

    user = cursor.fetchone()

    conn.commit()

    cursor.close()
    conn.close()

    return jsonify({
        "id": user[0],
        "name": user[1]
    }), 201


@app.route("/users", methods=["GET"])
def get_users():
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT id, name FROM users ORDER BY id")

    users = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify([
        {
            "id": user[0],
            "name": user[1]
        }
        for user in users
    ])


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
