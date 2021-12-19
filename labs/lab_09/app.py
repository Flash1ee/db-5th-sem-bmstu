from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
import json
from views import get_top_categories, delete_last_post, add_post, change_post
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
    2: delete_last_post,
    3: add_post,
    4: change_post,
}


def menu():
    choices = \
        '''
    1 - Получить топ категорий, используемых в постах.
    2 - Удалить последний пост.
    3 - Добавить тестовый пост.
    4 - Изменить один из тестовых постов.
    
    
    -1 = Выход.
    '''
    print(choices)


def main():
    is_work = True
    connection = db_connection.connect(DB_INFO)
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
                    res = QUERIES[action](connection)
                    print(res)
                    session.commit()
                else:
                    print("Error input action")

    connection.close()


if __name__ == "__main__":
    main()
