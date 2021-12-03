import time

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
import json

from db.viewes import linq_to_object, linq_to_json, linq_to_sql

cfg = json.load(open("../config.json"))
DB_INFO = cfg['db']

engine = create_engine(
    f'postgresql://{DB_INFO["user"]}:{DB_INFO["password"]}@{DB_INFO["host"]}:{DB_INFO["port"]}/{DB_INFO["name"]}',
    pool_pre_ping=True)

Session = sessionmaker(bind=engine)


def menu():
    choices = \
        '''
    1 - Получить список креаторов.
    2 - Получить список креаторов - женщин.
    3 - Получить количество креаторов - мужчин.
    4 - Получить средний платеж донатера.
    5 - Получить 10 последних платежей.
    -------------------------------------
    6 - Получить все записи из таблицы с JSON.
    7 - Изменить поле user у json таблицы с заданным id.
    8 - Добавить новую строку в таблицу с json.
    --------------------------------------
    9 - Получить все записи таблицы Content в формате имя категории - описание.
    10 - Получить сумму платежей донатеров.
    11 - Добавить нового донатера.
    12 - Обновить логин донатера.
    13 - Удалить донатера из базы.
    14 - Получить иерархию наград - процедура.
    -1 - Завершить работу.
    '''
    print(choices)


QUERIES = {
    # get_creators
    1: "SELECT first_name, second_name, login from creators;",
    # get_female_creators
    2: "SELECT first_name, second_name, login from creators where sex = 'F';",
    # get_count_male_donators
    3: "SELECT count(*) as cnt from donators where sex = 'F';",
    # get_avg_payment
    4: "SELECT AVG(amount) as avg_amount from payments;",
    # get_last_10_payments
    5: "SELECT amount, date, d.login, c.category_name from payments "
       "join donators d on payments.donators_id = d.id "
       "join content c on payments.content_id = c.id order by date DESC limit 10;",
    6: "SELECT data from tb_json;",
    7: "UPDATE tb_json SET data = {} where id = {}",
    8: "INSERT INTO tb_json(data) VALUES ({});",
    9: "SELECT description, category_name FROM content;",
    10: "SELECT first_name, second_name, SUM(amount) as sum_payments FROM donators JOIN payments p on donators.id = p.donators_id " +
        "group by first_name, second_name;",
    11: "INSERT INTO donators(first_name, second_name, login) VALUES({});",
    12: "UPDATE donators SET login = {} where id = {};",
    13: "DELETE FROM donators WHERE id = {};",
    14: "CALL reverse_counter(100);",
}


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
                    if action > 5 and action < 9:
                        for rows in linq_to_json()[QUERIES[action]](session):
                            for row in rows:
                                print(row)
                    elif action < 5:
                        for rows in linq_to_object(session)[QUERIES[action]]:
                            for row in rows:
                                print(row)
                    elif action >= 9:
                        if action >= 11:
                            for row in linq_to_sql(session)[QUERIES[action]]():
                                print(row)

                        else:
                            for rows in linq_to_sql(session)[QUERIES[action]]:
                                for row in rows:
                                    print(row)
                    session.commit()
                else:
                    print("Error input action")


if __name__ == "__main__":
    main()
