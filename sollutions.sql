-- Use the Sakila database
USE sakila;

-- 1️⃣ Determine the number of copies of the film "Hunchback Impossible" in inventory
SELECT f.title, COUNT(i.inventory_id) AS num_copies
FROM film f
JOIN inventory i ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible'
GROUP BY f.title;

-- 2️⃣ List all films whose length is longer than the average length of all films
SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length DESC;

-- 3️⃣ Use a subquery to display all actors who appear in the film "Alone Trip"
SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
WHERE a.actor_id IN (
    SELECT fa.actor_id
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    WHERE f.title = 'Alone Trip'
);

-- 4️⃣ BONUS: Identify all movies categorized as family films
SELECT f.title
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family'
ORDER BY f.title ASC;

-- 5️⃣ Retrieve the name and email of customers from Canada using both subqueries and joins

-- 5.1 Using a subquery
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
    SELECT address_id FROM address
    WHERE city_id IN (
        SELECT city_id FROM city
        WHERE country_id = (
            SELECT country_id FROM country WHERE country = 'Canada'
        )
    )
);

-- 5.2 Using a JOIN
SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- 6️⃣ Determine which films were starred by the most prolific actor
-- 6.1 Find the most prolific actor
SELECT actor_id, COUNT(film_id) AS film_count
FROM film_actor
GROUP BY actor_id
ORDER BY film_count DESC
LIMIT 1;

-- 6.2 Use that actor_id to find the films they starred in
SELECT f.title
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
);

-- 7️⃣ Find the films rented by the most profitable customer
-- 7.1 Find the most profitable customer
SELECT customer_id, SUM(amount) AS total_spent
FROM payment
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 1;

-- 7.2 Find the films rented by that customer
SELECT f.title
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.customer_id = (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
);

-- 8️⃣ Retrieve the client_id and the total amount spent by clients who spent more than the average
SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING total_amount_spent > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(amount) AS total_spent
        FROM payment
        GROUP BY customer_id
    ) AS subquery
)
ORDER BY total_amount_spent DESC;
