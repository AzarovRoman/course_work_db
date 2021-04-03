CREATE DATABASE sadasgf
    WITH 
    ENCODING = 'UTF8';

CREATE TABLE public.students
(
    id_student integer NOT NULL,
    surname character varying NOT NULL,
    name character varying NOT NULL,
    patronymic character varying,
    group_number integer NOT NULL,
    receipt_date date NOT NULL,
    PRIMARY KEY (id_student)
);


CREATE TABLE public.elective
(
    id serial NOT NULL,
    class_number integer NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE public.work_type
(
	id serial NOT NULL,
	type character varying NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE public.elective_type
(
	id_type integer NOT NULL references work_type(id),
	id_elective integer NOT NULL references elective(id)
);

CREATE TABLE public.attendance
(
    id serial NOT NULL,
    id_elective integer NOT NULL references elective(id),
    id_student integer NOT NULL references students(id_student),
    date date NOT NULL,
    score integer CHECK (score > 0),
    PRIMARY KEY (id)
);


CREATE TABLE public.faculty
(
    id serial NOT NULL,
    name character varying NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE public.elective_faculty
(
    id serial NOT NULL,
    id_elective integer NOT NULL references elective(id),
    id_faculty integer NOT NULL references faculty(id),
    PRIMARY KEY (id)
);


insert into public.faculty (name)
	values
	('Менеджмент и Инженерный Бизнесс'),
	('Факультет хороших дел'),
	('Факультет Монстров'),
	('Факультет крутых БэДэШников'),
	('Ленивый Факультет'),
	('Факультет незаметных корупционеров'),
	('Факультет честных воров'),
	('Факультет Факультетов'),
	('Факультет владельцев Карбюратора'),
	('ЧОткий Факультет');


insert into public.students (id_student, surname, Name, patronymic, group_number, receipt_date)
	values
	(2843, 'Азаров', 'Роман', 'Данилович', 1092, '2019-07-23'),
	(2199, 'Шарафутдинов', 'Эмиль', 'Маратович', 1091, '2019-08-02'),
	(1791 ,'Моцарт', 'Амодей', 'Вольфган', 2358, '2017-09-15'),
	(6666 ,'Навальный', 'Владимир', 'Владимирович', 5986, '2018-08-09'),
	(6715 ,'Непосредственно', 'Каха', 'Васильевич', 2040, '2019-12-23'),
	(1451 ,'На', 'Генадий', 'Крокодилов', 5986, '2020-08-23'),
	(9200 ,'Бульба', 'Тарас', 'Гонтавич', 1091, '2020-06-22'),
	(8489 ,'Иванов', 'Мага', 'Кавказовчи', 1092, '2019-10-01'),
	(8535 ,'Энштейн', 'Альберт', 'Требьла', 5986, '2020-07-29'),
	(6253 ,'Ульянов', 'Владлен', 'Сталинович', 2358, '2017-12-13');


insert into public.elective (class_number)
	values
	(336),
	(185),
	(294),
	(349),
	(234),
	(216),
	(168),
	(157),
	(367),
	(179);


insert into public.attendance (id_elective, id_student, date, score)
	values
	(6 ,2843 , '2021-03-12', 5),
	(9 ,2199 , '2020-12-02', 7),
	(2 ,1451 , '2021-01-24', 3),
	(6 ,6253 , '2021-03-12', 4),
	(1 ,8489 , '2020-10-17', 5),
	(4 ,1791 , '2021-01-23', 10),
	(4 ,6666 , '2021-01-23', 1),
	(7 ,1451 , '2020-11-07', 9),
	(3 ,6715 , '2020-12-08', 4),
	(2 ,6715 , '2020-10-12', 7);


insert into public.elective_faculty (id_elective, id_faculty)
	values
	(8 ,4 ),
	(4 ,8 ),
	(3 ,7 ),
	(10,10),
	(6 ,3 ),
	(4 ,2 ),
	(2 ,1 ),
	(5 ,1 ),
	(4 ,7 ),
	(9 ,8 );

insert into public.work_type (type)
	values
	('Лабораторная работа'),
	('Лекция'),
	('Семинар'),
	('Практическая работа'),
	('Дополнительные занятия'),
	('Профориентационный'),
	('Углубляющее занятия'),
	('Предметной направленности'),
	('Проектная деятельность'),
	('Подготовка к экзаменам');

insert into public.elective_type(id_type, id_elective)
	values
	(4, 8),
	(7, 2),
	(1, 4),
	(4, 3),
	(2, 2),
	(10, 1),
	(3, 6),
	(6, 9),
	(9, 5),
	(2, 8);

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
	order by count(elective.class_number) desc
	limit 3;

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

--14) 