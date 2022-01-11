CREATE TABLE empl_visits
(
  department text,
  name text,
  fdt date,
  status text
);

insert into empl_visits values ('ИТ', 'Иванов Иван Иванович', '2020-01-15', 'Больничный');
insert into empl_visits values ('ИТ', 'Иванов Иван Иванович', '2020-01-16', 'На работе');
insert into empl_visits values ('ИТ', 'Иванов Иван Иванович', '2020-01-17', 'На работе');
insert into empl_visits values ('ИТ', 'Иванов Иван Иванович', '2020-01-18', 'На работе');
insert into empl_visits values ('ИТ', 'Иванов Иван Иванович', '2020-01-19', 'Оплачиваемый отпуск');
insert into empl_visits values ('ИТ', 'Иванов Иван Иванович', '2020-01-20', 'Оплачиваемый отпуск');
insert into empl_visits values ('Бухгалтерия', 'Петрова Ирина Ивановна', '2020-01-15', 'Оплачиваемый отпуск');
insert into empl_visits values ('Бухгалтерия', 'Петрова Ирина Ивановна', '2020-01-16', 'На работе');
insert into empl_visits values ('Бухгалтерия', 'Петрова Ирина Ивановна', '2020-01-17', 'На работе');
insert into empl_visits values ('Бухгалтерия', 'Петрова Ирина Ивановна', '2020-01-18', 'На работе');
insert into empl_visits values ('Бухгалтерия', 'Петрова Ирина Ивановна', '2020-01-19', 'Оплачиваемый отпуск');
insert into empl_visits values ('Бухгалтерия', 'Петрова Ирина Ивановна', '2020-01-20', 'Оплачиваемый отпуск');

WITH cte AS (
    SELECT row_number() OVER(
        PARTITION BY name, status
        ORDER BY fdt
    ) AS i, department, name, fdt, status
    FROM empl_visits
)
select department, name, min(fdt) as date_from, max(fdt) as date_to,  status from cte
group by department, name, status, i
order by department, name, date_from;
