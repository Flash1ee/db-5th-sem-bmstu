import time

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy import Column, Integer, ForeignKey, Text, Numeric, CheckConstraint, Date
from citext import CIText

Base = declarative_base()

SEX_CONSTRAINT = "(\"F\", \"M\")"
CATEGORY_CONSTRAINT = \
    "('подкасты', 'творчество', \
    'блог', 'еда', 'путешествия', \
    'разработка игр', 'музыка', 'дизайн', 'разработка')"


class Donators(Base):
    __tablename__ = 'donators'
    id = Column(Integer, unique=True, primary_key=True, autoincrement=True)
    first_name = Column(Text)
    second_name = Column(Text)
    login = Column(Text)
    password = Column(Text)
    account = Column('account', Numeric, CheckConstraint("account >= 0"))
    sex = Column('sex', Text, CheckConstraint(f"sex in {SEX_CONSTRAINT}"))
    age = Column('age', Date)



class Creators(Base):
    __tablename__ = 'creators'
    id = Column(Integer, unique=True, primary_key=True, autoincrement=True)
    first_name = Column(Text)
    second_name = Column(Text)
    email = Column(CIText)
    login = Column(Text)
    password = Column(Text)
    sex = Column('sex', Text, CheckConstraint(f"sex in {SEX_CONSTRAINT}"))


class Content(Base):
    __tablename__ = 'content'
    id = Column(Integer, unique=True, primary_key=True, autoincrement=True)
    description = Column(Text, nullable=False)
    category_name = Column("category_name", Text, CheckConstraint(f"category_name in {CATEGORY_CONSTRAINT}"))


class Donators_Content(Base):
    __tablename__ = 'donators_content'
    id = Column(Integer, unique=True, primary_key=True, autoincrement=True)
    donators_id = Column(Integer, ForeignKey("donators.id", ondelete="CASCADE"), nullable=False)
    content_id = Column(Integer, ForeignKey('content.id', ondelete="CASCADE"), nullable=False)

    donators = relationship("Donators")
    content = relationship("Content")


class Payments(Base):
    __tablename__ = 'payments'
    id = Column(Integer, unique=True, primary_key=True, autoincrement=True)
    amount = Column(Numeric, nullable=False)
    date = Column(Date, default=time.time())
    donators_id = Column(Integer, ForeignKey("donators.id", ondelete="CASCADE"), nullable=False)
    content_id = Column(Integer, ForeignKey("content.id", ondelete="CASCADE"), nullable=False)

    donators = relationship("Donators")
    content = relationship("Content")
