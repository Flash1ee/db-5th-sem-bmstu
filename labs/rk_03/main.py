import time

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
import json

from viewes import task_01, task_01_sql, task_02, task_02_sql

cfg = json.load(open("./config.json"))
DB_INFO = cfg['db']

engine = create_engine(
    f'postgresql://{DB_INFO["user"]}:{DB_INFO["password"]}@{DB_INFO["host"]}:{DB_INFO["port"]}/{DB_INFO["name"]}',
    pool_pre_ping=True)

Session = sessionmaker(bind=engine)


def menu():
    choices = \
        '''
    1 - Найти все отделы, в которых работает более 10 сотрудников.
    2 - Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня.
    3 - Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату. Дату передавать с клавиатуры
    -1- Завершить работу.
    '''
    print(choices)


QUERIES = [1, 2, 3, 4]


def main():
    is_work = True
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
                    if action == 1:
                        res = task_01(session)
                    if action == 2:
                        res = task_01_sql(session)
                    if action == 3:
                        res = task_02(session)
                    if action == 4:
                        res = task_02_sql(session)
                        print(res)
                    session.commit()
                else:
                    print("Error input action")


if __name__ == "__main__":
    main()
