-- Q2: Publishers of books whose titles start with Προγραμματισμός.
SELECT DISTINCT p."Όνομα"
FROM "ΕΚΔΟΤΙΚΟΣ ΟΙΚΟΣ" AS p
JOIN "ΒΙΒΛΙΟ" AS b ON b."PublisherID" = p."ID"
WHERE b."Τίτλος" LIKE 'Προγραμματισμός%'
ORDER BY p."Όνομα";
