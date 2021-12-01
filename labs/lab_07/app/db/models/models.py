from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, ForeignKey, Text, Numeric, CheckConstraint, Date
from citext import CIText

Base = declarative_base()

SEX_CONSTRAINT = "(\"F\", \"M\")"
CATEGORY_CONSTRAINT = \
    "('подкасты', 'творчество', \
    'блог', 'еда', 'путешествия', \
    'разработка игр', 'музыка', 'дизайн', 'разработка')"


class Donators(Base):
    id = Column(Integer, unique=True, primary_key=True, autoincrement=True)
    first_name = Column(Text)
    second_name = Column(Text)
    login = Column(Text)
    password = Column(Text)
    account = Column('account', Numeric, CheckConstraint("account >= 0"))
    sex = Column('sex', Text, CheckConstraint(f"sex in {SEX_CONSTRAINT}"))
    age = Column('age', Date)


class Creators(Base):
    id = Column(Integer, unique=True, primary_key=True, autoincrement=True)
    first_name = Column(Text)
    second_name = Column(Text)
    email = Column(CIText)
    login = Column(Text)
    password = Column(Text)
    sex = Column('sex', Text, CheckConstraint(f"sex in {SEX_CONSTRAINT}"))


class Content(Base):
    id = Column(Integer, unique=True, primary_key=True, autoincrement=True)
    description = Column(Text, nullable=False)
    category_name = Column("category_name", Text, CheckConstraint(f"category_name in {CATEGORY_CONSTRAINT}"))


class Donators_Content(Base):
    id = Column(Integer, unique=True, primary_key=True, autoincrement=True)
    donators_id = Column(Integer, ForeignKey("donators.id", ondelete="CASCADE"), nullable=False)
    content_id = Column(Integer, ForeignKey('content.id', ondelete="CASCADE"), nullable=False)
