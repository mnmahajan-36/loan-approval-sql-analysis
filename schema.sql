CREATE TABLE applicants (
    Loan_ID TEXT PRIMARY KEY,
    Gender TEXT,
    Married TEXT,
    Dependents TEXT,
    Education TEXT,
    Self_Employed TEXT,
    ApplicantIncome INTEGER,
    CoapplicantIncome REAL,
    Property_Area TEXT
);

CREATE TABLE loans (
    Loan_ID TEXT PRIMARY KEY,
    LoanAmount REAL,
    Loan_Amount_Term REAL,
    Credit_History REAL,
    Loan_Status TEXT,
    FOREIGN KEY (Loan_ID) REFERENCES applicants(Loan_ID)
);
