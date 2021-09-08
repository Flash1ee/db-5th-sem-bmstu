import json

from psycopg2 import Error
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

cfg = json.load(open("config.json"))

DB_INFO = cfg['db']
TB_INFO = cfg['table']

import psycopg2
from psycopg2 import OperationalError
def table_exists(con, table_str):

    exists = False
    try:
        cur = con.cursor()
        cur.execute("select exists(select relname from pg_class where relname='" + table_str + "')")
        exists = cur.fetchone()[0]
        print(exists)
        # cur.close()
    except psycopg2.Error as e:
        print(e)
    return exists
def execute_query(connection, query):
    connection.autocommit = True
    cursor = connection.cursor()
    try:
        cursor.execute(query)
        print("Query executed successfully")
    except OperationalError as e:
        print(f"The error '{e}' occurred")

def init():
    try:
        connection = create_connection(
            DB_INFO['name'], DB_INFO['user'],
            DB_INFO['password'], DB_INFO['host'],
            DB_INFO['port']
        )
        connection.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)

        cursor = connection.cursor()

        create_database_query = f"CREATE DATABASE {TB_INFO['name']}"
        cursor.execute(create_database_query)
        print(f"table {TB_INFO['name']} successfully created")

    except (Exception, psycopg2.Error) as e:
        print("err:", e)
    finally:
        if connection:
            cursor.close()
            connection.close()

def create_connection(db_name, db_user, db_password, db_host, db_port):
    connection = None
    try:
        connection = psycopg2.connect(
            database=db_name,
            user=db_user,
            password=db_password,
            host=db_host,
            port=db_port
        )
        print("Connection to PostgreSQL DB successful")
    except OperationalError as e:
        print(f"The error '{e}' occurred")
    return connection


def create_database(connection, query):
    connection.autocommit = True
    cursor = connection.cursor()
    try:
        cursor.execute(query)
        print("Query executed successfully")
    except OperationalError as e:
        print(f"The error '{e}' occurred")


def main():
    init()


if __name__ == "__main__":
    main()
