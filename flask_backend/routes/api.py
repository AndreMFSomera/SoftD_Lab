from flask import Blueprint, request, jsonify
import mysql.connector

api = Blueprint('api', __name__)

def get_db_connection():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='',
        database='FacultyAttendanceDB'
    )

@api.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    id_number = data.get('id_number')
    password = data.get('password')

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM users WHERE id_number=%s AND password=%s", (id_number, password))
    user = cursor.fetchone()

    cursor.close()
    conn.close()

    if user:
        return jsonify({"status": "success", "message": "Login successful", "user": user})
    else:
        return jsonify({"status": "error", "message": "Invalid credentials"}), 401

@api.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()
    full_name = data.get('full_name')
    id_number = data.get('id_number')
    password = data.get('password')

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            "INSERT INTO users (full_name, id_number, password, role) VALUES (%s, %s, %s, %s)",
            (full_name, id_number, password, 'checker')
        )
        conn.commit()
        return jsonify({"status": "success", "message": "Signup successful"}), 201

    except mysql.connector.Error as err:
        return jsonify({"status": "error", "message": str(err)}), 400

    finally:
        cursor.close()
        conn.close()
