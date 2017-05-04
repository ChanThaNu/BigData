category = LOAD 'category.csv' USING PigStorage(',') as
(category_id:int,name:chararray); 

film_category = LOAD 'film_category.csv' USING PigStorage(',') as 
(film_id: int, category_id: int);

film = LOAD 'film.csv' USING PigStorage(',') as 
(film_id:int, title:chararray,description:chararray,release_year:int,language_id:int,rental_duration:int,rental_rate:double,length:int,replacement:double,rating:chararray,special_feature:chararray);

table1 = JOIN category BY category_id, film_category BY category_id;
table2 = JOIN table1 BY film_category::film_id, film BY film_id;

foreach_data = FOREACH table2 GENERATE 
    table1::category::name AS category_name,table1::film_category::film_id AS film_id,table1::category::category_id AS category_id,film::length AS film_length;

grouping = GROUP foreach_data BY category_name;

avg = FOREACH grouping GENERATE
      group AS category_name,
      ROUND_TO(AVG(foreach_data.film_length), 2) AS avg_film_length;

result = ORDER avg BY category_name;

dump result
