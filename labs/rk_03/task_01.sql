create type days as enum (
    'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'
    );

create table employer_time
(
    id   bigint                            not null references employers (id),
    date date                              not null default current_date,
    day  days,
    time time                              not null default current_time,
    type int check ( type = 1 or type = 2) not null
);

create table employers
(
    id          bigint not null primary key,
    fio         text   not null,
    birthday    date   not null,
    departament text   not null
);



create or replace function get_number_of_employers()
    RETURNS bigint as
$$
BEGIN
    return (select *
            from employers
            where extract(year from now()) - extract(year from birthday) BETWEEN (18, 40)
                      and id in (
                          select id from employer_time
                          group by id, type
                          having count(*) > 3)
    );
end;
$$ language plpgsql;

