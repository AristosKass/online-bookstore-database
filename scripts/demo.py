"""Run the seven coursework queries with disposable fictional data."""
import argparse
from datetime import date
from pathlib import Path
import sqlite3
import sys

ROOT = Path(__file__).resolve().parents[1]
DATABASE = ROOT / "database"


def validate(connection):
    """Check cross-row coursework rules after a complete import/transaction."""
    issues = []
    if connection.execute("PRAGMA foreign_keys").fetchone()[0] != 1:
        issues.append("Foreign-key enforcement must be enabled on this connection.")
    if connection.execute("PRAGMA integrity_check").fetchall() != [("ok",)]:
        issues.append("SQLite integrity check failed.")
    for row in connection.execute("PRAGMA foreign_key_check"):
        issues.append(f"Invalid foreign key: {row}")
    for (book_id,) in connection.execute(
        'SELECT b."ID" FROM "ΒΙΒΛΙΟ" b WHERE NOT EXISTS '
        '(SELECT 1 FROM "ΓΡΑΦΕΙ" ba WHERE ba."BookID" = b."ID")'
    ):
        issues.append(f"Book {book_id} has no author.")
    for (cart_id,) in connection.execute(
        'SELECT c."ID" FROM "ΚΑΛΑΘΙ ΑΓΟΡΩΝ" c WHERE NOT EXISTS '
        '(SELECT 1 FROM "ΠΕΡΙΕΧΕΙ" i WHERE i."CartID" = c."ID")'
    ):
        issues.append(f"Cart {cart_id} has no items.")
    for cart_id, text in connection.execute('SELECT "ID", "Ημερομηνία" FROM "ΚΑΛΑΘΙ ΑΓΟΡΩΝ"'):
        try:
            valid = date.fromisoformat(text).isoformat() == text
        except (TypeError, ValueError):
            valid = False
        if not valid:
            issues.append(f"Cart {cart_id} has an invalid calendar date.")
    return issues


def load_demo(connection):
    """Initialize only an empty database; roll back an unsuccessful import."""
    if connection.in_transaction:
        raise ValueError("Initialize outside an existing transaction.")
    connection.execute("PRAGMA foreign_keys = ON")
    if connection.execute(
        "SELECT 1 FROM sqlite_master WHERE name NOT LIKE 'sqlite_%' LIMIT 1"
    ).fetchone():
        raise ValueError("The database is not empty; demo initialization was refused.")
    sql = "BEGIN;\n" + (DATABASE / "schema.sql").read_text(encoding="utf-8")
    sql += "\n" + (DATABASE / "seed.sql").read_text(encoding="utf-8")
    try:
        connection.executescript(sql)
        issues = validate(connection)
        if issues:
            raise ValueError("\n".join(issues))
        connection.commit()
    except Exception:
        connection.rollback()
        raise


def run_queries(connection):
    for path in sorted((DATABASE / "queries").glob("*.sql")):
        cursor = connection.execute(path.read_text(encoding="utf-8"))
        print(f"\n{path.stem}")
        print(" | ".join(column[0] for column in cursor.description))
        for row in cursor:
            print(" | ".join("NULL" if value is None else str(value) for value in row))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", type=Path, help="Save a NEW demo SQLite file; default: in memory.")
    args = parser.parse_args()
    path = args.database
    if path is not None:
        path = path.resolve()
        path.parent.mkdir(parents=True, exist_ok=True)
        try:
            # Exclusive creation refuses an existing file, even an empty one.
            with path.open("xb"):
                pass
        except FileExistsError:
            parser.error(f"Refusing to overwrite an existing file: {path}")
    connection = None
    initialized = False
    try:
        connection = sqlite3.connect(str(path) if path else ":memory:")
        load_demo(connection)
        initialized = True
        print("Bookstore demo initialized. Monetary values are integer euro cents.")
        run_queries(connection)
        if path:
            print(f"\nSaved demo database: {path}")
    except (sqlite3.Error, ValueError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1
    finally:
        if connection is not None:
            connection.close()
        if path and not initialized:
            path.unlink(missing_ok=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
