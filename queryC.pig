category = LOAD '/user/hduser/project4/input/category.csv' USING PigStorage(',')
           AS (category_id: int, name: chararray);

film_category = LOAD '/user/hduser/project4/input/film_category.csv' USING PigStorage(',')
                
                AS (film_id: int, category_id: int);

film = LOAD '/user/hduser/project4/input/film.csv' USING PigStorage(',')
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

inventory = LOAD '/user/hduser/project4/input/inventory.csv' USING PigStorage(',')
            AS (inventory_id:int,
                film_id:int,
                store_id:int);

rental = LOAD '/user/hduser/project4/input/rental.csv' USING PigStorage(',')
         AS (rental_id:int,
             rental_date:chararray,
             inventory_id:int,
             customer_id:int,
             return_date:chararray,
             staff_id:int);

customer = LOAD '/user/hduser/project4/input/customer.csv' USING PigStorage(',')
         AS (customer_id:int,
             store_id:int,
			 first_name:chararray,
			 last_name:chararray,
			 email:chararray,
             address_id:int,
             active:int);

film_inventory_w_category = JOIN film BY film_id, film_category BY film_id, inventory BY film_id;
film_full_info = JOIN film_inventory_w_category BY film_category::category_id, category BY category_id;
film_inventory_rented = JOIN film_full_info BY inventory::inventory_id, rental BY inventory_id;
customers_who_rented_films = JOIN film_inventory_rented BY rental::customer_id, customer BY customer_id;

customer_film_info = FOREACH customers_who_rented_films
                     GENERATE customer::customer_id AS customer_id,
                              customer::first_name AS first_name,
                              customer::last_name AS last_name,
                              category::name AS category_name;

-- customers who have not rented 'Comedy' or 'Classics'
customers_rented_comedy_classic = FILTER customer_film_info BY category_name MATCHES '^(Comedy|Classics).*$';
-- customers who have rented 'Action' out of customers_not_rented_comedy_classic
customers_rented_action = FILTER customer_film_info BY category_name MATCHES '^(Action)$';
-- use left join to get the difference betwee customers_rented_comedy_classic and customers_rented_action
customers_action_in_comedy_classic = JOIN customers_rented_action BY customer_id LEFT,
                                          customers_rented_comedy_classic BY customer_id;
-- customers who have rented 'ACTION' but not 'Comedy' or 'Classics'
customers_info = DISTINCT (FILTER customers_action_in_comedy_classic BY customers_rented_comedy_classic::customer_id is null);
customers_final = FOREACH customers_info
                  GENERATE customers_rented_action::customer_id as customer_id,
                           customers_rented_action::first_name as first_name,
                           customers_rented_action::last_name as last_name;
customers_final_ordered = ORDER customers_final BY last_name, first_name;

dump customers_final_oredered