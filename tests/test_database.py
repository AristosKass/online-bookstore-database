"""Functional query results, integrity rules and safe demo initialization."""
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from demo import load_demo, validate


class DatabaseTests(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(":memory:")
        load_demo(self.db)

    def tearDown(self):
        self.db.close()

    def query(self, number):
        path, = (ROOT / "database" / "queries").glob(f"{number:02d}_*.sql")
        return self.db.execute(path.read_text(encoding="utf-8")).fetchall()

    def test_valid_demo(self):
        self.assertEqual(validate(self.db), [])
        self.assertEqual(self.db.execute("PRAGMA foreign_keys").fetchone()[0], 1)

    def test_ieee_titles_ordered(self):
        self.assertEqual(self.query(1), [("Αλγόριθμοι για Βάσεις",), ("Δομές Δεδομένων",), ("Προγραμματισμός με SQL",)])

    def test_programming_publishers_are_distinct(self):
        self.db.execute('UPDATE "ΒΙΒΛΙΟ" SET "Τίτλος" = ? WHERE "ID" = 2', ("Προγραμματισμός δεύτερο δείγμα",))
        self.assertEqual(self.query(2), [("Demo Press",), ("IEEE",), ("Εκδόσεις Δοκιμής",)])

    def test_author_books(self):
        self.assertEqual([row[0] for row in self.query(3)], [4, 5, 8])
        self.assertTrue(all(len(row) == 8 for row in self.query(3)))

    def test_warehouse_quantities_include_empty(self):
        self.assertEqual(self.query(4), [(1, 31), (2, 38), (3, 0)])

    def test_largest_individual_cart(self):
        self.assertEqual(self.query(5), [(7, "Πελάτης Δοκιμής Η", 8, 21000)])

    def test_cart_ties(self):
        self.db.execute('INSERT INTO "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" VALUES (11, 6, \'2024-12-11\')')
        self.db.execute('INSERT INTO "ΠΕΡΙΕΧΕΙ" VALUES (11, 2, 1, 21000)')
        self.assertEqual([row[0] for row in self.query(5)], [7, 6])

    def test_historical_prices_survive_catalogue_changes(self):
        before = self.query(5)
        self.db.execute('UPDATE "ΒΙΒΛΙΟ" SET "ΤιμήΛεπτά" = 999999')
        self.assertEqual(self.query(5), before)

    def test_most_prolific_authors_include_ties(self):
        self.assertEqual(self.query(6), [(1, "Paulo Coelho", 3), (2, "Συγγραφέας Α", 3), (3, "Συγγραφέας Β", 3)])

    def test_distinct_customers_not_carts_or_copies(self):
        self.assertEqual(self.query(7), [(1, "Προγραμματισμός με SQL", 6)])
        self.db.execute('INSERT INTO "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" VALUES (11, 1, \'2024-12-11\')')
        self.db.execute('INSERT INTO "ΠΕΡΙΕΧΕΙ" VALUES (11, 2, 100, 4000)')
        self.assertEqual(self.query(7), [(1, "Προγραμματισμός με SQL", 6)])

    def test_exactly_five_customers_do_not_qualify(self):
        self.db.execute('DELETE FROM "ΠΕΡΙΕΧΕΙ" WHERE "CartID" = 6')
        self.db.execute('DELETE FROM "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" WHERE "ID" = 6')
        self.assertEqual(self.query(7), [])

    def test_sixth_customer_crosses_threshold(self):
        for cart_id, customer_id in [(11, 2), (12, 3), (13, 4), (14, 5), (15, 6)]:
            self.db.execute('INSERT INTO "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" VALUES (?, ?, \'2024-12-11\')', (cart_id, customer_id))
            self.db.execute('INSERT INTO "ΠΕΡΙΕΧΕΙ" VALUES (?, 2, 1, 4000)', (cart_id,))
        self.assertEqual([row[0] for row in self.query(7)], [1, 2])

    def test_entities_have_globally_unique_ids(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute('INSERT INTO "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" VALUES (1, 8, \'2024-12-11\')')
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute('INSERT INTO "ΒΙΒΛΙΟ" VALUES (1, 3, 3, \'Duplicate\', 2024, \'OTHER\', 1000, 1)')

    def test_isbn_unique(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute('UPDATE "ΒΙΒΛΙΟ" SET "ISBN" = \'DEMO-ISBN-001\' WHERE "ID" = 2')

    def test_invalid_foreign_keys_rejected(self):
        statements = [
            'UPDATE "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" SET "CustomerID" = 999 WHERE "ID" = 1',
            'UPDATE "ΒΙΒΛΙΟ" SET "WarehouseID" = 999 WHERE "ID" = 1',
            'UPDATE "ΒΙΒΛΙΟ" SET "PublisherID" = 999 WHERE "ID" = 1',
            'INSERT INTO "ΓΡΑΦΕΙ" VALUES (1, 999)',
            'INSERT INTO "ΓΡΑΦΕΙ" VALUES (999, 1)',
            'INSERT INTO "ΠΕΡΙΕΧΕΙ" VALUES (999, 1, 1, 1000)',
            'INSERT INTO "ΠΕΡΙΕΧΕΙ" VALUES (1, 999, 1, 1000)',
            'INSERT INTO "ΤΗΛΕΦΩΝΟ ΠΕΛΑΤΗ" VALUES (999, \'DEMO\')',
            'INSERT INTO "ΤΗΛΕΦΩΝΟ ΕΚΔΟΤΗ" VALUES (999, \'DEMO\')',
        ]
        for sql in statements:
            with self.subTest(sql=sql), self.assertRaises(sqlite3.IntegrityError):
                self.db.execute(sql)

    def test_referenced_rows_cannot_be_deleted(self):
        for table in ["ΠΕΛΑΤΗΣ", "ΕΚΔΟΤΙΚΟΣ ΟΙΚΟΣ", "ΑΠΟΘΗΚΗ", "ΒΙΒΛΙΟ", "ΣΥΓΓΡΑΦΕΑΣ", "ΚΑΛΑΘΙ ΑΓΟΡΩΝ"]:
            with self.subTest(table=table), self.assertRaises(sqlite3.IntegrityError):
                self.db.execute(f'DELETE FROM "{table}" WHERE "ID" = 1')

    def test_duplicate_associations_rejected(self):
        for sql in ['INSERT INTO "ΓΡΑΦΕΙ" VALUES (1, 2)', 'INSERT INTO "ΠΕΡΙΕΧΕΙ" VALUES (1, 1, 1, 3500)']:
            with self.subTest(sql=sql), self.assertRaises(sqlite3.IntegrityError):
                self.db.execute(sql)

    def test_multiple_phones_and_duplicates(self):
        self.assertEqual(self.db.execute('SELECT COUNT(*) FROM "ΤΗΛΕΦΩΝΟ ΠΕΛΑΤΗ" WHERE "CustomerID" = 1').fetchone()[0], 2)
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute('INSERT INTO "ΤΗΛΕΦΩΝΟ ΠΕΛΑΤΗ" VALUES (1, \'DEMO-PHONE-1\')')

    def test_negative_and_fractional_numbers_rejected(self):
        updates = [
            ('ΒΙΒΛΙΟ', 'ΤιμήΛεπτά', -1), ('ΒΙΒΛΙΟ', 'ΤιμήΛεπτά', 10.5),
            ('ΒΙΒΛΙΟ', 'ΤιμήΛεπτά', 'not-money'), ('ΒΙΒΛΙΟ', 'Ποσότητα', -1),
            ('ΒΙΒΛΙΟ', 'Ποσότητα', 1.5), ('ΒΙΒΛΙΟ', 'Έτος', 0),
            ('ΠΕΡΙΕΧΕΙ', 'Ποσότητα', 0), ('ΠΕΡΙΕΧΕΙ', 'Ποσότητα', -1),
            ('ΠΕΡΙΕΧΕΙ', 'Ποσότητα', 1.5), ('ΠΕΡΙΕΧΕΙ', 'ΤιμήΜονάδαςΛεπτά', -1),
            ('ΠΕΡΙΕΧΕΙ', 'ΤιμήΜονάδαςΛεπτά', 10.5),
        ]
        for table, column, value in updates:
            with self.subTest(table=table, column=column, value=value), self.assertRaises(sqlite3.IntegrityError):
                self.db.execute(f'UPDATE "{table}" SET "{column}" = ?', (value,))

    def test_calendar_validation(self):
        self.db.execute('UPDATE "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" SET "Ημερομηνία" = \'2024-02-30\' WHERE "ID" = 1')
        self.assertIn("Cart 1 has an invalid calendar date.", validate(self.db))
        self.db.execute('UPDATE "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" SET "Ημερομηνία" = \'2024-02-29\' WHERE "ID" = 1')
        self.assertEqual(validate(self.db), [])

    def test_date_format_rejected_by_schema(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute('UPDATE "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" SET "Ημερομηνία" = \'12/10/2024\' WHERE "ID" = 1')

    def test_required_authors_validation(self):
        self.db.execute('DELETE FROM "ΓΡΑΦΕΙ" WHERE "BookID" = 8')
        self.assertIn("Book 8 has no author.", validate(self.db))

    def test_required_cart_items_validation(self):
        self.db.execute('DELETE FROM "ΠΕΡΙΕΧΕΙ" WHERE "CartID" = 10')
        self.assertIn("Cart 10 has no items.", validate(self.db))

    def test_reinitialization_refused(self):
        with self.assertRaisesRegex(ValueError, "not empty"):
            load_demo(self.db)
        self.assertEqual(self.query(5)[0][-1], 21000)

    def test_new_connection_requires_foreign_keys(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "demo.db"
            with sqlite3.connect(path) as first:
                load_demo(first)
            with sqlite3.connect(path) as second:
                second.execute("PRAGMA foreign_keys = OFF")
                self.assertIn("Foreign-key enforcement must be enabled on this connection.", validate(second))
                second.execute("PRAGMA foreign_keys = ON")
                self.assertEqual(validate(second), [])

    def test_cli_preserves_existing_file(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "existing.db"
            content = b"existing user file"
            path.write_bytes(content)
            result = subprocess.run([sys.executable, str(ROOT / 'scripts/demo.py'), '--database', str(path)], capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_bytes(), content)

    def test_cli_creates_valid_database(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "demo.db"
            result = subprocess.run([sys.executable, str(ROOT / 'scripts/demo.py'), '--database', str(path)], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("07_books_with_six_customers", result.stdout)
            with sqlite3.connect(path) as connection:
                connection.execute("PRAGMA foreign_keys = ON")
                self.assertEqual(validate(connection), [])


if __name__ == "__main__":
    unittest.main()
