from flask import Blueprint, request, jsonify
import mysql.connector

api = Blueprint('api', __name__)

def get_db_connection():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='160240',
        database='FacultyAttendanceDB'
    )
    
@api.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    id_number = data.get('id_number')
    password = data.get('password')
    role = data.get('role')

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE id_number=%s AND password=%s AND role=%s", (id_number, password, role))
    user = cursor.fetchone()
    cursor.close()
    conn.close()

    if user:
        return jsonify({"status": "success", "message": "Login successful", "user": user})
    else:
        return jsonify({"status": "error", "message": f"Invalid credentials or not a {role}"}), 401

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

@api.route('/count_checkers', methods=['GET'])
def count_checkers():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM users WHERE role = 'checker'")
    (count,) = cursor.fetchone()
    cursor.close()
    conn.close()
    return jsonify({"checker_count": count})

@api.route('/add_instructor', methods=['POST'])
def add_instructor():
    data = request.get_json()
    professor_name = data.get('professor_name')
    id_number = data.get('id_number')
    professor_email = data.get('professor_email')

    if not professor_name or not id_number or not professor_email:
        return jsonify({'error': 'Missing fields'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO instructors (professor_name, id_number, professor_email)
            VALUES (%s, %s, %s)
        """, (professor_name, id_number, professor_email))
        conn.commit()
        return jsonify({'message': 'Instructor added'}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@api.route('/get_instructors', methods=['GET'])
def get_all_instructors():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT * FROM instructors")
        instructors = cursor.fetchall()
        return jsonify(instructors)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@api.route('/save_attendance', methods=['POST'])
def save_attendance():
    data = request.get_json()

    recorded_by = data.get('recorded_by')  # This is the id_number (string)
    professor_name = data.get('professor_name')
    room_number = data.get('room_number')
    attendance_status = data.get('attendance_status')

    if not all([recorded_by, professor_name, room_number, attendance_status]):
        return jsonify({'error': 'Missing required fields'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO attendance_records (
                recorded_by, professor_name, room_number, attendance_status
            ) VALUES (%s, %s, %s, %s)
        """, (recorded_by, professor_name, room_number, attendance_status))

        conn.commit()
        return jsonify({'message': 'Attendance saved successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@api.route('/count_instructors', methods=['GET'])
def count_instructors():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM instructors")
    (count,) = cursor.fetchone()
    cursor.close()
    conn.close()
    return jsonify({"instructor_count": count})

@api.route('/checkers', methods=['GET'])
def get_checkers():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id, full_name, id_number, role, created_at FROM users WHERE role = 'checker'")
        checkers = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(checkers)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api.route('/delete_instructor/<id_number>', methods=['DELETE'])
def delete_instructor(id_number):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if the instructor exists first
        cursor.execute("SELECT * FROM instructors WHERE id_number = %s", (id_number,))
        if cursor.fetchone() is None:
            return jsonify({'error': 'Instructor not found'}), 404

        # Perform deletion
        cursor.execute("DELETE FROM instructors WHERE id_number = %s", (id_number,))
        conn.commit()
        return jsonify({'message': 'Instructor deleted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@api.route('/delete_checker/<int:user_id>', methods=['DELETE'])
def delete_checker(user_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if checker exists
        cursor.execute("SELECT * FROM users WHERE id = %s AND role = 'checker'", (user_id,))
        if cursor.fetchone() is None:
            return jsonify({'error': 'Checker not found'}), 404

        # Delete checker
        cursor.execute("DELETE FROM users WHERE id = %s", (user_id,))
        conn.commit()

        return jsonify({'message': 'Checker deleted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()


