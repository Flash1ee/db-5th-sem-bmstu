from .models.models import Creators, Donators, Payments, TbJson
from sqlalchemy import func


# LINQ_TO_OBJECTS
def linq_to_object(session):
    return {
        "SELECT first_name, second_name, login from creators;":
            [
                [row.first_name, row.second_name, row.login] for row in session.query(Creators).all()
            ],
        "SELECT first_name, second_name, login from creators where sex = 'F';":
            [
                [row.first_name, row.second_name, row.login] for row in
                session.query(Creators).where(Creators.sex == "F")
            ],
        "SELECT count(*) as cnt from donators where sex = 'F';":
            [
                [session.query(Donators.id).count()]
            ],
        "SELECT AVG(amount) as avg_amount from payments;":
            [
                [row.avg_amount for row in session.query(func.avg(Payments.amount).label("avg_amount"))][0]
            ],
        "SELECT amount, date, d.login, c.category_name from payments "
        "join donators d on payments.donators_id = d.id "
        "join content c on payments.content_id = c.id order by date DESC limit 10;":
            [
                [[row.amount, row.date.date().strftime('%d/%m/%y %I:%M %S %p'), row.donators.login,
                  row.content.category_name] for row in
                 session.query(Payments).join(Payments.donators).join(Payments.content).
                     order_by(Payments.date.desc()).limit(10)]

            ],
    }


def linq_to_json():
    def get_all_data(session):
        return [[row.id, row.data] for row in session.query(TbJson).all()]

    def insert_into_json_table(session):
        try:
            new_id = int(input("Input data id: "))
            login = input("Input login: ")
            firstname = input(("Input firstname: "))
            data = {"id": new_id, "user": {"login": login, "firstname": firstname}}
            newRow = TbJson(data = data)
            session.add(newRow)
            session.commit()
            return get_all_data(session)
        except:
            print("error input data")
            return

    def update_json_table(session):
        id = -1
        try:
            id = int(input("Input row id"))
            if id <= 0:
                raise Exception
        except:
            print("invalid id")
            return
        else:
            exists = session.query(
                session.query(TbJson).where(TbJson.id == id).exists()
            ).scalar()
            if not exists:
                print("row not exists")
                return
            else:
                try:
                    new_id = int(input("Input data id: "))
                    login = input("Input login: ")
                    firstname = input(("Firstname: "))
                    data = {"id" : new_id, "user" : {"login" : login, "firstname" : firstname}}
                    row = session.query(TbJson).get(id)
                    row.data = data
                    session.commit()
                    return [["id = " + str(row.id), "data = " + str(row.data)]]
                except:
                    print("error input data")
                    return

    return {
        "SELECT data from tb_json;": get_all_data,
        "UPDATE tb_json SET data = {} where id = {}": update_json_table,
        "INSERT INTO tb_json(data) VALUES ({});": insert_into_json_table,
    }
