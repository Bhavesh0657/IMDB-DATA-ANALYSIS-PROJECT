use imdb;
  
  
show tables;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/


-- Segment 1:


-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

select table_name, table_rows 
from information_schema.tables
where table_schema='imdb';


-- OR 

# using count(*) for each tables

select count(*) from genre;
select count(*) from director_mapping;
select count(*) from movie;
select count(*) from names;
select count(*) from ratings;
select count(*) from role_mapping;



-- Q2. Which columns in the movie table have null values?

select * from movie;

SELECT COLUMN_NAME
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'imdb'
  AND TABLE_NAME = 'movie'
  AND IS_NULLABLE = 'YES';
  

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */

select * from movie;

-- part 1 
select year, count(title) as number_of_movies
from movie
group by 1 ;

-- part 2 

select month(date_published) as month_num, count(title) as number_of_movies
from movie
group by 1
order by 1;


/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??

select count(distinct id) as no_of_movies , year
from movie
where (country like '%USA%' or country like '%INDIA%') and year = 2019;

-- or 

select count(distinct id) as num_movies , year
from movie
where (country regexp 'USA' or country regexp 'India') and year = 2019;



/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?


SELECT DISTINCT genre
FROM genre;


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?

select * from movie;
select * from genre;

select genre, count(id) as no_of_movies
from movie m 
join genre g 
on m.id = g.movie_id 
group by 1 
order by no_of_movies desc 
limit 1;

-- OR

select genre, count(movie_id) as number_of_movies
from genre
group by genre
order by number_of_movies desc;




/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?


select count(id) as num_movies_with_one_genre
from movie  
where id  in (select movie_id from genre 
              group by movie_id
              having count(*) = 1 );


/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */


SELECT genre, round(AVG(duration),2) AS average_duration
FROM movie
inner join genre 
on genre.movie_id = movie.id
WHERE duration IS NOT NULL
GROUP BY genre
order by average_duration desc;


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/


select * from genre;

select genre, 
    rank() over (order by count(*) desc) as genre_rank 
from genre 
where genre is not null
group by 1;

-- or 

select *, rank() over (order by num_movies desc) as genre_rank
from (select genre, count(*) as num_movies
      from movie m 
      join genre g 
      on m.id = g.movie_id 
      group by 1 
      ) wp;


/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/



-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:

+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/


SELECT MIN(avg_rating),MAX(avg_rating),MIN(total_votes),MAX(total_votes),MIN(median_rating),MAX(median_rating)
FROM ratings;


/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

-- It's ok if RANK() or DENSE_RANK() is used too

select * from ratings;
select * from movie;

select title, avg_rating,
dense_rank() over (order by avg_rating desc) as movie_rank
from movie m 
join ratings r 
on m.id = r.movie_id 
limit 10;



/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

-- Order by is good to have

select * from ratings;

select median_rating, count(movie_id) as movie_count
from ratings 
group by 1 
order by movie_count desc;



/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/

show tables;
select * from movie;

select * from production;

SELECT production_company,
       COUNT(movie_id) AS movie_count,
       RANK() OVER (ORDER BY COUNT(movie_id) DESC) AS prod_company_rank
FROM movie m
inner JOIN ratings r ON m.id = r.movie_id
WHERE avg_rating > 8
GROUP BY production_company;

with cte as (
select production_company, 
       count(movie_id) as movie_count
from movie m 
join ratings r 
on m.id = r.movie_id 
where avg_rating > 8 and production_company is not null
group by 1 
order by 2 desc)
select *, dense_rank() over (order by movie_count desc ) as prod_company_rank
from cte;


-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */


SELECT genre,
       COUNT(*) AS movie_count
FROM movie m 
join genre g ON m.id = g.movie_id
JOIN ratings r ON m.id = r.movie_id
WHERE m.country = 'USA'
  AND MONTH(m.release_date) = 3
  AND YEAR(m.release_date) = 2017
  AND r.votes > 1000
GROUP BY genre;



-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/


select * from movie;
select * from ratings;
select * from genre;


select title, avg_rating, genre 
from movie m 
join genre g 
on m.id =  g.movie_id 
join ratings r 
on m.id = r.movie_id
where title like 'The%' and avg_rating > 8 
order by 2 desc;


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

select median_rating, count(*) as movie_count
from movie m 
join ratings r 
on m.id = r.movie_id 
where date_published between '2018-04-01' and '2019-04-01' and median_rating = 8
group by 1;


-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.


select country , sum(total_votes) as Vote
from movie m 
join ratings r 
on m.id = r.movie_id 
where country in ('Italy','Germany')
group by 1;

-- another method

SELECT 'Germany' AS country,SUM(total_votes) as Votes
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE m.country like "%Germany%"
UNION ALL
SELECT 'Italy',SUM(total_votes) as Votes
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE m.country like "%Italy%";


-- Answer is Yes
/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/


-- Segment 3:

-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/


select * from names;

-- NULL counts for individual columns of names table

select count(*) as name_nulls
from names
where Name is null;

select count(*) as height_nulls 
from names
where height is null;

select count(*) as date_of_birth_nulls
from names
where date_of_birth is null;

select count(*) as known_for_movies_nulls
from names
where known_for_movies is null;

-- Another Method

-- NULL counts for columns of names table using CASE statements

select
sum(case when name is null then 1 else 0 end) as name_nulls,
sum(case when height is null then 1 else 0 end) as height_nulls,
sum(case when date_of_birth is null then 1 else 0 end) as date_of_birth_nulls,
sum(case when known_for_movies is null then 1 else 0 end) as known_for_movies_nulls
from names;


-- Height, date_of_birth, known_for_movies columns contain NULLS

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */


-- using cte to solve problem 

select * from genre;
select * from ratings;


with top_3_genre as
( select  genre,
   count(m.id) as movie_count,
   rank() over (order by count(m.id) desc ) as genre_rank
   from movie m 
   inner join genre g 
   on m.id = g.movie_id
   inner join ratings r 
   on m.id = r.movie_id 
   where avg_rating > 8 
   group by 1 
   limit 3 )
select n.name as director_name,
       count(d.movie_id) as movie_count
from director_mapping as d 
inner join genre g 
using (movie_id)
inner join names as n
on n.id = d.name_id
inner join top_3_genre
using (genre)
inner join ratings
using  (movie_id)
where  avg_rating > 8
group by name
order by  movie_count desc limit 3 ;


-- James Mangold , Joe Russo and Anthony Russo are top three directors in the top three genres whose movies have an average rating > 8



/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */


select * from role_mapping;
select * from names;
select * from genre;
select * from ratings;
select * from movie;


select n.name as actor_name,
    count(movie_id) as movie_count 
from role_mapping rm 
inner join names n 
on rm.name_id = n.id 
inner join genre g 
using (movie_id)
inner join ratings r 
using (movie_id)
inner join movie m 
on rm.movie_id = m.id 
where category = 'actor' and r.median_rating >= 8
group by name 
order by movie_count desc 
limit 2;

-- Top 2 actors are Mammootty and Mohanlal.

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/



select * from movie;
select * from ratings;

select production_company,
sum(total_votes) as vote_count,
rank() over (order by sum(total_votes) desc) as prod_comp_rank
from movie m 
inner join ratings r
on m.id = r.movie_id 
group by 1  
limit 3;

-- Top three production houses based on the number of votes received by their movies are Marvel Studios, Twentieth Century Fox and Warner Bros.

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.


_- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 

/* Output format:
 +---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

with actor_summary as(
    select
        n.name as actor_name,
        sum(total_votes) as total_votes,
        count(r.movie_id) as movie_count,
        round(sum(avg_rating * total_votes) / sum(total_votes), 2) as actor_avg_rating
    from  movie as m
        inner join ratings as r on m.id = r.movie_id
        inner join role_mapping as rm on m.id = rm.movie_id
        inner join names as n on rm.name_id = n.id
    where  
        category = 'ACTOR'
        and country = 'india'
    group by  1
    having movie_count >= 5
)
select 
    *,
    rank() over (order by actor_avg_rating desc) as actor_rank
from actor_summary
limit 5;
    
-- Top actor is Vijay Sethupathi followed by Fahadh Faasil and Yogi Babu.

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

use imdb;

with actresses_summary as 
( 
  select n.name as actresses_name,
  sum(total_votes) as total_votes,
  count(r.movie_id) as movie_count,
  round(sum(avg_rating * total_votes) / sum(total_votes), 2) as actress_avg_rating
from movie as m 
  inner join ratings as r on m.id = r.movie_id
  inner join role_mapping as rm on m.id = rm.movie_id
  inner join names as n on rm.name_id = n.id 
  where category = 'Actress' and country = "INDIA" and languages like '%Hindi%'
  group by 1 
  having movie_count >=3
  )
  select *,
  rank() over (order by actress_avg_rating desc) as actress_rank
  from actresses_summary;

-- Top five actresses in Hindi movies released in India based on their average ratings are Taapsee Pannu, Kriti Sanon, Divya Dutta, Shraddha Kapoor, Kriti Kharbanda


/* Taapsee Pannu tops with average rating 7.74. 

   
Now let us divide all the thriller movies in the following categories and find out their numbers.*/

/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/


with thriller_movies as
( select distinct title,
    avg_rating 
    from movie m
    inner join ratings r on m.id = r.movie_id 
    inner join genre g on m.id = g.movie_id 
    where genre like 'Thriller'
)
  select *,
  case 
     when avg_rating > 8 then 'Superhit movies'
     when avg_rating between 7 and 8 then 'Hit movies'
     when avg_rating between 5 and 7 then 'One-time-watch movies'
     else 'Flop movies'
     end as avg_rating_category
from thriller_movies;

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/

SELECT genre,
		round(avg(duration),2) as avg_duration,
        sum(round(avg(duration),2)) over(order by genre rows unbounded preceding) as running_total_duration,
        avg(round(avg(duration),2)) over(order by genre rows 5 preceding) as moving_avg_duration
from movie as m 
inner join genre as g 
on m.id= g.movie_id
group by genre
order by genre;


-- Q26.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

select * from ratings;
select * from movie;

with production_company_summary as
( select production_company,
   count(*) as movie_count
   from movie m 
   inner join ratings r on m.id = r.movie_id 
   where median_rating >= 8 and production_company is not null 
   and position(',' in languages ) > 0
   group by 1 
)
 select *, 
		rank() over( order by movie_count desc) as prod_comp_rank
 from production_company_summary
 limit 2;

-- Star Cinema and Twentieth Century Fox are the top two production houses that have produced the highest number of hits among multilingual movies.
 
 
-- Q27. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

with actresses_summary as 
( select n.name as actress_name,
         sum(total_votes) as total_votes,
         count(r.movie_id) as movie_count,
         round(sum(avg_rating * total_votes) /sum(total_votes)) as actress_avg_rating
	 from movie m 
     inner join ratings r on m.id = r.movie_id 
     inner join genre g using(movie_id)
     inner join role_mapping rm using(movie_id)
     inner join names n on rm.name_id = n.id 
     where category = 'actress' and genre = 'Drama' and avg_rating > 8 
     group by 1
)
 select * , 
     rank() over (order by movie_count desc ) as actress_rank
from actresses_summary
limit 3;

-- Top 3 actresses based on number of Super Hit movies are Parvathy Thiruvothu, Susan Brown and Amanda Lawrence

