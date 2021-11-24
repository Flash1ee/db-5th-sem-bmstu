create database rk2;
create schema rk2;
create table rk2.animals
(
    id       bigserial primary key not null,
    type     text,
    breed    text,
    nickname text
);

create table rk2.disease
(
    id      bigserial primary key,
    name    text,
    symptom text,
    result  text
);

create table rk2.disease_animals
(
    id         bigserial primary key not null,
    animals_id bigint                not null references rk2.animals (id),
    disease_id bigint                not null references rk2.disease (id)
);
create table rk2.owner
(
    id      bigserial primary key not null,
    fio     text,
    address text,
    phone   text
);

create table rk2.owner_animals
(
    id         bigserial primary key not null,
    owner_id   bigint                not null references rk2.owner (id),
    animals_id bigint                not null references rk2.animals (id)
);

insert into rk2.animals(type, breed, nickname)
values ('cat', 'ordinary', 'barsik'),
       ('dog', 'buldog', 'lapa'),
       ('elephant', 'ordinary', 'vasya'),
       ('rabbit', 'mq', 'queue'),
       ('cat', 'scottish', 'persik'),
       ('snake', 'case', 'Petr'),
       ('beer', 'russian', 'glass'),
       ('fish', 'shuka', 'elena'),
       ('monkey', 'belarusian', 'potatos'),
       ('horse', 'hound', 'lika');

insert into rk2.disease(name, symptom, result)
values ('AIDS', 'Кровотечение', 'жаропонижающие'),
       ('Allergy', 'Кровяное давление ', 'Анальгетики, болеутоляющие'),
       ('Angina', 'заложенность носа', 'Побочные эффекты'),
       ('Break', 'Жар, лихорадка', 'Антибиотики'),
       ('Bronchitis', 'Мочеиспускание', 'Антигистаминные средства'),
       ('Burn', 'Слабость', 'Антисептики'),
       ('Cancer', 'Сыпь, покраснение', 'Сердечные препараты'),
       ('Diabetes', 'Дефекация, «стул»', 'Противопоказания'),
       ('Dysentery', 'Диарея (понос)', 'Транквилизаторы'),
       ('Gastritis', 'Вздутый (живот)', 'Дозировка');

insert into rk2.owner(fio, address, phone)
values ('Носков Севастьян Германнович', 'Омская область, город Видное, проезд Ломоносова, 37', '+7 (993) 155-83-46'),
       ('Дмитриев Федор Рудольфович', 'Россия, г. Ессентуки, Новый пер., д. 12 кв.185', '+7 (940) 731-48-43'),
       ('Воронов Карл Эльдарович', 'Россия, г. Батайск, Комсомольская ул., д. 21 кв.192', '+7 (991) 832-32-47'),
       ('Калашников Терентий Александрович', 'Россия, г. Челябинск, Максима Горького ул., д. 1 кв.152',
        '+7 (967) 366-23-74'),
       ('Шаров Оскар Русланович', 'Россия, г. Киров, Трудовая ул., д. 18 кв.179', '+7 (937) 357-14-81'),
       ('Щукина Наталья Михаиловна', 'Россия, г. Чебоксары, Центральная ул., д. 11 кв.45', '+7 (976) 110-70-78'),
       ('Пестова Каролина Владленовна', 'Россия, г. Армавир, Севернаяул., д. 9 кв.80', '+7 (980) 249-72-85'),
       ('Исаева Светлана Витальевна', 'Россия, г. Улан-Удэ, Железнодорожная ул., д. 20 кв.170', '+7 (912) 918-20-62'),
       ('Гордеева Александрина Иосифовна', 'Россия, г. Камышин, Красноармейская ул., д. 15 кв.23',
        '+7 (912) 918-20-62'),
       ('Смирнова Лигия Якововна', 'Россия, г. Стерлитамак, Социалистическая ул., д. 11 кв.33', '+7 (919) 589-67-34');

insert into rk2.disease_animals(animals_id, disease_id)
values (1, 2),
       (2, 4),
       (9, 4),
       (3, 7),
       (6, 5),
       (10, 9),
       (8, 3),
       (7, 1),
       (6, 9),
       (10, 1),
       (3, 6);

insert into rk2.owner_animals(animals_id, owner_id)
values (8, 2),
       (2, 3),
       (9, 4),
       (3, 1),
       (6, 5),
       (10, 9),
       (5, 3),
       (7, 6),
       (6, 9),
       (2, 1),
       (3, 6);


-- Задание 2
-- Написать к разработанной базе данных 3 запроса, в комментарии указать, что
-- этот запрос делает:
-- 1) Инструкцию SELECT, использующую простое выражение CASE
-- 2) Инструкцию, использующую оконную функцию
-- 3) Инструкцию SELECT, консолидирующую данные с помощью
-- предложения GROUP BY и предложения HAVING

-- Вывести список животных с пометкой - дворняга он или нет. Если порода -- ordinary, то есть он
-- беспородный, то в столбце true, иначе false. Сортируем по этому столбцу - сначала трушные, потом нет.
select type, (case when breed = 'ordinary' then true else false end) is_ord_animal, nickname
from rk2.animals order by is_ord_animal desc;


-- Вывести количество пород тех животных, которых в таблице больше 2.
select breed, count(*) as count from rk2.animals
group by breed
having count(*) > 1
order by count;

-- Вывод нумерации строк, если id был бы не с 1, то можно было бы делать некоторые вычисления
-- на основе номера реальных строк.
select id, type, breed, row_number() over () as real_num from rk2.animals
group by id;


-- 3. Создать хранимую процедуру с выходным параметром, которая уничтожает
-- все SQL DDL триггеры (триггеры типа 'TR') в текущей базе данных.
-- Выходной параметр возвращает количество уничтоженных триггеров.
-- Созданную хранимую процедуру протестировать.

create or replace function delete_all_triggers() returns int
as $$ declare
    tgName record;
    tgTable record;
    count int;
begin
    count = 0;
    for tgName in
        select distinct(trigger_name) from information_schema.triggers
        where trigger_schema = 'public' loop
        for tgTable in
            select distinct(event_object_table) from information_schema.triggers
            where trigger_name = tgName.trigger_name LOOP
            raise notice 'Delete trigger: % which set up on table: %', tgName.trigger_name, tgTable.event_object_table;
            count = count + 1;
            execute 'drop trigger ' || tgName.trigger_name || ' from table ' || tgTable.event_object_table || ';';
        end loop;
    end loop;

    return count;
END;
$$ LANGUAGE plpgsql;


select delete_all_triggers();