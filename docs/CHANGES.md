# Publication changes

The uploaded coursework materials contained a conceptual diagram, relationship explanations, a relational diagram, a modelling XML file and a generated SQL export. The export failed in SQLite at the first unquoted table name containing a space. The uploaded SQL contained DDL only; it did not include the seven requested queries.

## Original work retained

- `original/report.pdf` and `original/report.odt` retain the original diagrams and Greek explanations. Headers containing the student number and report metadata were removed from these public copies. The source uploads were not modified.
- `original/eshop.xml` preserves the original DBMODEL modelling file. Its settings declare MySQL as the original modelling target. It documents the historical model; it is not the current SQLite schema.
- Author attribution remains in the repository README.

## Executable revision

- Quoted all Greek SQL identifiers, including names with spaces and `e-mail`.
- Used one globally unique ID per main entity, matching the requirement for a unique book or basket code.
- Removed redundant parent IDs from the authorship and purchase associations and corrected `ShoppingCardID` to `CartID`.
- Enabled and tested foreign keys and added supporting indexes.
- Split multiple customer/publisher phones into their own tables and split customer/warehouse address components.
- Stored prices as integer euro cents, added purchased quantities and recorded the actual historical line price after discounts.
- Added constraints for duplicate identifiers, ISBNs, association rows, negative values and fractional quantities/prices.
- Added a validator for book authorship, nonempty purchase baskets and calendar dates. These rules are explicitly documented as post-transaction checks rather than SQL-only enforcement.
- Added the seven coursework queries, fictional fixtures, the Python demo, 27 automated tests and the current model diagram.

## Publication packaging

- Added `.gitignore`, English README, model notes, verification notes and a Greek upload guide.
- Kept the assignment brief, unedited private report and generated database files outside the public package.
- Added no credentials, personal customer records or license grant.

The revision is documented as an updated runnable version rather than an unchanged copy of the submitted coursework. Original report diagrams and XML remain labelled as archival materials.
