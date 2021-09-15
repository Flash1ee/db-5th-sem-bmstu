import os
import random

from faker import Faker
import csv
import uuid

cur_dir = os.path.abspath(os.getcwd()) + "/data"
print(cur_dir)
COUNT = 3000
faker = Faker('ru')

category_names = ['подкасты', 'творчество',
                  'блог', 'еда', 'путешествия',
                  'разработка игр', 'музыка', "дизайн", 'разработка']
AWARDS_PRICE = [0, 100, 500, 1000, 3000, 5000]


def generate_donators(count):
    donators = []
    for i in range(count):
        user = faker.simple_profile()
        fio = user['name'].split()
        donator = [fio[1], fio[0], user['username'], faker.password(), str(faker.random_int(0, 5000)), user['sex']]
        donators.append(donator)
    return donators


def generate_creators(count):
    creators = []
    for i in range(count):
        user = faker.simple_profile()
        fio = user['name'].split()
        creator = [fio[1], fio[0], user['mail'], user['username'], faker.password(),
                   user['sex']]
        creators.append(creator)
    return creators


def generate_content(count):
    content = []
    for i in range(count):
        category = faker.word(category_names)
        description = faker.paragraph()
        content.append([description, category])
    return content


def generate_posts(count, count_contents):
    posts = []
    for i in range(count):
        content_id = random.randrange(1, count_contents + 1)
        title = faker.sentence()
        body = faker.paragraph()
        date = faker.date()
        posts.append([title, body, date, content_id])
    return posts


def generate_payments(count, count_content, count_donators):
    payments = []
    for i in range(count):
        amount = faker.random_int(0, 1000 * 5)
        date = faker.date()
        donators_id = faker.random_int(1, count_donators)
        content_id = faker.random_int(1, count_content)
        payments.append([amount, date, donators_id, content_id])
    return payments


def generate_awards(count, count_posts):
    awards = []
    for i in range(count):
        price = AWARDS_PRICE[faker.random_int() % len(AWARDS_PRICE)]
        title = faker.sentence()
        description = faker.paragraph()
        count = faker.random_int(1, 100)
        posts_id = faker.random_int(1, count_posts)
        awards.append([price, title, description, count, posts_id])
    return awards


def donators_content(count, count_donators, count_content):
    donators_content = []
    for i in range(count):
        donator_id = faker.random_int(1, count_donators)
        content_id = faker.random_int(1, count_content)
        donators_content.append([donator_id, content_id])
    return donators_content


def main():
    count = {
        "content": 0,
        "donators": 0,
        "posts": 0,
    }

    try:
        os.mkdir(cur_dir)
    except:
        print("Directory /data exists")

    with open(str(cur_dir + "/donators.csv"), "w") as donators_file:
        donators_writer = csv.writer(donators_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        donators = generate_donators(COUNT)

        count['donators'] = len(donators)

        for i in range(len(donators)):
            donators_writer.writerow(donators[i])

    with open(str(cur_dir + "/creators.csv"), "w") as creators_file:
        creators_writer = csv.writer(creators_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        creators = generate_creators(COUNT)
        for i in range(len(creators)):
            creators_writer.writerow(creators[i])

    with open(str(cur_dir + "/content.csv"), "w") as content_file:
        content_writer = csv.writer(content_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        content = generate_content(COUNT)

        count['content'] = len(content)

        for i in range(len(content)):
            content_writer.writerow(content[i])

    with open(str(cur_dir + "/posts.csv"), "w") as posts_file:
        posts_writer = csv.writer(posts_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        posts = generate_posts(COUNT, count['content'])

        count['posts'] = len(posts)

        for i in range(len(posts)):
            posts_writer.writerow(posts[i])

    with open(str(cur_dir + "/payments.csv"), "w") as payments_file:
        payments_writer = csv.writer(payments_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        payments = generate_payments(COUNT, count['content'], count['donators'])
        for i in range(len(payments)):
            payments_writer.writerow(payments[i])

    with open(str(cur_dir + "/awards.csv"), "w") as awards_file:
        awards_writer = csv.writer(awards_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        awards = generate_awards(COUNT, count['posts'])
        for i in range(len(awards)):
            awards_writer.writerow(awards[i])

    with open(str(cur_dir + "/donators_content.csv"), "w") as donators_content_file:
        donators_content_writer = csv.writer(donators_content_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        table = donators_content(COUNT, count['donators'], count['content'])
        for i in range(len(table)):
            donators_content_writer.writerow(table[i])
if __name__ == "__main__":
    main()
