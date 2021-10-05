DROP DATABASE IF EXISTS crowdfunding;
CREATE DATABASE crowdfunding;

\c crowdfunding;

create extension CITEXT;
create type category_type as enum ('подкасты', 'творчество',
    'блог', 'еда', 'путешествия',
    'разработка игр', 'музыка', 'дизайн', 'разработка');


CREATE TABLE donators
(
    id          BIGSERIAL NOT NULL PRIMARY KEY,
    first_name  TEXT,
    second_name TEXT,
    login       TEXT,
    password    TEXT,
    account     NUMERIC,
    sex         TEXT check (sex in ('F', 'M')),
    age         DATE,
    CHECK (id > 0),
    CHECK (account >= 0)
);

\COPY donators FROM './data/donators.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE creators
(
    id          BIGSERIAL NOT NULL PRIMARY KEY,
    first_name  TEXT,
    second_name TEXT,
    email       CITEXT,
    login       TEXT,
    password    TEXT,
    sex         TEXT check (sex in ('F', 'M')),
    CHECK (id > 0)
);
\COPY creators FROM './data/creators.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE content
(
    id            BIGSERIAL NOT NULL unique PRIMARY KEY references creators (id),
    description   TEXT,
    category_name category_type,
    CHECK (id > 0)
);
\COPY content FROM './data/content.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE awards
(
    id          BIGSERIAL NOT NULL PRIMARY KEY,
    price       NUMERIC,
    title       TEXT,
    description TEXT,
    count       INTEGER check (count >= 0),
    CHECK (id > 0),
    CHECK (price >= 0 )

);
\COPY awards FROM './data/awards.csv' DELIMITER ',' CSV HEADER;


CREATE TABLE posts
(
    id              BIGSERIAL NOT NULL PRIMARY KEY,
    title           TEXT,
    body            TEXT,
    date            timestamptz,
    age_restriction INTEGER,
    content_id      INTEGER   NOT NULL REFERENCES content (id) ON DELETE CASCADE,
    awards_id       INTEGER   NOT NULL REFERENCES awards (id) ON DELETE CASCADE,
    CHECK (id > 0),
    CHECK (age_restriction >= 0)
);

\COPY posts FROM './data/posts.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE payments
(
    id          BIGSERIAL NOT NULL PRIMARY KEY,
    amount      NUMERIC,
    date        timestamptz,
    donators_id INTEGER   NOT NULL references donators (id) ON DELETE CASCADE,
    content_id  INTEGER   NOT NULL references content (id) ON DELETE CASCADE,
    CHECK (id > 0),
    CHECK (amount >= 0)
);
\COPY payments FROM './data/payments.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE donators_content
(
    id          BIGSERIAL NOT NULL PRIMARY KEY,
    donators_id INTEGER   NOT NULL REFERENCES donators (id) ON DELETE CASCADE,
    content_id  INTEGER   NOT NULL REFERENCES content (id) ON DELETE CASCADE
);
\COPY donators_content FROM './data/donators_content.csv' DELIMITER ',' CSV HEADER;


