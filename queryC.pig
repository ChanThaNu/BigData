category = LOAD 'category.csv' USING PigStorage(',') 
           AS (category_id: int, name: chararray);

film_category = LOAD 'film_category.csv' USING PigStorage(',')
                AS (film_id: int, category_id: int);

film = LOAD 'film.csv' USING PigStorage(',') 
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

inventory = LOAD 'inventory.csv' USING PigStorage(',')
            AS (inventory_id:int,
                film_id:int,
                store_id:int);

rental = LOAD 'rental.csv' USING PigStorage(',') 
         AS (rental_id:int,
             rental_date:chararray,
             inventory_id:int,
             customer_id:int,
             return_date:chararray,
             staff_id:int);

customer = LOAD 'customer.csv' USING PigStorage(',') 
         AS (customer_id:int,
             store_id:int,
       first_name:chararray,
       last_name:chararray,
       email:chararray,
             address_id:int,
             active:int);

table1 = JOIN film BY film_id, film_category BY film_id,
                                 inventory BY film_id USING 'replicated';
table2 = JOIN table1 BY film_category::category_id,
                      category BY category_id USING 'replicated';
table3 = JOIN table2 BY inventory::inventory_id,
                             rental BY inventory_id USING 'replicated';
table4 = JOIN table3 BY rental::customer_id,
                                  customer BY customer_id USING 'replicated';
customer_film = FOREACH table4
                     GENERATE customer::customer_id AS customer_id,
                              customer::first_name AS first_name,
                              customer::last_name AS last_name,
                              category::name AS category_name;
comedy_classic = FILTER customer_film BY category_name MATCHES '^(Comedy|Classics).*$';
customers_action = FILTER customer_film BY category_name MATCHES '^(Action)$';
customers_action_in_comedy_classic = JOIN customers_action BY customer_id LEFT,
                                          comedy_classic BY customer_id USING 'replicated';
customers_data = DISTINCT (FILTER customers_action_in_comedy_classic BY comedy_classic::customer_id is null);
final = FOREACH customers_data
                  GENERATE customers_action::last_name as last_name;
result = ORDER final BY last_name;

dump result 