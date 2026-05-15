-- Active: 1778116211273@@127.0.0.1@3306@school
SELECT
    database ();

SELECT
    first_name,
    last_name,
    rating,
    title,
    released_year,
    genre
FROM
    reviewers
    JOIN reviews ON reviewers.id = reviews.reviewer_id
    JOIN series ON reviews.series_id = series.id;

SELECT
    title,
    rating
FROM
    series
    JOIN reviews ON series.id = reviews.reviewer_id
ORDER BY
    title;

SELECT
    title,
    ROUND(AVG(rating), 2) AS avg_rating
FROM
    series
    JOIN reviews ON series.id = reviews.series_id
GROUP BY
    title
ORDER BY
    avg_rating;

SELECT
    first_name,
    last_name,
    rating
FROM
    reviewers
    JOIN reviews ON reviewers.id = reviews.reviewer_id;

SELECT
    title AS unreviewed_series,
    rating
FROM
    series
    LEFT JOIN reviews ON series.id = reviews.reviewer_id
WHERE
    reviews.rating IS NULL;

SELECT
    title AS unreviewed_series,
    rating
FROM
    series
    LEFT JOIN reviews ON series.id = reviews.reviewer_id;

SELECT
    genre,
    ROUND(AVG(rating), 2) AS avg_rating
FROM
    series
    JOIN reviews ON series.id = reviews.series_id
GROUP BY
    genre;

SELECT
    first_name,
    last_name,
    ifnull (COUNT(rating), 0) AS COUNT,
    ifnull (MIN(rating), 0) AS MIN,
    ifnull (MAX(rating), 0) AS MAX,
    ifnull (ROUND(AVG(rating), 2), 0) AS AVG,
    CASE
        WHEN COUNT(rating) > 7 THEN 'POWERUSER'
        WHEN COUNT(rating) > 0 THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END as STATUS
FROM
    reviewers
    LEFT JOIN reviews ON reviewers.id = reviews.reviewer_id
GROUP BY
    first_name,
    last_name;

SELECT
    first_name,
    last_name,
    ifnull (COUNT(rating), 0) AS COUNT,
    ifnull (MIN(rating), 0) AS MIN,
    ifnull (MAX(rating), 0) AS MAX,
    ifnull (ROUND(AVG(rating), 2), 0) AS AVG,
    if (count(rating) > 0, 'ACTIVE', 'INACTIVE') as status
FROM
    reviewers
    LEFT JOIN reviews ON reviewers.id = reviews.reviewer_id
GROUP BY
    first_name,
    last_name;

select title, rating, concat(first_name, " ", last_name) as reviewer from series join reviews on series.id = reviews.series_id join reviewers on reviews.reviewer_id = reviewers.id order by title;

CREATE VIEW full_reviews AS
SELECT 
    title, released_year, genre, rating, first_name, last_name
FROM
    reviews
        JOIN
    series ON series.id = reviews.series_id
        JOIN
    reviewers ON reviewers.id = reviews.reviewer_id;

select * from full_reviews where genre = 'Animation';

CREATE VIEW ordered_series as
select * from series order by released_year;

select * from ordered_series;

insert into ordered_series (title, released_year, genre)
values ('The greate', 2020, 'Comedy');

insert into series (title, released_year, genre)
values('Test 1', 2026, 'Comedy');

select * from ordered_series;

CREATE OR REPLACE VIEW ordered_series as
select * from series order by released_year desc;

ALTER VIEW ordered_series as
select * from series order by released_year;

select * from ordered_series;

drop view ordered_series;

select * from information_schema.views where table_schema = DATABASE();

select title, avg(rating) as avg_rating from full_reviews GROUP BY title WITH ROLLUP;

select title, count(rating) from full_reviews GROUP BY title WITH ROLLUP;

select first_name, released_year, genre, avg(rating) from full_reviews GROUP BY released_year, genre, first_name with rollup;

select @@GLOBAL.sql_mode;
select @@SESSION.sql_mode;

select 3/0;

show WARNINGS;

set SESSION sql_mode = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';

set session sql_mode = DEFAULT;

select @@session.sql_mode;