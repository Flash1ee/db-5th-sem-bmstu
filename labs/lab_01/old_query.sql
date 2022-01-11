CREATE TABLE events (
    id SERIAL NOT NULL PRIMARY KEY,
    year INTEGER,
    country VARCHAR(32),
    city VARCHAR(16),
    location VARCHAR(32),
    broadcaster VARCHAR(4),
    date DATE,
    durability DATE
);

CREATE TABLE performers (
    id SERIAL NOT NULL PRIMARY KEY,
    firstname VARCHAR(16),
    lastname VARCHAR(16),
    country VARCHAR(16),
    gender VARCHAR(8)
);

CREATE TABLE events_performers (
    id SERIAL PRIMARY KEY NOT NULL,
    event_id INTEGER NOT NULL REFERENCES events(id),
    performers_id INTEGER NOT NULL REFERENCES performers(id)
);

CREATE TABLE votes (
    id SERIAL NOT NULL PRIMARY KEY,
    country_from VARCHAR(16),
    country_to VARCHAR(16),
    points INTEGER,
    type VARCHAR(8),
    event_id INTEGER NOT NULL,
    FOREIGN KEY(event_id) REFERENCES EVENTS(id) ON DELETE CASCADE
);



CREATE TABLE songs (
    id INTEGER PRIMARY KEY NOT NULL,
    performer_id INTEGER NOT NULL,
    song VARCHAR(64),
    durability TIME,
    YEAR INTEGER,
    foreign key (performer_id) REFERENCES performers(id) ON DELETE CASCADE
);

    SELECT distinct category_name from crowdfunding.public.content
