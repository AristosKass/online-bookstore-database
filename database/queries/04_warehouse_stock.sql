-- Q4: Total available copies per warehouse, including empty warehouses.
SELECT w."ID" AS "WarehouseID", COALESCE(SUM(b."Ποσότητα"), 0) AS "ΣυνολικάΑντίτυπα"
FROM "ΑΠΟΘΗΚΗ" AS w
LEFT JOIN "ΒΙΒΛΙΟ" AS b ON b."WarehouseID" = w."ID"
GROUP BY w."ID"
ORDER BY w."ID";
