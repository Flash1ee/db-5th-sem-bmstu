import db_connection

# Выполнить скалярный запрос;
GET_CONTENT_CATEGORIES = "SELECT distinct category_name from crowdfunding.public.content;"
# Выполнить запрос с несколькими соединениями (JOIN);
GET_CREATOR_AWARDS = "SELECT distinct awards.title, awards.description, awards.price FROM awards " \
                     "join posts p on awards.id = p.awards_id " \
                     "join public.content c on c.id = p.content_id where c.id = {}"
# Выполнить запрос с ОТВ(CTE) и оконными функциями;
GET_DONATORS_CTE = "with cte(id, first_name, second_name) as ( \
    select id, first_name, second_name \
    from donators \
    union all \
    select id, first_name, second_name \
    from donators \
) \
select id, first_name, second_name \
from ( \
         select id, first_name, second_name, row_number() over (partition by id) n \
         from cte) uniq \
where n = 1;"
# Выполнить запрос к метаданным;
GET_TABLE_FROM_PUBLIC_SCHEME = "select tablename from pg_catalog.pg_tables \
where schemaname = 'public';"
# Вызвать скалярную функцию (написанную в третьей лабораторной работе);
GET_SCALAR = "select get_count_donators({})"
# Вызвать многооператорную или табличную функцию (написанную в третьей
# лабораторной работе);
GET_TABLE_FUNC = "select * from get_posts_awards_limit_price({}, {});"
# Вызвать хранимую процедуру (написанную в третьей лабораторной работе);
CALL_FEMALE_BONUS_PROCEDURE = "CALL add_bonus({});"
# Вызвать системную функцию или процедуру;
GET_CURRENT_DATE = "select current_date;"
# Создать таблицу в базе данных, соответствующую тематике БД;
CREATE_NEW_TB = "create table if not exists events( \
                id bigserial primary key, \
                event_name text not null, \
                creator_id int references creators(id) not null \
            );"
DELETE_TB = "drop table events;"
# Выполнить вставку данных в созданную таблицу с использованием
# инструкции INSERT или COPY.
INSERT_DATA = "insert into events(event_name, creator_id) VALUES ({}, {})"


def get_content_categories(connection):
    data = "Categories: "
    cursor = db_connection.execute_query(connection, GET_CONTENT_CATEGORIES)
    if cursor is not None:
        res = cursor.fetchall()
        for category in res:
            data += category[0] + ", "
        data = data.rstrip(", ")

    return data


def get_creator_awards(connection):
    creator_id = -1
    try:
        creator_id = int(input("input creator_id - integer > 0: "))
    except:
        print("invalid creator_id")
        return
    else:
        return _get_creator_awards(connection, creator_id)


def _get_creator_awards(connection, creator_id):
    data = "Creator id = {}\nAwards:\n".format(creator_id)
    cursor = db_connection.execute_query(connection, GET_CREATOR_AWARDS.format(creator_id))
    if cursor is not None:
        res = cursor.fetchall()
        for awards in res:
            data += "title = {} description = {} price = {}\n".format(awards[0], awards[1], awards[2])
    return data


def get_donators_cte(connection):
    data = "Donators:\n"
    cursor = db_connection.execute_query(connection, GET_DONATORS_CTE)
    if cursor is not None:
        res = cursor.fetchall()
        for donator in res:
            data += "{} {} {}\n".format(donator[0], donator[1], donator[2])
    return data


def get_meta(connection):
    data = "Table names:\n"
    cursor = db_connection.execute_query(connection, GET_TABLE_FROM_PUBLIC_SCHEME)
    if cursor is not None:
        res = cursor.fetchall()
        for tb in res:
            data += "{}\n".format(tb[0])
    return data

def get_count_donators(connection):
    creator_id = -1
    try:
        creator_id = int(input("input creator_id - integer > 0: "))
    except:
        print("invalid creator_id")
        return
    else:
        return _get_count_donators(connection, creator_id)

def _get_count_donators(connection, creator_id):
    data = "Count donators = {}:\n"
    cursor = db_connection.execute_query(connection, GET_SCALAR.format(creator_id))
    if cursor is not None:
        res = cursor.fetchall()
        data = data.format(res[0][0])
    return data

def get_min_max_posts(connection):
    min_price, max_price = -1, -1
    try:
        min_price = int(input("input min_price - integer >= 0: "))
        max_price = int(input("input max_price - integer >= 0 and max_price >= min_price: "))
        if min_price < 0 or min_price > max_price:
            raise Exception
    except:
        print("invalid price")
        return
    else:
        return _get_min_max_posts(connection, min_price, max_price)

def _get_min_max_posts(connection, min_price, max_price):
    data = "Posts with price between {}, {}:\n".format(min_price, max_price)
    cursor = db_connection.execute_query(connection, GET_TABLE_FUNC.format(min_price, max_price))
    if cursor is not None:
        res = cursor.fetchall()
        for post in res:
            data += "{} {} {} {}\n".format(post[0], post[1], post[2], post[3])
    return data

def add_female_bonus(connection):
    bonus = -1
    try:
        bonus = int(input("input bonus - integer >= 0: "))
        if bonus <= 0:
            raise Exception
    except:
        print("invalid price")
        return
    else:
        return _add_female_bonus(connection, bonus)

def _add_female_bonus(connection, bonus):
    data = "Success\n"
    try:
        cursor = db_connection.execute_query(connection, CALL_FEMALE_BONUS_PROCEDURE.format(bonus))
    except:
        return "error database"
    else:
        return data

def get_cur_date(connection):
    data = "Cur date is {}\n"
    cursor = ""
    try:
        cursor = db_connection.execute_query(connection, GET_CURRENT_DATE)
    except:
        return "db error"
    else:
        res = cursor.fetchall()
        return data.format(res[0][0].strftime("%Y-%m-%d %H:%M:%S"))
def create_table_events(connection):
    data = "Create table events\n"
    try:
        cursor = db_connection.execute_query(connection, CREATE_NEW_TB)
    except:
        return "db_error"
    else:
        data += "Success"
        return data

def delete_table_events(connection):
    data = "Delete table events\n"
    try:
        cursor = db_connection.execute_query(connection, DELETE_TB)
    except:
        return "db_error"
    else:
        data += "Success"
        return data

def insert_values(connection):
    data = "Insert values\n"
    event_name = input("Entry event_name\n")
    creator_id = -1
    try:
        creator_id = int(input("Input creator_id"))
        if creator_id <= 0:
            raise Exception
    except:
        print("invalid creator_id")
        return
    check_creator = "SELECT * from creators where id = {}".format(creator_id)
    res = db_connection.execute_query(connection, check_creator)
    if res.rowcount == 0:
        return "not found creator with creator_id = {}".format(creator_id)
    try:
        res = db_connection.execute_query(connection, INSERT_DATA.format(event_name, creator_id))
    except:
        return "db_error"
    else:
        data += "Success insert"
        return data

