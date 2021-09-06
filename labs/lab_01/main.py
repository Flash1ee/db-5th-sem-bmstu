import json

cfg = json.load(open("config.json"))

DB_INFO = cfg['db']

import psycopg2
from psycopg2 import OperationalError


def init():
    connection = create_connection(
        DB_INFO['name'], DB_INFO['user'],
        DB_INFO['password'], DB_INFO['host'],
        DB_INFO['name']
    )

    create_database_query = "CREATE DATABASE {dbname}"
    create_database(connection, create_database_query)


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
