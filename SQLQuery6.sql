--1. Вывести названия аудиторий, в которых читает лекции преподаватель “Edward Hopper”.
SELECT DISTINCT lr.Name
FROM LectureRooms lr
JOIN Schedules s ON lr.Id = s.LectureRoomId
JOIN Lectures l ON s.LectureId = l.Id
JOIN Teachers t ON l.TeacherId = t.Id
WHERE t.Name = 'Edward' AND t.Surname = 'Hopper';
--2. Вывести фамилии ассистентов, читающих лекции в группе “F505”.
SELECT DISTINCT t.Surname
FROM Teachers t
JOIN Assistants a ON t.Id = a.TeacherId
JOIN Lectures l ON a.TeacherId = l.TeacherId
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
WHERE g.Name = 'F505';
--3. Вывести дисциплины, которые читает преподаватель “Alex Carmack” для групп 5-го курса.
SELECT DISTINCT s.Name
FROM Subjects s
JOIN Lectures l ON s.Id = l.SubjectId
JOIN Teachers t ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
WHERE t.Name = 'Alex' AND t.Surname = 'Carmack' AND g.Year = 5;
--4. Вывести фамилии преподавателей, которые не читают лекции по понедельникам.
SELECT DISTINCT t.Surname
FROM Teachers t
WHERE t.Id NOT IN (
    SELECT l.TeacherId
    FROM Lectures l
    JOIN Schedules s ON l.Id = s.LectureId
    WHERE s.DayOfWeek = 1
);
--5. Вывести названия аудиторий, с указанием их корпусов, в которых нет лекций в среду второй недели на третьей паре.
SELECT lr.Name, lr.Building
FROM LectureRooms lr
WHERE NOT EXISTS (
    SELECT 1
    FROM Schedules s
    WHERE s.LectureRoomId = lr.Id
    AND s.DayOfWeek = 3 
    AND s.Week = 2
    AND s.Class = 3 
);
--6. Вывести Полные Имена Преподавателей Факультета “Computer Science”, которые не курируют группы кафедры “Software Development”.
SELECT t.Name + ' ' + t.Surname AS FullName
FROM Teachers t
JOIN Faculties f ON t.Id = f.DeanId
LEFT JOIN Curators c ON t.Id = c.TeacherId
LEFT JOIN Departments d ON c.TeacherId = d.HeadId
WHERE f.Name = 'Computer Science' AND (d.Name <> 'Software Development' OR d.Name IS NULL);
--7. Вывести список номеров всех корпусов, которые имеются в таблицах факультетов, кафедр и аудиторий.
SELECT DISTINCT Building FROM Faculties
UNION
SELECT DISTINCT Building FROM Departments
UNION
SELECT DISTINCT Building FROM LectureRooms;
--8. Вывести полные имена преподавателей в следующем порядке: деканы факультетов, заведующие кафедрами, преподаватели, кураторы, ассистенты.
SELECT t.Name + ' ' + t.Surname AS FullName, 'Dean' AS Position
FROM Teachers t
JOIN Deans d ON t.Id = d.TeacherId
UNION ALL
SELECT t.Name + ' ' + t.Surname, 'Head'
FROM Teachers t
JOIN Heads h ON t.Id = h.TeacherId
UNION ALL
SELECT t.Name + ' ' + t.Surname, 'Teacher'
FROM Teachers t
UNION ALL
SELECT t.Name + ' ' + t.Surname, 'Curator'
FROM Teachers t
JOIN Curators c ON t.Id = c.TeacherId
UNION ALL
SELECT t.Name + ' ' + t.Surname, 'Assistant'
FROM Teachers t
JOIN Assistants a ON t.Id = a.TeacherId
ORDER BY Position;
--9. Вывести дни недели (без повторений), в которые имеются занятия в аудиториях “A311” и “A104” корпуса 6.
SELECT DISTINCT s.DayOfWeek
FROM Schedules s
JOIN LectureRooms lr ON s.LectureRoomId = lr.Id
WHERE lr.Building = 6 AND (lr.Name = 'A311' OR lr.Name = 'A104');

--База данных Академия(Academy)
﻿﻿create database Academy

use Academy 

--1. Ассистента (Assistants)
--■ Идентификатор (Id). Уникальный идентификатор ассистента.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Идентификатор преподавателя (TeacherId). Преподаватель, который является ассистентом.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
create table Assistants
(
	Id int not null primary key identity(1,1),
	TeacherId int not null FOREIGN KEY REFERENCES Teachers(Id)
)

--2. Кураторы (Curators)
--■ Идентификатор (Id). Уникальный идентификатор куратора.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Идентификатор преподавателя (TeacherId). Преподаватель, который является куратором.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
create table Curators
(
	Id int not null primary key identity(1,1),
	TeacherId int not null FOREIGN KEY REFERENCES Teachers(Id)
)

--3. Деканы (Deans)
--■ Идентификатор (Id). Уникальный идентификатор декана.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Идентификатор преподавателя (TeacherId). Преподаватель, который является деканом.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
create table Deans
(
	Id int not null primary key identity(1,1),
	TeacherId int not null FOREIGN KEY REFERENCES Teachers(Id)
)

--4. Кафедры (Departments)
--■ Идентификатор (Id). Уникальный идентификатор кафедры.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Корпус (Building). Номер корпуса, в котором располагается кафедра.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Должно быть в диапазоне от 1 до 5.
--■ Название (Name). Название кафедры.
--▷ тип данных nvarchar(100)
--▷ Не может содержать null-значения.
--▷ Не может быть пустым.
--▷ Должно быть уникальным.
--■ Идентификатор факультета (FacultyId). Факультет, в состав которого входит кафедра.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
--■ Идентификатор заведующего (HeadId). Заведующий кафедрой.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
create table Departments
(
	Id int not null primary key identity(1,1),
	Building  int not null check(Building>=1 and Building<=5),
	Name nvarchar(100) not null check(Name <> '') unique, 
	FacultyId int not null FOREIGN KEY REFERENCES Faculties(Id),
	HeadId int not null FOREIGN KEY REFERENCES Heads(Id)
)

--5. Факультеты (Faculties)
--■ Идентификатор (Id). Уникальный идентификатор факультета.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Корпус (Building). Номер корпуса, в котором располагается факультет.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Должно быть в диапазоне от 1 до 5.
--■ Название (Name). Название факультета.
--▷ тип данных nvarchar(100)
--▷ Не может содержать null-значения.
--▷ Не может быть пустым.
--▷ Должно быть уникальным.
--■Идентификатор декана (DeanId). Декан факультета.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
create table Faculties
(
	Id int not null primary key identity(1,1),
	Building  int not null check(Building>=1 and Building<=5),
	Name nvarchar(100) not null check(Name <> '') unique,
	DeanId int not null FOREIGN KEY REFERENCES Deans(Id)
)

--6. Группы (Groups)
--■ Идентификатор (Id). Уникальный идентификатор группы.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Название (Name). Название группы.
--▷ тип данных nvarchar(10)
--▷ Не может содержать null-значения.
--▷ Не может быть пустым.
--▷ Должно быть уникальным.
--■ Курс (Year). Курс (год) на котором обучается группа.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Должно быть в диапазоне от 1 до 5.
--■ Идентификатор кафедры (DepartmentId). Кафедра, в состав которой входит группа.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
create table Groups
(
	Id int not null primary key identity(1,1),
	Name nvarchar(10) not null check(Name <> '') unique,
	Year int not null check(Year>=1 and Year<=5),
	DepartmentId int not null FOREIGN KEY REFERENCES Departments(Id)
)

--7. Группы и кураторы (GroupsCurators)
--■ Идентификатор (Id). Уникальный идентификатор группы и куратора.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Идентификатор куратора (CuratorId). Куратор.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
--■ Идентификатор группы (GroupId). Группа.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
create table GroupsCurators
(
	Id int not null primary key identity(1,1),
	CuratorId int not null FOREIGN KEY REFERENCES Curators(Id),
	GroupId int not null FOREIGN KEY REFERENCES Groups(Id)
)

--8. Группы и лекции (GroupsLectures)
--■ Идентификатор (Id). Уникальный идентификатор группы и лекции.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Идентификатор группы (GroupId). Группа.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
--■ Идентификатор лекции (LectureId). Лекция.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
create table GroupsLectures
(
	Id int not null primary key identity(1,1),
	GroupId int not null FOREIGN KEY REFERENCES Groups(Id), 
	LectureId int not null FOREIGN KEY REFERENCES Lectures(Id), 
)

--9. Заведующие (Heads)
--■ Идентификатор (Id). Уникальный идентификатор заведующего.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Идентификатор преподавателя (TeacherId). Преподаватель, который является заведующим.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
create table Heads
(
	Id int not null primary key identity(1,1),
	TeacherId int not null FOREIGN KEY REFERENCES Teachers(Id)
)

--10.Аудитории (LectureRooms)
--■ Идентификатор (Id). Уникальный идентификатор аудитории.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Корпус (Building). Номер корпуса, в котором располагается аудитория.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Должно быть в диапазоне от 1 до 5.
--■ Название (Name). Название аудитории.
--▷ тип данных nvarchar(10)
--▷ Не может содержать null-значения.
--▷ Не может быть пустым.
--▷ oДолжно быть уникальным.
create table LectureRooms
(
	Id int not null primary key identity(1,1),
	Building  int not null check(Building>=1 and Building<=5),
	Name nvarchar(10) not null check(Name <> '') unique
)

--11. Лекции (Lectures)
--■ Идентификатор (Id). Уникальный идентификатор лекции.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Идентификатор дисциплины (SubjectId). Дисциплина, по которой читается лекция.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
--■ Идентификатор преподавателя (TeacherId). Преподаватель, который читает лекцию.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
create table Lectures
(
	Id int not null primary key identity(1,1),
   	SubjectId int not null FOREIGN KEY REFERENCES Subjects(Id),
	TeacherId int not null FOREIGN KEY REFERENCES Teachers(Id)
)

--12.Расписания (Schedules)
--■ Идентификатор (Id). Уникальный идентификатор расписания.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Пара (Class). Номер пары, на которой читается лекция.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Должно быть в диапазоне от 1 до 8.
--■ День недели (DayOfWeek). День недели, в который читается лекция.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Должен быть в диапазоне от 1 до 7.
--■ Неделя (Week). Номер недели, на которой читается лекция.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Должно быть в диапазоне от 1 до 52.
--■ Идентификатор лекции (LectureId). Лекция.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
--■ Идентификатор аудитории (LectureRoomId). Аудитория, в которой читается лекция.
--▷ тип данных int
--▷ Не может содержать null-значения.
--▷ Внешний ключ.
create table Schedules
(
	Id int not null primary key identity(1,1),
	Class int not null check(Class>=1 and Class<=8),
	DayOfWeek int not null check(DayOfWeek>=1 and DayOfWeek<=7),
	Week int not null check(Week>=1 and Week<=52),
	LectureId int not null FOREIGN KEY REFERENCES Lectures(Id), 
	LectureRoomId int not null FOREIGN KEY REFERENCES LectureRooms(Id)
)

--13. Дисциплины (Subjects)
--■ Идентификатор (Id). Уникальный идентификатор дисциплины.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Название (Name). Название дисциплины.
--▷ тип данных nvarchar(100)
--▷ Не может содержать null-значения.
--▷ Не может быть пустым.
--▷ Должно быть уникальным.
create table Subjects
(
	Id int not null primary key identity(1,1),
	Name nvarchar(100) not null check(Name <> '') unique
)

--14. Преподаватели (Teachers)
--■ Идентификатор (Id). Уникальный идентификатор преподавателя.
--▷ тип данных int
--▷ Авто приращение.
--▷ Не может содержать null-значения.
--▷ Первичный ключ.
--■ Имя (Name). Имя преподавателя.
--▷ тип данных nvarchar(max)
--▷ Не может содержать null-значения.
--▷ Не может быть пустым.
--■ Фамилия (Surname). Фамилия преподавателя.
--▷ тип данных nvarchar(max)
--▷ Не может содержать null-значения.
--▷ Не может быть пустым.
create table Teachers
(
	Id int not null primary key identity(1,1),
	Name nvarchar(max) not null check(Name <> ''),
	Surname nvarchar(max) not null check(Surname <> '')
)
