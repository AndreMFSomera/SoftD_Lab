from flask import Blueprint, request, jsonify
import mysql.connector
from datetime import timedelta

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
    cursor = conn.cursor(dictionary=True)

    try:
        # ✅ Only check ID uniqueness
        cursor.execute("SELECT * FROM users WHERE id_number = %s", (id_number,))
        existing_user = cursor.fetchone()

        if existing_user:
            return jsonify({"status": "error", "message": "User with this ID already exists"}), 409

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



@api.route('/add_instructor', methods=['POST'])
def add_instructor():
    data = request.get_json()
    professor_name = data.get('professor_name')
    id_number = data.get('id_number')
    professor_email = data.get('professor_email')

    if not professor_name or not id_number or not professor_email:
        return jsonify({'error': 'Missing fields'}), 400

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # Check if instructor with same name, id, or email already exists
        cursor.execute("""
            SELECT * FROM instructors 
            WHERE professor_name = %s OR id_number = %s OR professor_email = %s
        """, (professor_name, id_number, professor_email))
        existing = cursor.fetchone()

        if existing:
            return jsonify({'error': 'Instructor already exists'}), 409

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

@api.route('/attendance_records', methods=['GET'])
def get_attendance_records():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT id, recorded_by, professor_name, room_number, attendance_status,
                   DATE_FORMAT(date_recorded, '%Y-%m-%d') AS date_recorded,
                   TIME_FORMAT(time_recorded, '%H:%i:%s') AS time_recorded
            FROM attendance_records
            ORDER BY recorded_at DESC
        """)
        records = cursor.fetchall()

        return jsonify(records)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@api.route('/attendance_records/<int:record_id>', methods=['DELETE'])
def delete_attendance_record(record_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if the record exists
        cursor.execute("SELECT * FROM attendance_records WHERE id = %s", (record_id,))
        if cursor.fetchone() is None:
            return jsonify({'error': 'Attendance record not found'}), 404

        # Delete the record
        cursor.execute("DELETE FROM attendance_records WHERE id = %s", (record_id,))
        conn.commit()

        return jsonify({'message': 'Attendance record deleted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()


@api.route('/instructor_attendance_summary', methods=['GET'])
def get_instructor_attendance_summary():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
            SELECT 
                professor_name,
                SUM(CASE WHEN attendance_status = 'Present' THEN 1 ELSE 0 END) AS present_count,
                SUM(CASE WHEN attendance_status = 'Absent' THEN 1 ELSE 0 END) AS absent_count,
                SUM(CASE WHEN attendance_status = 'ODL' THEN 1 ELSE 0 END) AS odl_count
            FROM attendance_records
            GROUP BY professor_name
            ORDER BY professor_name;
        """

        cursor.execute(query)
        results = cursor.fetchall()

        return jsonify(results), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500

    finally:
        cursor.close()
        conn.close()

@api.route('/check_name_exists', methods=['POST'])
def check_name_exists():
    data = request.get_json()
    full_name = data.get('full_name')

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM users WHERE full_name = %s", (full_name,))
    (count,) = cursor.fetchone()
    cursor.close()
    conn.close()

    return jsonify({'exists': count > 0})

@api.route('/count_checkers', methods=['GET'])
def count_checkers():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM users WHERE role = 'checker'")
        (count,) = cursor.fetchone()
        cursor.close()
        conn.close()
        return jsonify({'checker_count': count})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api.route('/add_schedule', methods=['POST'])
def add_schedule():
    data = request.get_json()
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        query = """
        INSERT INTO Schedule_record (professor_name, room_number, day, starting_time, ending_time, subject_name)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        values = (
            data['professor_name'],
            data['room_number'],
            data['day'],
            data['starting_time'],
            data['ending_time'],
            data['subject_name']
        )

        cursor.execute(query, values)
        conn.commit()

        return jsonify({'message': 'Schedule added'}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        cursor.close()
        conn.close()



@api.route('/delete_schedule/<int:schedule_id>', methods=['DELETE'])
def delete_schedule(schedule_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("DELETE FROM Schedule_record WHERE id = %s", (schedule_id,))
        conn.commit()

        if cursor.rowcount == 0:
            return jsonify({'error': 'Schedule not found'}), 404

        return jsonify({'message': 'Schedule deleted successfully'}), 200
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@api.route('/get_schedules', methods=['GET'])
def get_schedules():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT * FROM Schedule_record")
        schedules = cursor.fetchall()

        # Convert timedelta fields to string
        for schedule in schedules:
            if isinstance(schedule['starting_time'], timedelta):
                schedule['starting_time'] = str(schedule['starting_time'])[:-3]  # remove seconds
            if isinstance(schedule['ending_time'], timedelta):
                schedule['ending_time'] = str(schedule['ending_time'])[:-3]

        return jsonify(schedules)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()



@api.route('/get_rooms', methods=['GET'])
def get_rooms():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT DISTINCT room_number FROM Schedule_record")
        rooms = [row['room_number'] for row in cursor.fetchall()]
        return jsonify(rooms), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()
