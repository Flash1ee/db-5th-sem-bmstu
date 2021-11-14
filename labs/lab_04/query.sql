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
-- Скоро 8 марта, в честь праздника всем женщинам
-- на счёт начислим bonus единиц--
CREATE OR REPLACE PROCEDURE add_women_bonus(bonus int) as
    $$
    query = '''UPDATE donators
    SET account = account + $1
    WHERE sex = 'F';'''
    bef = plpy.prepare(query, ['int'])
    res = plpy.execute(bef, [bonus])
    $$ language plpython3u;
DROP PROCEDURE add_women_bonus(bonus int);
BEGIN;
CALL add_women_bonus(100);
select * from donators where sex = 'F';
ROLLBACK;

-- • Триггер CLR,
-- После платежа на сумму >= стоимости подписки, в таблице awards количество подписок с минимально
-- подходящей ценой уменьшить на 1
CREATE OR REPLACE FUNCTION fix_count_awards()
RETURNS TRIGGER as
    $$
    payment_content_id = TD["new"]["content_id"]
    payment_amount = TD["new"]["amount"]
    awards_id_query = '''
   select awards.id as aw_id from awards
            join posts p on awards.id = p.awards_id
            join content c on p.content_id = $1
            where awards.price >= $2
            order by awards.price asc
            limit 1
    '''
    update_awards_query = '''UPDATE awards
    SET count = count - 1
    WHERE awards.id = $1'''

    prep_awards_id = plpy.prepare(awards_id_query, ["int", "int"])
    prep_update_awards = plpy.prepare(update_awards_query, ["int"])

    res = plpy.execute(prep_awards_id, [payment_content_id, payment_content_id])
    if res.nrows() != 0:
        res = plpy.execute(prep_update_awards, [res[0]['aw_id']])
        plpy.notice("SUCCESS UPD COUNT AWARDS")
    else:
        plpy.notice("SUCCESS NOT UPD COUNT AWARDS")

    $$ language plpython3u;

DROP TRIGGER tg_python_update_count_awards on payments;
CREATE TRIGGER tg_python_update_count_awards
AFTER INSERT ON payments
FOR EACH ROW
EXECUTE FUNCTION fix_count_awards();
insert into payments(amount, donators_id, content_id)
values(5000, 1, 2);
-- • Определяемый пользователем тип данных CLR.
CREATE TYPE greeting AS
(
    username text,
    greeting_text text
);
CREATE OR REPLACE FUNCTION greet(how text)
    RETURNS SETOF greeting
AS
$$
for who in ["Привет из России", "Hello from England", "Aloha from Hawaii"]:
    yield (who, how)
$$ LANGUAGE plpython3u;

select * from greet('Dmitry')

