create view BasicInformation as
select idnr, name, login, students.program, branch 
    from students left outer join studentbranches
        on idnr = student;

create view FinishedCourses as
select student, course, courses.name as courseName, grade, credits
    from students join taken
        on idnr = student
    join courses 
        on course = code
    order by student, course;

create view Registrations as
select student, course, 'registered' as status
    from students join registered
        on idnr = student
union select student, course, 'waiting' as status
    from students join waitingList
        on idnr = student
    order by status, course, student;

create view PassedCourses as
select student, course, credits
from FinishedCourses where grade in ('3', '4', '5');

create view UnreadMandatory as
select idnr as student, course
    from students join mandatoryprogram
        on students.program = mandatoryprogram.program
union select student, course
    from studentbranches join mandatorybranch
        on (studentbranches.branch = mandatorybranch.branch
            AND studentbranches.program = mandatorybranch.program)
except select student, course from PassedCourses;

create view TakenCredits as
select student, sum(credits) as totalCredits from PassedCourses group by student;

create view NumMandatoryLeft as
select student, count(*) as mandatoryLeft from UnreadMandatory group by student;

create view MathCredits as
select student, sum(credits) as mathcredits from passedcourses join classified on 
passedcourses.course = classified.course and classified.classification = 'math' group by student;

create view NumSeminarCourses as
select student, count(*) as seminarCourses from passedcourses join classified on 
passedcourses.course = classified.course and classified.classification = 'seminar' group by student;

create view RecommendedCoursesHelper as
select idnr as student, course from basicinformation join recommendedbranch on basicinformation.program = recommendedbranch.program AND basicinformation.branch = recommendedbranch.branch;

create view RecommendedCourses as
select passedcourses.student, passedcourses.course, sum(credits) as credits from recommendedcourseshelper join passedcourses on recommendedcourseshelper.student = passedcourses.student AND recommendedcourseshelper.course = passedcourses.course group by passedcourses.student, passedcourses.course;

create view PathToGraduation as
select
    students.idnr as student,
    coalesce(totalCredits, 0) as totalCredits,
    coalesce(mandatoryLeft, 0) as mandatoryleft,
    coalesce(mathCredits, 0) as mathCredits,
    coalesce(seminarCourses, 0) as seminarcourses,

    coalesce(mandatoryLeft = 0, true)
    AND coalesce(totalCredits >= 10, false)
    AND coalesce(recommendedcourses.credits >= 10, false)
    AND coalesce(mathcredits >= 20 and seminarcourses > 0, false) as qualified

from students full outer join TakenCredits on students.idnr = TakenCredits.student
    full outer join NumMandatoryLeft on students.idnr = NumMandatoryLeft.student
    full outer join MathCredits on students.idnr = MathCredits.student
    full outer join numseminarcourses on students.idnr = NumSeminarCourses.student
    full outer join recommendedcourses on students.idnr = recommendedcourses.student;

create view warnrecmand as
select recommendedbranch.course, branch from RecommendedBranch join MandatoryProgram on RecommendedBranch.program = MandatoryProgram.program AND recommendedbranch.course = mandatoryprogram.course;

create view registercount as
select course, count(*) from registrations where status = 'registered' group by course;

create view warnoverfill as
select course from limitedcourses join registercount on limitedcourses.code = registercount.course
AND registercount.count > limitedcourses.capacity;
