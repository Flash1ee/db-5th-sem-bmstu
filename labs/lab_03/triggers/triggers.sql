-- • Триггер AFTER
-- После платежа на сумму >= стоимости подписки, в таблице awards количество подписок с минимально
-- подходящей ценой уменьшить на 1
create or replace function update_count_awards()
returns trigger as
    $$
    DECLARE
        upd_id bigint;
    BEGIN
        with cte(awards_id) as (
            select awards.id from awards
            join posts p on awards.id = p.awards_id
            join content c on p.content_id = c.id
            where awards.price >= NEW.amount
            order by awards.price asc
            limit 1
        )
        select * from cte into upd_id;
        update awards
        set count = count - 1
        where awards.id = upd_id;

        raise notice 'award_id = %', upd_id;

        return NEW;
    end;
    $$ language plpgsql;

CREATE TRIGGER tg_update_count_awards
    AFTER INSERT ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_count_awards();

insert into payments(amount, donators_id, content_id)
values(5000, 1, 2);

DROP TRIGGER tg_update_count_awards on payments;

-- • Триггер INSTEAD OF
-- Срабатывает на добавление платежа
-- Если на балансе недостаточно средств, отмена

create view payments_view as select * from payments;
create or replace function insert_payment()
    RETURNS TRIGGER AS
$$
DECLARE
    cash numeric;
BEGIN
    select account from donators
    where id = NEW.donators_id
    into cash;
    if NEW.amount > cash THEN
        raise info 'user have not money for payment';
        RETURN NULL;
    else
        update donators
        set account = donators.account - NEW.amount
        where id = NEW.donators_id;
        RETURN NEW;
        end if;
END
$$ language plpgsql;
CREATE TRIGGER check_correct_payment
    INSTEAD OF INSERT ON payments_view
    FOR ROW
EXECUTE function insert_payment();

insert into payments_view(amount, donators_id, content_id)
values(80, 1, 1);

DROP VIEW payments_view;
DROP FUNCTION insert_payment();
DROP TRIGGER check_correct_payment ON payments_view

explain select  * from payments join content c on c.id = payments.content_id;

create index on payments(donators_id);
drop index payments_donators_id_idx;
explain select * from payments where donators_id < 6;