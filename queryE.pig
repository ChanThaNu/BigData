staff = LOAD 'staff.csv' USING PigStorage(',')
        AS (staff_id:long,fname:chararray,lname:chararray,address_id:long,email:chararray,store_id:long,active:long,username:chararray,password:chararray);

film = LOAD 'film.csv' USING PigStorage(',')
        AS (film_id:long,title:chararray,description:chararray,release_year:long,language_id:long,rental_duration:int,rental_rate:double,length:long,replacement_cost:double,rating:chararray,special_features:chararray);

inventory = LOAD 'inventory.csv' USING PigStorage(',')
            AS (inventory_id:long,film_id:long,store_id:long);

rental = LOAD 'rental.csv' USING PigStorage(',')
         AS (rental_id:long,rental_date:chararray,inventory_id:long,customer_id:long,return_date:chararray,staff_id:long);

rented_days = FOREACH rental
                GENERATE rental_id, inventory_id,
                         ToDate(REGEX_EXTRACT(return_date, '(\\d{4}-\\d{2}-\\d{2})', 1)) AS return_date,
                         ToDate(REGEX_EXTRACT(rental_date, '(\\d{4}-\\d{2}-\\d{2})', 1)) AS rental_date;

rented_10days = FILTER rented_days BY DaysBetween(return_date,  rental_date) == 10;


mike = FILTER staff BY (fname MATCHES '^Mike$');
mike_inventory = JOIN inventory BY store_id, mike BY store_id USING 'replicated';
mike_inventory = FOREACH mike_inventory
                        GENERATE inventory::inventory_id AS inventory_id,
                                 inventory::film_id AS film_id;
mike_10days = JOIN rented_10days BY inventory_id,
                             mike_inventory BY inventory_id USING 'replicated';
films_10days = FOREACH mike_10days
            GENERATE mike_inventory::film_id AS film_id;

unique_films_10days = DISTINCT films_10days;

final = FOREACH (GROUP unique_films_10days ALL)
        GENERATE COUNT(unique_films_10days);

dump final