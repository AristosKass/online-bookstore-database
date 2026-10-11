-- Q3: All book fields for books linked to Paulo Coelho.
SELECT b.*
FROM "ΒΙΒΛΙΟ" AS b
WHERE EXISTS (
    SELECT 1 FROM "ΓΡΑΦΕΙ" AS ba
    JOIN "ΣΥΓΓΡΑΦΕΑΣ" AS a ON a."ID" = ba."AuthorID"
    WHERE ba."BookID" = b."ID" AND a."Ονοματεπώνυμο" = 'Paulo Coelho'
)
ORDER BY b."ID";
