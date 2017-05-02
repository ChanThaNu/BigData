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


category = LOAD '/user/hduser/project4/input/category.csv' USING PigStorage(',') as
(category_id:int,name:chararray); 


film_category = LOAD '/user/hduser/project4/input/film_category.csv' USING PigStorage(',') as 
(film_id: int, category_id: int);

relation1 = JOIN category BY category_id, film_category BY category_id;
relation2 = JOIN relation1 BY film_category::film_id, film BY film_id;

foreach_data = FOREACH relation2 GENERATE
    relation1::category::category_id AS category_id,
    relation1::category::name AS category_name,
    relation1::film_category::film_id AS film_id,
    film::length AS film_length;

gp = GROUP foreach_data BY category_name;

avg = FOREACH gp GENERATE
      group AS category_name,
      ROUND_TO(AVG(foreach_data.film_length), 2) AS avg_film_length;

result = ORDER avg BY category_name;

dump result
