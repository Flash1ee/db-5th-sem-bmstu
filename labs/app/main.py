import json
import db_connection, queries
import psycopg2

cfg = json.load(open("config.json"))
DB_INFO = cfg['db']

EXIT = -1
workers = {
    -1: exit,
    1: queries.get_content_categories,
    2: queries.get_creator_awards,
    3: queries.get_donators_cte,
    4: queries.get_meta,
    5: queries.get_count_donators,
    6: queries.get_min_max_posts,
    7: queries.add_female_bonus,
    8: queries.get_cur_date,
    9: queries.create_table_events,
    10: queries.insert_values,
    11: queries.delete_table_events,
    12: queries.delete_donator,
}


def menu():
    choices = \
        '''
    1 - Получить список категорий контента.
    2 - Получить список наград креатора.
    3 - Получить список донатеров(использование СТЕ и оконных функций).
    4 - Получить список таблиц с schemaname = public.
    5 - Получить количество донатеров у креатора с id = creator_id.
    6 - Вывести список постов с категорией подписки в диапазоне цены min-max.
    7 - Всем женщинам на счёт начислим bonus единиц.
    8 - Вывести текущую дату.
    9 - Создать таблицу events.
    10 - Вставить значения в созданную таблицу.
    11 - Удалить созданную таблицу events.
    12 - Удалить донатера.
    
    -1 - Завершить работу.
    '''
    print(choices)


def main():
    connection = False
    try:
        connection = db_connection.create_database(DB_INFO)
    except psycopg2.Error as e:
        print(f"[INFO] database {DB_INFO['name']} exist")
        connection = db_connection.connect(DB_INFO)
        connection.autocommit = True
    finally:
        if connection:
            connection.close()
            print("[INFO] Connection close.")

    is_work = True
    while is_work:
        menu()
        action = input()
        try:
            action = int(action)
        except:
            print("Invalid input actions. Only nums.")
        else:
            if action == EXIT:
                print("End of work")
                break
            else:
                if action in workers.keys():
                    connection = db_connection.connect(DB_INFO)
                    res = workers[action](connection)
                    print(res)
                    connection.close()
                else:
                    print("Error input action")
                    print("Disconnect")


if __name__ == "__main__":
    main()
