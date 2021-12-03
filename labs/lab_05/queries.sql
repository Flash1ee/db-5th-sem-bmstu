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

-- Задание 4
-- Выполнить следующие действия:
-- 1. Извлечь XML/JSON фрагмент из XML/JSON документа
-- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON документа
-- 3. Выполнить проверку существования узла или атрибута
-- 4. Изменить XML/JSON документ
-- 5. Разделить XML/JSON документ на несколько строк по узлам

drop table tb_json;
create table tb_json
(
    id bigserial primary key not null unique,
    data jsonb
);

insert into tb_json(data)
VALUES ('{
  "id": "1",
  "user": {
    "firstname": "Dmitry",
    "login": "flashie"
  }
}'),
       ('{
         "id": "2",
         "user": {
           "firstname": "Vasiliy",
           "login": "vasya2003"
         }
       }'),
       ('{
         "id": "1",
         "user": {
           "firstname": "Alex",
           "login": "alexlion"
         }
       }');

-- 1. Извлечь XML/JSON фрагмент из XML/JSON документа
select (data ->> 'user')
from tb_json;

-- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON документа
select (data #> '{"user", "login"}')::text as nickname
from tb_json;

select (data -> 'user' -> 'login')::text as nickname
from tb_json;

-- 3. Выполнить проверку существования узла или атрибута
CREATE OR REPLACE FUNCTION json_key_exists(data jsonb, key text)
    returns bool as
$$
BEGIN
    return (data ? key);
END
$$ language plpgsql;
select *
from json_key_exists('{
  "user": "lama",
  "age": 99
}', 'user');
select *
from json_key_exists('{
  "user": "lama",
  "age": 99
}', 'password');

-- 4. Изменить XML/JSON документ
UPDATE tb_json
SET data = '{
  "id": "3",
  "user": {
    "login": "a",
    "firstname": "b"
  }
}'
where (data ->> 'id')::int = 2;

select *
from tb_json;

-- 5. Разделить XML/JSON документ на несколько строк по узлам
-- Разделить JSON документ на несколько строк по узлам.

with cte(data) as (
    select jsonb_array_elements(data)
    from temp
)
select *
from cte;
select current_date;

select *
from json_array_elements('[
  {
    "user": "lama",
    "age": 120
  },
  {
    "user": "lama",
    "age": 99
  }
]');


-- select с between
insert into tb_json
values ('{
  "id": "7",
  "user": {
    "login": "flashie",
    "firstname": "kek"
  }
}'),
       ('{
         "id": "9",
         "user": {
           "login": "lol",
           "firstname": "cheburek"
         }
       }');
select * from tb_json
where (data->>'id')::int between 2 and 9;
select * from tb_json;

select * from pg_catalog.pg_tables
where schemaname = 'public';

select get_count_donators(6);

drop table events;

create table if not exists events(
                id bigserial primary key,
                event_name text not null,
                creator_id int references creators(id) not null
            );