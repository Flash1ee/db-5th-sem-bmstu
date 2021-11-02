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
AS $$
begin
    create temp table tmp (
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

DROP FUNCTION get_posts_awards_limit_price(integer)
drop table tmp;
