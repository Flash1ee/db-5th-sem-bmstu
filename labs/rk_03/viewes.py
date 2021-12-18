from models import Employers, EmployerTime
from sqlalchemy import func, select, insert, delete, update



def task_01_sql(session):
    return session.execute("select departament from employers group by departament having count(*) > 10;")


def task_01(session):
    return [row.departament for row in
            session.query(Employers.departament).group_by(Employers.departament).having(func.count("*") > 10)]

def task_02_sql(session):
    return session.execute("select id, fio from employers where id not in ( select id from employer_time group by id, date, type having type = 2);")

def task_02(session):
    return [[row.id, row.fio] for row in
            session.query(Employers.id, Employers.fio).
                    where(Employers.id not in
                          (session.query(EmployerTime.id).group_by(Employers.id, Employers.date, Employers.type).having(Employers.type == 2)))]