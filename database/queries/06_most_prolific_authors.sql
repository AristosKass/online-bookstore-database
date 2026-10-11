-- Q6: Author(s) with the most distinct books; return all ties.
WITH book_counts AS (
    SELECT a."ID" AS author_id, a."Ονοματεπώνυμο" AS full_name,
           COUNT(ba."BookID") AS book_count
    FROM "ΣΥΓΓΡΑΦΕΑΣ" AS a
    LEFT JOIN "ΓΡΑΦΕΙ" AS ba ON ba."AuthorID" = a."ID"
    GROUP BY a."ID", a."Ονοματεπώνυμο"
)
SELECT author_id AS "AuthorID", full_name AS "Ονοματεπώνυμο", book_count AS "ΠλήθοςΒιβλίων"
FROM book_counts
WHERE book_count = (SELECT MAX(book_count) FROM book_counts)
ORDER BY author_id;
