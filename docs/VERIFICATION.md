# Verification

Checked with Python 3.12.14 and SQLite 3.53.1.

Commands from the repository root:

```sh
python3 scripts/demo.py
python3 -m unittest discover -s tests -v
```

The demo builds a fresh in-memory database, validates it and executes all seven queries. The 27 automated tests cover:

- Every coursework query and expected demo result.
- Ties for largest basket and most prolific author.
- Distinct buyers rather than numbers of baskets or copies, including the exact five/six-buyer boundary.
- Empty warehouses and historical prices after catalogue changes.
- Unique book/basket IDs, ISBNs, association rows and multiple phone numbers.
- All nine foreign-key relationships and blocked deletes of referenced parents.
- Negative, zero or fractional values where those values are invalid.
- Date format checks, actual calendar dates and leap-day validation.
- Detection of books without authors and baskets without items.
- Per-connection foreign-key activation, refused reinitialization and protection of existing database files.
- Creating a persistent demo file through the command-line script.

The public report copies were also checked for removal of student-number headers and identifying report metadata. All four PDF pages were rendered and inspected. Local Markdown/image links were checked before packaging.

## Limits

The original XML was checked for well-formedness and retained as an archival file. It was not opened in the original modelling application. The sanitized ODT was inspected as an OpenDocument ZIP/XML package; the PDF is the visually verified public report.

The executable revision was tested with Python's SQLite library. No MySQL compatibility is claimed. SQL-only imports do not automatically enforce the validator's cross-row rules. Inventory changes, checkout processing and user authentication are outside this database/query project.
