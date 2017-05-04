film_actors = LOAD 'film_actor.csv' USING PigStorage(',')
              AS (actor_id:long, film_id:long);
actors = LOAD 'actor.csv' USING PigStorage(',')
         AS (actor_id:long, fname:chararray, lname:chararray);
foreach_data = FOREACH (GROUP film_actors BY film_id)
               GENERATE group AS film_id:long,
                        COUNT(film_actors) AS actor_count:long;
sorted_actor_counts = ORDER foreach_data BY actor_count DESC;
largest_actor_counts = LIMIT sorted_actor_counts 1;
table1 = JOIN sorted_actor_counts BY actor_count, largest_actor_counts BY actor_count USING 'replicated';
films_max_actor_counts = FOREACH table1 GENERATE sorted_actor_counts::film_id AS film_id;
table1 = JOIN film_actors BY film_id, films_max_actor_counts BY film_id USING 'replicated';
actor_ids = FOREACH table1 GENERATE film_actors::actor_id AS actor_id;
actor_ids = DISTINCT actor_ids;
table1 = JOIN actors BY actor_id, actor_ids BY actor_id USING 'replicated';
actor_names = FOREACH table1
              GENERATE actors::fname as first_name,
                       actors::lname as last_name;
result = ORDER actor_names BY last_name, first_name;

dump result