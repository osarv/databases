CREATE TABLE Students (
    idnr CHAR(10) NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL
);

CREATE TABLE Branches (
    name TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (name, program)
);

CREATE TABLE Courses (
    code CHAR(6) NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    credits REAL NOT NULL CHECK (credits >= 0),
    department TEXT NOT NULL
);

CREATE TABLE LimitedCourses (
    code CHAR(6) NOT NULL PRIMARY KEY REFERENCES courses(code),
    capacity INT NOT NULL CHECK (capacity >= 0)
);

CREATE TABLE StudentBranches (
    student TEXT NOT NULL PRIMARY KEY REFERENCES students(idnr),
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (branch, program) REFERENCES branches(name, program)
);

CREATE TABLE Classifications (
    name TEXT NOT NULL PRIMARY KEY
);

CREATE TABLE Classified (
    course TEXT NOT NULL REFERENCES courses(code),
    classification TEXT NOT NULL REFERENCES classifications(name),
    PRIMARY KEY (course, classification)
);

CREATE TABLE MandatoryProgram (
    course TEXT NOT NULL REFERENCES courses(code),
    program TEXT NOT NULL,
    PRIMARY KEY (course, program)
);

CREATE TABLE MandatoryBranch (
    course TEXT NOT NULL REFERENCES courses(code),
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (branch, program) REFERENCES branches(name, program),
    PRIMARY KEY (course, branch, program)
);

CREATE TABLE RecommendedBranch (
    course TEXT NOT NULL REFERENCES courses(code),
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES branches(name, program)
);

CREATE TABLE Registered (
    student TEXT NOT NULL REFERENCES students(idnr),
    course TEXT NOT NULL REFERENCES courses(code),
    PRIMARY KEY (student, course)
);

CREATE TABLE Taken (
    student TEXT NOT NULL REFERENCES students(idnr),
    course TEXT NOT NULL REFERENCES courses(code),
    grade CHAR NOT NULL CHECK (grade IN ('U', '3', '4', '5')),
    PRIMARY KEY (student, course)
);

CREATE TABLE WaitingList (
    student TEXT NOT NULL REFERENCES students(idnr),
    course TEXT NOT NULL REFERENCES limitedcourses(code),
    position INT NOT NULL,
    PRIMARY KEY (student, course)
);
