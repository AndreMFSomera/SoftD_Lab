# softd

MARRON, MATIAS, SOMERA

## Getting Started

Faculty Attendance System
This project is a Faculty Attendance System that allows tracking and managing faculty attendance through a web-based interface connected to a MySQL database.

1. Install dependencies
    pip install -r requirements.txt
        -> These are the things you actually need to install, the others were just for my other projects
        Flask==3.1.1
        flask-cors==6.0.1
        mysql-connector-python==9.1.0
        python-dotenv==1.1.1
        requests==2.32.4
        Werkzeug==3.1.3
        click==8.2.1
        colorama==0.4.6
        itsdangerous==2.2.0
        Jinja2==3.1.6
        MarkupSafe==3.0.2
        pytz==2025.2
        tzdata==2025.2
        PyYAML==6.0.2

2. Set up your MySQL database
    When creating your database in MYSQL, copy paste this code if no '.sql' file was provided in the gdrive
    CREATE DATABASE FacultyAttendanceDB;

USE FacultyAttendanceDB;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    id_number VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'checker') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP );
    
CREATE TABLE attendance_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recorded_by VARCHAR(20) NOT NULL,  -- stores the id_number of the checker
    professor_name VARCHAR(100) NOT NULL,
    room_number VARCHAR(10) NOT NULL,
    attendance_status ENUM('Present', 'Absent', 'ODL') NOT NULL,
    date_recorded DATE NOT NULL DEFAULT (CURRENT_DATE),
    time_recorded TIME NOT NULL DEFAULT (CURRENT_TIME),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	starting_time TIME NOT NULL,
    ending_time TIME NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
	day VARCHAR(10) NOT NULL
);

CREATE TABLE Schedule_record (
    id INT AUTO_INCREMENT PRIMARY KEY,
    professor_name VARCHAR(100) NOT NULL,
    room_number VARCHAR(10) NOT NULL,
    day VARCHAR(10) NOT NULL,
    starting_time TIME NOT NULL,
    ending_time TIME NOT NULL,
    subject_name VARCHAR(100) NOT NULL
);

CREATE TABLE Instructors (
	id INT AUTO_INCREMENT PRIMARY KEY,
    professor_name VARCHAR(100) NOT NULL,
    id_number VARCHAR(20) NOT NULL UNIQUE,
    professor_email VARCHAR(100) NOT NULL
);

INSERT INTO users (full_name, id_number, password, role)
VALUES ('Super Admin', '22-0000-001', '123', 'admin');


SELECT 
    professor_name,
    SUM(attendance_status = 'Present') AS present_count,
    SUM(attendance_status = 'Absent') AS absent_count,
    SUM(attendance_status = 'ODL') AS odl_count
FROM attendance_records
GROUP BY professor_name
ORDER BY professor_name;

3. Configure database credentials in flask_backend/api.py

    def get_db_connection():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='your_password_here',
        database='database_name')

4. Update IP address in api.py
    Find your IPv4 address using:
        ipconfig   # on Windows
    
    Update the IP in api_service.dart file
        class ApiService {
            tatic const String baseUrl = 'http://192.168.1.7:5000';}

5. Running the Application

flask run --host=0.0.0.0
flutter run

    Use two terminals
        1st terminal:
          Make sure when running 'flask run --host=0.0.0.0'
          The file directory should be like this -> C:\VS_CODE\SOFTD_LAB\SoftD_Lab\flask_backend 
            if not -> copy path flask_backend then in the terminal enter cd C:\VS_CODE\SOFTD_LAB\SoftD_Lab\flask_backend before running flask
        
        2nd Terminal:
            flutter run, then choose which available platform to run (e.g chrome or Edge)
            If you want edge, you can just enter flutter run -d edge in the terminal

