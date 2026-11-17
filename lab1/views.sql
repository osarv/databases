CREATE VIEW BasicInformation AS
SELECT idnr, name, login, students.program, branch 
    FROM students LEFT OUTER JOIN studentbranches
        ON idnr = student;

CREATE VIEW FinishedCourses AS
SELECT student, course, courses.name AS courseName, grade, credits
    FROM students JOIN taken
        ON idnr = student
    JOIN courses 
        ON course = code
    ORDER BY student, course;

CREATE VIEW Registrations AS
SELECT student, course, 'registered' AS status
    FROM students JOIN registered
        ON idnr = student
UNION SELECT student, course, 'waiting' AS status
    FROM students JOIN waitingList
        ON idnr = student
    ORDER BY status, course, student;

CREATE VIEW PassedCourses AS
SELECT student, course, credits
FROM FinishedCourses WHERE grade IN ('3', '4', '5');

CREATE VIEW UnreadMandatory AS
SELECT idnr AS student, course
    FROM students JOIN mandatoryprogram
        ON students.program = mandatoryprogram.program
UNION SELECT student, course
    FROM studentbranches JOIN mandatorybranch
        ON (studentbranches.branch = mandatorybranch.branch
            AND studentbranches.program = mandatorybranch.program)
EXCEPT SELECT student, course FROM PassedCourses;

CREATE VIEW TakenCredits AS
SELECT student, SUM(credits) AS totalCredits FROM PassedCourses GROUP BY student;

CREATE VIEW NumMandatoryLeft AS
SELECT student, COUNT(*) AS mandatoryLeft FROM UnreadMandatory GROUP BY student;

CREATE VIEW MathCredits AS
SELECT student, SUM(credits) AS mathcredits FROM Passedcourses JOIN Classified ON 
Passedcourses.course = Classified.course AND Classified.Classification = 'math' GROUP BY student;

CREATE VIEW NumSeminarCourses AS
SELECT student, COUNT(*) AS seminarCourses FROM Passedcourses JOIN Classified ON 
Passedcourses.course = Classified.course AND Classified.Classification = 'seminar' GROUP BY student;

CREATE VIEW RecommendedCoursesHelper AS
SELECT idnr AS student, course FROM Basicinformation 
JOIN recommendedbranch ON Basicinformation.program = recommendedbranch.program 
AND Basicinformation.branch = recommendedbranch.branch;

CREATE VIEW RecommendedCourses AS
SELECT Passedcourses.student, Passedcourses.course, SUM(credits) AS credits 
FROM recommendedcourseshelper JOIN Passedcourses ON recommendedcourseshelper.student = Passedcourses.student AND recommendedcourseshelper.course = Passedcourses.course GROUP BY Passedcourses.student, Passedcourses.course;

CREATE VIEW PathToGraduation AS
SELECT
    students.idnr AS student,
    COALESCE(totalCredits, 0) AS totalCredits,
    COALESCE(mandatoryLeft, 0) AS mandatoryleft,
    COALESCE(mathCredits, 0) AS mathCredits,
    COALESCE(seminarCourses, 0) AS seminarcourses,

    COALESCE(mandatoryLeft = 0, TRUE)
    AND COALESCE(totalCredits >= 10, FALSE)
    AND COALESCE(recommendedcourses.credits >= 10, FALSE)
    AND COALESCE(mathcredits >= 20 AND seminarcourses > 0, FALSE) AS qualified

FROM students FULL OUTER JOIN TakenCredits ON students.idnr = TakenCredits.student
    FULL OUTER JOIN NumMandatoryLeft ON students.idnr = NumMandatoryLeft.student
    FULL OUTER JOIN MathCredits ON students.idnr = MathCredits.student
    FULL OUTER JOIN numseminarcourses ON students.idnr = NumSeminarCourses.student
    FULL OUTER JOIN recommendedcourses ON students.idnr = recommendedcourses.student;

CREATE VIEW warnrecmand AS
SELECT recommendedbranch.course, branch FROM RecommendedBranch JOIN MandatoryProgram ON RecommendedBranch.program = MandatoryProgram.program AND recommendedbranch.course = mandatoryprogram.course;

CREATE VIEW registercount AS
SELECT course, COUNT(*) FROM registrations WHERE status = 'registered' GROUP BY course;

CREATE VIEW warnOverfull AS
SELECT Course FROM limitedcourses JOIN registercount ON limitedcourses.code = registercount.course
AND registercount.COUNT > limitedcourses.capacity;
