--loading category
category = LOAD 'category.csv' USING PigStorage(',') as (category_id:int,name:chararray);
--loading film_category
film_category = LOAD 'film_category.csv' USING PigStorage(',') as (film_id: int, category_id: int);
--loading film
film = LOAD 'film.csv' USING PigStorage(',') as (film_id:int, title:chararray,description:chararray,release_year:int,language_id:int, rental_duration:int,rental_rate:double,length:int,replacement:double,rating:chararray,special_feature:chararray);

--Joining table1 and table2
table1 = JOIN category BY category_id, film_category BY category_id;
table2 = JOIN table1 BY film_category::film_id, film BY film_id;
--looping data
foreach_data = FOREACH table2
    GENERATE
        table1::category::category_id AS category_id,
        table1::category::name AS category_name,
        table1::film_category::film_id AS film_id,
        film::length AS film_length;

--avgValue = FOREACH (GROUP foreach_data BY (category_id, category_name))
avgValue = FOREACH (GROUP foreach_data BY (category_name))
      GENERATE
          FLATTEN(group),
          ROUND_TO(AVG(foreach_data.film_length), 2) AS avg_length;
--limiting min and max values
minimum = LIMIT (ORDER avgValue BY avg_length) 1;
maximum = LIMIT (ORDER avgValue BY avg_length DESC) 1;
--setting default value
set default_parallel 1;
result = UNION maximum, minimum;

--getting finalResult

finalResult = FOREACH (GROUP result BY 1)
              GENERATE
                  FLATTEN(result)
              AS (category_name, avg_length);
              --AS (category_id, category_name, avg_length);

dump finalResult

