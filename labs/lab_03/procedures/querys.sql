-- Хранимые процедуры --
-- Хранимая процедура без параметров или с параметрами --

-- Скоро 8 марта, в честь праздника всем женщинам на счёт начислим bonus единиц--
CREATE OR REPLACE PROCEDURE add_bonus(bonus int) AS
$$
BEGIN
    UPDATE donators
    SET account = account + bonus
    WHERE sex = 'F';
END;
$$ language plpgsql;

BEGIN;
CALL add_bonus(100);
select *
from donators
where sex = 'F';
-- Мужская часть начала возмущаться, так что бонус отменим :) --
ROLLBACK;

-- Рекурсивную хранимую процедуру или хранимую процедур с
-- рекурсивным ОТВ

-- • Хранимую процедуру с курсором
-- Вывести уровни подписки пользователя с id = donator_id, которые доступны ему по имеющимся
-- донатам для креаторов с id = creator_id --
CREATE OR REPLACE PROCEDURE get_awards_list(donator_id integer, creator_id integer) AS
$$
DECLARE
    cur_row record;
    cur1 CURSOR FOR
        with cte(payment_sum) as (
            select sum(amount)
            from payments
            group by donators_id
            having donators_id = donator_id
        )
        select distinct aw.id as id, aw.title as title, aw.price as price
        from awards aw
                 join content c on aw.id = c.id
                 join payments p on c.id = p.content_id
        where p.donators_id = donators_id
          and p.content_id = c.id
          and aw.price <= (select payment_sum from cte)
          and p.content_id = creator_id;
BEGIN
    OPEN cur1;
    RAISE NOTICE 'available awards for user with id = % creator_id = %',
        donator_id, creator_id;
    LOOP
        fetch cur1 into cur_row;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'award_id = % title = % price = %', cur_row.id,
            cur_row.title, cur_row.price;
    END LOOP;
END
$$ language plpgsql;

CALL get_awards_list(1, 1);
with cte(payment_sum) as (
    select sum(amount)
    from payments
    group by donators_id
    having donators_id = 1
)
select aw.id as id, aw.title as title, aw.price as price
from awards aw
         join content c on aw.id = c.id
         join payments p on c.id = p.content_id
where p.donators_id = donators_id
  and p.content_id = c.id
  and aw.price <= (select payment_sum from cte);


-- Хранимую процедуру доступа к метаданным
-- Вывести метаинформацию таблицы --
CREATE OR REPLACE PROCEDURE get_table_info(tbname text) AS
$$
DECLARE
    res record;
BEGIN
    for res in SELECT *
    from information_schema.tables
    WHERE table_name = tbname
    LOOP
        raise notice '% % % % % %', res.table_catalog, res.table_schema, res.table_name, res.table_type,
            res.is_typed, res.commit_action;
        end loop;
END
$$ language plpgsql;

CALL get_table_info('awards');

