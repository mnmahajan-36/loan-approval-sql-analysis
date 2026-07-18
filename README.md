# Loan Approval Analysis — SQL Portfolio Project

A SQL project analyzing 614 loan applications to understand what drives loan
approval decisions. Built to practice data validation, joins, aggregation,
and window functions on a realistic finance dataset.

## Dataset

Source: [Loan-Approval-Prediction.csv](https://github.com/prasertcbs/basic-dataset) (public, 614 records)

Split into two normalized tables to practice joins:

- **applicants**: Loan_ID, Gender, Married, Dependents, Education, Self_Employed, ApplicantIncome, CoapplicantIncome, Property_Area
- **loans**: Loan_ID, LoanAmount, Loan_Amount_Term, Credit_History, Loan_Status

## Tools

SQLite3, SQL (joins, CTEs, window functions, subqueries, aggregation)

## Files

- `loan_analysis.db` — SQLite database with both tables loaded
- `schema.sql` — table definitions
- `queries.sql` — 11 business-question queries, in increasing order of complexity
- `README.md` — this file

## How to run

```bash
sqlite3 loan_analysis.db
.read queries.sql
```

Or open `loan_analysis.db` in any SQLite viewer (e.g. DB Browser for SQLite)
and run the queries in `queries.sql` individually.

## Key findings

- **Credit history is the single strongest predictor of approval.** Applicants
  with a credit history record had a ~74% approval rate, versus ~8% for those
  without one — a gap far larger than any other factor in the dataset.
- **Semiurban properties had the highest approval rate (~77%)**, compared to
  Urban (~66%) and Rural (~61%) — worth flagging as a pattern, though not
  necessarily causal.
- No duplicate Loan_IDs were found in either table (data validation query),
  and missing values were concentrated in `Gender`, `Self_Employed`, and a
  small number of `LoanAmount`/`Credit_History` fields.

## What this project demonstrates

- Writing SQL from a business question, not just syntax practice
- Table joins across normalized data
- Aggregation with `GROUP BY` / `HAVING`
- Window functions (`RANK() OVER`, `AVG() OVER (PARTITION BY ...)`)
- Data validation queries (duplicate checks, missing value checks) — directly
  relevant to data quality / data enablement work
