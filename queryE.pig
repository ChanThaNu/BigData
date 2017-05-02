staff = LOAD '/user/hduser/project4/input/staff.csv'
        USING PigStorage(',')
        AS (staff_id:int,
            fname:chararray,
            lname:chararray,
            address_id:int,
            email:chararray,
            store_id:int,
            active:int,
            username:chararray,
            password:chararray);

film = LOAD '/user/hduser/project4/input/film.csv'
      USING PigStorage(',')
       AS (film_id:int,
           title:chararray,
           description:chararray,
           release_year:int,
           language_id:int,
           rental_duration:int,
           rental_rate:double,
           length:int,
           replacement_cost:double,
           rating:chararray,
           special_features:chararray);

inventory = LOAD '/user/hduser/project4/input/inventory.csv'
            USING PigStorage(',')
            AS (inventory_id:int,
                film_id:int,
                store_id:int);

rental = LOAD '/user/hduser/project4/input/rental.csv'
         USING PigStorage(',')
         AS (rental_id:int,
             rental_date:chararray,
             inventory_id:int,
             customer_id:int,
             return_date:chararray,
             staff_id:int);

stores = LOAD '/user/hduser/project4/input/store.csv'
         USING PigStorage(',')
         AS (store_id:int, address_id:int);

-- get Mike
mike = FILTER staff BY (fname matches '^Mike');
-- get the rented which are more than 10 days
rented = FILTER rental
         BY DaysBetween(
             ToDate(REPLACE(return_date, '\\s+', ' '), 'yyyy-MM-dd HH:mm:ss'),
             ToDate(REPLACE(rental_date, '\\s+', ' '), 'yyyy-MM-dd HH:mm:ss')
             ) + 1 == 10;
-- we need the inventory_ids only
rented_inventory = FOREACH rented GENERATE inventory_id as inventory_id:int;
-- get inventory by store, only inventory_id, film_id are needed:
film_inventory = FOREACH (JOIN mike BY store_id, stores BY store_id, inventory by store_id)
                 GENERATE inventory_id, film_id;
-- get unique ids
unique_films = DISTINCT (
    FOREACH (JOIN rented_inventory BY inventory_id, film_inventory BY inventory_id)
    GENERATE film_id AS film_id:int);
-- get the count
final = FOREACH (GROUP unique_films ALL)
        GENERATE COUNT(unique_films);

dump final