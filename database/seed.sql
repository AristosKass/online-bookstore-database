-- Fictional test fixtures. IEEE and Paulo Coelho are labels required by queries;
-- the sample titles, authorship links, addresses and purchases are invented.
PRAGMA foreign_keys = ON;

INSERT INTO "ΕΚΔΟΤΙΚΟΣ ΟΙΚΟΣ" ("ID", "Όνομα", "Διεύθυνση", "URL") VALUES
    (1, 'IEEE', 'Demo publisher address 1', 'https://publisher-one.example.invalid'),
    (2, 'Εκδόσεις Δοκιμής', 'Demo publisher address 2', 'https://publisher-two.example.invalid'),
    (3, 'Demo Press', 'Demo publisher address 3', NULL);

INSERT INTO "ΠΕΛΑΤΗΣ"
    ("ID", "Όνομα", "Επώνυμο", "Πατρώνυμο", "Πόλη", "Οδός", "Αριθμός", "ΤΚ", "e-mail") VALUES
    (1, 'Πελάτης', 'Δοκιμής Α', NULL, 'Demo City', 'Demo Street', '1', '00000', 'customer1@example.invalid'),
    (2, 'Πελάτης', 'Δοκιμής Β', NULL, 'Demo City', 'Demo Street', '2', '00000', 'customer2@example.invalid'),
    (3, 'Πελάτης', 'Δοκιμής Γ', NULL, 'Demo City', 'Demo Street', '3', '00000', 'customer3@example.invalid'),
    (4, 'Πελάτης', 'Δοκιμής Δ', NULL, 'Demo City', 'Demo Street', '4', '00000', 'customer4@example.invalid'),
    (5, 'Πελάτης', 'Δοκιμής Ε', NULL, 'Demo City', 'Demo Street', '5', '00000', 'customer5@example.invalid'),
    (6, 'Πελάτης', 'Δοκιμής Ζ', NULL, 'Demo City', 'Demo Street', '6', '00000', 'customer6@example.invalid'),
    (7, 'Πελάτης', 'Δοκιμής Η', NULL, 'Demo City', 'Demo Street', '7', '00000', 'customer7@example.invalid'),
    (8, 'Πελάτης', 'Χωρίς Αγορές', NULL, 'Demo City', 'Demo Street', '8', '00000', 'customer8@example.invalid');

INSERT INTO "ΤΗΛΕΦΩΝΟ ΠΕΛΑΤΗ" VALUES (1, 'DEMO-PHONE-1'), (1, 'DEMO-PHONE-2');
INSERT INTO "ΤΗΛΕΦΩΝΟ ΕΚΔΟΤΗ" VALUES (1, 'DEMO-PUBLISHER-1'), (1, 'DEMO-PUBLISHER-2');

INSERT INTO "ΣΥΓΓΡΑΦΕΑΣ" ("ID", "Ονοματεπώνυμο", "e-mail") VALUES
    (1, 'Paulo Coelho', NULL),
    (2, 'Συγγραφέας Α', 'author2@example.invalid'),
    (3, 'Συγγραφέας Β', 'author3@example.invalid'),
    (4, 'Συγγραφέας Χωρίς Βιβλία', NULL);

INSERT INTO "ΑΠΟΘΗΚΗ" ("ID", "Πόλη", "Οδός", "Αριθμός", "ΤΚ", "Τηλέφωνο") VALUES
    (1, 'Demo City', 'Warehouse Street', '1', '00000', 'DEMO-WAREHOUSE-1'),
    (2, 'Demo City', 'Warehouse Street', '2', '00000', 'DEMO-WAREHOUSE-2'),
    (3, 'Demo City', 'Warehouse Street', '3', '00000', NULL);

INSERT INTO "ΒΙΒΛΙΟ"
    ("ID", "WarehouseID", "PublisherID", "Τίτλος", "Έτος", "ISBN", "ΤιμήΛεπτά", "Ποσότητα") VALUES
    (1, 1, 1, 'Προγραμματισμός με SQL', 2024, 'DEMO-ISBN-001', 3500, 12),
    (2, 1, 1, 'Αλγόριθμοι για Βάσεις', 2023, 'DEMO-ISBN-002', 4000, 8),
    (3, 2, 2, 'Προγραμματισμός σε Python', 2024, 'DEMO-ISBN-003', 3000, 10),
    (4, 2, 2, 'Δείγμα Λογοτεχνίας Α', 2020, 'DEMO-ISBN-004', 1500, 20),
    (5, 2, 2, 'Δείγμα Λογοτεχνίας Β', 2021, 'DEMO-ISBN-005', 2000, 5),
    (6, 1, 1, 'Δομές Δεδομένων', 2022, 'DEMO-ISBN-006', 4500, 7),
    (7, 1, 3, 'Προγραμματισμός σε C++', 2024, 'DEMO-ISBN-007', 5000, 4),
    (8, 2, 3, 'Δείγμα Λογοτεχνίας Γ', 2022, 'DEMO-ISBN-008', 1800, 3);

INSERT INTO "ΓΡΑΦΕΙ" ("BookID", "AuthorID") VALUES
    (1, 2), (1, 3), (2, 2), (3, 3), (4, 1), (5, 1), (6, 2), (7, 3), (8, 1);

INSERT INTO "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" ("ID", "CustomerID", "Ημερομηνία") VALUES
    (1, 1, '2024-12-01'), (2, 2, '2024-12-02'), (3, 3, '2024-12-03'),
    (4, 4, '2024-12-04'), (5, 5, '2024-12-05'), (6, 6, '2024-12-06'),
    (7, 1, '2024-12-07'), (8, 7, '2024-12-08'), (9, 1, '2024-12-09'),
    (10, 1, '2024-12-10');

INSERT INTO "ΠΕΡΙΕΧΕΙ" ("CartID", "BookID", "Ποσότητα", "ΤιμήΜονάδαςΛεπτά") VALUES
    (1, 1, 1, 3500), (2, 1, 1, 3400), (3, 1, 1, 3300),
    (4, 1, 1, 3200), (5, 1, 1, 3100), (6, 1, 1, 3000),
    (7, 1, 2, 3500), (8, 2, 3, 4000), (8, 6, 2, 4500),
    (9, 2, 1, 4000), (10, 2, 1, 4000);
