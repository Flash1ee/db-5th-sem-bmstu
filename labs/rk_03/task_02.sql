-- 1. Найти все отделы, в которых работает более 10 сотрудников

select departament
from employers
group by departament
having count(*) > 10;

-- 2. Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня.

select id, fio
from employers
where id not in (
    select id
    from employer_time
    group by id, date, type
    having type = 2
);

-- 3. Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату. Дату
-- передавать с клавиатуры

select departament from employers
