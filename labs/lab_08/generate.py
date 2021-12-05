import datetime
from time import sleep
import json
import os

from faker import Faker

faker = Faker('ru')

# constants
N = 10
SLEEP = 60
# -------------------------------
counter = 0
date_mask = "%Y-%m-%d-%H.%M.%S"
file_mask = "{}_{}_{}.json"
dir = "./data/"


def gen_filename(tablename):
    global counter
    name = file_mask.format(counter, tablename, datetime.datetime.now().strftime(date_mask))
    return name


def generate_donators(count):
    donators = []
    for i in range(count):
        user = faker.simple_profile()
        fio = user['name'].split()
        age = faker.date()
        donator = {
            "first_name": fio[1],
            "second_name": fio[0],
            "login": user["username"],
            "password": faker.password(),
            "account": str(faker.random_int(0, 5000)),
            "sex": user["sex"],
            "age": age,
        }
        donators.append(donator)
    return json.dumps(donators, ensure_ascii=False)


def main():
    global counter
    table = "donators"
    if not os.path.exists(dir):
        os.makedirs(dir)
    while True:
        fname = gen_filename(table)
        with open(dir + fname, "w", encoding='utf-8') as file:
            file.write(generate_donators(N))
        counter += 1
        sleep(5)


if __name__ == "__main__":
    main()
