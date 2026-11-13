create table students (
    idnr char(10) not null primary key,
    name text not null,
    login text not null,
    program text not null
);

create table branches (
    name text not null,
    program text not null,
    primary key (name, program)
);

create table courses (
    code char(6) not null primary key,
    name text not null,
    credits real not null check (credits >= 0),
    department text not null
);

create table limitedcourses (
    code char(6) not null primary key references courses(code),
    capacity int not null check (capacity >= 0)
);

create table studentbranches (
    student text not null primary key references students(idnr),
    branch text not null,
    program text not null,
    foreign key (branch, program) references branches(name, program)
);

create table classifications (
    name text not null primary key
);

create table classified (
    course text not null references courses(code),
    classification text not null references classifications(name),
    primary key (course, classification)
);

create table mandatoryprogram (
    course text not null references courses(code),
    program text not null,
    primary key (course, program)
);

create table mandatorybranch (
    course text not null references courses(code),
    branch text not null,
    program text not null,
    foreign key (branch, program) references branches(name, program),
    primary key (course, branch, program)
);

create table recommendedbranch (
    course text not null references courses(code),
    branch text not null,
    program text not null,
    primary key (course, branch, program),
    foreign key (branch, program) references branches(name, program)
);

create table registered (
    student text not null references students(idnr),
    course text not null references courses(code),
    primary key (student, course)
);

create table taken (
    student text not null references students(idnr),
    course text not null references courses(code),
    grade char not null check (grade in ('U', '3', '4', '5')),
    primary key (student, course)
);

create table waitinglist (
    student text not null references students(idnr),
    course text not null references limitedcourses(code),
    position int not null,
    primary key (student, course)
);
