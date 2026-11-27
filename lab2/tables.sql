CREATE TABLE Programs ( 
    name TEXT NOT NULL PRIMARY KEY,
    abbreviation TEXT NOT NULL UNIQUE
);

CREATE TABLE Departments (
    name TEXT NOT NULL PRIMARY KEY,
    abbreviation TEXT NOT NULL UNIQUE
);

CREATE TABLE Students (
    idnr CHAR(10) NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (program) REFERENCES Programs(name),
    UNIQUE (login),
    UNIQUE (idnr, program)
);

CREATE TABLE Courses (
    code CHAR(6) NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    credits REAL NOT NULL CHECK (credits >= 0),
    department TEXT NOT NULL REFERENCES Departments(name)
);

CREATE TABLE HostsProgram (
    program TEXT NOT NULL REFERENCES Programs(name),
    department TEXT NOT NULL REFERENCES Departments(name),
    PRIMARY KEY (program, department)
);

CREATE TABLE Registered (
    student TEXT NOT NULL REFERENCES Students(idnr),
    course TEXT NOT NULL REFERENCES Courses(code),
    PRIMARY KEY (student, course)
);

CREATE TABLE Taken (
    student TEXT NOT NULL REFERENCES students(idnr),
    course TEXT NOT NULL REFERENCES courses(code),
    grade CHAR NOT NULL CHECK (grade IN ('U', '3', '4', '5')),
    PRIMARY KEY (student, course)
);

CREATE TABLE Classifications (
    name TEXT NOT NULL PRIMARY KEY
);

CREATE TABLE Prerequisites (
    course CHAR(6) NOT NULL REFERENCES Courses(code),
    prerequisite CHAR(6) NOT NULL REFERENCES Courses(code),
    PRIMARY KEY (course, prerequisite)
);

CREATE TABLE Classified (
    course TEXT NOT NULL REFERENCES courses(code),
    classification TEXT NOT NULL REFERENCES classifications(name),
    PRIMARY KEY (course, classification)
);


CREATE TABLE LimitedCourses (
    code CHAR(6) NOT NULL PRIMARY KEY REFERENCES courses(code),
    capacity INT NOT NULL CHECK (capacity >= 0)
);


CREATE TABLE WaitingList (
    student TEXT NOT NULL REFERENCES students(idnr),
    course TEXT NOT NULL REFERENCES limitedcourses(code),
    position INT NOT NULL,
    PRIMARY KEY (student, course)
);

CREATE TABLE Branches (
    name TEXT NOT NULL,
    program TEXT NOT NULL REFERENCES Programs(name),
    PRIMARY KEY (name, program)
);

CREATE TABLE StudentBranches (
    student TEXT NOT NULL PRIMARY KEY REFERENCES Students(idnr),
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (student, program) REFERENCES Students(idnr, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);


CREATE TABLE RecommendedBranch (
    course TEXT NOT NULL REFERENCES Courses(code),
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE MandatoryBranch (
    course TEXT NOT NULL REFERENCES Courses(code),
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE MandatoryProgram (
    course TEXT NOT NULL REFERENCES Courses(code),
    program TEXT NOT NULL REFERENCES Programs(name),
    PRIMARY KEY (course, program)
);
