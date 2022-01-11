import time

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy import Column, Integer, ForeignKey, Text, CheckConstraint, Date, Time

Base = declarative_base()

DAYS_CONSTRAINT = \
    "('Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье')"


class Employers(Base):
    __tablename__ = 'employers'
    id = Column(Integer, unique=True, primary_key=True, autoincrement=True)
    fio = Column(Text, nullable=False)
    date = Column(Date, default=time.time())
    departament = Column(Text)

    employer_time = relationship("EmployerTime")


class EmployerTime(Base):
    __tablename__ = 'EmployerTime'

    id = Column(Integer, ForeignKey("employers.id", ondelete="CASCADE"), primary_key=True, nullable=False)
    date = Column(Date, default=time.time())
    days = Column(Text, CheckConstraint(f"days in {DAYS_CONSTRAINT}"), nullable=False)
    action_time = Column("time", Time, default=time.time())
    action_type = Column("type", Integer, CheckConstraint("type = 1 or type = 2"))

create or replace function get_number_of_employers()
    RETURNS bigint as
$$
BEGIN
    return (select *
            from employers
            where current_time - birthday BETWEEN (18, 40)
                      and (select count(*) from employer_time group by id) > 3
    );
end;
$$ language plpgsql;