/*
==========================================================================
LOAN APPROVAL ANALYSIS - SQL PORTFOLIO PROJECT
Database: loan_analysis.db (SQLite)
Tables:
  applicants (Loan_ID, Gender, Married, Dependents, Education, Self_Employed,
              ApplicantIncome, CoapplicantIncome, Property_Area)
  loans      (Loan_ID, LoanAmount, Loan_Amount_Term, Credit_History, Loan_Status)

Each query below answers a specific business question, in increasing
order of complexity: basic filtering -> aggregation -> joins ->
subqueries -> window functions / CTEs.
==========================================================================
*/

-- 1. BASIC FILTER
-- Q: How many loan applications were approved vs rejected?
SELECT Loan_Status, COUNT(*) AS total_applications
FROM loans
GROUP BY Loan_Status;


-- 2. SORTING + FILTERING
-- Q: Which are the 10 largest loan amounts requested by approved applicants?
SELECT Loan_ID, LoanAmount
FROM loans
WHERE Loan_Status = 'Y'
ORDER BY LoanAmount DESC
LIMIT 10;


-- 3. JOIN
-- Q: What is the average applicant income for approved vs rejected loans,
--    broken down by education level?
SELECT
    a.Education,
    l.Loan_Status,
    ROUND(AVG(a.ApplicantIncome), 0) AS avg_income,
    COUNT(*) AS num_applicants
FROM applicants a
JOIN loans l ON a.Loan_ID = l.Loan_ID
GROUP BY a.Education, l.Loan_Status
ORDER BY a.Education, l.Loan_Status;


-- 4. JOIN + CASE (derived segmentation)
-- Q: How does approval rate differ by property area (Urban/Semiurban/Rural)?
SELECT
    a.Property_Area,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN l.Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(100.0 * SUM(CASE WHEN l.Loan_Status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS approval_rate_pct
FROM applicants a
JOIN loans l ON a.Loan_ID = l.Loan_ID
GROUP BY a.Property_Area
ORDER BY approval_rate_pct DESC;


-- 5. HAVING (filter on aggregated result)
-- Q: Which applicant segments (by marital status + dependents) have more
--    than 20 applications, and what's their approval rate?
SELECT
    a.Married,
    a.Dependents,
    COUNT(*) AS total_applications,
    ROUND(100.0 * SUM(CASE WHEN l.Loan_Status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS approval_rate_pct
FROM applicants a
JOIN loans l ON a.Loan_ID = l.Loan_ID
GROUP BY a.Married, a.Dependents
HAVING COUNT(*) > 20
ORDER BY approval_rate_pct DESC;


-- 6. SUBQUERY
-- Q: Which applicants requested a loan amount higher than the overall
--    average loan amount?
SELECT a.Loan_ID, a.ApplicantIncome, l.LoanAmount
FROM applicants a
JOIN loans l ON a.Loan_ID = l.Loan_ID
WHERE l.LoanAmount > (SELECT AVG(LoanAmount) FROM loans)
ORDER BY l.LoanAmount DESC;


-- 7. CREDIT HISTORY IMPACT (business-critical question)
-- Q: Does having a credit history record actually affect approval rate?
SELECT
    l.Credit_History,
    COUNT(*) AS total_applications,
    ROUND(100.0 * SUM(CASE WHEN l.Loan_Status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS approval_rate_pct
FROM loans l
GROUP BY l.Credit_History;


-- 8. CTE + WINDOW FUNCTION
-- Q: Rank property areas by average loan amount, and show each area's
--    rank alongside its approval rate.
WITH area_stats AS (
    SELECT
        a.Property_Area,
        ROUND(AVG(l.LoanAmount), 1) AS avg_loan_amount,
        ROUND(100.0 * SUM(CASE WHEN l.Loan_Status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS approval_rate_pct
    FROM applicants a
    JOIN loans l ON a.Loan_ID = l.Loan_ID
    GROUP BY a.Property_Area
)
SELECT
    Property_Area,
    avg_loan_amount,
    approval_rate_pct,
    RANK() OVER (ORDER BY avg_loan_amount DESC) AS loan_amount_rank
FROM area_stats;


-- 9. WINDOW FUNCTION (income percentile per group)
-- Q: For each education level, show every applicant's income alongside
--    that group's average income, to spot who's above/below their peers.
SELECT
    a.Loan_ID,
    a.Education,
    a.ApplicantIncome,
    ROUND(AVG(a.ApplicantIncome) OVER (PARTITION BY a.Education), 0) AS avg_income_in_group,
    a.ApplicantIncome - ROUND(AVG(a.ApplicantIncome) OVER (PARTITION BY a.Education), 0) AS diff_from_group_avg
FROM applicants a
ORDER BY a.Education, diff_from_group_avg DESC
LIMIT 20;


-- 10. DATA QUALITY CHECK (validation-style query - relevant to a
--     data-enablement/trainee role: finding missing/incomplete records)
-- Q: How many records have missing values in key fields?
SELECT
    SUM(CASE WHEN a.Gender IS NULL THEN 1 ELSE 0 END) AS missing_gender,
    SUM(CASE WHEN a.Self_Employed IS NULL THEN 1 ELSE 0 END) AS missing_self_employed,
    SUM(CASE WHEN l.LoanAmount IS NULL THEN 1 ELSE 0 END) AS missing_loan_amount,
    SUM(CASE WHEN l.Credit_History IS NULL THEN 1 ELSE 0 END) AS missing_credit_history
FROM applicants a
JOIN loans l ON a.Loan_ID = l.Loan_ID;


-- 11. DUPLICATE CHECK (data validation - another data-enablement-relevant query)
-- Q: Confirm there are no duplicate Loan_IDs in either table.
SELECT Loan_ID, COUNT(*) AS occurrences
FROM applicants
GROUP BY Loan_ID
HAVING COUNT(*) > 1;
