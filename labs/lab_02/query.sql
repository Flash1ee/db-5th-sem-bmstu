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
)

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
select first_name, second_name
from creators cr
         join (
    select first_name as first_name_donator
)
-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем
-- вложенности 3.
--
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
-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET.
--
-- 20. Простая инструкция DELETE.
--
-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в
-- предложении WHERE.
--
-- 22. Инструкция SELECT, использующая простое обобщенное табличное
-- выражение
--
-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное
-- выражение.
--
-- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
--
-- 25. Оконные фнкции для устранения дублей