-- 1. SELECT с предикатом сравнения
SELECT id, description
from content
where category_name = 'подкасты';

-- 2. Инструкция SELECT, использующая предикат BETWEEN
select first_name, second_name, account
from donators
where account between 100 and 200
order by account;

-- 3. Инструкция SELECT, использующая предикат LIKE.
select dc.title, dc.body, dc.age_restriction
from content
         inner join posts as dc on content.id = dc.id
where dc.body LIKE 'Факультет%';

-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
select first_name, second_name
from donators
where id in (
    select donators_id
    from payments
             join content c on payments.content_id = c.id
    where c.category_name = 'подкасты'
)
order by first_name, second_name;

-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным
-- подзапросом
select d.first_name, d.second_name
from donators as d
where exists(
              select donators_id
              from payments
                       join content c on payments.content_id = c.id
              where c.category_name = 'музыка'
                and d.id = payments.donators_id
              group by donators_id
              having count(*) >= 2
          );


-- 6. Инструкция SELECT, использующая предикат сравнения с квантором.
-- ALL, ANY(SOME)
select p.donators_id,
       p.amount,
       creators.first_name,
       creators.second_name,
       c.category_name
from payments as p
         join content c on p.content_id = c.id
         join creators on creators.id = c.id
where p.amount = ANY (
    select price
    from awards
);

-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях
-- столбцов.
select first_name, second_name, SUM(amount) as sum_payments
from creators
         join content c on c.id = creators.id
         join payments p on c.id = p.content_id
group by creators.id
order by sum_payments DESC
LIMIT 10;
-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях
-- столбцов.
select first_name,
       second_name,
       account,
       (case
            when account >
                 (
                     select AVG(amount) as avg
                     from payments
                 ) then 'more_average_payments'
            else 'less_average_payments' end)
from donators as d
order by account;
--
-- 9. Инструкция SELECT, использующая простое выражение CASE.
select c.category_name,
       p.title,
       p.date,
       case p.age_restriction
           when 18 then '18+'
           else 'kids' end
from content as c
         join posts p on c.id = p.content_id
order by title;
-- 10. Инструкция SELECT, использующая поисковое выражение CASE.
select first_name,
       second_name,
       account,
       (case
            when account >
                 (
                     select AVG(amount) as avg
                     from payments
                 ) then '25%'
            else '10%' end) as discont
from donators as d
order by first_name, second_name;
-- 11. Создание новой временной локальной таблицы из результирующего набора
-- данных инструкции SELECT.
begin;
create temp table donators_posts on commit drop as
    (
        select first_name, second_name, c.category_name, p.title
        from donators
                 join donators_content dc on donators.id = dc.donators_id
                 join content c on dc.content_id = c.id
                 join posts p on c.id = p.content_id
        order by title
    );
commit;
--
-- 12. Инструкция SELECT, использующая вложенные коррелированные
-- подзапросы в качестве производных таблиц в предложении FROM.
-- Вывести информацию о контенте с привязкой к его наградам, стоимостью более 500.
-- lateral позволяет из подзапроса обратиться к столбцам внешней таблицы
select cont.category_name, cont.description, price, title
from awards as a
         join lateral (
    select awards_id, category_name, description
    from content
             join posts p on content.id = p.content_id
    where a.price > 500
    ) as cont on a.id = cont.awards_id;

-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем
-- вложенности 3.
-- Логины пользователей, у которых есть платежи за контент, посты которого
-- входят в 10ку самых первых
select login, payments.date
from donators
         join (
    select donators_id, amount, date
    from payments
             join (
        select id, category_name
        from content
        where id in (
            select content_id
            from posts
            order by date
            limit 10
        )
    ) content on content.id = payments.content_id
) payments on payments.donators_id = donators.id
order by payments.date;
-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY, но без предложения HAVING.
-- Вывести количество постов по категориям
select c.category_name, count(c.id) as cnt
from content as c
         join posts p on c.id = p.content_id
group by category_name
order by cnt;
-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY и предложения HAVING.
-- Вывести количество постов по категорям с возврастным ограничением больше 6
-- и датой публикации - позже 01-01-2010
select c.category_name, count(*) as cnt
from content c
         join posts p on c.id = p.content_id
where p.date > date('2010-01-01')
group by c.category_name, age_restriction
having age_restriction > 6
order by cnt;
--
-- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной
-- строки значений.
SELECT setval('payments_id_seq', COALESCE((SELECT MAX(id) + 1 FROM payments), 1), false);

insert into payments(id, amount, date, donators_id, content_id)
values (default, 1000, current_date, 1, 1);
-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу
-- результирующего набора данных вложенного подзапроса.
SELECT setval('posts_id_seq', COALESCE((SELECT MAX(id) + 1 FROM posts), 1), false);
insert into posts(title, body, date, content_id, awards_id, age_restriction)
values ('Пост о жизни', 'жизненные истории', current_date,
        (select max(id) from content),
        (select min(id) from awards),
        6);

-- 18. Простая инструкция UPDATE.
update awards
set price = 250
where price = 100;
-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET.
-- Начислить бонус на аккаунт всем донатером в размере минимального платежа
-- среди всех донатеров.
update donators
set account = account + (
    select MIN(p.amount)
    from payments as p
);
-- 20. Простая инструкция DELETE.
-- Удалить все посты с ограничением больше 21
delete
from posts
where posts.age_restriction > 21;
-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в
-- предложении WHERE.
-- Удалить посты, у контента которых не было платежей
begin;
delete
from posts as p
where not exists(
        select *, c.id, p2.id
        from payments
                 join content c on c.id = payments.content_id
                 join posts p2 on c.id = p2.content_id
        where p2.id = p.id
    );
rollback;
-- 22. Инструкция SELECT, использующая простое обобщенное табличное
-- выражение
-- Вывести имя, фамилию креатеров и их донатеров и сумму пожертвований
with d_c_sum as (
    select donators_id, content_id, sum(amount) as donats
    from payments as p
    group by donators_id, content_id
)
select d.first_name, d.second_name, c.first_name, c.second_name, d_c_sum.donats
from donators as d
         join donators_content dc on d.id = dc.donators_id
         join creators c on dc.content_id = c.id
         join d_c_sum on d_c_sum.donators_id = d.id and d_c_sum.content_id = c.id;
-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное
-- ввыражение.
drop type if exists rank_type cascade;
drop table if exists ranks cascade;

create type rank_type as enum
    ('Селерон', 'Атлончик','Ашечка', 'Рязань','Пентиум', 'Третий корик', 'Пятерочка', 'Седьмое ядрище');
create temp table ranks
(
    id   int not null primary key,
    parent_id int,
    name rank_type
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
-- select * from ranks;
with recursive cte(id, parent_id, level, name) as (
    select id, parent_id, 0, name from ranks
    where parent_id = 0
    union all
    select r.id, r.parent_id, level + 1, r.name
    from ranks r
    join cte on r.parent_id = cte.id
)
select * from cte;
-- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
-- Подсчитать сумму платежей донатеров
select distinct d.login, sum(p.amount) over (partition by p.donators_id) as sum_donats
from donators as d
         join payments p on d.id = p.donators_id
order by sum_donats;

-- 25. Оконные фнкции для устранения дублей
with cte(id, first_name, second_name) as (
    select id, first_name, second_name
    from donators
    union all
    select id, first_name, second_name
    from donators
)
-- @todo почему нет доступа до n без оборачивания таблицы??
select id, first_name, second_name
from (
         select id, first_name, second_name, row_number() over (partition by id) n
         from cte) uniq
where n = 1;
