-- SELECT *
-- FROM information_schema.tables
-- WHERE table_schema = 'public'
--
-- create or replace procedure export_to_json(fname text) as
-- $$
-- declare
--     tb_name text;
--     cur1 CURSOR FOR (
--         SELECT table_name
--         FROM information_schema.tables
--         WHERE table_schema = 'public');
-- BEGIN
--     open cur1;
--     LOOP
--         fetch cur1 into tb_name;
--         raise notice '%',  tb_name;
--         COPY (
--             SELECT row_to_json(tb)
--             FROM (
--                      SELECT *
--                      FROM tb_name
--                  ) tb
--             ) TO 'export.json';
--         EXIT WHEN NOT FOUND;
--     end loop;
-- end;
--
-- $$ language plpgsql;
--
-- CALL export_to_json('data.json')
\c crowdfunding

-- \t Отключает вывод имён столбцов и результирующей строки с количеством выбранных записей.
-- \a выравнивание +

-- Задание 1 - выгрузить таблицы в json
\t \a
\! mkdir -p pg_json_data
\o ./pg_json_data/awards.json
SELECT array_to_json(array_agg(row_to_json(a)))
FROM awards a;

\o ./pg_json_data/content.json
SELECT array_to_json(array_agg(row_to_json(content)))
FROM content;

\o ./pg_json_data/creators.json
SELECT array_to_json(array_agg(row_to_json(creators)))
FROM creators;

\o ./pg_json_data/donators.json
SELECT array_to_json(array_agg(row_to_json(donators)))
FROM donators;

\o ./pg_json_data/donators_content.json
SELECT array_to_json(array_agg(row_to_json(donators_content)))
FROM donators_content;

\o ./pg_json_data/payments.json
SELECT array_to_json(array_agg(row_to_json(payments)))
FROM payments;

\o ./pg_json_data/posts.json
SELECT array_to_json(array_agg(row_to_json(posts)))
FROM posts;

-- Задание 2 - создать таблицу из json

CREATE TABLE if not exists temp
(
    data jsonb
);
create table if not exists load_awards
(
    id          integer primary key,
    price       numeric,
    title       text,
    description text,
    count       integer
);

copy temp (data) from '/home/dmitry/bmstu/db-5th-sem-bmstu/labs/lab_05/pg_json_data/awards.json';
-- copy temp(data) from 'PATH_TO_FILE_GLOBAL';


insert into load_awards(id, price, title, description, count)
SELECT (data ->> 'id')::integer,
       (data ->> 'price')::numeric,
       data ->> 'title',
       data ->> 'description',
       (data ->> 'count')::integer
from temp;

with cte(data) as (
    select jsonb_array_elements(data)
    from temp
)
insert
into load_awards(id, price, title, description, count)
SELECT (data ->> 'id')::integer,
       (data ->> 'price')::numeric,
       data ->> 'title',
       data ->> 'description',
       (data ->> 'count')::integer
from cte;

select *
from load_awards;

-- Задание 3 - Создать таблицу, в которой будет атрибут(-ы) с типом JSON, или
-- добавить атрибут с типом JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE.

alter table load_awards
    ADD json_id_price jsonb;


-- задать столбцу json_id_price json вида {"count": NUM}
-- количество постов для текущей категории подписки
update load_awards la_src
set json_id_price = (
    select json_build_object(
                   'count', (
                select count(*)
                from posts
                where awards_id = la_src.id
            )
               )
    from load_awards
    where load_awards.id = la_src.id
)
where id < (
    select count(*)
    from load_awards
);

select *
from load_awards;

