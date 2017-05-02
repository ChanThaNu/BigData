category = LOAD '/user/hduser/project4/input/category.csv' USING PigStorage(',') as
(category_id:int,name:chararray);

film_category = LOAD '/user/hduser/project4/input/film_category.csv' USING PigStorage(',') as 
(film_id: int, category_id: int);

film = LOAD '/user/hduser/project4/input/film.csv' USING PigStorage(',') as 
(film_id:int, title:chararray,
description:chararray,
release_year:int,
language_id:int,
rental_duration:int,
rental_rate:double,
length:int,
replacement:double,
rating:chararray,
special_feature:chararray);

connect1 = JOIN category BY category_id, film_category BY category_id;
connect2 = JOIN connect1 BY film_category::film_id, film BY film_id;

x = FOREACH connect2
    GENERATE
        connect1::category::category_id AS category_id,
        connect1::category::name AS category_name,
        connect1::film_category::film_id AS film_id,
        film::length AS film_length;

avg = FOREACH (GROUP x BY (category_id, category_name))
      GENERATE
          FLATTEN(group),
          ROUND_TO(AVG(x.film_length), 2) AS avg_length;

-- get max/min
limit_min = LIMIT (ORDER avg BY avg_length) 1;
limit_max = LIMIT (ORDER avg BY avg_length DESC) 1;

set default_parallel 1;
result = UNION limit_max, limit_min;

--gpResult = GROUP result BY 1;

finalResult = FOREACH (GROUP result BY 1)
              GENERATE
                  FLATTEN(result)
              AS (category_id, category_name, avg_length);

dump finalResult

