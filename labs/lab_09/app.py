from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
import json
from views import get_top_categories, delete_last_post, add_post, change_post, get_top_categories_cache
from compare_tests import benchmark
import db_connection
import redis

cfg = json.load(open("./config.json"))
DB_INFO = cfg['db']

engine = create_engine(
    f'postgresql://{DB_INFO["user"]}:{DB_INFO["password"]}@{DB_INFO["host"]}:{DB_INFO["port"]}/{DB_INFO["name"]}',
    pool_pre_ping=True)

r = redis.Redis()

Session = sessionmaker(bind=engine)

QUERIES = {
    # количество постов по категориям
    1: get_top_categories,
    2: get_top_categories_cache,
    3: delete_last_post,
    4: add_post,
    5: change_post,
}


def menu():
    choices = \
        '''
    1 - Получить топ категорий, используемых в постах.
    2 - Получить топ категорий с кешированием.
    3 - Удалить последний пост.
    4 - Добавить тестовый пост.
    5 - Изменить один из тестовых постов.
    
    
    -1 = Выход.
    '''
    print(choices)


def main():
    is_work = True
    connection = db_connection.connect(DB_INFO)
    benchmark(connection, r)
    while is_work:
        menu()
        action = input()
        try:
            action = int(action)
        except:
            print("Invalid input actions. Only nums.")
        else:
            if action == -1:
                print("End of work")
                break
            else:
                if action in QUERIES:
                    session = Session()
                    res = QUERIES[action](connection, r)
                    print(res)
                    session.commit()
                else:
                    print("Error input action")

    connection.close()


if __name__ == "__main__":
    main()
