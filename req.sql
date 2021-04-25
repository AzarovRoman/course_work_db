-- ПРЕДСТАВЛЕНИЯ

--1) Вывести все кабинеты, в которых никогда не велись занятия.
create view empty_cabinets as 
select class_number from elective 
left join attendance on attendance.id_elective = elective.id
where id_elective is null;

--2) вывести всех студентов, у которых баллы > 5
create view smart_students as 
select students.id_student, students.name, students.surname, sum(attendance.score) from attendance
left join students on students.id_student = attendance.id_student
where score > 4
group by students.id_student;

--3) вывод всех студентов (Фамилия, имя, № билета) с сортировкой.
create view all_students as 
select id_student, surname, name from students
order by surname asc;

--------------------------------------------------------------------------------------------------------------
-- ЗАПРОСЫ

--1) вывести всех студентов, не посетивших ни одного занятия.
select students.id_student, surname, name from students 
left join attendance on students.id_student = attendance.id_student 
where score is null;

--2) вывести все занятия за 2020 год 
select * from attendance where date >= '2020-01-01' and date <= '2021-01-01';


--3) Вывести всех второкурсников
select extract(year from receipt_date), name from students
where extract (year from current_date) - extract(year from receipt_date) = 2;

--4) Вывести всех студентов с фамилией на А.
select * from students
where students.surname like 'А%';

--5) Вывести три самых часто используемых кабинетов
select elective.class_number, count(elective.class_number) from elective
join attendance on elective.id = attendance.id_elective
group by elective.class_number
order by count(elective.class_number) desclimit 3;

--6) Вывести количество студентов в каждой группе.
select students.group_number, count(students.id_student) from students
group by students.group_number;

--7) Вывести топ-5 самых активных факультетов.
select faculty.name, count(id_elective) from faculty
left join elective_faculty on faculty.id = elective_faculty.id_faculty
group by faculty.name
order by count(id_elective) desc
limit 5;

--8) Вывести средние баллы студентов по группам. Результат округлить до тысячных.
select students.group_number, round(avg(attendance.score), 3) from students
left join attendance on students.id_student = attendance.id_student
group by students.group_number;

--9) Вывести топ-3 студента: № билета, фамилию, и сумму баллов
select students.id_student ,students.surname, sum(attendance.score) from students
join attendance on students.id_student = attendance.id_student
group by students.id_student
order by sum(attendance.score) desc
limit 3;

--10) Вывести всех студентов у которых оценка выше 4, не поситвших ни одного занятия за 2021 год
select students.id_student, students.surname, sum(attendance.score) from students
join attendance on attendance.id_student = students.id_student
where attendance.date >= '2021-01-01' and date <= '2022-01-01'
group by students.id_student
having sum(attendance.score) > 4;

--11) Вывести месяц, в котором было больше всего занятий (за всё время)
select extract(month from date) as "месяц", count(extract(month from date)) as "Кол-во занятий" from attendance
group by extract(month from date)
order by count(extract(month from date)) desc
limit 1;

--12) Вывести типы занятий, и их популярность (Тип занятие и общее число посещений).
select work_type.type, count(elective_type.id_type) from attendance
left join elective on attendance.id_elective = elective.id
left join elective_type on elective.id = elective_type.id_elective
left join work_type on  elective_type.id_type = work_type.id
where work_type.type is not null
group by work_type.type
order by count(elective_type.id_type) desc;

--13) Вывести всех студентов, которые посещали занятия одного типа более 1 раза.
select students.surname, students.name, students.id_student, count(students.id_student), count(attendance.id_elective) from attendance
left join students on attendance.id_student = students.id_student
left join elective on attendance.id_elective = elective.id
left join elective_type on elective.id = elective_type.id_elective
left join work_type on  elective_type.id_type = work_type.id
group by students.id_student
having count(students.id_student) > 1 and count(attendance.id_elective) > 1;

--14) Вывести топ-5 типов занятий, на которых студенты получают больше всего баллов.
select work_type.type, sum(score) from attendance
join students on attendance.id_student = students.id_student
left join elective on attendance.id_elective = elective.id
left join elective_type on elective.id = elective_type.id_elective
left join work_type on  elective_type.id_type = work_type.id
where work_type.type is not null
group by work_type.type
order by sum(score) desc
limit 5;

--15) Вывести всех студентов, посетивших факультатив 2021-01-24.
select students.id_student, students.surname from attendance
left join students on attendance.id_student = students.id_student
left join elective on attendance.id_elective = elective.id
left join elective_type on elective.id = elective_type.id_elective
left join work_type on  elective_type.id_type = work_type.id
where work_type.type is not null and date = '2021-01-24'
group by students.id_student;
--------------------------------------------------------------------------------------------------------------
--Функции
--1) Сощдать фукнкцию, которая будет заменять id студента на '****'
create or replace function hide_student_id(student_id int)
returns text
as
$$
	select overlay(student_id::varchar placing '****' from 1 for 4)
$$
language sql;

--Вызов
select hide_student_id(id_student), surname, name from students;
--

--2) Создать функцию, которая будет из ФИО делать инициалы.
create or replace function(surname, name, patronymic)
returns text
as
$$
	if patronymic is not null then
		select surname || overlay(name placing '.' from 2) || overlay(patronymic placing '.' from 2)
	else
		select surname || overlay(name placing '.' from 2)
	end if;
$$
language sql;