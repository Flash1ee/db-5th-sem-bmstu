import datetime

import db_connection, random

CACHE_KEY = "cache"

QUERY_COUNT_CONTENT = "SELECT reltuples::bigint AS estimate FROM pg_class WHERE oid = 'content'::regclass;"

QUERY_COUNT_AWARDS = "SELECT reltuples::bigint AS estimate FROM pg_class WHERE oid = 'awards'::regclass;"

QUERY_COUNT_POSTS = "SELECT count(*) from posts where title = 'test post';"

QUERY_GET_ID_TEST_POSTS = "SELECT id from posts where title = 'test post';"

QUERY_TOP_CATEGORY = "select category_name, count(*) as cnt from content " \
                     "join posts p on content.id = p.content_id " \
                     "group by category_name " \
                     "order by cnt desc;"

QUERY_DELETE_LAST_POST = "delete from posts where id = (select id from posts where title = 'test post' order by date desc limit 1) returning id;"
QUERY_ADD_POST = "insert into posts(title, body, age_restriction, content_id, awards_id) values ('{}', '{}', {}, {}, {}) returning id;"
QUERY_CHANGE_POST = "update posts set body = 'change data' where id = {};"


def get_top_categories(connection, r):
    data = "Top Categories: "
    cursor = db_connection.execute_query(connection, QUERY_TOP_CATEGORY)
    if cursor is not None:
        res = cursor.fetchall()
        for category in res:
            data += category[0] + ", "
        data = data.rstrip(", ")

    return data

def get_top_categories_cache(connection, r):
    data = "Top Categories: "
    redis_cache = r.get(CACHE_KEY)
    if redis_cache is not None:
        print("DATA FROM CACHE")
        return redis_cache.decode("utf-8")
    else:
        return "NO DATA IN CACHE"

    cursor = db_connection.execute_query(connection, QUERY_TOP_CATEGORY)
    if cursor is not None:
        res = cursor.fetchall()
        for category in res:
            data += category[0] + ", "
        data = data.rstrip(", ")

    r.set(CACHE_KEY, data)

    return data


def delete_last_post(connection, r):
    data = "Success deleted post with id = {}"
    res = db_connection.execute_query(connection, QUERY_DELETE_LAST_POST)
    res = res.fetchall()
    if len(res) == 0:
        return "NO TEST POSTS"
    r.expire(CACHE_KEY, datetime.timedelta(seconds=0))

    return data.format(res[0][0])


def add_post(connection, r):
    data = "Success add post - id = {}"
    res_content = db_connection.execute_query(connection, QUERY_COUNT_CONTENT).fetchall()
    content_id = random.randint(0, res_content[0][0])

    res_awards = db_connection.execute_query(connection, QUERY_COUNT_AWARDS).fetchall()
    awards_id = random.randint(0, res_awards[0][0])

    query = QUERY_ADD_POST.format("test post", "lab_09 testing", 18, content_id, awards_id)
    res = db_connection.execute_query(connection, query)

    r.expire(CACHE_KEY, datetime.timedelta(seconds=0))

    return data.format(res.fetchall()[0][0])


def change_post(connection, r):
    data = "Success change post with id = {}"
    posts_ids = []
    posts = db_connection.execute_query(connection, QUERY_GET_ID_TEST_POSTS).fetchall()
    for row in posts:
        posts_ids.append(row[0])
    id = random.randint(0, len(posts_ids) - 1)

    res = db_connection.execute_query(connection, QUERY_CHANGE_POST.format(posts_ids[id]))

    r.expire(CACHE_KEY, datetime.timedelta(seconds=0))

    return data.format(posts_ids[id])
