import time

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
import json

from db.viewes import linq_to_object

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
                    for rows in linq_to_object(session)[QUERIES[action]]:
                        for row in rows:
                            print(row)
                    session.commit()
                else:
                    print("Error input action")

if __name__ == "__main__":
    main()