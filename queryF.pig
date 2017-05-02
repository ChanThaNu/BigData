
film_actors = LOAD '/user/hduser/project4/input/film_actor.csv'
        USING PigStorage(',')
        AS (actor_id:long, film_id:long);

actors = LOAD '/user/hduser/project4/input/actor.csv' 
        USING PigStorage(',')
        AS (actor_id:long, fname:chararray, lname:chararray);


actor_counts = FOREACH (GROUP film_actors BY film_id)
               GENERATE
                   group as film_id:long,
                   COUNT(film_actors.$0) as actor_count:long;


sorted_actor_counts = ORDER actor_counts BY actor_count DESC;

max_actor_counts = LIMIT sorted_actor_counts 1;

films_max_actor_counts = FOREACH (
                        JOIN sorted_actor_counts BY actor_count,
                        max_actor_counts BY actor_count)
                        GENERATE
                             sorted_actor_counts::film_id AS film_id:long;

actor_ids = DISTINCT (FOREACH (
                        JOIN film_actors BY film_id,
                             films_max_actor_counts BY film_id)
                      GENERATE
                          film_actors::actor_id AS actor_id:long);

actor_names = FOREACH (JOIN actors BY actor_id, actor_ids BY actor_id)
              GENERATE
                  actors::actor_id AS actor_id:long,
                  actors::fname AS first_name:chararray,
                  actors::lname AS last_name:chararray;

ordered_actors = ORDER actor_names BY last_name, first_name;

dump ordered_actors