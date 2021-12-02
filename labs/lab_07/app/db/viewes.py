from .models.models import Creators, Donators, Payments, Content
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
                [[row.amount, row.date.date().strftime('%d/%m/%y %I:%M %S %p'), row.donators.login, row.content.category_name] for row in
                 session.query(Payments).join(Payments.donators).join(Payments.content).
                     order_by(Payments.date.desc()).limit(10)]

            ],
    }
