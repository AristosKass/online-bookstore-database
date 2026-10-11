-- Q5: Customer(s) with the largest individual cart; return all tied carts.
-- Values use historical line prices, never the book's current catalogue price.
WITH cart_totals AS (
    SELECT c."ID" AS cart_id, c."CustomerID" AS customer_id,
           SUM(i."Ποσότητα" * i."ΤιμήΜονάδαςΛεπτά") AS total_cents
    FROM "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" AS c
    JOIN "ΠΕΡΙΕΧΕΙ" AS i ON i."CartID" = c."ID"
    GROUP BY c."ID", c."CustomerID"
)
SELECT p."ID" AS "CustomerID", p."Όνομα" || ' ' || p."Επώνυμο" AS "Ονοματεπώνυμο",
       t.cart_id AS "CartID", t.total_cents AS "ΣύνολοΛεπτά"
FROM cart_totals AS t
JOIN "ΠΕΛΑΤΗΣ" AS p ON p."ID" = t.customer_id
WHERE t.total_cents = (SELECT MAX(total_cents) FROM cart_totals)
ORDER BY t.cart_id;
