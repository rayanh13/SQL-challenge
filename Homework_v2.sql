USE sakila;

SELECT * FROM sakila.actor;

-- 1a. Display the first and last names of all actors from the table actor
SELECT 
	first_name,
	last_name
FROM sakila.actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
SELECT concat(UPPER(first_name), ' ', UPPER(last_name)) AS Actor_Name
FROM sakila.actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
SELECT
	actor_id,
	first_name,
	last_name
FROM sakila.actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN
SELECT *
FROM sakila.actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order
SELECT
	actor_id,
    last_name,
    first_name
FROM sakila.actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
SELECT
	country_id,
    country
FROM sakila.country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant)
ALTER TABLE sakila.actor
ADD COLUMN Description BLOB;

SELECT * FROM sakila.actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column
ALTER TABLE sakila.actor
DROP COLUMN Description;

-- 4a. List the last names of actors, as well as how many actors have that last name
SELECT
	last_name,
    COUNT(last_name) AS how_many_actors
FROM sakila.actor
GROUP BY last_name;
-- ORDER BY how_many_actors, last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT
	last_name,
    COUNT(last_name) AS how_many_actors
FROM sakila.actor
GROUP BY last_name
HAVING COUNT(how_many_actors) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record
UPDATE sakila.actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO
UPDATE sakila.actor 
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
DESCRIBE sakila.address;
SHOW CREATE TABLE address;
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address
SELECT 
	staff.first_name, 
    staff.last_name, 
    address.address
FROM staff
INNER JOIN address ON
address.address_id = staff.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment
SELECT 
	staff.first_name,
    staff.last_name,
    SUM(payment.amount) AS total_amount
FROM staff
INNER JOIN payment ON
payment.staff_id = staff.staff_id
GROUP BY payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join
SELECT 
    film.title,
    COUNT(film_actor.actor_id) AS number_of_actors
FROM film_actor
INNER JOIN film ON
film.film_id = film_actor.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT
	film.title,
    COUNT(inventory.inventory_id) AS copies_inventory_system
FROM film
INNER JOIN inventory ON
inventory.film_id = film.film_id
WHERE film.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name
SELECT
	customer.first_name,
    customer.last_name,
    SUM(payment.amount) AS 'total paid'
FROM customer
INNER JOIN payment ON
payment.customer_id = customer.customer_id
GROUP BY customer.last_name
ORDER BY customer.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English
SELECT i.title, f.name
FROM film i
JOIN language f
ON (i.language_id = f.language_id)
WHERE (i.title LIKE 'K%' OR i.title LIKE 'Q%') AND f.name IN ('English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
SELECT actor_id
FROM film_actor
WHERE film_id IN
(
 SELECT film_id
 FROM film
 WHERE title = 'Alone Trip'
));


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information
SELECT c.first_name, c.last_name, c.email
FROM customer c
WHERE address_id IN 
(
SELECT address_id
FROM city
WHERE city_id IN 
(
SELECT city_id
FROM city
WHERE country_id IN
(
SELECT country_id
FROM country
WHERE country = 'Canada'
)));

SELECT c.last_name, c.first_name, c.email
FROM customer c
INNER JOIN store s
ON (c.store_id = s.store_id)
INNER JOIN address ad
ON (ad.address_id = s.address_id)
INNER JOIN city ct
ON (ct.city_id = ad.city_id)
INNER JOIN country cn
ON (cn.country_id = ct.country_id)
WHERE country = 'Canada';
    
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films
SELECT *
FROM category c
INNER JOIN film_category fc
ON (c.category_id = fc.category_id)
where c.name = 'Family';

SELECT title
	FROM film
	WHERE film_id
	IN (
		SELECT film_id
			FROM film_category
			WHERE category_id
			IN (
				SELECT category_id
                FROM category
                WHERE name = 'Family'
                )
		);


-- 7e. Display the most frequently rented movies in descending order
SELECT ft.title, COUNT(ft.title) AS 'frequency movies rented'
FROM film_text ft
INNER JOIN inventory i
ON (ft.film_id = i.film_id)
INNER JOIN rental r
ON (i.inventory_id = r.inventory_id)
GROUP BY ft.title
ORDER BY COUNT(ft.title) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in
SELECT s.store_id, SUM(p.amount) AS 'business brought in'
FROM store s
INNER JOIN staff st
ON (s.store_id = st.store_id)
INNER JOIN payment p
ON (p.staff_id = st.staff_id)
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country
SELECT s.store_id, c.city, cn.country
FROM store s
INNER JOIN address ad
ON (s.address_id = ad.address_id)
INNER JOIN city c
ON (c.city_id = ad.city_id)
INNER JOIN country cn
ON (cn.country_id = c.country_id);

-- 7h. List the top five genres in gross revenue in descending order
SELECT c.name, SUM(p.amount) AS 'gross revenue'
FROM category c
INNER JOIN film_category fc 
ON (fc.category_id = c.category_id)
INNER JOIN inventory i 
ON (i.film_id = fc.film_id)
INNER JOIN rental r 
ON (r.inventory_id = i.inventory_id)
INNER JOIN payment p 
ON (p.rental_id = r.rental_id)
GROUP BY name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view
CREATE VIEW top_five_genres AS 
SELECT c.name, SUM(p.amount) AS 'gross revenue'
FROM category c
INNER JOIN film_category fc 
ON (fc.category_id = c.category_id)
INNER JOIN inventory i 
ON (i.film_id = fc.film_id)
INNER JOIN rental r 
ON (r.inventory_id = i.inventory_id)
INNER JOIN payment p 
ON (p.rental_id = r.rental_id)
GROUP BY name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT *
FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;