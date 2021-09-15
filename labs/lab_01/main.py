import json

import psycopg2
from psycopg2 import OperationalError
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

cfg = json.load(open("config.json"))

DB_INFO = cfg['db']


def table_exists(con, table_str):
    exists = False
    try:
        cur = con.cursor()
        cur.execute("select exists(select relname from pg_class where relname='" + table_str + "')")
        exists = cur.fetchone()[0]
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


def connect():
    connection = psycopg2.connect(
        user=DB_INFO['user'],
        password=DB_INFO['password'],
        host=DB_INFO['host'],
        port=DB_INFO['port'],
        database=DB_INFO['name']
    )

    connection.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    return connection


def create_database():
    connection = psycopg2.connect(
        user=DB_INFO['user'],
        password=DB_INFO['password'],
        host=DB_INFO['host'],
        port=DB_INFO['port']
    )
    connection.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)

    cursor = connection.cursor()

    print(f"Server version {cursor.fetchone()}")

    create_database_query = f"CREATE DATABASE {DB_INFO['name']}"
    cursor.execute(create_database_query)
    print(f"table {DB_INFO['name']} successfully created")

    return connection


def main():
    connection = False
    try:
        connection = create_database()
    except psycopg2.Error as e:
        print(f"[INFO] database {DB_INFO['name']} exist")
        connection = connect()
        connection.autocommit = True
        # with open('query.sql', 'r') as f:
        #     cursor = connection.cursor()
        #     cursor.execute("\n".join(f.readlines()))
        #     print(f"[INFO] database {DB_INFO['name']} successfully filling")
    finally:
        if connection:
            connection.close()
            print("[INFO] Connection close.")


if __name__ == "__main__":
    main()
