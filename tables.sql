DROP TABLE IF EXISTS meeting CASCADE;
DROP TABLE IF EXISTS course CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS faculty CASCADE;
DROP TABLE IF EXISTS class CASCADE;
DROP TABLE IF EXISTS student CASCADE;
DROP TABLE IF EXISTS probation CASCADE;
DROP TABLE IF EXISTS course_prereq CASCADE;
DROP TABLE IF EXISTS course_oldnum CASCADE;
DROP TABLE IF EXISTS faculty_class CASCADE;
DROP TABLE IF EXISTS faculty_department CASCADE;
DROP TABLE IF EXISTS student_attendance CASCADE;
DROP TABLE IF EXISTS student_probation CASCADE;
DROP TABLE IF EXISTS student_prev_degree CASCADE;
DROP TABLE IF EXISTS undergrad_major CASCADE;
DROP TABLE IF EXISTS undergrad_minor CASCADE;
DROP TABLE IF EXISTS undergraduate CASCADE;
DROP TABLE IF EXISTS degree CASCADE;
DROP TABLE IF EXISTS degree_MS CASCADE;
DROP TABLE IF EXISTS degree_BS CASCADE;
DROP TABLE IF EXISTS degree_MS_concentration CASCADE;
DROP TABLE IF EXISTS degree_unit_categories CASCADE;
DROP TABLE IF EXISTS graduate CASCADE;
DROP TABLE IF EXISTS graduate_MS CASCADE;
DROP TABLE IF EXISTS graduate_PHD CASCADE;
DROP TABLE IF EXISTS thesis_committee CASCADE;
DROP TABLE IF EXISTS graduate_thesis CASCADE;
DROP TABLE IF EXISTS thesis_committee_faculty CASCADE;
DROP TABLE IF EXISTS class_course CASCADE;
DROP TABLE IF EXISTS course_old_num CASCADE;
DROP TABLE IF EXISTS current_classes CASCADE;
DROP TABLE IF EXISTS degree_ms_concentration CASCADE;
DROP TABLE IF EXISTS five_year_student CASCADE;
DROP TABLE IF EXISTS prev_classes CASCADE;

CREATE TABLE student
(
    student_id serial PRIMARY KEY,
    first_name varchar(256),
    middle_name varchar(256),
    last_name varchar(256),
    residency varchar(256),
    enrolled boolean
);

CREATE TABLE class
(
    course_title varchar(256),
    section_id char(4),
    qtr_year varchar(20),
    class_size int,
    waitlist_size int,
    PRIMARY KEY (course_title, section_id, qtr_year)
);



CREATE TABLE course
(
    course_num varchar(256),
    grade_option varchar(256),
    consent boolean,
    lab_work boolean,
    min_units int,
    max_units int,
    PRIMARY KEY (course_num)
);

CREATE TABLE course_prereq
(
    course_num varchar(256),
    required_course_num varchar(256),
    FOREIGN KEY(course_num) REFERENCES course(course_num) ON DELETE CASCADE,
    FOREIGN KEY(required_course_num) REFERENCES course(course_num) ON DELETE CASCADE,
    PRIMARY KEY(course_num, required_course_num)
);

CREATE TABLE course_old_num
(
    course_num varchar(256),
    old_course_num varchar(256),
    FOREIGN KEY(course_num) REFERENCES course(course_num) ON DELETE CASCADE,
    PRIMARY KEY(course_num, old_course_num)
);

CREATE TABLE department
(
    dept_name varchar(10),
    PRIMARY KEY(dept_name)
);

CREATE TABLE faculty
(
    name varchar(256),
    title varchar(256),
    PRIMARY KEY(name)
);

CREATE TABLE faculty_class
(
    name varchar(256),
    course_title varchar(256),
    section_id char(4),
    qtr_year varchar(20),
    FOREIGN KEY(name) references faculty(name) ON DELETE CASCADE,
    FOREIGN KEY(course_title,section_id,qtr_year) references class(course_title,section_id,qtr_year) ON DELETE CASCADE,
    PRIMARY KEY (name,course_title,section_id,qtr_year)
);

CREATE TABLE faculty_department
(
    name varchar(256),
    dept_name varchar(256),
    FOREIGN KEY(name) references faculty(name) ON DELETE CASCADE,
    FOREIGN KEY(dept_name) references department(dept_name) ON DELETE CASCADE,
    PRIMARY KEY(name,dept_name)
);



CREATE TABLE student_attendance
(
    student_id int,
    start_qtr varchar(10),
    start_year int,
    end_qtr varchar(10),
    end_year int,
    FOREIGN KEY(student_id) references student(student_id) ON DELETE CASCADE,
    PRIMARY KEY(student_id, start_qtr, start_year)

);

CREATE TABLE probation
(
    probation_id serial,
    start_qtr varchar(10),
    start_year int,
    end_qtr varchar(10),
    end_year int,
    reason varchar(256),
    PRIMARY KEY(probation_id)
);

CREATE TABLE student_probation
(
    student_id int,
    probation_id int,
    FOREIGN KEY(student_id) references student(student_id) ON DELETE CASCADE,
    FOREIGN KEY(probation_id) references probation(probation_id) ON DELETE CASCADE,
    PRIMARY KEY (student_id, probation_id)
);

CREATE TABLE student_prev_degree
(
    student_id int,
    degree varchar(256),
    year int,
    FOREIGN KEY(student_id) references student(student_id) ON DELETE CASCADE,
    PRIMARY KEY(student_id,degree,year)
);

CREATE TABLE degree
(
    degree_id serial,
    name varchar(256),
    PRIMARY KEY(degree_id)
);

CREATE TABLE degree_unit_categories
(
    degree_id int,
    category varchar(20),
    grade varchar(2),
    units int,
    FOREIGN KEY(degree_id) references degree(degree_id) ON DELETE CASCADE,
    PRIMARY KEY(degree_id,category)
);

CREATE TABLE degree_BS
(
    degree_id int,
    FOREIGN KEY(degree_id) references degree(degree_id) ON DELETE CASCADE,
    PRIMARY KEY(degree_id)
);

CREATE TABLE degree_MS
(
    degree_id int,
    FOREIGN KEY(degree_id) references degree(degree_id) ON DELETE CASCADE,
    PRIMARY KEY(degree_id)
);

CREATE TABLE degree_MS_concentration
(
    degree_id int,
    course_num varchar(256),
    FOREIGN KEY(degree_id) references degree_MS(degree_id) ON DELETE CASCADE,
    FOREIGN KEY(course_num) references course(course_num) ON DELETE CASCADE,
    PRIMARY KEY(degree_id,course_num)
);

CREATE TABLE meeting(
    course_title varchar(256),
    section_id char(4),
    qtr_year varchar(20),
    start_meeting_time varchar(256),
    end_meeting_time varchar(256),
    location varchar(256),
    mandatory boolean,
    meeting_type varchar(10),
    FOREIGN KEY(course_title,section_id,qtr_year) references class(course_title,section_id,qtr_year) ON DELETE CASCADE,
    PRIMARY KEY(course_title,section_id,qtr_year,start_meeting_time)
);

CREATE TABLE undergraduate
(
    student_id int,
    five_year_BSMS boolean,
    college varchar(10),
    FOREIGN KEY(student_id) references student(student_id) ON DELETE CASCADE,
    PRIMARY KEY(student_id)
);

CREATE TABLE undergrad_major
(
    student_id int,
    major varchar(256),
    FOREIGN KEY(student_id) references student(student_id) ON DELETE CASCADE,
    PRIMARY KEY(student_id,major)
);

CREATE TABLE undergrad_minor
(
    student_id int,
    minor varchar(256),
    FOREIGN KEY(student_id) references student(student_id) ON DELETE CASCADE,
    PRIMARY KEY(student_id,minor)
);

CREATE TABLE graduate
(
    student_id int,
    dept_name varchar(10),
    FOREIGN KEY(student_id) references student(student_id) ON DELETE CASCADE,
    PRIMARY KEY(student_id)
);

CREATE TABLE graduate_MS
(
    student_id int,
    FOREIGN KEY(student_id) references graduate(student_id) ON DELETE CASCADE,
    PRIMARY KEY(student_id)
);

CREATE TABLE graduate_PHD
(
    student_id int,
    candidacy boolean,
    advisor varchar(256),
    FOREIGN KEY(student_id) references graduate(student_id) ON DELETE CASCADE,
    FOREIGN KEY(advisor) references faculty(name) ON DELETE CASCADE,
    PRIMARY KEY(student_id)
);

CREATE TABLE five_year_student
(
    student_id int,
    undergraduate boolean,
    FOREIGN KEY(student_id) references student(student_id) ON DELETE CASCADE,
    PRIMARY KEY(student_id)
);

CREATE TABLE thesis_committee
(
    thesis_name varchar(256),
    PRIMARY KEY(thesis_name)
);

CREATE TABLE graduate_thesis
(
    student_id int,
    thesis_name varchar(256),
    FOREIGN KEY(student_id) references graduate(student_id) ON DELETE CASCADE,
    FOREIGN KEY(thesis_name) references thesis_committee(thesis_name) ON DELETE CASCADE,
    PRIMARY KEY(student_id)
);

CREATE TABLE thesis_committee_faculty
(
    thesis_name varchar(256),
    faculty_name varchar(256),
    FOREIGN KEY(thesis_name) references thesis_committee(thesis_name) ON DELETE CASCADE,
    FOREIGN KEY(faculty_name) references faculty(name) ON DELETE CASCADE,
    PRIMARY KEY(thesis_name,faculty_name)
);

CREATE TABLE current_classes
(
    student_id int,
    course_title varchar(256),
    section_id char(4),
    qtr_year varchar(20),
    units int,
    FOREIGN KEY(student_id) references student(student_id) ON DELETE CASCADE,
    FOREIGN KEY(course_title,section_id,qtr_year) references class(course_title,section_id,qtr_year) ON DELETE CASCADE,
    PRIMARY KEY(student_id,course_title,section_id,qtr_year)
);

CREATE TABLE prev_classes
(
    student_id int,
    course_title varchar(256),
    section_id char(4),
    qtr_year varchar(20),
    units int,
    grade varchar(5),
    FOREIGN KEY(student_id) references student(student_id) ON DELETE CASCADE,
    FOREIGN KEY(course_title,section_id,qtr_year) references class(course_title,section_id,qtr_year) ON DELETE CASCADE,
    PRIMARY KEY(student_id,course_title,section_id,qtr_year)
);

CREATE TABLE class_course
(
    course_num varchar(256),
    course_title varchar(256),
    section_id char(4),
    qtr_year varchar(20),
    FOREIGN KEY(course_num) references course(course_num) ON DELETE CASCADE,
    FOREIGN KEY(course_title,section_id,qtr_year) references class(course_title,section_id,qtr_year) ON DELETE CASCADE,
    PRIMARY KEY(course_num,course_title,section_id,qtr_year)
);
