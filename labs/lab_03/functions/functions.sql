--Скалярная функция--
--Количество донатеров--
CREATE OR REPLACE FUNCTION get_count_donators(creator_id bigint)
    RETURNS bigint as
$BODY$
BEGIN
    RETURN (select count(*)
            from payments
                     JOIN content c on c.id = payments.content_id
                     JOIN creators cr on c.id = cr.id
            where cr.id = creator_id);
end;
$BODY$ language plpgsql;

select get_count_donators(1);

--Пример использования--
select id, first_name, get_count_donators(id)
from creators;

--•Подставляемая табличная функция--
--Таблица - количество контента по возрасту--
CREATE OR REPLACE FUNCTION posts_age_stat()
    RETURNS TABLE
            (
                age         integer,
                count_posts integer
            )
as
$$
begin
    return query
        select age_restriction, count(*)::integer as count_posts
        from posts
        group by age_restriction
        order by age_restriction;
end;
$$ language plpgsql;

--Пример использования--
select *
from posts_age_stat();

-- Многооператорная табличная функция --
-- Вывести список постов с категорией подписки в диапазоне цены min-max --
CREATE OR REPLACE FUNCTION get_posts_awards_limit_price(min int, max int)
    RETURNS TABLE
            (
                id           int,
                title        text,
                awards_title text,
                awards_price int
            )
AS
$$
begin
    create temp table tmp
    (
        id           int,
        title        text,
        awards_title text,
        awards_price int
    );
    insert into tmp(id, title, awards_title, awards_price)
    select p.id, p.title, aw.title, aw.price
    from posts p
             join awards aw on aw.id = p.awards_id
    where aw.price BETWEEN min AND max;

    return query
        select * from tmp;
end;
$$ language plpgsql;

-- Пример использования --
select *
from get_posts_awards_limit_price(250, 1000);

-- • Рекурсивную функцию или функцию с рекурсивным ОТВ
-- Создаёт rank_type иерархию и возвращает её в виде таблицы
create type rank_type as enum
    ('Селерон', 'Атлончик','Ашечка', 'Рязань','Пентиум', 'Третий корик', 'Пятерочка', 'Седьмое ядрище');
create or replace function get_rank_type_hierarhy()
    RETURNS TABLE
            (
                id        int,
                parent_id int,
                level     int,
                name      rank_type
            )
as
$$
BEGIN
    return query (
        with recursive cte(res_id, parent_id, res_level, name) as (
            select r.id, r.parent_id, 0 as r_level, r.name
            from ranks r
            where r.parent_id = 0
            union all
            select r2.id, r2.parent_id, res_level + 1, r2.name
            from ranks r2
                     join cte on r2.parent_id = cte.res_id
        )
        select cte.res_id, cte.parent_id, cte.res_level, cte.name
        from cte);
end;
$$ language plpgsql;

create temp table ranks
(
    id        int not null primary key,
    parent_id int,
    name      rank_type
);
insert into ranks(id, parent_id, name)
values (1, 0, 'Рязань'),
       (2, 0, 'Седьмое ядрище'),
       (3, 1, 'Ашечка'),
       (4, 2, 'Пятерочка'),
       (5, 3, 'Атлончик'),
       (6, 4, 'Третий корик'),
       (7, 6, 'Пентиум'),
       (8, 7, 'Селерон');

select *
from get_rank_type_hierarhy();
DROP FUNCTION get_rank_type_hierarhy()



