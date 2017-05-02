film = LOAD '/user/hduser/project4/input/film.csv'
       USING PigStorage(',')
       AS (film_id: int,
           title: chararray,
           description: chararray,
           release_year: int,
           language: int,
           rental_duration: int,
           rental_rate: double,
           length: int,
           relacement_cost: double,
           rating: chararray,
           special_features: chararray);

film_actor = LOAD '/user/hduser/project4/input/film_actor.csv'
       USING PigStorage(',')
       AS (actor_id: int,
       film_id: int);

actor = LOAD '/user/hduser/project4/input/actor.csv'
       USING PigStorage(',')
       AS (actor_id: int,
           first_name: chararray,
           last_name: chararray);

language = LOAD '/user/hduser/project4/input/language.csv'
       USING PigStorage(',')
       AS (language_id: int,
           name: chararray);

table1 = JOIN film_actor BY film_id, film BY film_id;
table2 = JOIN table1 BY film::language, language BY language_id;
table3 = JOIN table2 BY table1::film_actor::actor_id, actor BY actor_id;

table4 = FOREACH table3 GENERATE
  table2::table1::film_actor::actor_id AS actor_id,
  table2::table1::film_actor::film_id AS film_id,
  table2::language::language_id AS language_id,
  table2::language::name AS language_name,
    actor::last_name AS last_name;

table5 = FILTER table4 BY (language_name matches 'English');

table6 = GROUP table5 BY actor_id;
count = FOREACH table6
        GENERATE
        group AS actor_id,
        COUNT(table5) AS actor_count;

table7 = ORDER count BY actor_count DESC;

table8 = LIMIT table7 1;

table9 = JOIN table8 BY actor_id, actor BY actor_id;
result = FOREACH table9 GENERATE
         actor::last_name AS last_name,
         actor::actor_id AS actor_id,
         table8::actor_count AS count;

dump result