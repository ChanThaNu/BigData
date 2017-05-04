# BigData Project4
In this project, three team members are grouped by
Myat Oo (Team Leader),
Zijian Zhang, 
Mohammad Islam

Before this project,

You need to install hadoop in your machine using virtual machine.Installation for Pig, you can see at the .txt for 
step by step installation. You can run this program both eithor Version or mapreduce Version.


The questions are as follow:

For each of the following queries write a Pig Latin script executing on a Hadoop cluster of size 2:
 
A.   What is the average length of films in each category? List the results in alphabetic order of categories. 
B.   Which categories have the longest and shortest average film lengths?
C.   Which customers have rented action but not comedy or classic movies?
D.   Which actor has appeared in the most English-language movies?
E.   How many distinct movies were rented for exactly 10 days from the store where Mike works?
F.    Alphabetically list actors who appeared in the movie with the largest cast of actors.
 

Notes
 
�         All tables have the indicated primary key, foreign key and unique constraints
�         Category names come from the set {Animation, Comedy, Family, Foreign, Sci-Fi, Travel, Children, Drama, Horror, Action, Classics, Games, New, Documentary, Sports, Music}
�         A film�s special_features attribute comes from the set {Behind the Scenes, Commentaries, Deleted Scenes, Trailers}
�         All dates are between 2005 and 2015
�         Active is from the set {0,1} where 1 means active and 0 inactive
�         Rental duration is a positive number of days between 2 and 8
�         Rental rate per day is between 0.99 and 6.99
�         Film length is between 30 and 200 minutes
�         Ratings are {PG, G, NC-17, PG-13, R}
�         Replacement cost is between 5.00 and 100.00
�         Amount >= 0
 
