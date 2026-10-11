-- Q1: Titles of IEEE books, ordered by title.
SELECT b."Τίτλος"
FROM "ΒΙΒΛΙΟ" AS b
JOIN "ΕΚΔΟΤΙΚΟΣ ΟΙΚΟΣ" AS p ON p."ID" = b."PublisherID"
WHERE p."Όνομα" = 'IEEE'
ORDER BY b."Τίτλος", b."ID";
