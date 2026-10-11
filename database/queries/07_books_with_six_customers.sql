-- Q7: Books purchased by more than five distinct customers.
SELECT b."ID", b."Τίτλος", COUNT(DISTINCT c."CustomerID") AS "ΔιαφορετικοίΠελάτες"
FROM "ΒΙΒΛΙΟ" AS b
JOIN "ΠΕΡΙΕΧΕΙ" AS i ON i."BookID" = b."ID"
JOIN "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" AS c ON c."ID" = i."CartID"
GROUP BY b."ID", b."Τίτλος"
HAVING COUNT(DISTINCT c."CustomerID") > 5
ORDER BY b."ID";
