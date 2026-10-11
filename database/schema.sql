-- Executable SQLite revision of the original Greek bookstore model.
-- Enable foreign keys again for every new connection.
PRAGMA foreign_keys = ON;

CREATE TABLE "ΕΚΔΟΤΙΚΟΣ ΟΙΚΟΣ" (
    "ID" INTEGER PRIMARY KEY CHECK ("ID" > 0),
    "Όνομα" TEXT NOT NULL CHECK (length(trim("Όνομα")) > 0),
    "Διεύθυνση" TEXT NOT NULL CHECK (length(trim("Διεύθυνση")) > 0),
    "URL" TEXT
);

CREATE TABLE "ΠΕΛΑΤΗΣ" (
    "ID" INTEGER PRIMARY KEY CHECK ("ID" > 0),
    "Όνομα" TEXT NOT NULL CHECK (length(trim("Όνομα")) > 0),
    "Επώνυμο" TEXT NOT NULL CHECK (length(trim("Επώνυμο")) > 0),
    "Πατρώνυμο" TEXT,
    "Πόλη" TEXT NOT NULL,
    "Οδός" TEXT NOT NULL,
    "Αριθμός" TEXT NOT NULL,
    "ΤΚ" TEXT NOT NULL,
    "e-mail" TEXT NOT NULL CHECK (length(trim("e-mail")) > 0)
);

CREATE TABLE "ΤΗΛΕΦΩΝΟ ΠΕΛΑΤΗ" (
    "CustomerID" INTEGER NOT NULL REFERENCES "ΠΕΛΑΤΗΣ" ("ID"),
    "Τηλέφωνο" TEXT NOT NULL CHECK (length(trim("Τηλέφωνο")) > 0),
    PRIMARY KEY ("CustomerID", "Τηλέφωνο")
);

CREATE TABLE "ΤΗΛΕΦΩΝΟ ΕΚΔΟΤΗ" (
    "PublisherID" INTEGER NOT NULL REFERENCES "ΕΚΔΟΤΙΚΟΣ ΟΙΚΟΣ" ("ID"),
    "Τηλέφωνο" TEXT NOT NULL CHECK (length(trim("Τηλέφωνο")) > 0),
    PRIMARY KEY ("PublisherID", "Τηλέφωνο")
);

CREATE TABLE "ΣΥΓΓΡΑΦΕΑΣ" (
    "ID" INTEGER PRIMARY KEY CHECK ("ID" > 0),
    "Ονοματεπώνυμο" TEXT NOT NULL CHECK (length(trim("Ονοματεπώνυμο")) > 0),
    "e-mail" TEXT
);

CREATE TABLE "ΑΠΟΘΗΚΗ" (
    "ID" INTEGER PRIMARY KEY CHECK ("ID" > 0),
    "Πόλη" TEXT NOT NULL,
    "Οδός" TEXT NOT NULL,
    "Αριθμός" TEXT NOT NULL,
    "ΤΚ" TEXT NOT NULL,
    "Τηλέφωνο" TEXT
);

CREATE TABLE "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" (
    "ID" INTEGER PRIMARY KEY CHECK ("ID" > 0),
    "CustomerID" INTEGER NOT NULL REFERENCES "ΠΕΛΑΤΗΣ" ("ID"),
    "Ημερομηνία" TEXT NOT NULL
        CHECK (length("Ημερομηνία") = 10 AND
               "Ημερομηνία" GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')
);

CREATE TABLE "ΒΙΒΛΙΟ" (
    "ID" INTEGER PRIMARY KEY CHECK ("ID" > 0),
    "WarehouseID" INTEGER NOT NULL REFERENCES "ΑΠΟΘΗΚΗ" ("ID"),
    "PublisherID" INTEGER NOT NULL REFERENCES "ΕΚΔΟΤΙΚΟΣ ΟΙΚΟΣ" ("ID"),
    "Τίτλος" TEXT NOT NULL CHECK (length(trim("Τίτλος")) > 0),
    "Έτος" INTEGER NOT NULL
        CHECK (typeof("Έτος") = 'integer' AND "Έτος" BETWEEN 1 AND 9999),
    "ISBN" TEXT NOT NULL UNIQUE CHECK (length(trim("ISBN")) > 0),
    "ΤιμήΛεπτά" INTEGER NOT NULL
        CHECK (typeof("ΤιμήΛεπτά") = 'integer' AND "ΤιμήΛεπτά" >= 0),
    "Ποσότητα" INTEGER NOT NULL
        CHECK (typeof("Ποσότητα") = 'integer' AND "Ποσότητα" >= 0)
);

CREATE TABLE "ΠΕΡΙΕΧΕΙ" (
    "CartID" INTEGER NOT NULL REFERENCES "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" ("ID"),
    "BookID" INTEGER NOT NULL REFERENCES "ΒΙΒΛΙΟ" ("ID"),
    "Ποσότητα" INTEGER NOT NULL
        CHECK (typeof("Ποσότητα") = 'integer' AND "Ποσότητα" > 0),
    -- Actual unit price at purchase time, including any discount.
    "ΤιμήΜονάδαςΛεπτά" INTEGER NOT NULL
        CHECK (typeof("ΤιμήΜονάδαςΛεπτά") = 'integer' AND "ΤιμήΜονάδαςΛεπτά" >= 0),
    PRIMARY KEY ("CartID", "BookID")
);

CREATE TABLE "ΓΡΑΦΕΙ" (
    "BookID" INTEGER NOT NULL REFERENCES "ΒΙΒΛΙΟ" ("ID"),
    "AuthorID" INTEGER NOT NULL REFERENCES "ΣΥΓΓΡΑΦΕΑΣ" ("ID"),
    PRIMARY KEY ("BookID", "AuthorID")
);

CREATE INDEX "idx_carts_customer" ON "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" ("CustomerID");
CREATE INDEX "idx_books_publisher" ON "ΒΙΒΛΙΟ" ("PublisherID");
CREATE INDEX "idx_books_warehouse" ON "ΒΙΒΛΙΟ" ("WarehouseID");
CREATE INDEX "idx_cart_items_book" ON "ΠΕΡΙΕΧΕΙ" ("BookID");
CREATE INDEX "idx_book_authors_author" ON "ΓΡΑΦΕΙ" ("AuthorID");
