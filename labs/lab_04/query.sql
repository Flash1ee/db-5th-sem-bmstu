CREATE EXTENSION plpython3u;

-- Создать, развернуть и протестировать 6 объектов SQL CLR:
-- • Определяемую пользователем скалярную функцию CLR,
CREATE OR REPLACE FUNCTION get_count_donators(creator_id int)
    returns int as
$$
query = plpy.prepare(
    "select count(*) as cnt from payments JOIN content c on c.id = payments.content_id JOIN creators cr on c.id = cr.id where cr.id = $1",
    ["int"])
res = plpy.execute(query, [creator_id])
return res[0]['cnt']
$$ language plpython3u;
select *
from get_count_donators(1);

-- • Пользовательскую агрегатную функцию CLR,
-- функция возвращает максимальную сумму платежей донатеров
CREATE TYPE sum_max_donators AS
(
    id  int,
    sum int
);

CREATE OR REPLACE FUNCTION get_sum_max_donations()
    returns sum_max_donators as
$$
def maximum_keys(d):
    maximum = max(d.values())
    res = filter(lambda x: x[1] == maximum, d.items())
    return res, maximum


donators_payments = {}
query = "SELECT amount, donators_id from payments"
res = plpy.execute(query)
for row in res:
    if row['donators_id'] in donators_payments:
        donators_payments[row['donators_id']] += row['amount']
    else:
        donators_payments[row['donators_id']] = row['amount']

max_row, maximum = maximum_keys(donators_payments)
return [list(max_row)[0][0], maximum]
$$ language plpython3u;

drop function get_sum_max_donations();
select *
from get_sum_max_donations();

-- • Определяемую пользователем табличную функцию CLR,
-- Функция возвращает таблицу - количество контента по возрасту--
CREATE OR REPLACE FUNCTION get_count_content()
    RETURNS TABLE
            (
                age   integer,
                count integer
            )
as
$$
    query = '''SELECT age_restriction as age, count(*) as cnt
    from posts group by age order by age'''
    res = plpy.execute(query)
    for row in res:
        yield (row['age'], row['cnt'])
$$ language plpython3u;

select * from get_count_content();
-- • Хранимую процедуру CLR,
-- • Триггер CLR,
-- • Определяемый пользователем тип данных CLR.

CREATE TYPE greeting AS
(
    how text,
    who text
);
CREATE FUNCTION greet(how text)
    RETURNS SETOF greeting
AS
$$
for who in ["World", "PostgreSQL", "PL/Python"]:
    yield (how, who)
$$ LANGUAGE plpython3u;

